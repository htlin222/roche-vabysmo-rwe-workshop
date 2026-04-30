#!/usr/bin/env Rscript
#
# 生成模擬 Vabysmo (faricimab) vs aflibercept RWE 資料集
# 仿 TENAYA/LUCERNE 12-week head-to-head dosing phase
# 參考：Cheung et al. Ophthalmology 2025;132:519-526
#
# 輸出：
#   data/vabysmo_baseline.csv     1329 列，每病人一列
#   data/vabysmo_followup.csv     long format, patient × visit at week 4/8/12
#   data/vabysmo_my_hospital.csv  「假裝是你院內」n=180，同 schema
#
# 用法：
#   Rscript R/simulate_vabysmo.R

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
})

set.seed(20260516)

# -----------------------------------------------------------------------------
# 設計參數（per paper p.521）
# -----------------------------------------------------------------------------

# Trial-size
N_FARI  <- 665
N_AFLI  <- 664

# Stratification factor 比例
P_TENAYA    <- 0.50
P_US_CANADA <- 0.55
P_LLD_GE33  <- 0.30

# Demographics
AGE_MEAN <- 75; AGE_SD <- 9; AGE_MIN <- 50
P_FEMALE <- 0.55

# Baseline (per arm)
BCVA_BASE <- list(
  faricimab   = list(mean = 60.0, sd = 13.3),
  aflibercept = list(mean = 60.2, sd = 13.1)
)
CST_BASE <- list(
  faricimab   = list(mean = 356.8, sd = 122.1),
  aflibercept = list(mean = 357.5, sd = 119.4)
)
P_IRF_BASE <- c(faricimab = 0.433, aflibercept = 0.468)
P_SRF_BASE <- c(faricimab = 0.657, aflibercept = 0.673)

# Adjusted mean change from baseline (per paper Fig 1)
BCVA_CHANGE <- list(
  faricimab   = c("4" = 4.6, "8" = 5.8, "12" = 6.7),
  aflibercept = c("4" = 4.0, "8" = 5.2, "12" = 5.9)
)
CST_CHANGE <- list(
  faricimab   = c("4" = -128.8, "8" = -140.3, "12" = -145.4),
  aflibercept = c("4" = -115.0, "8" = -127.7, "12" = -133.0)
)

# 個體層級 noise
BCVA_RANDINT_SD <- 6     # subject-level random intercept on change
BCVA_RESID_SD   <- 4     # residual per visit
CST_RANDINT_SD  <- 30
CST_RESID_SD    <- 25

# Absence proportions per visit (CMH-weighted estimates per paper)
ABSENCE_IRF <- list(
  faricimab   = c("4" = 0.881, "8" = 0.880, "12" = 0.884),
  aflibercept = c("4" = 0.841, "8" = 0.845, "12" = 0.850)
)
ABSENCE_SRF <- list(
  faricimab   = c("4" = 0.693, "8" = 0.822, "12" = 0.879),
  aflibercept = c("4" = 0.602, "8" = 0.750, "12" = 0.790)
)

# Missingness（implicit MAR）
P_MISSING <- c("4" = 0.02, "8" = 0.04, "12" = 0.06)

VISITS <- c(4, 8, 12)

# -----------------------------------------------------------------------------
# 工具函數
# -----------------------------------------------------------------------------

rtnorm <- function(n, mean, sd, lower = -Inf, upper = Inf) {
  x <- rnorm(n, mean, sd)
  while (any(x < lower | x > upper)) {
    bad <- x < lower | x > upper
    x[bad] <- rnorm(sum(bad), mean, sd)
  }
  x
}

bcva_strat_of <- function(bcva) {
  cut(
    bcva,
    breaks = c(-Inf, 54.5, 73.5, Inf),
    labels = c("<=54", "55-73", ">=74"),
    right = TRUE
  ) |> as.character()
}

# -----------------------------------------------------------------------------
# 生 baseline
# -----------------------------------------------------------------------------

simulate_baseline <- function(n_fari, n_afli, id_prefix = "P", id_pad = 4,
                              region_levels = c("US-Canada", "Rest-of-world"),
                              region_p = c(P_US_CANADA, 1 - P_US_CANADA)) {
  n <- n_fari + n_afli
  arm <- c(rep("faricimab", n_fari), rep("aflibercept", n_afli))
  arm <- sample(arm)  # 打亂順序，避免 id 與 arm 同向

  baseline <- tibble(
    patient_id = sprintf(paste0(id_prefix, "%0", id_pad, "d"), seq_len(n)),
    arm        = arm,
    study      = sample(c("TENAYA", "LUCERNE"), n, replace = TRUE,
                        prob = c(P_TENAYA, 1 - P_TENAYA)),
    region     = sample(region_levels, n, replace = TRUE, prob = region_p),
    age        = round(rtnorm(n, AGE_MEAN, AGE_SD, lower = AGE_MIN)),
    sex        = sample(c("F", "M"), n, replace = TRUE,
                        prob = c(P_FEMALE, 1 - P_FEMALE)),
    lld_strat  = sample(c("<33", ">=33"), n, replace = TRUE,
                        prob = c(1 - P_LLD_GE33, P_LLD_GE33))
  )

  # arm-specific baseline values
  baseline$bcva_baseline <- ifelse(
    baseline$arm == "faricimab",
    rtnorm(n, BCVA_BASE$faricimab$mean,   BCVA_BASE$faricimab$sd,   lower = 0,   upper = 100),
    rtnorm(n, BCVA_BASE$aflibercept$mean, BCVA_BASE$aflibercept$sd, lower = 0,   upper = 100)
  ) |> round(0)

  baseline$cst_baseline <- ifelse(
    baseline$arm == "faricimab",
    rtnorm(n, CST_BASE$faricimab$mean,   CST_BASE$faricimab$sd,   lower = 150, upper = 800),
    rtnorm(n, CST_BASE$aflibercept$mean, CST_BASE$aflibercept$sd, lower = 150, upper = 800)
  ) |> round(0)

  baseline$irf_baseline <- ifelse(
    baseline$arm == "faricimab",
    rbinom(n, 1, P_IRF_BASE["faricimab"]),
    rbinom(n, 1, P_IRF_BASE["aflibercept"])
  )

  baseline$srf_baseline <- ifelse(
    baseline$arm == "faricimab",
    rbinom(n, 1, P_SRF_BASE["faricimab"]),
    rbinom(n, 1, P_SRF_BASE["aflibercept"])
  )

  baseline$bcva_strat <- bcva_strat_of(baseline$bcva_baseline)

  # 重新排欄位
  baseline |>
    select(patient_id, arm, study, region, age, sex,
           bcva_baseline, cst_baseline, irf_baseline, srf_baseline,
           bcva_strat, lld_strat)
}

# -----------------------------------------------------------------------------
# 生 follow-up
# -----------------------------------------------------------------------------

simulate_followup <- function(baseline, visits = VISITS,
                              missing_p = P_MISSING) {

  n <- nrow(baseline)
  fu_list <- list()

  # subject-level random intercept on change
  bcva_re <- rnorm(n, 0, BCVA_RANDINT_SD)
  cst_re  <- rnorm(n, 0, CST_RANDINT_SD)
  names(bcva_re) <- baseline$patient_id
  names(cst_re)  <- baseline$patient_id

  for (wk in visits) {
    wk_chr <- as.character(wk)

    # arm-specific group means
    bcva_grp_mean <- ifelse(
      baseline$arm == "faricimab",
      BCVA_CHANGE$faricimab[wk_chr],
      BCVA_CHANGE$aflibercept[wk_chr]
    )
    cst_grp_mean <- ifelse(
      baseline$arm == "faricimab",
      CST_CHANGE$faricimab[wk_chr],
      CST_CHANGE$aflibercept[wk_chr]
    )

    bcva <- baseline$bcva_baseline +
      bcva_grp_mean +
      bcva_re[baseline$patient_id] +
      rnorm(n, 0, BCVA_RESID_SD)
    cst <- baseline$cst_baseline +
      cst_grp_mean +
      cst_re[baseline$patient_id] +
      rnorm(n, 0, CST_RESID_SD)

    # round + clip
    bcva <- pmin(pmax(round(bcva, 0), 0), 100)
    cst  <- pmin(pmax(round(cst, 0), 0), 1000)

    # IRF / SRF：以 marginal absence prob 直接 Bernoulli
    p_irf_present <- ifelse(
      baseline$arm == "faricimab",
      1 - ABSENCE_IRF$faricimab[wk_chr],
      1 - ABSENCE_IRF$aflibercept[wk_chr]
    )
    p_srf_present <- ifelse(
      baseline$arm == "faricimab",
      1 - ABSENCE_SRF$faricimab[wk_chr],
      1 - ABSENCE_SRF$aflibercept[wk_chr]
    )
    irf <- rbinom(n, 1, p_irf_present)
    srf <- rbinom(n, 1, p_srf_present)

    visit_df <- tibble(
      patient_id = baseline$patient_id,
      week       = wk,
      bcva       = bcva,
      cst        = cst,
      irf        = irf,
      srf        = srf
    )

    # missingness：整列同時 NA
    miss <- rbinom(n, 1, missing_p[wk_chr]) == 1
    visit_df$bcva[miss] <- NA_real_
    visit_df$cst[miss]  <- NA_real_
    visit_df$irf[miss]  <- NA_integer_
    visit_df$srf[miss]  <- NA_integer_

    fu_list[[wk_chr]] <- visit_df
  }

  bind_rows(fu_list) |> arrange(patient_id, week)
}

# -----------------------------------------------------------------------------
# 主 pipeline
# -----------------------------------------------------------------------------

baseline <- simulate_baseline(N_FARI, N_AFLI, id_prefix = "P", id_pad = 4)
followup <- simulate_followup(baseline)

# my_hospital：n=180，AP region，real-world 比 trial 嚴重一點點
set.seed(20260517)  # 不同 seed 讓兩份資料完全獨立
mh_baseline <- simulate_baseline(
  n_fari = 100, n_afli = 80,
  id_prefix = "PT-", id_pad = 3,
  region_levels = "Asia-Pacific",
  region_p = 1
)
# real-world tweak：BCVA 偏低 ~5 letters、CST 偏高 ~25 μm
mh_baseline$bcva_baseline <- pmax(round(mh_baseline$bcva_baseline - 5), 0)
mh_baseline$cst_baseline  <- mh_baseline$cst_baseline + 25
mh_baseline$bcva_strat    <- bcva_strat_of(mh_baseline$bcva_baseline)
mh_followup <- simulate_followup(mh_baseline)

# -----------------------------------------------------------------------------
# 輸出
# -----------------------------------------------------------------------------

resolve_out_dir <- function() {
  candidates <- c(
    "data",
    file.path(getwd(), "data"),
    file.path(dirname(getwd()), "data")
  )
  hit <- candidates[dir.exists(candidates)]
  if (length(hit) > 0) return(normalizePath(hit[1]))
  d <- file.path(getwd(), "data")
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
  normalizePath(d)
}
out_dir <- resolve_out_dir()

write_csv(baseline,    file.path(out_dir, "vabysmo_baseline.csv"))
write_csv(followup,    file.path(out_dir, "vabysmo_followup.csv"))
write_csv(mh_baseline |>
            left_join(mh_followup, by = "patient_id") |>
            # 也順便輸出一份 long 給學員看；主要 csv 是 baseline + followup
            select(patient_id, arm, study, region, age, sex,
                   bcva_baseline, cst_baseline, irf_baseline, srf_baseline,
                   bcva_strat, lld_strat,
                   week, bcva, cst, irf, srf),
          file.path(out_dir, "vabysmo_my_hospital.csv"))

# 另外把 my_hospital 的 baseline 與 followup 也分檔（方便 part5 呼叫）
write_csv(mh_baseline, file.path(out_dir, "vabysmo_my_hospital_baseline.csv"))
write_csv(mh_followup, file.path(out_dir, "vabysmo_my_hospital_followup.csv"))

# -----------------------------------------------------------------------------
# Sanity check：印出 summary，與 paper 比對
# -----------------------------------------------------------------------------

cat("\n========== Baseline summary (主資料集 n=1329) ==========\n")
baseline |>
  group_by(arm) |>
  summarise(
    n             = n(),
    age_mean      = round(mean(age), 1),
    bcva_mean     = round(mean(bcva_baseline), 1),
    bcva_sd       = round(sd(bcva_baseline), 1),
    cst_mean      = round(mean(cst_baseline), 1),
    cst_sd        = round(sd(cst_baseline), 1),
    irf_pct       = round(mean(irf_baseline) * 100, 1),
    srf_pct       = round(mean(srf_baseline) * 100, 1)
  ) |> as.data.frame() |> print()

cat("\n========== Adjusted mean change from baseline at week 12 (vs paper) ==========\n")
adj <- followup |>
  left_join(baseline |> select(patient_id, arm, bcva_baseline, cst_baseline),
            by = "patient_id") |>
  filter(week == 12, !is.na(bcva), !is.na(cst)) |>
  mutate(bcva_chg = bcva - bcva_baseline, cst_chg = cst - cst_baseline) |>
  group_by(arm) |>
  summarise(
    bcva_chg_mean = round(mean(bcva_chg), 1),
    cst_chg_mean  = round(mean(cst_chg), 1)
  ) |> as.data.frame()
print(adj)
cat("(paper: faricimab BCVA +6.7 / CST -145.4 ; aflibercept BCVA +5.9 / CST -133.0)\n")

cat("\n========== Absence rates at week 12 (vs paper) ==========\n")
abs_w12 <- followup |>
  filter(week == 12, !is.na(irf), !is.na(srf)) |>
  left_join(baseline |> select(patient_id, arm), by = "patient_id") |>
  group_by(arm) |>
  summarise(
    abs_irf_pct      = round(mean(irf == 0) * 100, 1),
    abs_srf_pct      = round(mean(srf == 0) * 100, 1),
    abs_both_pct     = round(mean(irf == 0 & srf == 0) * 100, 1)
  ) |> as.data.frame()
print(abs_w12)
cat("(paper week 12: faricimab IRF 88.4 / SRF 87.9 / both 77.2 ; aflibercept IRF 85.0 / SRF 79.0 / both 66.5)\n")

cat("\n========== my_hospital 摘要 ==========\n")
mh_baseline |>
  group_by(arm) |>
  summarise(
    n         = n(),
    bcva_mean = round(mean(bcva_baseline), 1),
    cst_mean  = round(mean(cst_baseline), 1)
  ) |> as.data.frame() |> print()

cat("\n[OK] 三份 csv 寫到", normalizePath(out_dir), "\n")

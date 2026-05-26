#!/usr/bin/env Rscript
# scripts/05_psm_my_hospital.R
# Reproduces Part 5: 院內 cohort PSM + ASMD + matched MMRM/CMH，standalone。
#
# 從專案根目錄執行：
#   Rscript scripts/05_psm_my_hospital.R

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr)
  library(MatchIt); library(cobalt)
  library(mmrm); library(emmeans)
  library(ggplot2); library(patchwork)
})

arm_colours <- c("faricimab" = "#1F5C8B", "aflibercept" = "#C75D38")

# ---------------------------------------------------------------------------
# 1. 載入院內模擬資料
# ---------------------------------------------------------------------------
mh_baseline <- read_csv("data/faricimab_my_hospital_baseline.csv",
                        show_col_types = FALSE) |>
  mutate(
    treat = if_else(arm == "faricimab", 1L, 0L),
    sex   = factor(sex),
    bcva_strat = factor(bcva_strat),
    lld_strat  = factor(lld_strat)
  )
mh_followup <- read_csv("data/faricimab_my_hospital_followup.csv",
                        show_col_types = FALSE)

cat("\n載入：n =", nrow(mh_baseline),
    "（faricimab:", sum(mh_baseline$treat == 1),
    "aflibercept:", sum(mh_baseline$treat == 0), "）\n")

# ---------------------------------------------------------------------------
# 2. PSM 前 ASMD（baseline 不平衡診斷）
# ---------------------------------------------------------------------------
covariates <- c("age", "sex", "bcva_baseline", "cst_baseline",
                "irf_baseline", "srf_baseline", "bcva_strat", "lld_strat")

cat("\n=== PSM 前 ASMD ===\n")
print(bal.tab(
  reformulate(covariates, response = "treat"),
  data = mh_baseline, estimand = "ATT",
  thresholds = c(m = 0.1), un = TRUE
))

# ---------------------------------------------------------------------------
# 3. 1:1 nearest neighbor PSM (caliper 0.2)
# ---------------------------------------------------------------------------
set.seed(20260530)
m_out <- matchit(
  treat ~ age + sex + bcva_baseline + cst_baseline +
          irf_baseline + srf_baseline + bcva_strat + lld_strat,
  data = mh_baseline,
  method = "nearest", distance = "glm",
  ratio = 1, caliper = 0.2
)
cat("\n=== matchit summary ===\n"); print(summary(m_out))

mh_matched <- match.data(m_out) |> as_tibble()
cat("\n配對後 n =", nrow(mh_matched),
    "（faricimab:", sum(mh_matched$treat == 1),
    "aflibercept:", sum(mh_matched$treat == 0), "）\n")

mh_matched_followup <- mh_followup |>
  semi_join(mh_matched, by = "patient_id")

# ---------------------------------------------------------------------------
# 4. PSM 後 ASMD + Love plot
# ---------------------------------------------------------------------------
cat("\n=== PSM 後 ASMD ===\n")
print(bal.tab(m_out, thresholds = c(m = 0.1), un = TRUE))

dir.create("output", showWarnings = FALSE)
love_plot <- love.plot(
  m_out, binary = "std", threshold = 0.1, abs = TRUE,
  var.order = "unadjusted",
  colors = c("#C75D38", "#1F5C8B"),
  shapes = c("circle filled", "triangle filled"),
  sample.names = c("配對前 (Unadjusted)", "配對後 (Matched)"),
  title = "ASMD: Before vs After 1:1 PSM"
) + theme(legend.position = "bottom")

ggsave("output/love_plot_standalone.png", love_plot,
       width = 8, height = 5, dpi = 150)
cat("\n[OK] Love plot saved to output/love_plot_standalone.png\n")
print(love_plot)  # preview in RStudio Plot pane

# ---------------------------------------------------------------------------
# 5. Matched cohort 上的 Figure 1（MMRM）
# ---------------------------------------------------------------------------
mh_fu_long <- mh_matched_followup |>
  left_join(
    mh_matched |> select(patient_id, arm,
                         bcva_baseline, cst_baseline,
                         bcva_strat, lld_strat),
    by = "patient_id"
  ) |>
  mutate(
    bcva_change = bcva - bcva_baseline,
    cst_change  = cst - cst_baseline,
    visit       = factor(week, levels = c(4, 8, 12)),
    arm         = factor(arm, levels = c("aflibercept", "faricimab"))
  )

safe_mmrm <- function(formula_us, formula_cs, data) {
  tryCatch(mmrm(formula_us, data = data),
           error = function(e) mmrm(formula_cs, data = data))
}

m_bcva <- safe_mmrm(
  bcva_change ~ arm + visit + arm:visit + bcva_strat + lld_strat +
    us(visit | patient_id),
  bcva_change ~ arm + visit + arm:visit + bcva_strat + lld_strat +
    cs(visit | patient_id),
  mh_fu_long |> filter(!is.na(bcva_change))
)
m_cst <- safe_mmrm(
  cst_change ~ arm + visit + arm:visit + bcva_strat + lld_strat +
    us(visit | patient_id),
  cst_change ~ arm + visit + arm:visit + bcva_strat + lld_strat +
    cs(visit | patient_id),
  mh_fu_long |> filter(!is.na(cst_change))
)

baseline_zero <- function(df) bind_rows(
  data.frame(arm = c("aflibercept","faricimab"),
             week = 0, emmean = 0, lower.CL = 0, upper.CL = 0),
  df |> select(arm, week, emmean, lower.CL, upper.CL)
) |> arrange(arm, week)

emm_b <- as.data.frame(emmeans(m_bcva, ~ arm | visit)) |>
  mutate(week = as.numeric(as.character(visit)))
emm_c <- as.data.frame(emmeans(m_cst, ~ arm | visit)) |>
  mutate(week = as.numeric(as.character(visit)))

p_b <- ggplot(baseline_zero(emm_b),
       aes(x = week, y = emmean, colour = arm, group = arm)) +
  geom_line(linewidth = 1) + geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.4) +
  scale_colour_manual(values = arm_colours, name = NULL) +
  scale_x_continuous(breaks = c(0, 4, 8, 12)) +
  labs(title = "(A) BCVA — My Hospital (post-PSM)",
       x = "Time (Weeks)", y = "Adj. Mean Change (Letters)") +
  theme_minimal() + theme(legend.position = "bottom")

p_c <- ggplot(baseline_zero(emm_c),
       aes(x = week, y = emmean, colour = arm, group = arm)) +
  geom_line(linewidth = 1) + geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.4) +
  scale_colour_manual(values = arm_colours, name = NULL) +
  scale_x_continuous(breaks = c(0, 4, 8, 12)) +
  labs(title = "(B) CST — My Hospital (post-PSM)",
       x = "Time (Weeks)", y = "Adj. Mean Change (μm)") +
  theme_minimal() + theme(legend.position = "bottom")

fig1_mh <- p_b + p_c + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")
ggsave("output/figure1_my_hospital_standalone.png", fig1_mh,
       width = 11, height = 5, dpi = 150)
cat("\n[OK] Figure 1 (matched) saved to output/figure1_my_hospital_standalone.png\n")
print(fig1_mh)  # preview in RStudio Plot pane

# ---------------------------------------------------------------------------
# 6. Matched cohort 上的 Figure 2（CMH）
# ---------------------------------------------------------------------------
cmh_weighted_proportion <- function(data, outcome_col,
                                    arm_col = "arm",
                                    strata_cols = c("bcva_strat", "lld_strat")) {
  d <- data |>
    filter(!is.na(.data[[outcome_col]])) |>
    mutate(stratum = do.call(paste, c(across(all_of(strata_cols)), sep = "|")))

  per_stratum <- d |>
    group_by(stratum, !!sym(arm_col)) |>
    summarise(n = n(), x = sum(.data[[outcome_col]]), p = x / n,
              .groups = "drop")

  arms <- levels(factor(per_stratum[[arm_col]]))
  ws <- per_stratum |>
    select(stratum, !!sym(arm_col), n) |>
    pivot_wider(names_from = !!sym(arm_col), values_from = n,
                values_fill = 0) |>
    mutate(w = (.data[[arms[1]]] * .data[[arms[2]]]) /
                pmax(.data[[arms[1]]] + .data[[arms[2]]], 1)) |>
    filter(.data[[arms[1]]] > 0 & .data[[arms[2]]] > 0) |>
    select(stratum, w)

  per_stratum |>
    inner_join(ws, by = "stratum") |>
    group_by(!!sym(arm_col)) |>
    summarise(
      p_hat = sum(w * p) / sum(w),
      se    = sqrt(sum(w^2 * p * (1 - p) / pmax(n, 1))) / sum(w),
      .groups = "drop"
    ) |>
    mutate(lower = pmax(p_hat - 1.96 * se, 0),
           upper = pmin(p_hat + 1.96 * se, 1))
}

mh_fu_strata <- mh_matched_followup |>
  left_join(
    mh_matched |> select(patient_id, arm, bcva_strat, lld_strat,
                         irf_baseline, srf_baseline),
    by = "patient_id"
  ) |>
  mutate(
    abs_irf  = if_else(is.na(irf), NA, as.integer(irf == 0)),
    abs_srf  = if_else(is.na(srf), NA, as.integer(srf == 0)),
    abs_both = if_else(is.na(irf) | is.na(srf), NA,
                       as.integer(irf == 0 & srf == 0)),
    arm = factor(arm, levels = c("aflibercept", "faricimab"))
  )

bl_abs <- mh_matched |>
  mutate(week = 0L,
         abs_irf  = as.integer(irf_baseline == 0),
         abs_srf  = as.integer(srf_baseline == 0),
         abs_both = as.integer(irf_baseline == 0 & srf_baseline == 0),
         arm = factor(arm, levels = c("aflibercept", "faricimab"))) |>
  select(patient_id, arm, bcva_strat, lld_strat,
         week, abs_irf, abs_srf, abs_both)

mh_fu_strata <- bind_rows(
  bl_abs,
  mh_fu_strata |> select(patient_id, arm, bcva_strat, lld_strat,
                         week, abs_irf, abs_srf, abs_both)
)

mh_results <- expand.grid(
  outcome = c("abs_irf", "abs_srf", "abs_both"),
  wk = c(0, 4, 8, 12), stringsAsFactors = FALSE
) |>
  rowwise() |>
  mutate(res = list(cmh_weighted_proportion(
    mh_fu_strata |> filter(week == wk), outcome_col = outcome
  ))) |>
  ungroup() |> tidyr::unnest(res) |> rename(week = wk)

print(mh_results)

make_panel <- function(out_col, ttl) {
  ggplot(mh_results |> filter(outcome == out_col),
         aes(x = factor(week), y = p_hat * 100, fill = arm)) +
    geom_col(position = position_dodge(width = 0.8),
             width = 0.7, colour = "white") +
    geom_errorbar(aes(ymin = lower * 100, ymax = upper * 100),
                  position = position_dodge(width = 0.8), width = 0.25) +
    scale_fill_manual(values = arm_colours, name = NULL) +
    scale_y_continuous(limits = c(0, 100),
                       expand = expansion(mult = c(0, 0.08))) +
    labs(title = ttl, x = "Visit (Week)", y = "Proportion (%)") +
    theme_minimal() + theme(legend.position = "bottom")
}

plt2 <- (make_panel("abs_both","(A) IRF and SRF") |
           make_panel("abs_irf", "(B) IRF") |
           make_panel("abs_srf", "(C) SRF")) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave("output/figure2_my_hospital_standalone.png", plt2,
       width = 12, height = 5, dpi = 150)
cat("\n[OK] Figure 2 (matched) saved to output/figure2_my_hospital_standalone.png\n")
print(plt2)  # preview in RStudio Plot pane

cat("\n========== 全部完成 ==========\n")
cat("輸出檔案：\n")
cat("  output/love_plot_standalone.png            — PSM 前後 ASMD 對比\n")
cat("  output/figure1_my_hospital_standalone.png  — matched cohort 上的 BCVA + CST MMRM\n")
cat("  output/figure2_my_hospital_standalone.png  — matched cohort 上的 CMH 三 panel\n")

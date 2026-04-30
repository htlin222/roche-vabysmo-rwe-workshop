#!/usr/bin/env Rscript
# scripts/03_cmh_figure2.R
# Reproduces Figure 2 (CMH-weighted absence proportions) from part4.qmd, standalone.

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr)
  library(ggplot2); library(patchwork)
})

baseline <- read_csv("data/vabysmo_baseline.csv", show_col_types = FALSE)
followup <- read_csv("data/vabysmo_followup.csv", show_col_types = FALSE)

arm_colours <- c("faricimab" = "#7B5CA8", "aflibercept" = "#7E9CB7")

fu <- followup |>
  left_join(
    baseline |> select(patient_id, arm, study, bcva_strat, lld_strat,
                       region, irf_baseline, srf_baseline),
    by = "patient_id"
  ) |>
  mutate(
    abs_irf  = if_else(is.na(irf), NA, as.integer(irf == 0)),
    abs_srf  = if_else(is.na(srf), NA, as.integer(srf == 0)),
    abs_both = if_else(is.na(irf) | is.na(srf), NA,
                       as.integer(irf == 0 & srf == 0)),
    arm = factor(arm, levels = c("aflibercept","faricimab"))
  )

bl_abs <- baseline |>
  mutate(
    week = 0L,
    abs_irf  = as.integer(irf_baseline == 0),
    abs_srf  = as.integer(srf_baseline == 0),
    abs_both = as.integer(irf_baseline == 0 & srf_baseline == 0),
    arm = factor(arm, levels = c("aflibercept","faricimab"))
  ) |>
  select(patient_id, arm, study, bcva_strat, lld_strat, region,
         week, abs_irf, abs_srf, abs_both)

fu <- bind_rows(
  bl_abs,
  fu |> select(patient_id, arm, study, bcva_strat, lld_strat, region,
               week, abs_irf, abs_srf, abs_both)
)

cmh_weighted_proportion <- function(data, outcome_col,
                                    arm_col = "arm",
                                    strata_cols = c("study","bcva_strat",
                                                    "lld_strat","region")) {
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

results <- expand.grid(
  outcome = c("abs_irf","abs_srf","abs_both"),
  wk      = c(0, 4, 8, 12), stringsAsFactors = FALSE
) |>
  rowwise() |>
  mutate(res = list(cmh_weighted_proportion(
    fu |> filter(week == wk), outcome_col = outcome
  ))) |>
  ungroup() |>
  unnest(res) |>
  rename(week = wk)

print(results)

make_panel <- function(out_col, ttl) {
  ggplot(results |> filter(outcome == out_col),
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

dir.create("_book", showWarnings = FALSE)
plt <- (make_panel("abs_both","(A) IRF and SRF") |
          make_panel("abs_irf","(B) IRF") |
          make_panel("abs_srf","(C) SRF")) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave("_book/figure2_standalone.png", plt, width = 12, height = 5, dpi = 150)
cat("\n[OK] Figure 2 saved to _book/figure2_standalone.png\n")

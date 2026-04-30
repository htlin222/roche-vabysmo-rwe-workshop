#!/usr/bin/env Rscript
# scripts/01_table1.R
# Reproduces Table 1 (baseline characteristics) from part2.qmd, standalone.
#
# Run from project root:
#   Rscript scripts/01_table1.R

suppressPackageStartupMessages({
  library(readr); library(dplyr)
  library(gtsummary); library(gt)
})

baseline <- read_csv("data/vabysmo_baseline.csv", show_col_types = FALSE)

t1 <- baseline |>
  select(arm, age, sex, region, bcva_baseline, cst_baseline,
         irf_baseline, srf_baseline, study, bcva_strat, lld_strat) |>
  tbl_summary(
    by = arm,
    statistic = list(all_continuous() ~ "{mean} ({sd})",
                     all_categorical() ~ "{n} ({p}%)"),
    digits = list(all_continuous() ~ 1),
    label = list(
      age ~ "Age, years",
      sex ~ "Sex",
      region ~ "Region",
      bcva_baseline ~ "BCVA at baseline, ETDRS letters",
      cst_baseline ~ "CST at baseline, μm",
      irf_baseline ~ "IRF present at baseline",
      srf_baseline ~ "SRF present at baseline",
      study ~ "Study",
      bcva_strat ~ "BCVA stratum",
      lld_strat ~ "LLD stratum"
    )
  ) |>
  add_overall() |>
  add_p() |>
  modify_caption("**Table 1.** Baseline characteristics by treatment arm")

print(t1)

# 存成 HTML
out <- "_book/table1_standalone.html"
dir.create(dirname(out), showWarnings = FALSE, recursive = TRUE)
t1 |> as_gt() |> gt::gtsave(filename = out)
cat("\n[OK] saved:", out, "\n")

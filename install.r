# 一鍵安裝所有套件 — Posit.Cloud / 本機通用
#
# 用法：
#   source("install.r")     # 在 RStudio Console
#   或 Rscript install.r    # 在 terminal

options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

required_pkgs <- c(
  # data
  "tidyverse", "readr",
  # tables
  "gtsummary", "gt", "knitr",
  # MMRM
  "mmrm", "emmeans", "broom", "broom.mixed",
  # CMH / proportions
  "DescTools",
  # survival
  "survival", "survminer",
  # plotting
  "ggplot2", "patchwork", "ggsci", "scales",
  # i18n / fonts
  "showtext", "sysfonts",
  # rendering
  "rmarkdown", "quarto"
)

pak::pak(required_pkgs, ask = FALSE)

cat("\n[OK] 套件安裝完成。\n")
cat("下一步：開啟 part1.qmd → 按右上 Render 按鈕，或在 Console 跑 quarto::quarto_render()。\n")

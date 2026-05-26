# 一鍵安裝所有套件 — Posit.Cloud / 本機通用
#
# 用法：
#   source("setup/install.r")     # 在 RStudio Console
#   或 Rscript setup/install.r    # 在 terminal

# 自動選 repo：
#   Linux（含 Posit.Cloud）→ PPM binary repo，免從原始碼編譯（省時間、無 C++ 警告）
#   macOS / Windows        → CRAN-style latest 本身已是 binary
ppm_repo <- local({
  if (Sys.info()[["sysname"]] == "Linux" && file.exists("/etc/os-release")) {
    os <- readLines("/etc/os-release", warn = FALSE)
    line <- grep("^VERSION_CODENAME=", os, value = TRUE)
    codename <- if (length(line)) gsub('^VERSION_CODENAME=|"', "", line[1]) else ""
    if (is.na(codename) || codename == "") codename <- "jammy"  # Posit.Cloud fallback
    sprintf("https://packagemanager.posit.co/cran/__linux__/%s/latest", codename)
  } else {
    "https://packagemanager.posit.co/cran/latest"
  }
})
options(repos = c(CRAN = ppm_repo))

# 讓 PPM 依 R 版本回傳正確的 Linux binary（pak 多半會自動帶，這裡保險起見明示）
options(HTTPUserAgent = sprintf(
  "R/%s R (%s)", getRversion(),
  paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])
))

cat(sprintf("[repo] %s\n", ppm_repo))

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
  # PSM / ASMD（Part 5 院內 RWE）
  "MatchIt", "cobalt",
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
cat("下一步：開啟 chapters/part1.qmd → 按右上 Render 按鈕，或在 Console 跑 quarto::quarto_render()。\n")

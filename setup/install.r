# 一鍵安裝所有套件 — Posit.Cloud / 本機通用
#
# 用法：
#   source("setup/install.r")     # 在 RStudio Console
#   或 Rscript setup/install.r    # 在 terminal

# repo + UA 設定（與 .Rprofile 共用同一份，確保所有安裝走 binary）
if (file.exists("setup/_repos.R")) {
  source("setup/_repos.R")
} else {
  # 萬一不在專案根目錄被呼叫的保險
  options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/noble/latest"))
}

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

# 版本鎖定（reproducible）：
#   有 setup/pak.lock → 照鎖定版本裝（每位學員 / 助教拿到完全相同的版本）
#   沒有              → 裝最新版，裝完自動產生 lockfile
# 注意：lockfile 請在「Posit.Cloud（Noble）」上產生並 commit，才會鎖到 Linux binary 的解析結果。
lock <- "setup/pak.lock"
if (file.exists(lock)) {
  cat(sprintf("[lock] 偵測到 %s → 依鎖定版本安裝\n", lock))
  pak::lockfile_install(lock)
} else {
  cat("[lock] 無 lockfile → 安裝最新版，完成後產生 setup/pak.lock\n")
  pak::pak(required_pkgs, ask = FALSE)
  pak::lockfile_create(required_pkgs, lockfile = lock, dependencies = TRUE)
  cat(sprintf("[lock] 已建立 %s — 請 commit 進 repo，之後所有人就裝同一版本。\n", lock))
}

cat("\n[OK] 套件安裝完成。\n")
cat("下一步：開啟 chapters/part1.qmd → 按右上 Render 按鈕，或在 Console 跑 quarto::quarto_render()。\n")

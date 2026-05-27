#!/usr/bin/env Rscript
# START.R — 一鍵開始（給第一次使用的人）
#
# 你只要做這一步！三種用法擇一即可：
#   ① RStudio：打開這個檔案 → 按右上角的「Source」按鈕
#   ② Console：輸入  source("START.R")
#   ③ 終端機：輸入  Rscript START.R
#
# 它只做一件事：把這個 workshop 需要的所有 R 套件裝好。
# （這裡就是安裝邏輯的「唯一來源」；setup/install.r 只是轉呼叫本檔的相容入口。）

# --- 確認在「專案根目錄」執行 ---------------------------------------------
# 安裝會用相對路徑找 setup/_repos.R，所以工作目錄一定要是專案根目錄。
if (!file.exists("setup/_repos.R")) {
  stop(paste0(
    "\n找不到 setup/_repos.R —— 你可能不在專案根目錄。\n",
    "目前的工作目錄是：", getwd(), "\n\n",
    "解法（RStudio）：選單 Session → Set Working Directory → To Source File Location，\n",
    "然後重新 Source 這個 START.R 即可。\n"
  ), call. = FALSE)
}

cat("=========================================\n")
cat("  Vabysmo RWE Workshop — 環境安裝\n")
cat("=========================================\n")
cat("正在安裝所有需要的套件，第一次可能要幾分鐘，請耐心等候…\n\n")

# --- repo + UA 設定（與 .Rprofile 共用同一份，確保所有安裝走 binary）---------
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
  cat("[lock] 無 lockfile → 安裝最新版，完成後嘗試產生 setup/pak.lock\n")
  pak::pak(required_pkgs, ask = FALSE)
  # 只鎖硬相依（Depends/Imports/LinkingTo）；不碰 Suggests，
  # 否則會去解 glmmADMB / RDCOMClient / gurobi 這些非 CRAN、裝不了的選用套件而失敗。
  # 包 tryCatch：lockfile 是 bonus，就算失敗也不該讓「套件已裝好」變成紅字。
  ok <- tryCatch({
    pak::lockfile_create(required_pkgs, lockfile = lock,
                         dependencies = c("Depends", "Imports", "LinkingTo"))
    TRUE
  }, error = function(e) {
    message("[lock] 略過 lockfile（不影響套件安裝）：", conditionMessage(e))
    FALSE
  })
  if (ok) cat(sprintf("[lock] 已建立 %s — 請 commit 進 repo，之後所有人就裝同一版本。\n", lock))
}

cat("\n[OK] 套件安裝完成。\n")
cat("下一步：開啟 chapters/part1.qmd → 按右上 Render 按鈕，或在 Console 跑 quarto::quarto_render()。\n")

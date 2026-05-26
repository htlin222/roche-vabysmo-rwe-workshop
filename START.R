#!/usr/bin/env Rscript
# START.R — 一鍵開始（給第一次使用的人）
#
# 你只要做這一步！三種用法擇一即可：
#   ① RStudio：打開這個檔案 → 按右上角的「Source」按鈕
#   ② Console：輸入  source("START.R")
#   ③ 終端機：輸入  Rscript START.R
#
# 它只做一件事：把這個 workshop 需要的所有 R 套件裝好（呼叫 setup/install.r）。

# --- 確認在「專案根目錄」執行 ---------------------------------------------
# install.r 會用相對路徑找 setup/_repos.R，所以工作目錄一定要是專案根目錄。
if (!file.exists("setup/install.r")) {
  stop(paste0(
    "\n找不到 setup/install.r —— 你可能不在專案根目錄。\n",
    "目前的工作目錄是：", getwd(), "\n\n",
    "解法（RStudio）：選單 Session → Set Working Directory → To Source File Location，\n",
    "然後重新 Source 這個 START.R 即可。\n"
  ), call. = FALSE)
}

cat("=========================================\n")
cat("  Vabysmo RWE Workshop — 環境安裝\n")
cat("=========================================\n")
cat("正在安裝所有需要的套件，第一次可能要幾分鐘，請耐心等候…\n\n")

source("setup/install.r")

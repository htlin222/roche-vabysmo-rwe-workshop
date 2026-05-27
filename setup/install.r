# setup/install.r — 安裝邏輯已整併到專案根目錄的 START.R。
#
# 本檔保留為「相容入口」：不論你用
#   source("setup/install.r")   # RStudio Console
#   Rscript setup/install.r     # 終端機
# 都會轉呼叫 START.R（安裝邏輯的唯一來源）。
#
# 建議直接用：source("START.R")

if (file.exists("START.R")) {
  source("START.R")
} else if (file.exists("../START.R")) {
  # 萬一從 setup/ 目錄裡被呼叫
  source("../START.R")
} else {
  stop(paste0(
    "找不到 START.R。請從『專案根目錄』執行：\n",
    '  source("START.R")    # RStudio Console\n',
    "  Rscript START.R       # 終端機\n",
    "目前的工作目錄是：", getwd(), "\n"
  ), call. = FALSE)
}

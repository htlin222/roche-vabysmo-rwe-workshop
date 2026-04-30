#!/usr/bin/env Rscript
# scripts/05_render_report_for_my_data.R
# 把整本 Quarto book 用「你的院內 csv」重 render 一次。
#
# 用法：
#   1. 把你的院內 csv 改名成下面這四個檔案，放進 data/：
#        - vabysmo_baseline.csv
#        - vabysmo_followup.csv
#        - vabysmo_my_hospital_baseline.csv
#        - vabysmo_my_hospital_followup.csv
#      （或是改 _quarto.yml 與各 qmd 中的檔名）
#   2. 跑 Rscript scripts/05_render_report_for_my_data.R

suppressPackageStartupMessages({
  library(quarto)
})

cat("\n→ 開始 render 整本書到 _book/...\n")
quarto::quarto_render(as_job = FALSE)

idx <- file.path("_book", "index.html")
if (file.exists(idx)) {
  cat("\n[OK] _book/ 渲染完成。\n")
  cat("    主頁：", normalizePath(idx), "\n")
  cat("    用瀏覽器打開上面那個 HTML 即可。\n")
} else {
  stop("[FAIL] _book/index.html 沒生出來，看看上面 quarto 的錯誤訊息。")
}

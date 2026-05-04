#!/usr/bin/env Rscript
#
# validate_env.R — 工作坊環境健檢
#
# 用法（任一）：
#   Rscript validate_env.R                    # terminal
#   source("validate_env.R")                  # RStudio Console
#
# 設計：完全 self-contained，不需要任何套件就能跑（base R 即可）。
# 檢查點：
#   1. R / Quarto 版本
#   2. 14 個必要套件都裝好且可 load
#   3. 5 個 faricimab_*.csv 都在 data/
#   4. _freeze/ 預烤 cache 存在
#   5. _book/ 已 render（index.html 存在）
#   6. 模擬資料 schema 與本書範例一致

suppressWarnings(suppressMessages({
  cat("\n========================================\n")
  cat(" 羅氏眼科研究賦能工作坊 — 環境健檢\n")
  cat(" 對齊版本：教材 v0.2.x\n")
  cat("========================================\n\n")
}))

# ----------------------------------------------------------------------------
# 工具函數
# ----------------------------------------------------------------------------

PASS <- 0L
FAIL <- 0L
WARN <- 0L

ok   <- function(msg) { cat("  ✅ ", msg, "\n", sep = ""); PASS <<- PASS + 1L }
bad  <- function(msg) { cat("  ❌ ", msg, "\n", sep = ""); FAIL <<- FAIL + 1L }
warn <- function(msg) { cat("  ⚠️  ", msg, "\n", sep = ""); WARN <<- WARN + 1L }
hd   <- function(msg) { cat("\n", strrep("─", 4), " ", msg, " ",
                           strrep("─", 50 - nchar(msg) - 6), "\n", sep = "") }

# ----------------------------------------------------------------------------
# 1. R / Quarto 版本
# ----------------------------------------------------------------------------

hd("1. 系統版本")

r_ver <- getRversion()
if (r_ver >= "4.2.0") {
  ok(sprintf("R %s （>= 4.2 OK）", r_ver))
} else {
  warn(sprintf("R %s （建議升級到 >= 4.2）", r_ver))
}

quarto_path <- Sys.which("quarto")
if (nzchar(quarto_path)) {
  q_ver <- tryCatch(
    system2(quarto_path, "--version", stdout = TRUE, stderr = TRUE),
    error = function(e) "unknown"
  )
  ok(sprintf("Quarto %s @ %s", q_ver[1], quarto_path))
} else {
  warn("Quarto 找不到（純跑 scripts/*.R 不需要，render book 才需要）")
}

# ----------------------------------------------------------------------------
# 2. 必要套件
# ----------------------------------------------------------------------------

required <- c(
  # data
  "tidyverse", "readr", "dplyr", "tidyr",
  # tables
  "gtsummary", "gt", "knitr",
  # MMRM
  "mmrm", "emmeans", "broom", "broom.mixed",
  # PSM / ASMD（v0.2 新增）
  "MatchIt", "cobalt",
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

hd(sprintf("2. 必要套件（%d 個）", length(required)))

installed <- rownames(installed.packages())
missing   <- setdiff(required, installed)

if (length(missing) == 0L) {
  ok(sprintf("全部 %d 個套件都已裝", length(required)))
} else {
  bad(sprintf("缺 %d 個套件：%s",
              length(missing), paste(missing, collapse = ", ")))
  cat("\n  \U0001F4A1 解法：在 Console 跑 source(\"install.r\")\n")
}

# 重點套件 load 測試（容易因為 system dep 漏裝而 install 成功但 load 失敗）
critical <- c("mmrm", "MatchIt", "cobalt", "survminer", "gtsummary")
for (pkg in critical) {
  if (!pkg %in% installed) next
  loaded <- suppressWarnings(suppressMessages(
    requireNamespace(pkg, quietly = TRUE)
  ))
  if (loaded) {
    ok(sprintf("library(%s) — load OK", pkg))
  } else {
    bad(sprintf("library(%s) — install 了但 load 失敗（system dep？）", pkg))
  }
}

# ----------------------------------------------------------------------------
# 3. 資料檔
# ----------------------------------------------------------------------------

hd("3. 資料檔（data/faricimab_*.csv）")

expected_csvs <- c(
  "data/faricimab_baseline.csv",
  "data/faricimab_followup.csv",
  "data/faricimab_my_hospital.csv",
  "data/faricimab_my_hospital_baseline.csv",
  "data/faricimab_my_hospital_followup.csv"
)

for (f in expected_csvs) {
  if (file.exists(f)) {
    n <- length(readLines(f, warn = FALSE)) - 1L
    ok(sprintf("%s（%d 列）", f, n))
  } else {
    bad(sprintf("找不到 %s", f))
  }
}

# 偵測舊檔名殘留
legacy <- list.files("data", pattern = "^vabysmo_", full.names = TRUE)
if (length(legacy) > 0L) {
  warn(sprintf("發現 %d 個舊檔名 vabysmo_*.csv（v0.1 殘留）：%s",
               length(legacy), paste(basename(legacy), collapse = ", ")))
  cat("  \U0001F4A1 解法：rm 舊檔或 git pull 取得最新版\n")
}

# Schema sanity check（baseline csv 應有的欄位）
baseline_path <- "data/faricimab_baseline.csv"
if (file.exists(baseline_path)) {
  hdr <- strsplit(readLines(baseline_path, n = 1), ",")[[1]]
  required_cols <- c("patient_id", "arm", "study", "region", "age", "sex",
                     "bcva_baseline", "cst_baseline",
                     "irf_baseline", "srf_baseline",
                     "bcva_strat", "lld_strat")
  missing_cols <- setdiff(required_cols, hdr)
  if (length(missing_cols) == 0L) {
    ok(sprintf("baseline schema 對齊（%d 個必要欄位齊）", length(required_cols)))
  } else {
    bad(sprintf("baseline 缺欄位：%s", paste(missing_cols, collapse = ", ")))
  }
}

# ----------------------------------------------------------------------------
# 4. Quarto 預烤 cache
# ----------------------------------------------------------------------------

hd("4. Quarto 預烤狀態")

if (dir.exists("_freeze")) {
  n_frozen <- length(list.files("_freeze", recursive = TRUE))
  ok(sprintf("_freeze/ cache 存在（%d 個檔）", n_frozen))
} else {
  warn("_freeze/ 不存在 — 學員第一次 render 會慢 1–2 分鐘")
  cat("  \U0001F4A1 解法：Console 跑 quarto::quarto_render() 一次\n")
}

if (file.exists("_book/index.html")) {
  ok("_book/index.html 存在 — 已 render 過")
} else {
  warn("_book/index.html 不存在 — 還沒 render")
}

# ----------------------------------------------------------------------------
# 5. Standalone scripts（給不寫 code 的學員）
# ----------------------------------------------------------------------------

hd("5. Standalone scripts")

expected_scripts <- c(
  "scripts/01_table1.R",
  "scripts/02_mmrm_figure1.R",
  "scripts/03_cmh_figure2.R",
  "scripts/04_km_figure3.R",
  "scripts/05_render_report_for_my_data.R",
  "scripts/06_psm_my_hospital.R"
)

n_present <- sum(file.exists(expected_scripts))
if (n_present == length(expected_scripts)) {
  ok(sprintf("6 支 standalone scripts 齊全"))
} else {
  bad(sprintf("standalone scripts 只有 %d/%d 支", n_present, length(expected_scripts)))
}

# ----------------------------------------------------------------------------
# 結論
# ----------------------------------------------------------------------------

cat("\n========================================\n")
cat(sprintf(" 結果：✅ PASS=%d  ⚠️  WARN=%d  ❌ FAIL=%d\n",
            PASS, WARN, FAIL))

if (FAIL == 0L && WARN == 0L) {
  cat(" \U0001F389 環境完美，可以直接開課！\n")
} else if (FAIL == 0L) {
  cat(" \U0001F44C 可以用，但有幾個 warning（看上面）。\n")
} else {
  cat(" \U0001F525 有問題請先處理 FAIL 項目（看上面 \U0001F4A1 提示）。\n")
}
cat("========================================\n\n")

# 給 teacher 用的小提示
if (interactive() || identical(commandArgs(trailingOnly = TRUE), character(0))) {
  cat("· 老師：跑 source(\"install.r\") + quarto::quarto_render() + Posit.Cloud Access 設 public\n")
  cat("· 學員：點老師連結 → Save a Permanent Copy → 開 part1.qmd\n")
  cat("· 不寫 code 的學員：Rscript scripts/0[1-6]_*.R 一行跑完\n\n")
}

# Exit code（CI 友善）：FAIL > 0 退出 1
if (!interactive() && FAIL > 0L) {
  quit(status = 1L)
}

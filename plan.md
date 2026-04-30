# Vabysmo 眼科 RWE 工作坊：Build Plan（睡前版）

## Context

Roche / Shao Shih-Chieh 邀請的眼科醫師研究工作坊（原訂 5/16，現改 5/30），主題「如何讓你的 Vabysmo RWE 長得像 Ophthalmology 論文」。

- **學員**：眼科醫師為主，技術底子 D 偏 A — Excel-only 多、能打開 Jupyter/RStudio 的少。
- **真正的 deliverable**（潛台詞翻譯）：不是「會 reproduce TENAYA/LUCERNE paper」，是「下課後想動手做自己的 Vabysmo cohort、知道院內 csv 該長什麼樣、拿到後跑這份 Quarto 就出 paper」。
- **目標 paper**：Cheung et al., Ophthalmology 2025;132:519-526（CC BY，refs/tenaya-lucerne-paper.pdf）— 12-week head-to-head dosing phase post-hoc analysis。
- **Shao 指定教的兩個 method**：MMRM（連續端點 + repeated measures + unstructured covariance + MAR implicit imputation）、CMH-weighted proportion（stratified by study × randomization factors）。

## Deliverable（user 醒來時要看到的東西）

1. `/Users/htlin/Mail/projects/roche-vabysmo-rwe-workshop/` 一個完整可上課的 Quarto book project：
   - 6 章 + 前言 + 附錄的 `*.qmd`
   - 5 支可獨立執行的 `scripts/*.R`
   - 3 份模擬 csv（`vabysmo_baseline.csv` + `vabysmo_followup.csv` + `vabysmo_my_hospital.csv`）
   - 1 支可重現的模擬腳本 `R/simulate_vabysmo.R`（fixed seed）
   - `_book/` 渲染好的 HTML（可直接 open in browser，每章每張圖都跑出來）
   - `README.md`（GitHub 入口，含 Posit.Cloud 一鍵 workflow）
   - `plan.md`（這份 plan 的 copy，放在 project root 給未來自己參考）
2. Git commit 完成（在 parent `htlin222/Mail` repo 上）。
3. （Best effort）Public mirror repo `htlin222/roche-vabysmo-rwe-workshop` 推上去 — 為 Posit.Cloud 的「new project from git URL」flow。如果 `gh repo create` 因任何原因卡住，**不阻塞** main deliverable，留 TODO 即可。

## Constraints / Decisions（已和 user 確認）

| 軸 | 選擇 | 理由 |
|---|---|---|
| 學員程度 | D 偏 A（Excel-many） | 整本書 happy path = 「複製 prompt → 貼給 AI → 拿 code → 貼 Posit.Cloud 跑」，不要求學員自己寫 R |
| 工具 | Posit.Cloud + R + Quarto book | Roche RWE 圈的 native stack，比 Colab 對眼科醫師友善（一鍵 fork、環境齊全） |
| 敘事 | A. Reproduce-the-paper | 有具體 target，MMRM/CMH 自然 fall out |
| 「換院內資料」深度 | 中度 | 下半場 30–60 min 換 csv 重 render，學員身體記憶「換 csv = 換 paper input」 |
| 上下半場 | 上 Part 1–4 reproduce paper / 下 Part 5–6 換資料 + bonus | |
| Reproduce 範圍 | Table 1 + Figure 1A/B（MMRM）+ Figure 2（CMH）；Figure 3（KM）為 bonus | Shao spec 只列 MMRM + CMH，KM 雖在 paper 但不是要求 |
| AI tier | **Free-tier ChatGPT / Gemini / Claude** | Email 8293：「沒辦法去安裝或是花錢訂閱」 |
| 教學風格 | 沿用 [`htlin222/learn-r-with-ai`](https://github.com/htlin222/learn-r-with-ai) 的 DNA | 已驗證可行，user 自己的另一本書 |
| 寫作語言 | 內文 zh-TW、code/identifier 英文 | 與 learn-r-with-ai 一致 |
| 工作坊長度 | 預設 3 小時（modular，可壓到 90 min） | README 說「待確認時間」，三小時是常見邀約 default |

## Repo 骨架（建立後）

```
roche-vabysmo-rwe-workshop/
├── _quarto.yml                         # Book config (zh-TW, cosmo, AMA csl, html only)
├── _common.R                           # showtext + ggplot theme + knitr 全域
├── install.r                           # 一鍵安裝（pak 走 Posit Public Package Manager）
│
├── index.qmd                           # 前言：課程目標、玩法、paper 一頁懶人包
├── part1.qmd                           # Part 1 — 認識 paper + 認識資料 (任務 1–5)
├── part2.qmd                           # Part 2 — Table 1 baseline characteristics (任務 6–9)
├── part3.qmd                           # Part 3 — Figure 1: MMRM 跑 BCVA + CST (任務 10–15)
├── part4.qmd                           # Part 4 — Figure 2: CMH 跑 IRF/SRF/both (任務 16–20)
├── part5.qmd                           # Part 5 — 換你院內資料 (任務 21–24) ← 真正 deliverable
├── part6.qmd                           # Part 6 — (bonus) Figure 3 KM + 整合報告 (任務 25–28)
├── appendix.qmd                        # 院內 csv schema + 常見錯誤 + AI 對話技巧
│
├── data/
│   ├── vabysmo_baseline.csv            # 1329 列，每病人一列
│   ├── vabysmo_followup.csv            # long format (patient × visit at week 0/4/8/12)
│   ├── vabysmo_my_hospital.csv         # 「假裝是你院內」，同 schema 不同數字（n=180）
│   └── data_dictionary.md              # 院內 csv 必備欄位 schema
│
├── scripts/
│   ├── 01_table1.R
│   ├── 02_mmrm_figure1.R
│   ├── 03_cmh_figure2.R
│   ├── 04_km_figure3.R
│   └── 05_render_report_for_my_data.R
│
├── R/
│   └── simulate_vabysmo.R              # 模擬資料生成（reproducibility，set.seed(20260516)）
│
├── refs/
│   └── tenaya-lucerne-paper.pdf        # 已存在，不動
├── emails/                             # 已存在，不動
│
├── references.bib                      # paper 與 method 引用
├── american-medical-association.csl    # AMA 引用格式
├── styles.css                          # 微調
├── README.md                           # 改寫，含 Posit.Cloud workflow + book URL
├── plan.md                             # 這份 plan 的 copy
└── .gitignore                          # 忽略 _book/, _freeze/, .Rproj.user/ 等
```

## §A. 模擬資料規格（`R/simulate_vabysmo.R`）

**目標**：產出兩份 long-format-friendly csv，summary statistics 接近 Cheung 2025 paper（不要求一模一樣，但 MMRM 和 CMH 跑出來的方向、量級、顯著性要對得起 paper）。

### 設計參數

```r
set.seed(20260516)

N_FARI <- 665
N_AFLI <- 664
N_TOTAL <- N_FARI + N_AFLI  # 1329

# 兩個 trial 比例約 1:1（paper 沒明說精確，假定平衡）
P_TENAYA <- 0.50

# Region
P_US_CANADA <- 0.55  # 估計

# Demographics
AGE_MEAN <- 75; AGE_SD <- 9; AGE_MIN <- 50
P_FEMALE <- 0.55

# Baseline visual / anatomic（per paper p.521）
BCVA_BASELINE_MEAN_FARI <- 60.0; BCVA_BASELINE_SD_FARI <- 13.3
BCVA_BASELINE_MEAN_AFLI <- 60.2; BCVA_BASELINE_SD_AFLI <- 13.1
CST_BASELINE_MEAN_FARI  <- 356.8; CST_BASELINE_SD_FARI <- 122.1
CST_BASELINE_MEAN_AFLI  <- 357.5; CST_BASELINE_SD_AFLI <- 119.4
P_IRF_BASELINE_FARI <- 0.433
P_IRF_BASELINE_AFLI <- 0.468
P_SRF_BASELINE_FARI <- 0.657
P_SRF_BASELINE_AFLI <- 0.673

# LLD strat（paper 用 <33 vs >=33 letters 但沒明說比例，估計）
P_LLD_GE33 <- 0.30

# Adjusted mean change from baseline (per paper Fig 1)
# BCVA (letters): visit-specific means
BCVA_CHANGE_FARI <- c(W4 = 4.6, W8 = 5.8, W12 = 6.7)
BCVA_CHANGE_AFLI <- c(W4 = 4.0, W8 = 5.2, W12 = 5.9)
# CST (μm): visit-specific means
CST_CHANGE_FARI  <- c(W4 = -128.8, W8 = -140.3, W12 = -145.4)
CST_CHANGE_AFLI  <- c(W4 = -115.0, W8 = -127.7, W12 = -133.0)

# 個體層級 SD（讓 summary 出來像 paper 的 CI）
BCVA_RANDINT_SD <- 12   # subject-level random intercept on change
BCVA_RESID_SD   <- 4    # residual per visit
CST_RANDINT_SD  <- 50
CST_RESID_SD    <- 25

# Absence proportions per visit (CMH-weighted estimates, per paper)
ABSENCE_IRF_FARI  <- c(W4 = 0.881, W8 = 0.880, W12 = 0.884)
ABSENCE_IRF_AFLI  <- c(W4 = 0.841, W8 = 0.845, W12 = 0.850)
ABSENCE_SRF_FARI  <- c(W4 = 0.693, W8 = 0.822, W12 = 0.879)
ABSENCE_SRF_AFLI  <- c(W4 = 0.602, W8 = 0.750, W12 = 0.790)

# Missingness（implicit MAR）
P_MISSING_W4  <- 0.02
P_MISSING_W8  <- 0.04
P_MISSING_W12 <- 0.06
```

### 演算法

1. **生 baseline** (`baseline` data frame，1329 列)：
   - `patient_id` (P0001…P1329)
   - `arm` (faricimab / aflibercept)，依 N_FARI/N_AFLI 分配
   - `study` (TENAYA / LUCERNE)，二項分配
   - `region` (US-Canada / Rest-of-world)，二項分配
   - `age`，截斷 normal at 50
   - `sex` (F/M)
   - `bcva_baseline`，arm-specific normal，截斷 [0, 100]
   - `cst_baseline`，arm-specific normal，截斷 [150, 800]
   - `irf_baseline`，arm-specific Bernoulli
   - `srf_baseline`，arm-specific Bernoulli
   - `bcva_strat`：依 baseline BCVA 分 (≥74, 73–55, ≤54)
   - `lld_strat`：依 P_LLD_GE33 二項分配（"<33" vs "≥33"）

2. **生 follow-up** (`followup` data frame，1329 × 3 = 3987 列前提，扣除 missing)：
   - 對每位病人，在 week ∈ {4, 8, 12}：
     - `bcva` = `bcva_baseline` + (group_mean[week] + subject_random_intercept + visit_residual)
     - `cst`  = `cst_baseline`  + (group_mean[week] + subject_random_intercept + visit_residual)
     - `irf`：以 `1 - ABSENCE_IRF_*[week]` 為機率（注意 baseline 沒 IRF 的人 follow-up 也 0；有 IRF 的人按比例消失）。簡化規則：以 marginal probability 直接 Bernoulli 即可（learner 不會檢查 monotonicity）
     - `srf`：同上
     - 隨 week 增加 missing 機率，整列（bcva, cst, irf, srf）一起 NA — 模擬病人沒回診
   - 結構：`patient_id`, `week`, `bcva`, `cst`, `irf`, `srf`

3. **生 my_hospital.csv**（n=180）：
   - 同樣演算法，但：
     - 縮小 N（faricimab 100 / aflibercept 80，模擬「院內單臂或極小規模」）
     - 替換為「假裝院內」的命名：`PT-001…PT-180`
     - region 全 = "Asia-Pacific"
     - 加 1–2 個院內常見的 noise（例如 baseline BCVA 偏低 ~55，CST 偏高 ~380，模擬 real-world 比 trial population 嚴重）
     - **schema 完全相同**（這是重點：學員只要換 csv 路徑、code 不動）

4. 寫出三個 csv，並印出 summary 確認：
   - 每 arm 的 baseline mean / SD 是否接近 paper 數字
   - week 12 的 mean change from baseline 是否接近 paper（差 ≤ 1 letter / ≤ 5 μm）
   - week 12 的 absence proportion 是否接近 paper（差 ≤ 2%）
   - 跑一次 `mmrm::mmrm()` 和 `mantelhaen.test()` sanity check，diff in adjusted means 量級對

5. **驗收**：跑 `Rscript R/simulate_vabysmo.R` 沒 error，三個 csv 寫到 `data/`。

## §B. `_quarto.yml`

```yaml
project:
  type: book
  output-dir: _book

knitr:
  opts_chunk:
    message: false
    warning: false
    fig.width: 8
    fig.height: 5
    fig.dpi: 150

execute:
  echo: true
  freeze: auto

book:
  title: "讓你的 Vabysmo RWE 長得像 Ophthalmology 論文"
  subtitle: "眼科醫師研究工作坊教材"
  author: "林協霆 / 邵時傑"
  date: "2026/05/30"
  chapters:
    - index.qmd
    - part1.qmd
    - part2.qmd
    - part3.qmd
    - part4.qmd
    - part5.qmd
    - part6.qmd
    - appendix.qmd

bibliography: references.bib
csl: american-medical-association.csl

format:
  html:
    theme: cosmo
    toc: true
    toc-depth: 3
    number-sections: true
    code-fold: false
    code-tools: true
    css: styles.css
```

> **不出 PDF**：zh-TW + LaTeX + showtext 在 fresh env 上常 fail，HTML-only 換來 build 穩定。學員用瀏覽器看 / 印 PDF 都 OK。

## §C. `install.r`

```r
# 一鍵安裝所有套件（Posit.Cloud 與本機通用）
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))

if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")

pak::pak(c(
  "tidyverse", "gtsummary", "mmrm", "broom", "broom.mixed",
  "survival", "survminer", "gt", "patchwork", "ggsci",
  "showtext", "knitr", "rmarkdown", "quarto"
))

cat("\n✅ 安裝完成。下一步：開啟 part1.qmd，按 Shift+Enter 跑 chunks。\n")
```

## §D. `_common.R`

中文字型 + ggplot theme + knitr 預設。複用 learn-r-with-ai 的設計。

```r
# Chinese font
suppressPackageStartupMessages({
  library(showtext)
  library(ggplot2)
})
font_add_google("Noto Sans TC", "noto-sans-tc")
showtext_auto()

# ggplot global theme
theme_set(
  theme_minimal(base_family = "noto-sans-tc", base_size = 12) +
    theme(
      plot.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
)

# Treatment arm colour palette（matches paper：faricimab 紫、aflibercept 灰藍）
arm_colours <- c(
  "faricimab"  = "#7B5CA8",
  "aflibercept" = "#7E9CB7"
)

# 預設 dplyr 輸出寬度
options(dplyr.print_min = 6, dplyr.print_max = 6)
```

## §E. 章節內容規格（任務級別）

每章按 `learn-r-with-ai` 的 DNA：
- 開頭 callout-note collapse=true「一鍵 Prompt：整章一次跑完」
- 接著一連串「任務 N」，每個任務有：
  1. 📋 **複製這段話，貼給 AI** — 學員 copy 的 prompt 原文（zh-TW，自然語言）
  2. **參考程式碼** chunk — 一種可能的答案，echo=true、可執行
  3. **解釋** — 口語化、避免術語，1–3 句話
  4. （選用）**🎯 小提醒** — 常見坑

### `index.qmd` — 前言

- 課程目標（5 個 bullets）
- 玩法（5 步驟，沿用 learn-r-with-ai）
- 工作坊全圖（這 6 個 part 在做什麼）
- TENAYA/LUCERNE paper 一頁懶人包：
  - n=1329（faricimab 665 vs aflibercept 664）
  - 12-week head-to-head dosing phase
  - Outcomes：BCVA, CST, IRF, SRF
  - Methods：MMRM + CMH
- 強調：「你不會學 MMRM 和 CMH 的數學，你會學如何讓 AI 幫你跑出來、看懂結果、放進你的 paper」

### `part1.qmd` — 認識 paper + 認識資料（任務 1–5）

預計 30–40 分鐘。

- **任務 1**：開 Posit.Cloud → New Project from Git Repository → 貼 URL → 等到 RStudio 跳出來
- **任務 2**：在 Console 跑 `source("install.r")`（或第一次 render qmd 時自動裝）
- **任務 3**：用 AI 解釋這篇 paper 在做什麼（給學員模板 prompt：「這是 TENAYA/LUCERNE 的 paper abstract，請用 100 字告訴我它在比較什麼藥、為什麼比較、結論是什麼」）
- **任務 4**：用 `readr::read_csv()` 讀 `data/vabysmo_baseline.csv` 和 `data/vabysmo_followup.csv`，用 `dplyr::glimpse()` 看欄位
- **任務 5**：用 AI 解釋 long format vs wide format（為什麼 followup 要 long）

### `part2.qmd` — Table 1 baseline characteristics（任務 6–9）

預計 20 分鐘。

- **任務 6**：用 AI 寫一段「給我 Table 1 with `gtsummary::tbl_summary`，by arm，包含 age / sex / region / baseline_bcva / baseline_cst / irf_baseline / srf_baseline / bcva_strat / lld_strat / study」
- **任務 7**：加上 `add_p()` 和 `add_overall()`
- **任務 8**：用 `as_gt() %>% gt::gtsave()` 存成 docx 或 html
- **任務 9**：用 AI 解釋 Table 1 看哪些 row 來判斷「兩臂是否平衡」

### `part3.qmd` — Figure 1：MMRM（任務 10–15）

預計 40 分鐘。**這是最長的一章。**

- **任務 10**：用 AI 解釋什麼是 repeated measures、什麼是 MMRM（用「同一隻眼睛被量很多次」的比喻）
- **任務 11**：把 followup data merge baseline 的 `arm` 和分層因子（`study`, `bcva_strat`, `lld_strat`, `region`）
- **任務 12**：跑第一個 MMRM — BCVA change from baseline
  ```r
  library(mmrm)
  m_bcva <- mmrm(
    formula = bcva_change ~ arm + visit + arm:visit + study + bcva_strat + lld_strat + region + us(visit | patient_id),
    data = followup_long
  )
  ```
- **任務 13**：用 `emmeans::emmeans()` 取 adjusted means by arm × visit
- **任務 14**：畫 Figure 1A — `ggplot()` + `geom_line` + `geom_pointrange`，模仿 paper Fig 1A
- **任務 15**：複製整段 code 改 outcome 為 `cst_change` → 出 Figure 1B
- 章末加一個 `patchwork` 把 1A + 1B 合併成 paper 樣

### `part4.qmd` — Figure 2：CMH（任務 16–20）

預計 30 分鐘。

- **任務 16**：用 AI 解釋什麼是 stratified analysis、為什麼要 weighted by stratum
- **任務 17**：建立 stratified 2×2×K table（K = strata combination of study × randomization factors）
- **任務 18**：跑 base R `mantelhaen.test()` 拿到 P value 與 common odds ratio（教學用）
- **任務 19**：寫一個小函數 `cmh_weighted_proportion()` 算 stratum-weight × per-stratum proportion → output adjusted proportion + 95% CI（用 Wilson score 各 stratum 再 weight），對 IRF / SRF / IRF+SRF 各 visit 各 arm 都跑一次
- **任務 20**：用 ggplot 三個 panel 畫 Figure 2（Absence of IRF / SRF / IRF and SRF），bar plot + error bar，配色與 paper 一致

### `part5.qmd` — 換你院內資料（任務 21–24）← 真正 deliverable

預計 30 分鐘。

- **任務 21**：說明 data dictionary（appendix）— 你的院內 csv 該長什麼樣（哪些欄位 mandatory、哪些 optional）。展示 `data/vabysmo_my_hospital.csv` 的 head
- **任務 22**：把 part2/3/4 的 code 重新跑一次，但 input 換成 `vabysmo_my_hospital.csv`。重點：**code 完全不動**，只改檔名。看 Quarto 重 render，圖換了。
- **任務 23**：討論 — 結果是不是和 paper 的方向一致？樣本變小了，95% CI 怎麼變化？哪些 stratum 太空（學員會看到 CMH 在 small N 時某些 stratum 0 events 的問題）
- **任務 24**：學員回院後的 checklist
  - 找院內 IT 撈 cohort（提供 SQL-like 描述）
  - IRB 流程（簡單帶過）
  - 把 csv 放進 `data/`、改 `_quarto.yml` 中的書名 → render → 拿到「你自己的 paper draft」

### `part6.qmd` — Bonus + 整合（任務 25–28）

預計 20 分鐘。如果時間吃緊可整段跳。

- **任務 25**：用 AI 解釋什麼是 time-to-event、censoring
- **任務 26**：用 `survival::survfit()` 做 KM curve（time to first absence of IRF and SRF in patients with IRF or SRF at baseline）
- **任務 27**：用 `survminer::ggsurvplot()` 畫圖（模仿 paper Fig 3）
- **任務 28**：用 `survival::coxph()` 拿 hazard ratio + 95% CI + log-rank p
- 章末：把所有結果（Table 1 + Fig 1 + Fig 2 + Fig 3）整合成一份 self-contained Quarto report（事實上整本書就是了），講「你下課帶回家的東西」

### `appendix.qmd` — 附錄

- **A. 院內 csv 必備欄位 schema** — 配上 sample row、注意事項（變項命名、單位、編碼）。和 `data/data_dictionary.md` 互相參照
- **B. AI 對話技巧** — 給 prompt 三原則（給情境、給樣本、要可執行 code），三個常見坑（AI 給的 code 套件名拼錯 / AI 給 outdated function / AI 沒看資料就幻想欄位）
- **C. 常見錯誤** — `mmrm` 套件裝不起來（→ pak）、`mantelhaen.test` 在某 stratum n=0 時報錯（→ 合併或 drop stratum）、ggplot 中文字型亂碼（→ `_common.R`）、long vs wide pivot 弄錯（→ `tidyr::pivot_longer/wider` 範例）

## §F. `scripts/*.R`（給有底子的人）

每支獨立可跑，不依賴 qmd。內容是 qmd 中對應 part 的「參考程式碼」整理版。命名同前面骨架。`05_render_report_for_my_data.R` 用 `quarto::quarto_render()` 觸發整本重新渲染。

## §G. `README.md`（GitHub 入口）

短，給學員與未來訪客的入口。

```markdown
# 讓你的 Vabysmo RWE 長得像 Ophthalmology 論文

5/30 眼科醫師研究工作坊教材。

## 在線閱讀

- 書籍：（GitHub Pages / 內網靜態網址；render 後填）
- 模擬資料：[`data/`](data/)
- 程式碼：[`scripts/`](scripts/)

## 學員開始（Posit.Cloud 路線）

1. 註冊 [Posit.Cloud](https://posit.cloud/) 免費帳號
2. **New Project** → **New Project from Git Repository** → 貼這個 repo 的 URL
3. 開啟 `part1.qmd`，按 Render
4. 跟著做即可

## 老師開始（本機路線）

```bash
git clone <repo>
cd roche-vabysmo-rwe-workshop
Rscript install.r
Rscript R/simulate_vabysmo.R   # 重生模擬資料（可選）
quarto render
open _book/index.html
```

## 結構

[簡短 tree]

## 對口

Shao, Shih-Chieh (邵時傑) / 林協霆
```

> 既存 `README.md` 含「對口」「素材」「任務」等 Shao-給的 context，那份留給 user 自己內部用。**新的 `README.md` 把那些當作 internal note，搬到本 plan 開頭已經 cover；GitHub-facing README 改寫成 student/visitor 版**。但 user 的舊 README 內容不能丟，移到 `docs/internal-notes.md` 保留。

## §H. `.gitignore`

```
_book/
_freeze/
.Rproj.user/
.Rhistory
.RData
*.html
!references.bib
.DS_Store
.quarto/
```

> 注意：`_book/` 通常會 git-ignore。但**這次要 commit `_book/`**，因為 deliverable 是 user 醒來能看到 build 結果。改：先 build → `_book/` 加進 git → 之後 push GitHub Pages 就能用。所以 `.gitignore` 不要 ignore `_book/`，改 ignore `_freeze/` 和 `.quarto/` 即可。

## 執行步驟（從 ExitPlanMode 後依序做）

1. **首先 copy 這份 plan 到 `./plan.md`**（user 醒來時可以在 project root 看到）
2. 建立 quarto book skeleton：`_quarto.yml`, `_common.R`, `install.r`, `references.bib`, `american-medical-association.csl`, `styles.css`, `.gitignore`
3. 寫 `R/simulate_vabysmo.R` 並執行，產生 3 份 csv 至 `data/`，加 `data/data_dictionary.md`
4. 寫 8 份 qmds（index + part1–6 + appendix）— 每份按 §E 規格
5. 寫 5 份 `scripts/*.R`
6. 安裝 `mmrm` 套件：`Rscript -e 'install.packages("mmrm", repos="https://packagemanager.posit.co/cran/latest")'`
7. **`quarto render`** — 渲染整本書到 `_book/`，逐章跑通。預期跑 5–15 分鐘（MMRM 運算最慢）
8. 開 `_book/index.html` 用 headless tool（curl 或 `open`）確認首頁 OK；逐頁掃 figure 是否生成
9. 新寫 `README.md`（學員/訪客版），舊 README 內容搬到 `docs/internal-notes.md`
10. **失敗處理**（FYTM — follow your mind, but be conservative）：
    - 任何 chunk render 失敗 → 讀 error → 修 → 重 render
    - `mmrm` 模型 singularity → 簡化 covariance（`cs(visit | patient_id)` instead of `us`）並在文中註記
    - CMH 某 stratum cell=0 → 合併 stratum 或加 `correct=FALSE`
    - Chinese font 不出來 → 確認 `_common.R` showtext 設定
    - 不要為了過 build 而裁掉 deliverable；寧可在某章加「⚠️ 此處 simulated data 在某 stratum n 不足，CMH 跑不出，下面用合併 stratum」也比靜默丟東西好
11. Git add / commit（在 parent `Mail` repo）— message 要描述每個檔案在做什麼
12. **Best effort：** `gh repo create htlin222/roche-vabysmo-rwe-workshop --public --source=<workshop dir> --push` 同步到 standalone public repo（Posit.Cloud 學員 fork 用）。如果失敗（auth、name conflict），記錄在 commit message TODO，不阻塞

## 驗收（user 醒來時自己對 checklist）

- [ ] `cd /Users/htlin/Mail/projects/roche-vabysmo-rwe-workshop && open _book/index.html` 開出首頁
- [ ] index → part1 → … → part6 → appendix 八頁都能瀏覽
- [ ] Table 1 出現在 part2，with arms in columns
- [ ] Figure 1A (BCVA) 與 Figure 1B (CST) 出現在 part3，且 faricimab 線在 CST 圖上低於 aflibercept（趨勢對）
- [ ] Figure 2 三個 panel（IRF / SRF / IRF+SRF）出現在 part4，week 12 數值接近 paper（差 ≤ 2%）
- [ ] part5 中 Table 1 / Fig 1 / Fig 2 都用 `vabysmo_my_hospital.csv` render 過一次
- [ ] part6 KM curve 出現
- [ ] `data/` 三 csv 存在；`data/data_dictionary.md` 描述清楚
- [ ] `scripts/*.R` 五支單獨跑都不 error（可 spot-check 1–2 支）
- [ ] `plan.md` 在 project root（這份的 copy）
- [ ] `git log -1` 看到本次 commit
- [ ] （optional）`gh repo view htlin222/roche-vabysmo-rwe-workshop` 顯示 public repo

## 已知風險與緩解

| 風險 | 緩解 |
|---|---|
| MMRM 模型 unstructured covariance 在 n=1329 收斂慢 | `mmrm` 是 Roche 自家套件，跑得動；若慢 → reduce strata，或先在 chunk 加 `eval: false` 預載 cached fit |
| CMH 在 strata 太多時 cell sparsity | 把 strata 簡化為 study × bcva_strat（移除 lld_strat × region），文中註記 |
| Posit.Cloud 上 `mmrm` 裝不起來 | 用 PPM CRAN binary（`packagemanager.posit.co`），install.r 已設好；若不行加 install fallback |
| Chinese font 在 ggplot 不出來 | `_common.R` 用 showtext + Noto Sans TC，已驗證 |
| `gh repo create` 失敗 | 不阻塞 main deliverable，記 TODO |
| 整本 build 超過 30 分鐘 | 不大可能（n=1329 MMRM 應 ~1 min）；若真超時，將某些 long chunk 加 `cache: true` |
| 模擬資料數字 leak 太多細節讓 paper 結果完全可重現 | 不是問題，paper 是 CC BY，且模擬資料本來就是設計來像 paper 的 |

## 跨檔關鍵 reference

| 檔案 | 用途 |
|---|---|
| `refs/tenaya-lucerne-paper.pdf` | source of truth；不寫進 git LFS，原本就在 |
| `emails/8291-5-16-workshop-spec.txt` | Shao 對 method 的 prose 描述，引到 part3/4 開頭 quote 用 |
| `emails/8293-5-16-workshop-followup.txt` | confirm 學員不能裝東西、不能訂閱 → free-tier AI |
| `https://github.com/htlin222/learn-r-with-ai` | 教學 DNA 的 reference repo |

## 不在這次 scope（明確排除）

- 教 MMRM / CMH 的數學原理
- 教 R 程式語法本身（學員只要會 copy-paste）
- Subgroup analysis、sensitivity analysis、multiple imputation
- 真正的院內 EHR ETL
- 上 Posit.Cloud 後的權限 / 帳號管理
- 投影片 (`.Rmd` presentation) — 不在這次 deliverable，等內容定型後另出

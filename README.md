# 羅氏眼科臨床研究賦能工作坊教材

> 副標：讓你的 Faricimab RWE 長得像 Ophthalmology 論文（5/30）
> 主辦單位：羅氏大藥廠（Roche Products Ltd. Taiwan）
> 作者：和信治癌中心醫院 林協霆醫師 × 羅氏大藥廠 邵時傑博士

這是一本 Quarto book，教眼科醫師用 AI + R 把院內 faricimab cohort 資料做成可投 _Ophthalmology_ 的圖表，
reproduce TENAYA/LUCERNE paper 的 Figure 1（MMRM）與 Figure 2（CMH-weighted），並示範院內 RWE 必備的 PSM + ASMD 工作流。
**學員不需要會 R**，照著「📋 複製這段話貼給 AI」操作即可。

> ⚠️ **利益揭露**：本工作坊由羅氏大藥廠贊助舉辦。教材內容以方法學教學為主，藥物一律以學名（faricimab、aflibercept）呈現、不使用商品名；圖表配色為教材中性色。詳見書內前言宣告。

---

## 在線閱讀

- 🌐 **線上書（GitHub Pages）**：<https://htlin222.github.io/roche-vabysmo-rwe-workshop/>
- 📦 **Repo（學員 fork 用）**：<https://github.com/htlin222/roche-vabysmo-rwe-workshop>
- 模擬資料：[`data/`](data/)
- 程式碼：[`scripts/`](scripts/)
- 院內 csv schema：[`data/data_dictionary.md`](data/data_dictionary.md)
- **教學現場文件**（`docs/`）
  - [`docs/posit-cloud-setup.md`](docs/posit-cloud-setup.md) — 老師的課前預烤 setup
  - [`docs/ta-handbook.md`](docs/ta-handbook.md) — 助教工作手冊
  - [`docs/faq.md`](docs/faq.md) — 常見問題（學員 / 助教共用）
  - [`docs/internal-notes.md`](docs/internal-notes.md) — 對口 / 信件 / 行事曆
- **非眼科背景請先讀**：書內 Primer 章節（眼科解剖 / nAMD / OCT / faricimab 機轉 30 分鐘速懂）

### 更新流程：本機 render → publish gh-pages → release 附 PDF

`_book/`（HTML + PDF）已 gitignore，**不進版控**。HTML 用本機 `quarto publish gh-pages`
直接推到 `gh-pages` branch（GitHub 內建的 _pages build and deployment_ 會自動上線），
PDF 則用 GitHub Release asset 散布給學員下載。CI **不裝 R、不 render**。

```bash
# 1. 編輯內容（qmd / data / scripts）
# 2. 本機 render（HTML + PDF）
quarto render
# 3. commit 原始檔（_book/ 已 gitignore，不會進 commit）
git add -A && git commit -m "..." && git push
# 4. 部署 HTML 到 GitHub Pages（本機推 gh-pages branch）
quarto publish gh-pages --no-render --no-browser
# 5. 發 release，附上 PDF 給學員下載
gh release create v0.2.4 \
  "_book/羅氏眼科臨床研究賦能工作坊教材.pdf" \
  --generate-notes
```

> 為什麼 CI 不自己 render？R packages install 在 CI 上要 5–10 min，
> 而教材是「人類在桌前改完才發版」的 cadence——本機 render 已成品。
> 部署交給 `quarto publish gh-pages`（本機）+ GitHub 內建 Pages pipeline（自動），
> 不再維護自訂 deploy workflow。

---

## 學員開始：三層 fallback

| 層                           | 怎麼進                                                                                                                                         | 體驗                            | 適合                          |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- | ----------------------------- |
| 🥇 **預烤 Posit.Cloud 連結** | <https://posit.cloud/content/12416569> → Save a Permanent Copy                                                                                 | 30 秒進 RStudio，**套件已裝好** | 全部學員（推薦）              |
| 🥈 **GitHub fork**           | Posit.Cloud → New Project from Git Repository → 貼 `https://github.com/htlin222/roche-vabysmo-rwe-workshop` → Console 跑 `source("START.R")` | 5–10 分鐘安裝後可跑 code        | 預烤連結掛了 / 想保留自己版本 |
| 🥉 **純讀網頁版**            | <https://htlin222.github.io/roche-vabysmo-rwe-workshop/>                                                                                       | 0 安裝、純閱讀                  | 環境完全裝不起來              |

> 老師：工作坊前一晚請看 [`docs/posit-cloud-setup.md`](docs/posit-cloud-setup.md) 預烤 🥇 連結。

> ⚠️ Free tier 限 25 hr/月，工作坊一個下午足夠。下課用 **Save a Permanent Copy** 保存。

---

## 老師 / 助教開始（本機路線）

```bash
git clone <this repo>
cd roche-vabysmo-rwe-workshop

# 一鍵安裝套件（START.R 內部呼叫 setup/install.r）
Rscript START.R

# 重生模擬資料（可選，repo 已含 csv）
Rscript R/simulate_faricimab.R

# 渲染整本書
quarto render

# 用瀏覽器打開
open _book/index.html
```

---

## 結構

```
.
├── README.md                  # 本文件
├── START.R                     # 一鍵入口：source("START.R") 裝好所有套件（內部呼叫 setup/install.r）
├── _quarto.yml                # Quarto book 設定（execute-dir: project）
├── _common.R                  # 字型 / theme / knitr 全域（每章 source 它）
├── index.qmd                  # 前言（書封面頁，Quarto 要求留在根目錄）
│
├── chapters/                  # 各章 qmd
│   ├── primer.qmd             # 暖身
│   ├── part1.qmd              # Part 1 認識 paper + 資料
│   ├── part2.qmd              # Part 2 Table 1
│   ├── part3.qmd              # Part 3 Figure 1：MMRM
│   ├── part4.qmd              # Part 4 Figure 2：CMH
│   ├── part5.qmd              # Part 5 換你院內資料 ← 真正 deliverable
│   ├── part6.qmd              # Part 6 Bonus：KM + Cox
│   └── appendix.qmd           # 院內 csv schema + 常見錯誤 + AI 對話技巧
│
├── assets/                    # references.bib / .csl / styles.css（_quarto.yml 引用）
├── setup/                     # install.r 裝套件、validate_env.R 環境健檢
├── data/                      # 模擬 csv + data dictionary
├── scripts/                   # standalone R scripts（01–05 → output/、99 → _book/）
├── R/simulate_faricimab.R    # 可重現的模擬資料生成腳本
├── refs/                      # 參考論文（TENAYA/LUCERNE PDF）
├── docs/                      # 內部筆記（含 plan.md build plan、posit-cloud-setup、faq）
├── output/                    # standalone scripts 圖表輸出（gitignore）
└── _book/                     # Quarto 渲染輸出（gitignore；HTML→gh-pages、PDF→Release asset）
```

---

## 工作坊章節速覽

| 章節     | 主題                          | 預計時間  | 學員會做出                                    |
| -------- | ----------------------------- | --------- | --------------------------------------------- |
| Part 1   | 認識 paper + 認識資料         | 30–40 min | Posit.Cloud 開好、看到欄位                    |
| Part 2   | Table 1 baseline              | 20 min    | gtsummary 跑出論文等級 Table 1                |
| Part 3   | Figure 1（MMRM）              | 40 min    | BCVA + CST 兩張曲線                           |
| Part 4   | Figure 2（CMH）               | 30 min    | IRF/SRF/both 三張 absence bar                 |
| Part 5   | 換你院內資料（含 PSM + ASMD） | 30 min    | PSM 配對 + matched cohort 上跑出 n≈100 院內版 |
| Part 6   | Bonus：KM + Cox               | 20 min    | Time-to-event 曲線 + HR                       |
| Appendix | 回院 checklist                | —         | 院內 csv schema                               |

---

## 設計決策

**為什麼是 Quarto book + R + Posit.Cloud（不是 Colab + Python）？**
RWE / regulatory 圈的 lingua franca 是 R + Quarto；`mmrm` 套件本來就是 Roche/Genentech 維護。

**為什麼學員不寫 R？**
[Email 8293](emails/8293-5-16-workshop-followup.txt)：「沒辦法去安裝或是花錢訂閱」。
所以走 free-tier ChatGPT / Gemini / Claude 的「📋 複製貼給 AI」流程。

**為什麼用模擬資料而不是 paper 原始 data？**
TENAYA/LUCERNE raw data 不公開（Roche 內部）。我們從 paper 的 summary statistics 反推、
重生統計特性接近的 1329 筆資料，用 `R/simulate_faricimab.R` 完全 reproducible（fixed seed）。

詳細設計討論看 [`docs/plan.md`](docs/plan.md)。

---

## 引用 / 授權

教材本身：CC BY 4.0
參考論文：

> Cheung CMG, Lim JI, Priglinger S, et al. **Anatomic Outcomes with Faricimab vs Aflibercept in Head-to-Head Dosing Phase of the TENAYA/LUCERNE Trials in Neovascular Age-related Macular Degeneration.** _Ophthalmology_. 2025;132(5):519-526. (CC BY)

---

## 對口

- **Shao, Shih-Chieh** (邵時傑) — Principal Data Scientist, RWE, Roche Products Ltd. Taiwan
- **林協霆** — 教材設計與實作

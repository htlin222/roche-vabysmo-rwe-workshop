# 老師現場 / 工作坊前的 Posit.Cloud 設定

> 給講師（你）— 學員不必看這份。
>
> 對齊版本：教材 v0.2.x（2026-05 改版後，含 PSM/ASMD、faricimab_*.csv、6 支 standalone scripts）

## TL;DR

```text
你（老師）做一次：
  1. Posit.Cloud → New Project from Git Repository → 貼 repo URL
  2. Console: source("install.r")          # 5–10 分鐘，14 個套件含 MatchIt/cobalt
  3. Console: quarto::quarto_render()      # 2–3 分鐘，充滿 _freeze/ cache
  4. Project 三點 → Access → Everyone + Allow Permanent Copies
  5. 複製 project URL，工作坊當天發給學員

學員每人做一次（< 30 秒）：
  1. 點老師的連結（Google 登入 Posit.Cloud）
  2. 右上 Save a Permanent Copy
  3. 雙擊 part1.qmd → Render → 開做
```

完整版 SOP 與 fallback 在下面。

學員端 90% 的痛苦來自「**第一次 install 套件**」：mmrm + tidyverse + survminer + ggsci + **MatchIt + cobalt**（v0.2 後 PSM 用）在 Posit.Cloud 免費 node 上要 5–10 分鐘，而且一旦遇到網路抖動、版本不合就會卡死。

避免方式：**前一晚老師在自己 Posit.Cloud 帳號上預烤一份「已裝好套件」的 project，把 public 連結發給學員**。
學員點連結 → **Save a Permanent Copy** → 5 秒得到一份完整可用的 RStudio。

::: {.callout-important}
**v0.2 教材改版（2026-05）後 install.r 套件清單已擴充至 14 個**，新增 `MatchIt`、`cobalt` 給 Part 5 的 PSM/ASMD 工作流。
若你的預烤 project 是 v0.1 時做的，**請重新 `source("install.r")` 一次**，否則學員跑 Part 5 會缺套件。
:::

---

## 一次性 setup（工作坊前一晚做）

### Step 1 — 在 Posit.Cloud 開 project

1. <https://posit.cloud/> 登入（用 Google 帳號免費）
2. **New Project** → **New Project from Git Repository**
3. 貼：<https://github.com/htlin222/roche-vabysmo-rwe-workshop>
4. 等 30 秒 RStudio 跳出來

### Step 2 — 預裝套件（14 個，包含 PSM）

在 Console 跑：

```r
source("install.r")
```

會跑 5–10 分鐘，泡杯咖啡。看到 `[OK] 套件安裝完成` 就好。

清單（給你心裡有底）：
- **資料**：tidyverse, readr
- **表格**：gtsummary, gt, knitr
- **MMRM**：mmrm, emmeans, broom, broom.mixed
- **CMH / 比例**：DescTools
- **PSM / ASMD（v0.2 新增）**：MatchIt, cobalt
- **Survival**：survival, survminer
- **繪圖**：ggplot2, patchwork, ggsci, scales
- **i18n / 字型**：showtext, sysfonts
- **Render**：rmarkdown, quarto

### Step 3 — 預跑一次 render（充快取）

```r
quarto::quarto_render()
```

會跑 1–3 分鐘（含 PSM 章節跑 MatchIt + Love plot）。看到 `Output created: _book/index.html` 就好。
這步驟把 `_freeze/` cache 充滿，學員之後改一個 chunk 重 render 只需要幾秒。

### Step 3.5 — （可選）預跑 6 支 standalone scripts

讓你自己心裡有把握、`_book/` 內也存有現成的標準輸出可以對學員圖：

```r
# 在 RStudio Terminal（注意是 terminal、不是 Console）
Rscript scripts/01_table1.R              # → _book/table1_standalone.html
Rscript scripts/02_mmrm_figure1.R        # → _book/figure1_standalone.png
Rscript scripts/03_cmh_figure2.R         # → _book/figure2_standalone.png
Rscript scripts/04_km_figure3.R          # → _book/figure3_standalone.png
Rscript scripts/06_psm_my_hospital.R     # → Love plot + matched fig 1/2
```

這些 `*_standalone.*` 檔可以給「完全不寫 code」的學員直接 `Rscript scripts/0X_xxx.R` 重跑。
詳細流程在書內 appendix 開頭「🚀 完全不會寫程式：6 支腳本一行跑完」。

### Step 4 — 公開這份 project

1. Posit.Cloud 右上角 project 名稱旁邊的 **三點選單** → **Access**
2. 把 **Project Access** 設成 **Everyone**（或 Anyone with the link）
3. **Allow Permanent Copies** 打勾
4. 複製這份 project 的 URL（網址列那串長 ID 的）

這就是你工作坊當天要發給學員的「神奇連結」。

---

## 工作坊當天 — 給學員的 3 步驟

把下面這段貼進 group chat / 投影片：

> 1. 點：[預烤好的 Posit.Cloud project 連結，貼這裡]
> 2. 右上 **Save a Permanent Copy**（要先註冊 Posit.Cloud 免費帳號，用 Google 登入即可）
> 3. RStudio 跳出來後，點 `part1.qmd`，按 Render → 開始跟著做

**整個過程 < 30 秒**，因為套件已經幫他們裝過了。

::: {.callout-tip title="完全不寫 code 的學員"}
若有學員只想看圖、不想跟 prompt：直接打開 RStudio Terminal、依序 `Rscript scripts/01_table1.R` ~ `06_psm_my_hospital.R`，每支 30 秒內輸出對應 `_book/*_standalone.*`。書內 appendix 開頭有完整對應表。
:::

---

## 三層 fallback

| 層 | 給誰 | 體驗 | 限制 |
|---|---|---|---|
| **🥇 預烤連結（推薦）** | 全部學員 | 30 秒進到完整 RStudio | 老師要前一晚做一次 setup |
| **🥈 自己從 GitHub fork** | 預烤連結掛了 / 學員想存自己版本 | 5–10 分鐘等 install | 偶有網路 / 版本問題 |
| **🥉 純讀網頁版** | 環境完全裝不起來的學員 | 0 安裝、能讀但不能跑 | 看不到自己改 csv 的效果 |

學員只要有其中一層活，就能跟得上工作坊。**至少永遠有 🥉**（GH Pages 24/7 在），所以「我裝不起來」的學員不會被卡到動彈不得。

---

## 一些常見的 Posit.Cloud 坑

| 症狀 | 原因 | 解法 |
|---|---|---|
| 「Project not found」 | 連結 typo / project access 沒設 Public | 重貼連結，檢查 Settings → Access |
| Console 跑 `install.r` 跑到一半就斷 | 免費 tier 1 GB RAM 編譯到 mmrm 時撐不住 | 重跑 `source("install.r")`，pak 會跳過已裝好的 |
| `Save a Permanent Copy` 灰色按不下去 | 學員還沒登入 | 點右上人頭 → Sign In |
| 課堂 25 hr/月用完了 | 免費 tier 限制 | 升級 Cloud Plus（$5/月）或匯出 zip 本機跑 |
| Part 5 跑到 `library(MatchIt)` 跳錯 | 預烤 project 是 v0.1 時做的、沒裝 PSM 套件 | Console 跑 `pak::pak(c("MatchIt","cobalt"))` 補裝；或重做 setup |
| 「找不到 `data/faricimab_baseline.csv`」 | 預烤 project 還是舊檔名 `vabysmo_*.csv` | 重新 `git pull`、或重做 New Project from Git |

---

## Plan B / Plan C 的提示

工作坊當天要先在投影片寫 fallback 順位：

```
連不上預烤 project？
  → 1. 用 GitHub URL 自己 fork（多 5 分鐘安裝）
  → 2. 直接讀：https://htlin222.github.io/roche-vabysmo-rwe-workshop/
  → 3. 兩個都掛了：跟旁邊的同學共用螢幕
```

旁邊的同學共用螢幕也是好方法——這課本來就是「複製貼上 prompt」，2 個人 1 個螢幕完全可行。

---

## 為什麼不是 Docker / Binder / WebR？

| 方案 | 不適合的原因 |
|---|---|
| Docker | 學員是眼科醫師，不會 docker run |
| MyBinder + Quarto | 沒有 RStudio UI，學員會迷路 |
| WebR / Quarto live | mmrm 這個 C++/TMB 套件不能在 WebAssembly 跑 |
| 教室機房預裝 | 跨醫院統一機房不存在 |

Posit.Cloud + 預烤 project 是「眼科醫師可以接受的最低摩擦解」。

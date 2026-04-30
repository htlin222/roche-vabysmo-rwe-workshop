# 老師現場 / 工作坊前的 Posit.Cloud 設定

> 給講師（你）— 學員不必看這份。

學員端 90% 的痛苦來自「**第一次 install 套件**」：mmrm + tidyverse + survminer + ggsci 在 Posit.Cloud 免費 node 上要 5–10 分鐘，而且一旦遇到網路抖動、版本不合就會卡死。

避免方式：**前一晚老師在自己 Posit.Cloud 帳號上預烤一份「已裝好套件」的 project，把 public 連結發給學員**。
學員點連結 → **Save a Permanent Copy** → 5 秒得到一份完整可用的 RStudio。

---

## 一次性 setup（工作坊前一晚做）

### Step 1 — 在 Posit.Cloud 開 project

1. <https://posit.cloud/> 登入（用 Google 帳號免費）
2. **New Project** → **New Project from Git Repository**
3. 貼：<https://github.com/htlin222/roche-vabysmo-rwe-workshop>
4. 等 30 秒 RStudio 跳出來

### Step 2 — 預裝套件

在 Console 跑：

```r
source("install.r")
```

會跑 5–10 分鐘，泡杯咖啡。看到 `[OK] 套件安裝完成` 就好。

### Step 3 — 預跑一次 render（充快取）

```r
quarto::quarto_render()
```

會跑 1–2 分鐘。看到 `Output created: _book/index.html` 就好。
這步驟把 `_freeze/` cache 充滿，學員之後改一個 chunk 重 render 只需要幾秒。

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

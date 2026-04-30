# 助教工作手冊（TA Handbook）

> 5/30 眼科醫師研究工作坊 · 給工作坊現場助教

歡迎加入。你的工作不是「教 R」，是讓教室裡每一個學員**有出口可以前進**——不卡、不放棄、知道下一步該做什麼。

---

## 1. 一頁懶人包：工作坊在做什麼

| | |
|---|---|
| **主題** | 用 AI + R 把眼科 RWE 做成像 paper 的圖表 |
| **參考 paper** | Cheung et al., Ophthalmology 2025（TENAYA/LUCERNE 12-week head-to-head dosing） |
| **學員** | 眼科醫師為主，**多數沒寫過 R**（Excel-only） |
| **學員工具** | Posit.Cloud（瀏覽器跑 RStudio）+ Quarto book + ChatGPT/Gemini/Claude（free tier） |
| **教學風格** | 學員**不寫 R**，照「📋 複製這段話貼給 AI」操作 |
| **真正目標** | 下課後學員想做自己的院內 Vabysmo cohort、知道 csv schema、敢動手 |

**把這句話刻在腦袋裡**：
> 學員的工作是「問對問題」、「看懂結果」，不是「寫對程式」。

如果你看到學員在 debug 程式語法的細節，輕輕把他帶回 prompt 流程：「這段你貼給 AI，請它幫你看錯誤訊息」。

---

## 2. 課前一週：你要先做的事

### Step 1 — 自己跑一遍整本書

工作坊前**至少 3 天**前，做這件事：

1. 註冊 Posit.Cloud（免費，Google 登入）
2. New Project → New Project from Git Repository → 貼 `https://github.com/htlin222/roche-vabysmo-rwe-workshop`
3. Console 跑 `source("install.r")`，等 5–10 分鐘
4. 從 `index.qmd` 開始，**每章每個任務都跟著做一次**
5. 卡住的地方寫下來（Slack / Telegram 群組記下，這就是學員會卡的地方）

**目的**：你要對「會出什麼錯」有手感，學員問你時你不用看著 traceback 才知道。

### Step 2 — 預習 Appendix

特別是：

- **Appendix C（常見坑）** ←最常被問到
- **Appendix E（ELI5 統計方法）**：學員問「為什麼要 stratify」「什麼是 unstructured covariance」時，你照這節的話回他即可
- **Appendix F（ELI5 R / 程式）**：學員問「factor 是什麼」「pipe 怎麼用」時的標準答案
- **Appendix G（名詞速查表）**：所有縮寫的中英對照

### Step 2.5 — 非眼科背景的助教請讀 Primer

如果你不是眼科背景（你是內科 / 血液 / 腫瘤 / 家醫 / 研究員），開課前請讀書內 **Primer 章節**：
<https://htlin222.github.io/roche-vabysmo-rwe-workshop/primer.html>

裡面 30 分鐘讓你知道：nAMD 是什麼、anti-VEGF 怎麼作用、OCT 怎麼看、faricimab 跟 aflibercept 差在哪、為什麼 anatomic 跟 functional outcome 會 dissociate。
有這個底，你才能聽得懂學員講「我們院 AMD case 比 paper 嚴重」這類在地討論。

### Step 3 — 確認 fallback 三層都通

工作坊當天可能出錯的點都先驗一次：

| 檢查 | 怎麼驗 |
|---|---|
| 🥇 老師預烤連結能 Save Copy | 老師應該在前一晚發到群組，你點一次驗證 |
| 🥈 GitHub fork 能跑 install.r | 你 Step 1 已經做過 |
| 🥉 GH Pages 開得起來 | <https://htlin222.github.io/roche-vabysmo-rwe-workshop/> 點一下 |

任何一層失敗，**馬上**在群組講，不要等到上課當天才發現。

---

## 3. 上課當天：你的角色

### 你要帶的東西

- 自己的筆電（已 install 好套件 / 或用 Posit.Cloud）
- 一份印好的 [`docs/faq.md`](faq.md)（救命用）
- 一份印好的 [`docs/posit-cloud-setup.md`](posit-cloud-setup.md)（學員 onboarding 卡關時翻）
- 教室 Wifi 密碼

### 開場 15 分鐘：onboarding 大隊長

老師講開場時，你的任務是**確認所有學員都進得去 Posit.Cloud**。
走動式檢查：每位學員的螢幕上應該看得到 RStudio。

| 看到什麼 | 怎麼處理 |
|---|---|
| Posit.Cloud 登入頁 | 引導用 Google 帳號登入 |
| Project 已開、有 file panel | ✅ 跳過 |
| 灰色 "Save a Permanent Copy" | 還沒登入，點右上角人頭登入 |
| 「Project not found」 | 預烤連結掛了，引導走 🥈 GitHub fork 路線 |
| 連 Posit.Cloud 都進不去 | 引導開 🥉 GH Pages 純讀，跟同學共用螢幕 hands-on |

**目標**：老師講完開場，全部學員都進到至少一個 fallback layer。

### 任務段落：流動 troubleshooter

學員照著 part1 → part6 自己跑時，你**走動**：

- 看 RStudio 紅字 → 過去問需不需要幫忙
- 看學員螢幕停在某個 chunk 超過 3 分鐘 → 過去看一下卡在哪
- 學員問問題 → 先試圖讓他自己解決（「你貼錯誤訊息給 AI 看看」），真的不行再直接出手

**不要**：
- 直接接過鍵盤幫學員打字（把控制權還給他們）
- 講太多統計理論（學員不需要懂，課程設計就不教）
- 讓學員陷在某個 chunk > 5 分鐘（直接幫他跳過，往前走比較重要）

### 中場休息

老師會宣布。你利用時間：
- 上廁所
- 跟其他助教 sync：哪些學員需要關注
- 補水

### 收尾段落：part 5 是真正重點

Part 5「換你院內資料」是工作坊**核心 deliverable**。學員到這時應該已經疲倦，但這段最有價值。
你的任務是讓他們**感受到**「換 csv 就能跑出新 paper」這個身體記憶。

如果有學員開始想「我能不能用我們醫院的資料現在試試看」——**鼓勵他**，但提醒他資料保護（不要在公開的 Posit.Cloud 上傳真實病人資料）。

---

## 4. 五個最常見場景 & 你的腳本

### 場景 A：學員的 chunk 跑不起來，紅字一片

**腳本**：
> 「先別急，你把這個錯誤訊息整段選起來，加上『請幫我看這個錯誤是什麼意思，怎麼修』，貼給 ChatGPT。AI 通常很會看錯誤訊息。」

讓他自己問。如果 AI 回的解法有問題，你再介入。

### 場景 B：學員跑出來的數字跟 paper 不一樣

**腳本**：
> 「我們的資料是模擬的，不是 paper 的原始資料。**方向**對就好（faricimab 在 SRF absence 比 aflibercept 高、CST 降得多）。差個 1–2% 是隨機浮動。」

如果差距很大（>5%），檢查他是否用錯資料（mh_baseline 而非 baseline 之類）。

### 場景 C：學員在問統計細節「為什麼要 unstructured covariance」

**腳本**：
> 「翻 Appendix E。這份教材設計上不教統計原理，重點是『讓 AI 跑得動，自己看得懂結果』。原理感興趣下次找老師約 office hour。」

不要陷入統計討論，會耽誤其他學員。

### 場景 D：學員 install.r 跑不完 / 報錯

**腳本**：
> 「先試 `source("install.r")` 重跑一次，pak 會跳過已經裝好的。如果還是不行，我們改走網頁版（gold → silver/bronze fallback）。」

**判斷**：如果重跑兩次仍失敗，直接讓他切到 🥉 GH Pages，跟旁邊同學共用螢幕。**不要 burn 30 分鐘 debug 一個 install**。

### 場景 E：中文亂碼 / □□□□

**腳本**：
> 「這個是 ggplot 中文字型問題。每章開頭都要有 `source("_common.R")` 那行，會自動載入中文字型。你檢查 chunk 1 是不是有跑到。」

通常重跑 setup chunk 就好。

---

## 5. 升級路徑（escalation）

| 嚴重度 | 例子 | 找誰 |
|---|---|---|
| 🟢 個別學員卡 | 一個人 install 失敗 | 你自己處理，5 分鐘內判斷 fallback |
| 🟡 多人同症狀 | 三個人 mmrm 都裝不起來 | 群組 ping 其他助教 + 老師，可能要全班一起切 fallback |
| 🟠 全班連不上 Posit.Cloud | Posit.Cloud 服務中斷 | 老師喊「全班切 GH Pages 純讀」，所有助教協助學員打開瀏覽器 |
| 🔴 老師 / Roche 端被找麻煩 | 學員問醫療廣告 / Roche policy 相關 | 直接找老師，不要自己回 |

---

## 6. 通訊頻道

| 頻道 | 用途 |
|---|---|
| 助教 Telegram 群 | 課堂中即時 sync（會在開場前建立） |
| 講師 + Roche 對口群 | 跨機構協調，助教不用看 |

**規則**：
- 發到群組的訊息**精簡**：「3 號桌的學員在 mmrm 那邊卡了」就好
- 不要發整段 traceback——直接走過去看比較快

---

## 7. 課後

- 下課後留 10 分鐘給「想多問一下」的學員
- 把今天遇到的坑、常見問題、學員回饋寫進**今天的助教 retro**（群組訊息就好）
- 老師會在 1 週內整理出來更新 FAQ / appendix

---

## 8. 你不必負責的事

明確列出來，免得負擔太大：

- ❌ 你不必教完美的 R 語法
- ❌ 你不必證明 MMRM 的數學推導
- ❌ 你不必幫學員寫他自己的 paper
- ❌ 你不必處理 Roche 商業 / 法規問題（找老師）
- ❌ 你不必 stay 到所有人都跑完 Part 6（Bonus 章節，沒做完沒關係）

---

## 9. 一句話總結

> **學員的「卡關」是常態，「卡到放棄」才是失敗。**
> 你的工作是讓「放棄」這件事不發生——所以 fallback 永遠優先於完美解。

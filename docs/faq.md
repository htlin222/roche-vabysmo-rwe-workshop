# FAQ：常見問題集

> 5/30 眼科醫師研究工作坊
> 學員、助教、老師通用。出問題先翻這份。

---

## 🚦 環境 / 上手

### Q1. 我需要先安裝什麼嗎？

**短答**：不用。整堂課都在瀏覽器（Posit.Cloud）跑。

**長答**：理想路線是老師工作坊前一晚會給你「**預烤好的 Posit.Cloud 連結**」，你點 → Save a Permanent Copy → 5 秒進到一份套件已裝好的 RStudio。完全零安裝。

### Q2. Posit.Cloud 是什麼？要付錢嗎？

「在瀏覽器裡跑的 RStudio」。你不用裝任何東西，打開網頁就有完整 R 環境。
**免費 tier 25 hr/月**，工作坊一個下午用得完還剩。下課想長期使用可以升級 Cloud Plus（$5/月）或匯出到本機。

### Q3. 我從哪裡拿到工作坊連結？

老師會在開場前 30 分鐘發到群組（Telegram / Line / 工作坊網頁）。
拿不到？問身旁的助教或同學。**最後 fallback：直接用 GitHub URL** `https://github.com/htlin222/roche-vabysmo-rwe-workshop` 自己 fork。

### Q4. 預烤連結點進去說「Project not found」

預烤連結掛了。改走 🥈 路線：
1. Posit.Cloud → New Project → New Project from Git Repository
2. 貼 `https://github.com/htlin222/roche-vabysmo-rwe-workshop`
3. Console 跑 `source("install.r")`，等 5–10 分鐘
4. 然後跟原本流程一樣

### Q5. 我完全沒辦法弄 Posit.Cloud（網路 / 帳號 / 公司擋）

**🥉 純讀路線**：<https://htlin222.github.io/roche-vabysmo-rwe-workshop/>

整本書渲染好的版本，phone 也能讀。你看不到自己跑 code 的效果，但**內容都讀得到**。
建議跟旁邊的同學共用螢幕做 hands-on 部分——這課本來就是「複製貼上 prompt」，2 個人 1 個螢幕完全可行。

---

## 💻 R / RStudio 操作

### Q6. 怎麼跑 chunk？

`.qmd` 檔裡綠色 ▶ 按鈕，或游標在 chunk 內按 **Ctrl + Shift + Enter**（Mac: Cmd + Shift + Enter）。
單行：**Ctrl/Cmd + Enter**。

### Q7. 怎麼看 data frame？

```r
glimpse(baseline)   # 簡明欄位 + 型別
head(baseline)      # 前 6 列
View(baseline)      # 開 Excel 樣的查看視窗（推薦）
baseline            # 直接 print，會印很多
```

### Q8. Console 跑了一行什麼都沒發生

可能是：
- 還在跑（看左下角紅色 STOP icon）
- 等你打 enter（中括號 `>` 旁有 `+` 表示語法不完整）
- 跑完沒輸出（賦值 `x <- 1` 沒輸出是正常）

按 **ESC** 強制中止任何卡住的執行。

### Q9. 套件名稱拼錯了

例如 `library(ggplo2)` → 你會看到：
```
Error in library(ggplo2) : there is no package called ‘ggplo2’
```

修正：拼對 → `library(ggplot2)`。

把錯誤訊息整段貼給 AI，順便加「請告訴我我哪裡拼錯了」就行。

### Q10. 中文亂碼 / □□□□ / Tofu boxes

每章 qmd 開頭都有 `source("_common.R")`——如果你的 chunk 沒跑到那行，中文字型沒載入。
解法：執行 chunk 1（`setup-` 開頭那個）。

### Q11. RStudio 找不到我的檔案

確認 working directory 是 project 根目錄：

```r
getwd()   # 應該是 /cloud/project 或類似
list.files("data/")   # 應該看到 csv
```

如果不對，**Session → Set Working Directory → To Project Directory**。

---

## 🔁 換你院內資料

### Q12. 我可以用我們醫院的資料現場跑嗎？

**技術上可以**——把你的 csv 整成 [`data/data_dictionary.md`](../data/data_dictionary.md) 的 schema、放進 `data/`、改 part5 的檔名就跑得起來。

**但是**：
- ⚠️ 不要把真實病人資料上傳 Posit.Cloud（資料保護）
- ⚠️ IRB 沒過不要做 retrospective analysis
- ✅ 練習用：去識別化的少量 mock data 可以

最安全：**回院後** 在院內安全環境弄。Part 5 / 24 有 checklist。

### Q13. 我的院內 csv 應該長什麼樣？

[`data/data_dictionary.md`](../data/data_dictionary.md) 有完整 schema。最低必要欄位：

**baseline.csv**: `patient_id, arm, study, region, age, sex, bcva_baseline, cst_baseline, irf_baseline, srf_baseline, bcva_strat, lld_strat`

**followup.csv** (long format): `patient_id, week, bcva, cst, irf, srf`

### Q14. 我們院內沒有 LLD（low-luminance deficit）資料怎麼辦？

`lld_strat` 全填 `<33` 或刪掉這欄並從 model formula 拿掉 `lld_strat`。

---

## 📊 結果 / 對 paper

### Q15. 我跑出來的數字跟 paper 不一樣

**正常**。我們的資料是模擬的，不是 TENAYA/LUCERNE 的原始 raw data。
**方向對**就好——faricimab 應該在：

- BCVA：兩 arm 接近、faricimab 略高
- CST：faricimab 比 aflibercept 多降 ~12 μm
- IRF / SRF absence：faricimab 顯著高（特別是 SRF 與 both）

差個 1–2% 是模擬隨機。差 > 5% 才需要 debug（檢查是不是讀錯 csv）。

### Q16. 我的 confidence interval 比 paper 寬很多

只發生在 Part 5 換成 my_hospital.csv 時。**正常**：
- Trial n = 1329，CI ~ ±2 letters
- My hospital n = 180，CI ~ ±5–7 letters
- 大約寬 √(1329/180) ≈ **2.7 倍**

這就是為什麼院內 RWE 通常需要更多 patient / 多中心合作才能寫得像 paper。

### Q17. CMH 報錯說 stratum 太空

```
Error in mantelhaen.test(x) :
  'x' must contain at least one positive entry per stratum
```

n 不夠分散到 24 個 stratum。**解法**：合併分層因子，例如只留 `study × bcva_strat` 不要 `lld_strat × region`。Part 5 的 code 就是這麼做的。

### Q18. MMRM 跑不收斂 / 報 singular

n 太小 + unstructured covariance 太多 free parameter。降階：

```r
# 把 us(...) 改成 cs(...)（compound symmetry，更簡單的結構）
mmrm(... + cs(visit | patient_id), data = ...)
```

Part 5 的 code 已經有 try/catch fallback。

---

## 📚 概念 / 統計

### Q19. 什麼是 MMRM？

「同一隻眼睛被量很多次」的迴歸。詳細 ELI5：[Appendix E](../_book/appendix.html#e-eli5統計方法給門外漢的中文白話)。

### Q20. 什麼是 CMH？

把 24 個 stratum 的差異加權平均。詳細 ELI5：[Appendix E](../_book/appendix.html#g-cmh-weighted-proportion--cochran-mantel-haenszel-加權比例)。

### Q21. 什麼是 hazard ratio？

「兩組事件發生的瞬間速率比」。HR = 1.47 表示 faricimab 比 aflibercept 早達標 47%。詳細 ELI5：[Appendix E](../_book/appendix.html)。

### Q22. nominal P 和一般 P 有差嗎？

「nominal P」= 沒做多重比較校正的 p。post-hoc / exploratory 分析常用，**不能拿來做 confirmatory 結論**。Paper 也是這樣標的。

### Q23. 為什麼用 ETDRS letters，不是「視力 0.x」？

ETDRS letter chart 是國際標準（每行 5 letter），分數連續、適合做統計分析。
換算：~85 letters ≈ 6/6（1.0）；~70 letters ≈ 6/12（0.5）；~55 letters ≈ 6/30（0.2）。

---

## ✍️ 寫成 paper

### Q24. 我跑出院內結果，下一步怎麼寫成 paper？

Part 5 / 任務 24 的 checklist。簡版：

1. IRB 申請（retrospective chart review，通常 expedited）
2. 找院內 IT 撈 cohort（[`data_dictionary.md`](../data/data_dictionary.md) 是規格書）
3. 跑本書 pipeline，render `_book/`
4. Methods 段直接照本書的 Stat Analysis 寫
5. 找 Shao 看 draft

### Q25. 可以投 Ophthalmology / Retina 嗎？

Single-center RWE n=100–200 通常不到 Ophthalmology 主刊接受門檻，但：
- *Eye and Vision*、*BMC Ophthalmology*、*Clinical Ophthalmology* 是合理目標
- 多中心合作把 n 拉到 500+ 就有機會挑戰主刊
- 投 *Asia Pacific Journal of Ophthalmology* 也可以

### Q26. Roche 會幫忙 / 干涉嗎？

工作坊本身是 Roche 贊助的教學。Shao 可以給 methodology / writing 建議。
**Roche 不會干涉你的研究結論**——你做出 faricimab 沒比較好的結果，仍然投得出去。

---

## 🛟 真的卡住的時候

### Q27. 上面都試過還是不行

依序試：
1. 重整瀏覽器
2. Posit.Cloud → File → New File → Restart R Session
3. 整個 close、重開 Posit.Cloud project
4. 切到 🥉 GH Pages 純讀路線
5. 找助教 / 老師

### Q28. 我下課回家，發現之前的 project 不見了

Posit.Cloud free tier 有 idle policy。對策：
- 下課前點 **Save a Permanent Copy** 到自己帳號
- 或匯出 zip：右下 More → Export Project to ZIP
- 或 git push 到自己的 GitHub

### Q29. 我想問更深的問題

下課後留下來，或寫 mail 給林協霆 / Shao 約 office hour。

---

## 📞 對口

| 角色 | 找誰 |
|---|---|
| 講師 / 教材 | 林協霆 |
| Roche / RWE 方法 | Shao Shih-Chieh（邵時傑），shih-chieh.shao@roche.com |
| 助教 | 工作坊現場、Telegram 群組 |
| 教材 bug | <https://github.com/htlin222/roche-vabysmo-rwe-workshop/issues> |

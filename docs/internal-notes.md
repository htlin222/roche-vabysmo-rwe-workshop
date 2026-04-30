# Roche Vabysmo 眼科 RWE 工作坊

Roche / Shao Shih-Chieh (Principal Data Scientist, RWE) 邀請的眼科 RWE 教學案。
主題：**「如何讓你的 Vabysmo RWE 長得像 Ophthalmology 論文」**

## 時程

| 日期 | 時間 (Asia/Taipei) | 事件 | 行事曆 |
|---|---|---|---|
| 2026-05-04 (一) | 21:00–21:30 | 林協霆醫師討論 (與 Shao 的行前 1:1) | ✅ 已建到 `生活` |
| 2026-05-30 (六) | — | 眼科醫師研究工作坊 (主課，原訂 5/16 改期) | 待確認時間 |
| 2026-05-25 (一) | 20:00–21:00 | 羅氏眼科 RWE 行前會 (團隊彩排) | 待加 |

## 對口

- **Shao, Shih-Chieh**（邵時傑）— Principal Data Scientist, RWE, Roche Products Ltd. Taiwan
- Roche 團隊（不列名以保護 PII）

## Meet / Drive 連結

> 因為這是 public repo，行前會 Meet PINs、教材包 Drive folder 連結
> 不放這裡。連結保存在私人 vault，需要時跟林協霆要。

## 素材

- 教材包：Roche 內部 Google Drive（連結私下索取）
- 參考論文：`refs/tenaya-lucerne-paper.pdf` (Vabysmo TENAYA/LUCERNE 試驗，*Ophthalmology* 2025)

## 任務 (Shao 給的)

1. **AI 生模擬眼科資料集** — 因論文無 raw data，需用 AI 產出眼科 RWE 模擬檔，讓學員能跑出類似圖表。
2. **教材中要 cover 的特殊分析方法** (學員不必懂統計原理，只要產出結果)：
   - **MMRM** — Adjusted means for continuous endpoints, mixed model for repeated measures, unstructured covariance, missing data implicitly imputed (MAR).
   - **CMH-weighted averages** — Cochran-Mantel-Haenszel weighted, strata = study (TENAYA vs LUCERNE) × randomization factors.
3. 看 `00 課程目標` 與 `01 data`，協助設計。

## 信件來源

| 信箱 | ID | 主題 | 來源檔 |
|---|---|---|---|
| Work | 8291 | 5/16 眼科醫師研究工作坊教材討論 (含 paper attachment) | `emails/8291-5-16-workshop-spec.txt` |
| Work | 8293 | Re: 5/16 眼科醫師研究工作坊教材討論 | `emails/8293-5-16-workshop-followup.txt` |
| Work | 8512 | 教材包 Drive 分享通知 | `emails/8512-jiao-cai-bao-shared.txt` |
| Work | 8568 | 邀請：羅氏眼科 RWE 行前會 (5/25) | `emails/8568-5-25-rwe-prep-invite.txt` |

## 結構

```
.
├── README.md
├── emails/        # 4 封來自 Shao 的關鍵信件全文 (himalaya 抓的)
├── materials/     # 給工作坊產出的東西 (模擬資料集、jupyter notebook、ppt 等)
└── refs/          # 參考論文與外部素材
    └── tenaya-lucerne-paper.pdf
```

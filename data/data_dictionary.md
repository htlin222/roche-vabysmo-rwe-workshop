# 院內 csv schema（資料字典）

「下課後想做自己的 Vabysmo cohort」時，請你的院內 IT 把資料整理成下面這個樣子。
**欄位名稱、單位、編碼都對齊**，本書的程式碼就可以直接重跑。

---

## 兩份 csv

### 1. `your_baseline.csv`（一筆病人一列）

| 欄位 | 型別 | 範例 | 必須 | 說明 |
|---|---|---|---|---|
| `patient_id` | string | `PT-001` | ✅ | 院內去識別化編號（不要放真姓名 / 真病歷號） |
| `arm` | string | `faricimab` / `aflibercept` | ✅ | 治療組別。也可以放 `vabysmo` / `eylea` 這類藥名再 mutate 對齊 |
| `study` | string | `KFSYSCC-2024-01` | ✅ | 研究 / cohort 識別碼。本書範例用 `TENAYA` / `LUCERNE`，你可以填院名加年份 |
| `region` | string | `Asia-Pacific` | ✅ | 地理區。院內單一地區可以全填 `Asia-Pacific` |
| `age` | integer | `74` | ✅ | 用藥開始時的歲數 |
| `sex` | string | `F` / `M` | ✅ | 生理性別 |
| `bcva_baseline` | integer | `62` | ✅ | 用藥前 BCVA（ETDRS letters，0–100） |
| `cst_baseline` | integer | `345` | ✅ | 用藥前 OCT 中央視網膜厚度（μm） |
| `irf_baseline` | 0/1 | `0` | ✅ | 用藥前是否有 intraretinal fluid（1 = 有） |
| `srf_baseline` | 0/1 | `1` | ✅ | 用藥前是否有 subretinal fluid（1 = 有） |
| `bcva_strat` | string | `>=74` / `55-73` / `<=54` | ⚠️ | 由 `bcva_baseline` 派生。也可以讓 R 自動算 |
| `lld_strat` | string | `<33` / `>=33` | ⚠️ | low-luminance deficit 分層。沒量 LLD 可全填 `<33` 或刪掉這欄並調整 model |

### 2. `your_followup.csv`（同一病人多列，每次回診一列；long format）

| 欄位 | 型別 | 範例 | 必須 | 說明 |
|---|---|---|---|---|
| `patient_id` | string | `PT-001` | ✅ | 對應 baseline 的 id |
| `week` | integer | `4` | ✅ | 距用藥起始的週數。本書範例用 `4`/`8`/`12`，你的院內可以 `0`/`4`/`8`/`12` |
| `bcva` | integer | `66` | ⚠️ | 該次回診的 BCVA。沒量留空（`NA`）即可，MMRM 會自動處理 |
| `cst` | integer | `220` | ⚠️ | 該次回診的 CST |
| `irf` | 0/1 | `0` | ⚠️ | 該次 IRF 是否仍存在 |
| `srf` | 0/1 | `0` | ⚠️ | 該次 SRF 是否仍存在 |

> **⚠️ Missing 是 OK 的**。MMRM 預設假設 missing-at-random（病人沒回診的原因和未測得的數值無關），會自動 implicit imputation。CMH 對 missing 也容忍，但會降低 power。

---

## 編碼規則（很重要）

- **Boolean / binary** 一律用 `0` / `1`，不要 `Yes`/`No`、不要 `True`/`False`、不要中文「是」/「否」。
- **Missing** 在 csv 留空（`,,`），不要寫 `999`、`NULL`、`-`。
- **日期** 本書沒用，但若你想加：用 `YYYY-MM-DD` ISO 格式。
- **Encoding** 用 UTF-8。
- **欄位名稱** 全小寫加底線，不要空格、不要中文。

---

## 對齊本書範例的 quick check

```r
library(readr)
library(dplyr)

baseline <- read_csv("data/your_baseline.csv")
followup <- read_csv("data/your_followup.csv")

# 必要欄位都存在
required_baseline <- c("patient_id","arm","study","region","age","sex",
                       "bcva_baseline","cst_baseline","irf_baseline","srf_baseline")
stopifnot(all(required_baseline %in% names(baseline)))

required_followup <- c("patient_id","week","bcva","cst","irf","srf")
stopifnot(all(required_followup %in% names(followup)))

# 每個 followup id 都對得到 baseline id
stopifnot(all(followup$patient_id %in% baseline$patient_id))

cat("✅ schema 通過\n")
```

通過這段就 OK，可以拿到 part5 的 code 跑出你的版本。

# 專案層級 .Rprofile — 每次開啟 R session 自動執行。
# 把 repo 設成 PPM 預編譯 binary（Posit.Cloud = Ubuntu Noble），
# 讓「任何」安裝（install.packages() / pak / quarto 補裝）都走 binary、不再從原始碼編譯。
# 真正的邏輯在 setup/_repos.R（與 setup/install.r 共用同一份）。
if (file.exists("setup/_repos.R")) source("setup/_repos.R")

# 單一來源：依平台把 repo 設成「預編譯 binary」，所有安裝都免從原始碼編譯。
# 被 .Rprofile（每次開 R session 自動載入）與 setup/install.r 共用，避免兩邊設定漂移。
#   Linux（含 Posit.Cloud）→ PPM __linux__/<codename> binary repo（Posit.Cloud = Ubuntu 24.04 noble）
#   macOS / Windows        → CRAN-style latest 本身就回 binary
local({
  repo <- if (Sys.info()[["sysname"]] == "Linux" && file.exists("/etc/os-release")) {
    os   <- readLines("/etc/os-release", warn = FALSE)
    line <- grep("^VERSION_CODENAME=", os, value = TRUE)
    code <- if (length(line)) gsub('^VERSION_CODENAME=|"', "", line[1]) else ""
    if (is.na(code) || code == "") code <- "noble"   # fallback
    sprintf("https://packagemanager.posit.co/cran/__linux__/%s/latest", code)
  } else {
    "https://packagemanager.posit.co/cran/latest"
  }
  options(repos = c(CRAN = repo))
  # 讓 PPM 依 R 版本回傳對應的 Linux binary
  options(HTTPUserAgent = sprintf(
    "R/%s R (%s)", getRversion(),
    paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])
  ))
  message(sprintf("[repos] %s", repo))
})

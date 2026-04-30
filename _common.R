# 全域設定 — 在每章 qmd 開頭 source 一次即可

suppressPackageStartupMessages({
  if (requireNamespace("showtext", quietly = TRUE)) {
    library(showtext)
    if (requireNamespace("sysfonts", quietly = TRUE)) {
      tryCatch(
        {
          sysfonts::font_add_google("Noto Sans TC", "noto-sans-tc")
          showtext_auto()
        },
        error = function(e) {
          message("[_common.R] Google font 抓取失敗，後備：用系統字型。")
        }
      )
    }
  }
  library(ggplot2)
  library(dplyr)
})

# ggplot 全域 theme
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      strip.background = element_rect(fill = "grey95", colour = NA),
      strip.text = element_text(face = "bold")
    )
)

# Treatment arm 配色 — 模仿 paper：faricimab 紫、aflibercept 灰藍
arm_colours <- c(
  "faricimab"   = "#7B5CA8",
  "aflibercept" = "#7E9CB7"
)

# dplyr 輸出寬度
options(dplyr.print_min = 6, dplyr.print_max = 6)

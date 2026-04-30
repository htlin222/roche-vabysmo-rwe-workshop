#!/usr/bin/env Rscript
# scripts/02_mmrm_figure1.R
# Reproduces Figure 1 (MMRM on BCVA + CST) from part3.qmd, standalone.

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(tidyr)
  library(mmrm); library(emmeans)
  library(ggplot2); library(patchwork)
})

baseline <- read_csv("data/vabysmo_baseline.csv", show_col_types = FALSE)
followup <- read_csv("data/vabysmo_followup.csv", show_col_types = FALSE)

arm_colours <- c("faricimab" = "#7B5CA8", "aflibercept" = "#7E9CB7")

fu_long <- followup |>
  left_join(
    baseline |> select(patient_id, arm, study, region,
                       bcva_baseline, cst_baseline,
                       bcva_strat, lld_strat),
    by = "patient_id"
  ) |>
  mutate(
    bcva_change = bcva - bcva_baseline,
    cst_change  = cst - cst_baseline,
    visit       = factor(week, levels = c(4, 8, 12)),
    arm         = factor(arm, levels = c("aflibercept","faricimab")),
    study       = factor(study), bcva_strat = factor(bcva_strat),
    lld_strat   = factor(lld_strat), region = factor(region)
  )

m_bcva <- mmrm(
  bcva_change ~ arm + visit + arm:visit + study + bcva_strat + lld_strat +
    region + us(visit | patient_id),
  data = fu_long |> filter(!is.na(bcva_change))
)
m_cst <- mmrm(
  cst_change ~ arm + visit + arm:visit + study + bcva_strat + lld_strat +
    region + us(visit | patient_id),
  data = fu_long |> filter(!is.na(cst_change))
)

emm_b <- as.data.frame(emmeans(m_bcva, ~ arm | visit)) |>
  mutate(week = as.numeric(as.character(visit)))
emm_c <- as.data.frame(emmeans(m_cst, ~ arm | visit)) |>
  mutate(week = as.numeric(as.character(visit)))

baseline_zero <- function(df) bind_rows(
  data.frame(arm = c("aflibercept","faricimab"),
             week = 0, emmean = 0, lower.CL = 0, upper.CL = 0),
  df |> select(arm, week, emmean, lower.CL, upper.CL)
) |> arrange(arm, week)

p_b <- ggplot(baseline_zero(emm_b),
       aes(x = week, y = emmean, colour = arm, group = arm)) +
  geom_line(linewidth = 1) + geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.4) +
  scale_colour_manual(values = arm_colours, name = NULL) +
  scale_x_continuous(breaks = c(0,4,8,12)) +
  labs(title = "(A) BCVA", x = "Time (Weeks)",
       y = "Adj. Mean Change (Letters)") +
  theme_minimal() + theme(legend.position = "bottom")

p_c <- ggplot(baseline_zero(emm_c),
       aes(x = week, y = emmean, colour = arm, group = arm)) +
  geom_line(linewidth = 1) + geom_point(size = 3) +
  geom_errorbar(aes(ymin = lower.CL, ymax = upper.CL), width = 0.4) +
  scale_colour_manual(values = arm_colours, name = NULL) +
  scale_x_continuous(breaks = c(0,4,8,12)) +
  labs(title = "(B) CST", x = "Time (Weeks)",
       y = "Adj. Mean Change (μm)") +
  theme_minimal() + theme(legend.position = "bottom")

dir.create("_book", showWarnings = FALSE)
ggsave("_book/figure1_standalone.png",
       p_b + p_c + plot_layout(guides = "collect") &
         theme(legend.position = "bottom"),
       width = 11, height = 5, dpi = 150)

cat("\n[OK] Figure 1 saved to _book/figure1_standalone.png\n")
print(emm_b); print(emm_c)

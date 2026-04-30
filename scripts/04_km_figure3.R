#!/usr/bin/env Rscript
# scripts/04_km_figure3.R
# Reproduces Figure 3 (KM time-to-first-absence) from part6.qmd, standalone.

suppressPackageStartupMessages({
  library(readr); library(dplyr)
  library(survival); library(survminer); library(broom)
})

baseline <- read_csv("data/vabysmo_baseline.csv", show_col_types = FALSE)
followup <- read_csv("data/vabysmo_followup.csv", show_col_types = FALSE)

elig <- baseline |>
  filter(irf_baseline == 1 | srf_baseline == 1) |>
  select(patient_id, arm)

tte <- followup |>
  filter(patient_id %in% elig$patient_id) |>
  mutate(both_absent = (irf == 0 & srf == 0)) |>
  group_by(patient_id) |>
  arrange(week) |>
  summarise(
    first_event_week = suppressWarnings(
      min(week[!is.na(both_absent) & both_absent])
    ),
    last_visit_week  = suppressWarnings(
      max(week[!is.na(both_absent)])
    ),
    .groups = "drop"
  ) |>
  mutate(
    event = is.finite(first_event_week),
    time  = if_else(event, first_event_week, last_visit_week),
    time  = if_else(is.infinite(time), 12, time)
  ) |>
  left_join(elig, by = "patient_id") |>
  mutate(arm = factor(arm, levels = c("aflibercept","faricimab")))

cat("\nEligible n:", nrow(tte),
    "  (faricimab:", sum(tte$arm == "faricimab"),
    "  aflibercept:", sum(tte$arm == "aflibercept"), ")\n")

fit_km <- survfit(Surv(time, event) ~ arm, data = tte)
print(fit_km)

m_cox <- coxph(Surv(time, event) ~ arm, data = tte)
print(summary(m_cox))

cat("\nHR (faricimab vs aflibercept):\n")
tidy(m_cox, exponentiate = TRUE, conf.int = TRUE) |>
  filter(grepl("^arm", term)) |>
  print()

dir.create("_book", showWarnings = FALSE)
plt <- ggsurvplot(
  fit_km, data = tte, fun = "event",
  conf.int = TRUE, risk.table = TRUE, risk.table.height = 0.25,
  palette = c("#7E9CB7","#7B5CA8"),
  legend.labs = c("Aflibercept","Faricimab"),
  xlab = "Time (Weeks)", ylab = "Cumulative Incidence",
  break.time.by = 4
)

png("_book/figure3_standalone.png", width = 8 * 150, height = 6 * 150, res = 150)
print(plt)
dev.off()

cat("\n[OK] Figure 3 saved to _book/figure3_standalone.png\n")

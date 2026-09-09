source("sample-trajectories.R")

dir.create("logs", recursive = TRUE, showWarnings = FALSE)
saveRDS(
  vp_sample_trajectories(),
  file.path("logs", "vp-sample-trajectories.rds")
)

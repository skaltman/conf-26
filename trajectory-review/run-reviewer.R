pkgload::load_all(
  "../../../rstudio/commons/pkg-r",
  export_all = FALSE,
  quiet = TRUE
)
source("sample-trajectories.R")

review_dir <- normalizePath("reviews", mustWork = FALSE)
dir.create(review_dir, recursive = TRUE, showWarnings = FALSE)

shiny::runApp(
  commons::trajectory_review(
    vp_sample_trajectories(),
    review_dir = review_dir
  ),
  host = "127.0.0.1",
  port = 8766,
  launch.browser = FALSE
)

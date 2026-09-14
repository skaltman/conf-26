record_tlg_demos <- function(
  url = Sys.getenv(
    "TLG_AGENT_URL",
    unset = "http://127.0.0.1:8766"
  ),
  output_dir = "figures/raw",
  viewport_width = 2400,
  viewport_height = 1350,
  slugs = c("table", "plot", "custom-code")
) {
  source("demos/vp-agent/record-demos.R")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  demos <- list(
    list(
      slug = "table",
      question = "Show an adverse event overview by treatment arm.",
      marker = 'button[aria-label="Verified answer"]',
      expand_measure_details = TRUE,
      hover_marker = FALSE,
      hover_source = TRUE
    ),
    list(
      slug = "plot",
      question = paste(
        "Plot time to first serious adverse event by treatment arm for the",
        "safety population."
      ),
      marker = 'button[aria-label="Verified answer"]',
      scroll_result = TRUE,
      hover_marker = FALSE
    ),
    list(
      slug = "custom-code",
      question = paste(
        "How many patients in each treatment arm experienced more than 5",
        "adverse events? Please quote the exact counts."
      ),
      marker = "button.shiny-aside-pill",
      tool_call = "Retrieved data",
      close_tool_call = FALSE,
      scroll_result = TRUE,
      hover_marker = FALSE
    )
  )

  available_slugs <- vapply(demos, `[[`, character(1), "slug")
  unknown_slugs <- setdiff(slugs, available_slugs)
  if (length(unknown_slugs) > 0) {
    cli::cli_abort(
      "{.arg slugs} contains unknown demo names: {.or {.val {unknown_slugs}}}."
    )
  }
  demos <- Filter(\(demo) demo$slug %in% slugs, demos)

  outputs <- character(length(demos))
  for (i in seq_along(demos)) {
    demo <- demos[[i]]
    cli::cli_inform("Recording the {.field {demo$slug}} demo.")
    outputs[[i]] <- record_demo(
      slug = demo$slug,
      question = demo$question,
      marker = demo$marker,
      tool_call = demo$tool_call,
      close_tool_call = if (is.null(demo$close_tool_call)) {
        TRUE
      } else {
        demo$close_tool_call
      },
      expand_result = isTRUE(demo$expand_result),
      expand_measure_details = isTRUE(demo$expand_measure_details),
      scroll_result = isTRUE(demo$scroll_result),
      hover_marker = if (is.null(demo$hover_marker)) {
        TRUE
      } else {
        demo$hover_marker
      },
      hover_source = isTRUE(demo$hover_source),
      url = url,
      output_dir = output_dir,
      output_prefix = "tlg-agent",
      viewport_width = viewport_width,
      viewport_height = viewport_height
    )
  }

  cli::cli_inform(c("Recordings created:", "*" = outputs))
  invisible(outputs)
}

if (sys.nframe() == 0L) {
  record_tlg_demos()
}

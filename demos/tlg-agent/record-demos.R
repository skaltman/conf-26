record_tlg_demos <- function(
  url = Sys.getenv(
    "TLG_AGENT_URL",
    unset = "http://127.0.0.1:8766"
  ),
  output_dir = "figures"
) {
  source("demos/vp-agent/record-demos.R")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  demos <- list(
    list(
      slug = "table",
      question = "Show an adverse event overview by treatment arm.",
      marker = 'button[aria-label="Verified answer"]',
      expand_result = TRUE
    ),
    list(
      slug = "plot",
      question = paste(
        "Plot the percentage of patients with adverse events by system organ",
        "class and treatment arm."
      ),
      marker = 'button[aria-label="Verified answer"]'
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
      hover_marker = FALSE
    )
  )

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
      hover_marker = if (is.null(demo$hover_marker)) {
        TRUE
      } else {
        demo$hover_marker
      },
      url = url,
      output_dir = output_dir,
      output_prefix = "tlg-agent"
    )
  }

  cli::cli_inform(c("Recordings created:", "*" = outputs))
  invisible(outputs)
}

if (sys.nframe() == 0L) {
  record_tlg_demos()
}

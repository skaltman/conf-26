record_trajectory_review <- function(
  url = "http://127.0.0.1:8766",
  output = "../../figures/vp-agent-trajectory-review.mp4"
) {
  frame_dir <- tempfile("trajectory-review-")
  dir.create(frame_dir)
  on.exit(unlink(frame_dir, recursive = TRUE), add = TRUE)

  state <- new.env(parent = emptyenv())
  state$files <- character()
  state$times <- numeric()
  state$frame_dir <- frame_dir

  browser <- chromote::ChromoteSession$new()
  on.exit(browser$close(), add = TRUE)
  browser$set_viewport_size(1400, 850)
  browser$go_to(url)
  wait_for_review_entry(browser)

  browser$Page$screencastFrame(callback_ = function(message) {
    capture_screencast_frame(message, state, browser)
  })
  browser$Page$startScreencast(
    format = "jpeg",
    quality = 90,
    maxWidth = 1400,
    maxHeight = 850,
    everyNthFrame = 1
  )

  pump_browser(2)
  click_review_target(browser, "#entry_2_1")
  pump_browser(3)
  click_review_target(browser, "#flag_toggle")
  pump_browser(1.5)
  browser$Runtime$evaluate(
    paste0(
      'const note = document.querySelector("#review_note");',
      'note.value = "Promote this recurring question to a trusted calculation.";',
      'note.dispatchEvent(new Event("input", {bubbles: true}));'
    )
  )
  pump_browser(1)
  click_review_target(browser, 'button[aria-label="Add note"]')
  pump_browser(3)
  capture_final_frame(browser, state)
  browser$Page$stopScreencast()
  pump_browser(0.2)

  encode_recording(state$files, state$times, output, final_hold = 3)
  normalizePath(output)
}

wait_for_review_entry <- function(
  browser,
  timeout = 20,
  call = rlang::caller_env()
) {
  started <- Sys.time()
  repeat {
    ready <- browser$Runtime$evaluate(
      '!!document.querySelector("#entry_2_1")',
      returnByValue = TRUE
    )$result$value
    if (isTRUE(ready)) {
      return(invisible())
    }
    if (elapsed_seconds(started) > timeout) {
      cli::cli_abort(
        "The trajectory review entries did not become ready.",
        call = call
      )
    }
    pump_browser(0.1)
  }
}

click_review_target <- function(
  browser,
  selector,
  call = rlang::caller_env()
) {
  clicked <- browser$Runtime$evaluate(
    sprintf(
      paste0(
        "(() => {",
        "const target = document.querySelector(%s);",
        "if (!target) return false;",
        "target.click();",
        "return true;",
        "})()"
      ),
      jsonlite::toJSON(selector, auto_unbox = TRUE)
    ),
    returnByValue = TRUE
  )$result$value
  if (!isTRUE(clicked)) {
    cli::cli_abort(
      "Could not find review target {.code {selector}}.",
      call = call
    )
  }
  invisible()
}

source("../vp-agent/record-demos.R")

cat(record_trajectory_review(), "\n")

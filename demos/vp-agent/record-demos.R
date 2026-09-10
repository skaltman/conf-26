record_vp_demos <- function(
  url = "http://127.0.0.1:8765",
  output_dir = "figures"
) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  demos <- list(
    list(
      slug = "trusted",
      question = "How is traffic trending for our site?",
      marker = 'button[aria-label="Verified answer"]'
    ),
    list(
      slug = "custom-query",
      question = "Which day had the most site visits?",
      marker = 'button[aria-label="Untrusted"]'
    ),
    list(
      slug = "context",
      question = paste(
        "Why are pageview events falling while site visits are rising?"
      ),
      marker = 'button[aria-label="documentation"]',
      tool_call = "Searched context"
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
      url = url,
      output_dir = output_dir
    )
  }

  cli::cli_inform(c("Recordings created:", "*" = outputs))
  invisible(outputs)
}

record_demo <- function(
  slug,
  question,
  marker,
  tool_call = NULL,
  close_tool_call = TRUE,
  expand_result = FALSE,
  scroll_result = FALSE,
  hover_marker = TRUE,
  url,
  output_dir,
  output_prefix = "vp-agent",
  call = rlang::caller_env()
) {
  frame_dir <- tempfile(paste0(output_prefix, "-", slug, "-"))
  dir.create(frame_dir)
  on.exit(unlink(frame_dir, recursive = TRUE), add = TRUE)

  state <- new.env(parent = emptyenv())
  state$files <- character()
  state$times <- numeric()
  state$frame_dir <- frame_dir

  browser <- chromote::ChromoteSession$new()
  on.exit(browser$close(), add = TRUE)
  browser$set_viewport_size(1200, 766)
  browser$go_to(paste0(url, "?recording=", slug))
  wait_for_chat_input(browser, call = call)

  browser$Page$screencastFrame(
    callback_ = function(message) {
      capture_screencast_frame(message, state, browser)
    }
  )
  invisible(browser$Page$startScreencast(
    format = "jpeg",
    quality = 90,
    maxWidth = 1200,
    maxHeight = 766,
    everyNthFrame = 1
  ))

  pump_browser(1.25)
  type_question(browser, question)
  pump_browser(0.4)
  click_send(browser)
  wait_for_answer(browser, marker, call = call)
  pump_browser(0.75)

  if (!is.null(tool_call)) {
    click_tool_call(browser, tool_call, call = call)
    pump_browser(1.5)
    capture_final_frame(browser, state, hold = 2)
    pump_browser(0.5)
    if (close_tool_call) {
      click_tool_call(browser, tool_call, call = call)
      pump_browser(0.5)
    }
  }

  if (expand_result) {
    toggle_full_screen_result(browser, call = call)
    pump_browser(2)
    capture_final_frame(browser, state, hold = 2)
    pump_browser(0.5)
    toggle_full_screen_result(browser, expanded = TRUE, call = call)
    pump_browser(0.5)
  }

  if (hover_marker) {
    hover_element(browser, marker, call = call)
    pump_browser(2.5)
  }
  if (scroll_result) {
    scroll_tool_card_result(browser, call = call)
    pump_browser(2)
  }
  capture_final_frame(browser, state)
  invisible(browser$Page$stopScreencast())
  pump_browser(0.2)

  if (length(state$files) < 10L) {
    cli::cli_abort(
      "The {.field {slug}} recording captured too few frames.",
      call = call
    )
  }

  output <- file.path(
    output_dir,
    paste0(output_prefix, "-", slug, ".mp4")
  )
  encode_recording(state$files, state$times, output, call = call)
  normalizePath(output)
}

capture_screencast_frame <- function(message, state, browser) {
  save_frame(message$data, message$metadata$timestamp, state)
  browser$Page$screencastFrameAck(message$sessionId, wait_ = FALSE)
  invisible()
}

save_frame <- function(data, timestamp, state) {
  index <- length(state$files) + 1L
  path <- file.path(state$frame_dir, sprintf("frame-%05d.jpg", index))
  writeBin(base64enc::base64decode(data), path)
  state$files <- c(state$files, path)
  state$times <- c(state$times, timestamp)
  invisible()
}

capture_final_frame <- function(browser, state, hold = NULL) {
  screenshot <- browser$Page$captureScreenshot(
    format = "jpeg",
    quality = 90
  )
  timestamp <- if (length(state$times)) {
    tail(state$times, 1) + 1 / 30
  } else {
    as.numeric(Sys.time())
  }
  save_frame(screenshot$data, timestamp, state)
  if (!is.null(hold)) {
    save_frame(screenshot$data, timestamp + hold, state)
  }
}

wait_for_chat_input <- function(
  browser,
  timeout = 20,
  call = rlang::caller_env()
) {
  started <- Sys.time()
  repeat {
    ready <- browser$Runtime$evaluate(
      '!!document.querySelector("[aria-label=\\"Chat message\\"]")',
      returnByValue = TRUE
    )$result$value
    if (isTRUE(ready)) {
      return(invisible())
    }
    if (elapsed_seconds(started) > timeout) {
      cli::cli_abort("The chat input did not become ready.", call = call)
    }
    pump_browser(0.1)
  }
}

type_question <- function(browser, question) {
  invisible(browser$Runtime$evaluate(
    'document.querySelector("[aria-label=\\"Chat message\\"]").focus()',
    returnByValue = TRUE
  ))

  characters <- strsplit(question, "", fixed = TRUE)[[1]]
  for (character in characters) {
    browser$Input$insertText(text = character)
    pump_browser(0.04)
  }
}

click_send <- function(browser) {
  invisible(browser$Runtime$evaluate(
    paste0(
      'document.querySelector(',
      '"button[aria-label=\\"Send message\\"]"',
      ").click()"
    ),
    returnByValue = TRUE
  ))
}

click_tool_call <- function(
  browser,
  label,
  call = rlang::caller_env()
) {
  click_element(
    browser,
    ".shiny-chat-tool-group__row",
    text = label,
    call = call
  )
}

toggle_full_screen_result <- function(
  browser,
  expanded = FALSE,
  call = rlang::caller_env()
) {
  label <- if (expanded) "Exit fullscreen" else "Expand card"
  click_element(
    browser,
    sprintf('button[aria-label="%s"]', label),
    call = call
  )
}

scroll_tool_card_result <- function(
  browser,
  call = rlang::caller_env()
) {
  scrolled <- browser$Runtime$evaluate(
    paste0(
      "(() => {",
      "const card = document.querySelector('.shiny-tool-card');",
      "const body = card?.querySelector(':scope > .card-body');",
      "if (!card || !body) return false;",
      "if (body.scrollHeight <= body.clientHeight) {",
      "body.style.maxHeight = '380px';",
      "body.style.overflow = 'auto';",
      "}",
      "body.scrollTo({top: body.scrollHeight});",
      "card.scrollIntoView({block: 'center'});",
      "return true;",
      "})()"
    ),
    returnByValue = TRUE
  )$result$value

  if (!isTRUE(scrolled)) {
    cli::cli_abort(
      "Could not scroll the requested demo result into view.",
      call = call
    )
  }

  invisible()
}

click_element <- function(
  browser,
  selector,
  text = NULL,
  call = rlang::caller_env()
) {
  center <- element_center(
    browser,
    selector,
    text = text,
    call = call
  )
  move_mouse(browser, center)
  pump_browser(0.25)
  browser$Input$dispatchMouseEvent(
    type = "mousePressed",
    x = center$x,
    y = center$y,
    button = "left",
    clickCount = 1
  )
  browser$Input$dispatchMouseEvent(
    type = "mouseReleased",
    x = center$x,
    y = center$y,
    button = "left",
    clickCount = 1
  )
  invisible()
}

hover_element <- function(
  browser,
  selector,
  call = rlang::caller_env()
) {
  center <- element_center(browser, selector, call = call)
  move_mouse(browser, center)
  invisible()
}

element_center <- function(
  browser,
  selector,
  text = NULL,
  call = rlang::caller_env()
) {
  script <- sprintf(
    paste0(
      "(() => {",
      "const elements = Array.from(document.querySelectorAll(%s));",
      "const text = %s;",
      "const element = elements.find((candidate) => ",
      "text === null || candidate.textContent.trim() === text);",
      "if (!element) return null;",
      "element.scrollIntoView({block: 'center', inline: 'center'});",
      "const rect = element.getBoundingClientRect();",
      "return {x: rect.left + rect.width / 2, ",
      "y: rect.top + rect.height / 2};",
      "})()"
    ),
    jsonlite::toJSON(selector, auto_unbox = TRUE),
    jsonlite::toJSON(text, auto_unbox = TRUE, null = "null")
  )
  center <- browser$Runtime$evaluate(
    script,
    returnByValue = TRUE
  )$result$value

  if (is.null(center)) {
    cli::cli_abort(
      "Could not find the requested demo interaction target.",
      call = call
    )
  }

  center
}

move_mouse <- function(browser, center) {
  browser$Input$dispatchMouseEvent(
    type = "mouseMoved",
    x = center$x,
    y = center$y
  )
  invisible()
}

wait_for_answer <- function(
  browser,
  marker,
  timeout = 120,
  stable_for = 1.5,
  call = rlang::caller_env()
) {
  started <- Sys.time()
  last_change <- started
  previous <- ""

  repeat {
    state <- browser$Runtime$evaluate(
      sprintf(
        "({text: document.body.innerText, marked: !!document.querySelector(%s)})",
        jsonlite::toJSON(marker, auto_unbox = TRUE)
      ),
      returnByValue = TRUE
    )$result$value

    if (!identical(state$text, previous)) {
      previous <- state$text
      last_change <- Sys.time()
    }
    if (isTRUE(state$marked) && elapsed_seconds(last_change) >= stable_for) {
      return(invisible())
    }
    if (elapsed_seconds(started) > timeout) {
      cli::cli_abort(
        "Timed out waiting for the final provenance marker.",
        call = call
      )
    }
    pump_browser(0.15)
  }
}

pump_browser <- function(seconds) {
  deadline <- Sys.time() + seconds
  while (Sys.time() < deadline) {
    later::run_now(0.02)
    Sys.sleep(0.02)
  }
  invisible()
}

elapsed_seconds <- function(started) {
  as.numeric(difftime(Sys.time(), started, units = "secs"))
}

encode_recording <- function(
  files,
  timestamps,
  output,
  final_hold = 2,
  call = rlang::caller_env()
) {
  keep <- !duplicated(timestamps)
  files <- files[keep]
  timestamps <- timestamps[keep]

  durations <- diff(timestamps)
  durations[!is.finite(durations) | durations <= 0] <- 1 / 30
  durations <- pmin(pmax(durations, 1 / 30), 1)

  manifest <- tempfile(fileext = ".txt")
  on.exit(unlink(manifest), add = TRUE)

  lines <- character()
  for (i in seq_along(durations)) {
    lines <- c(
      lines,
      sprintf("file '%s'", normalizePath(files[[i]])),
      sprintf("duration %.6f", durations[[i]])
    )
  }
  final_file <- normalizePath(tail(files, 1))
  lines <- c(
    lines,
    sprintf("file '%s'", final_file),
    sprintf("duration %.6f", final_hold),
    sprintf("file '%s'", final_file)
  )
  writeLines(lines, manifest)

  status <- system2(
    "ffmpeg",
    c(
      "-y",
      "-loglevel",
      "error",
      "-f",
      "concat",
      "-safe",
      "0",
      "-i",
      shQuote(manifest),
      "-vf",
      "fps=30,format=yuv420p",
      "-an",
      "-c:v",
      "libx264",
      "-preset",
      "medium",
      "-crf",
      "20",
      "-movflags",
      "+faststart",
      shQuote(output)
    )
  )
  if (!identical(status, 0L)) {
    cli::cli_abort("FFmpeg failed to encode {.file {output}}.", call = call)
  }
  invisible()
}

if (sys.nframe() == 0L) {
  record_vp_demos()
}

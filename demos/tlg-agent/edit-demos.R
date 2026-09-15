edit_tlg_demos <- function(
  raw_dir = "figures/raw",
  output_dir = "figures",
  preset = "medium",
  crf = 20,
  slugs = c("table", "plot", "custom-analysis")
) {
  specs <- tlg_demo_edit_specs()
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  available_slugs <- vapply(specs, `[[`, character(1), "output_slug")
  unknown_slugs <- setdiff(slugs, available_slugs)
  if (length(unknown_slugs) > 0) {
    cli::cli_abort(
      "{.arg slugs} contains unknown demo names: {.or {.val {unknown_slugs}}}."
    )
  }
  specs <- Filter(\(spec) spec$output_slug %in% slugs, specs)

  outputs <- character(length(specs))
  for (i in seq_along(specs)) {
    spec <- specs[[i]]
    input <- file.path(raw_dir, paste0("tlg-agent-", spec$raw_slug, ".mp4"))
    output <- file.path(
      output_dir,
      paste0("tlg-agent-", spec$output_slug, "-demo.mp4")
    )
    cli::cli_inform("Editing the {.field {spec$output_slug}} demo.")
    edit_tlg_demo(
      input,
      output,
      spec$segments,
      spec$keyframes,
      preset = preset,
      crf = crf
    )
    outputs[[i]] <- normalizePath(output)
  }

  names(outputs) <- vapply(specs, `[[`, character(1), "output_slug")
  cli::cli_inform(c("Edited recordings created:", "*" = outputs))
  invisible(outputs)
}

stitch_tlg_demos <- function(
  # The talk shows the adverse-event table followed by the validated
  # Kaplan-Meier plot, ending shortly after the plot zooms out.
  inputs = c(
    "figures/tlg-agent-table-demo.mp4",
    "figures/tlg-agent-plot-demo.mp4"
  ),
  output = "figures/clinical-trials-agent-demo.mp4",
  duration = 37.87,
  cuts = data.frame(
    start = 9,
    end = 21.633333
  ),
  preset = "slow",
  crf = 18,
  call = rlang::caller_env()
) {
  missing_inputs <- inputs[!file.exists(inputs)]
  if (length(missing_inputs) > 0) {
    cli::cli_abort(
      "Cannot stitch missing recordings: {.or {.file {missing_inputs}}}.",
      call = call
    )
  }
  if (
    !is.null(duration) &&
      (length(duration) != 1L || !is.finite(duration) || duration <= 0)
  ) {
    cli::cli_abort(
      "{.arg duration} must be a single positive number or {.code NULL}.",
      call = call
    )
  }
  cuts <- validate_tlg_demo_cuts(cuts, duration, call = call)

  manifest <- tempfile(fileext = ".txt")
  on.exit(unlink(manifest), add = TRUE)
  writeLines(
    sprintf("file '%s'", normalizePath(inputs)),
    manifest
  )
  duration_args <- if (is.null(duration)) {
    character()
  } else {
    c("-t", format_number(duration))
  }
  stitched_output <- if (nrow(cuts) > 0) {
    tempfile(fileext = ".mp4")
  } else {
    output
  }
  if (!identical(stitched_output, output)) {
    on.exit(unlink(stitched_output), add = TRUE)
  }

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
      duration_args,
      "-an",
      "-c",
      "copy",
      "-movflags",
      "+faststart",
      shQuote(stitched_output)
    )
  )
  if (!identical(status, 0L)) {
    cli::cli_abort(
      "FFmpeg failed to stitch {.file {output}}.",
      call = call
    )
  }
  if (nrow(cuts) > 0) {
    remove_tlg_demo_ranges(
      stitched_output,
      output,
      cuts,
      duration,
      preset,
      crf,
      call = call
    )
  }

  normalizePath(output)
}

edit_tlg_demo <- function(
  input,
  output,
  segments,
  keyframes,
  preset,
  crf,
  input_range = "full",
  call = rlang::caller_env()
) {
  if (!file.exists(input)) {
    cli::cli_abort(
      "Cannot edit missing recording {.file {input}}.",
      call = call
    )
  }
  if (
    length(input_range) != 1L ||
      !input_range %in% c("full", "tv")
  ) {
    cli::cli_abort(
      "{.arg input_range} must be either {.val full} or {.val tv}.",
      call = call
    )
  }

  filter <- tlg_demo_filter(segments, keyframes, input_range = input_range)

  status <- system2(
    "ffmpeg",
    c(
      "-y",
      "-loglevel",
      "error",
      "-i",
      shQuote(input),
      "-filter_complex",
      shQuote(filter),
      "-map",
      "[v]",
      "-an",
      "-c:v",
      "libx264",
      "-preset",
      preset,
      "-crf",
      as.character(crf),
      "-movflags",
      "+faststart",
      shQuote(output)
    )
  )
  if (!identical(status, 0L)) {
    cli::cli_abort("FFmpeg failed to edit {.file {output}}.", call = call)
  }

  invisible(output)
}

remove_tlg_demo_ranges <- function(
  input,
  output,
  cuts,
  duration,
  preset,
  crf,
  call = rlang::caller_env()
) {
  starts <- c(0, cuts$end)
  ends <- c(cuts$start, duration)
  segment_filters <- vapply(
    seq_along(starts),
    \(i) sprintf(
      "[0:v]trim=start=%.3f:end=%.3f,setpts=PTS-STARTPTS[v%d]",
      starts[[i]],
      ends[[i]],
      i
    ),
    character(1)
  )
  inputs <- paste0("[v", seq_along(starts), "]", collapse = "")
  filter <- paste(
    c(
      segment_filters,
      paste0(
        inputs,
        "concat=n=",
        length(starts),
        ":v=1:a=0,format=yuv420p[v]"
      )
    ),
    collapse = ";"
  )

  status <- system2(
    "ffmpeg",
    c(
      "-y",
      "-loglevel",
      "error",
      "-i",
      shQuote(input),
      "-filter_complex",
      shQuote(filter),
      "-map",
      "[v]",
      "-an",
      "-c:v",
      "libx264",
      "-preset",
      preset,
      "-crf",
      as.character(crf),
      "-color_range",
      "tv",
      "-movflags",
      "+faststart",
      shQuote(output)
    )
  )
  if (!identical(status, 0L)) {
    cli::cli_abort(
      "FFmpeg failed to remove pauses from {.file {output}}.",
      call = call
    )
  }

  invisible(output)
}

validate_tlg_demo_cuts <- function(
  cuts,
  duration,
  call = rlang::caller_env()
) {
  if (is.null(cuts)) {
    return(data.frame(start = numeric(), end = numeric()))
  }
  if (
    !is.data.frame(cuts) ||
      !all(c("start", "end") %in% names(cuts)) ||
      !is.numeric(cuts$start) ||
      !is.numeric(cuts$end)
  ) {
    cli::cli_abort(
      "{.arg cuts} must be a data frame with numeric {.field start} and {.field end} columns.",
      call = call
    )
  }
  if (is.null(duration)) {
    cli::cli_abort(
      "{.arg duration} cannot be {.code NULL} when {.arg cuts} are supplied.",
      call = call
    )
  }

  cuts <- cuts[order(cuts$start), , drop = FALSE]
  invalid <- !is.finite(cuts$start) |
    !is.finite(cuts$end) |
    cuts$start < 0 |
    cuts$end <= cuts$start |
    cuts$end >= duration
  overlaps <- length(cuts$start) > 1L &&
    any(cuts$start[-1] < cuts$end[-nrow(cuts)])
  if (any(invalid) || overlaps) {
    cli::cli_abort(
      "{.arg cuts} must contain ordered, non-overlapping ranges within the video duration.",
      call = call
    )
  }

  cuts
}

tlg_demo_edit_specs <- function() {
  list(
    list(
      raw_slug = "table",
      output_slug = "table",
      segments = data.frame(
        start = c(0.6, 5.5, 8.5),
        end = c(5.5, 8.5, 25.5),
        speed = c(1.35, 3, 1)
      ),
      keyframes = data.frame(
        time = c(
          0,
          0.55,
          1.35,
          3.2,
          3.8,
          4.7,
          5.5,
          7.5,
          8.5,
          10.6,
          11.4,
          15.7,
          16.5,
          18.3,
          19.1,
          21.5
        ),
        zoom = c(
          1.02,
          1.02,
          2.25,
          2.25,
          2,
          2,
          2.25,
          2.25,
          2.25,
          2.25,
          2.4,
          2.4,
          2.15,
          2.15,
          3.2,
          3.2
        ),
        x = c(
          0.5,
          0.5,
          0.5,
          0.5,
          0.54,
          0.54,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.49,
          0.49
        ),
        y = c(
          0.5,
          0.5,
          0.55,
          0.55,
          0.18,
          0.18,
          0.18,
          0.18,
          0.38,
          0.4,
          0.42,
          0.42,
          0.34,
          0.34,
          0.48,
          0.48
        )
      )
    ),
    list(
      raw_slug = "plot",
      output_slug = "plot",
      segments = data.frame(
        start = c(0.6, 6, 14.5, 20.4, 26.5, 29),
        end = c(6, 14.5, 17.4, 26.5, 29, 32.7),
        speed = c(1.4, 3.8, 1, 1, 8, 1)
      ),
      keyframes = data.frame(
        time = c(
          0,
          0.55,
          1.35,
          3.4,
          4.2,
          5.4,
          6.2,
          7.4,
          8.2,
          14.5,
          15.4,
          19
        ),
        zoom = c(
          1.02,
          1.02,
          2.25,
          2.25,
          2,
          2,
          2.25,
          2.25,
          2.65,
          2.65,
          2.2,
          2.2
        ),
        x = c(
          0.5,
          0.5,
          0.5,
          0.5,
          0.54,
          0.54,
          0.5,
          0.5,
          0.48,
          0.48,
          0.48,
          0.48
        ),
        y = c(
          0.5,
          0.5,
          0.55,
          0.55,
          0.18,
          0.18,
          0.18,
          0.18,
          0.49,
          0.49,
          0.32,
          0.32
        )
      )
    ),
    list(
      raw_slug = "custom-analysis-short",
      output_slug = "custom-analysis",
      segments = data.frame(
        start = c(0.6, 9.2, 18, 24, 53, 57, 63),
        end = c(9.2, 18, 24, 53, 57, 63, 68.8),
        speed = c(1.45, 8, 3, 13, 3, 1.15, 1)
      ),
      keyframes = data.frame(
        time = c(
          0,
          0.55,
          1.35,
          5.35,
          6.15,
          7.25,
          7.9,
          11.4,
          12.2,
          13.05,
          17.25,
          18.05,
          18.85,
          23.6
        ),
        # Opens near the zoom the plot demo ends on so the stitched video does
        # not snap wide at the segment boundary.
        zoom = c(
          2,
          2,
          2.5,
          2.5,
          2.1,
          2.1,
          1.58,
          1.58,
          1.58,
          2.05,
          2.05,
          2.05,
          1.9,
          1.9
        ),
        x = c(
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5,
          0.5
        ),
        # The conversation column spans x 0.348-0.652 and grows downward, so y
        # tracks the content centre to keep the question bubble from clipping.
        y = c(
          0.52,
          0.52,
          0.55,
          0.55,
          0.18,
          0.18,
          0.3,
          0.3,
          0.37,
          0.67,
          0.67,
          0.67,
          0.69,
          0.69
        )
      )
    )
  )
}

tlg_demo_filter <- function(segments, keyframes, input_range = "full") {
  segment_filters <- vapply(
    seq_len(nrow(segments)),
    function(i) {
      sprintf(
        paste0(
          "[0:v]trim=start=%.3f:end=%.3f,",
          "setpts=(PTS-STARTPTS)/%.3f[s%d]"
        ),
        segments$start[[i]],
        segments$end[[i]],
        segments$speed[[i]],
        i
      )
    },
    character(1)
  )

  inputs <- paste0("[s", seq_len(nrow(segments)), "]", collapse = "")
  zoom <- smooth_keyframe_expression(keyframes$time, keyframes$zoom)
  center_x <- smooth_keyframe_expression(keyframes$time, keyframes$x)
  center_y <- smooth_keyframe_expression(keyframes$time, keyframes$y)
  x <- sprintf(
    "max(0,min(iw-iw/zoom,(%s)*iw-iw/zoom/2))",
    center_x
  )
  y <- sprintf(
    "max(0,min(ih-ih/zoom,(%s)*ih-ih/zoom/2))",
    center_y
  )
  edit_filter <- paste0(
    inputs,
    "concat=n=",
    nrow(segments),
    ":v=1:a=0,",
    "fps=60,",
    "zoompan=",
    "z='",
    zoom,
    "':",
    "x='",
    x,
    "':",
    "y='",
    y,
    "':",
    "d=1:s=3340x1874:fps=60,",
    "scale=iw:ih:in_range=",
    input_range,
    ":out_range=tv,",
    "format=yuv420p[v]"
  )

  paste(c(segment_filters, edit_filter), collapse = ";\n")
}

smooth_keyframe_expression <- function(times, values) {
  expression <- format_number(tail(values, 1))

  for (i in rev(seq_len(length(times) - 1))) {
    start <- format_number(times[[i]])
    end <- format_number(times[[i + 1]])
    from <- format_number(values[[i]])
    to <- format_number(values[[i + 1]])
    progress <- sprintf("clip((it-%s)/(%s-%s),0,1)", start, end, start)
    smooth_progress <- sprintf("(%s*%s*(3-2*%s))", progress, progress, progress)
    transition <- sprintf(
      "%s+(%s-%s)*%s",
      from,
      to,
      from,
      smooth_progress
    )
    expression <- sprintf("if(lt(it,%s),%s,%s)", end, transition, expression)
  }

  expression
}

format_number <- function(x) {
  format(x, scientific = FALSE, trim = TRUE)
}

if (sys.nframe() == 0L) {
  edit_tlg_demos()
  stitch_tlg_demos()
}

# VP site traffic agent

A small Commons app for recording the VP example in the talk. It uses fictional
traffic data and a trusted calculation that reports a 22% increase in daily site
visits.

From the talk repository root, run:

```r
shiny::runApp("vp-agent")
```

The app uses `ANTHROPIC_API_KEY` when available and otherwise falls back to
`OPENAI_API_KEY`.

## Record the demos

With the app running on port 8765, record the three example interactions from
the talk repository root:

```sh
Rscript vp-agent/record-demos.R
```

The script writes silent H.264 MP4 files to `figures/`.

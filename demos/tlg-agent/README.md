# TLG agent demos

These recordings show two validated measures and one custom SQL analysis in
the clinical-trials TLG agent:

- `ae_overview`, including its formatted table
- `ae_by_soc_plot`, including its `ggplot`
- an ad-hoc adverse-event count, with the generated SQL expanded

## Run the app

Start the local TLG agent on port 8766. From this talk repository, the checkout
in this workspace can be started with:

```sh
Rscript -e 'shiny::runApp("../../rstudio/tlg-agent", port = 8766)'
```

## Record the demos

In another terminal, from this talk repository:

```sh
Rscript demos/tlg-agent/record-demos.R
```

The recorder uses Chromote and writes silent H.264 MP4 files to `figures/`:

- `tlg-agent-table.mp4`
- `tlg-agent-plot.mp4`
- `tlg-agent-custom-code.mp4`

Set `TLG_AGENT_URL` to record against a different app URL.

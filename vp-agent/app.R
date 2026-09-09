library(commons)
library(shiny)
library(shinychat)

new_vp_agent <- function() {
  commons(
    client = model_client(),
    data_sources = list(
      warehouse = data_source(
        sessions_daily = sessions_data(),
        pageview_events_daily = pageview_data()
      )
    ),
    semantic_layer = semantic_layer(
      measure(
        "site_traffic_trend",
        paste(
          "The canonical trend in daily site visits over the latest 90 days.",
          "Use this calculation for questions about how site traffic is trending.",
          "It compares average daily sessions in the latest 14 days with the",
          "first 14 days of the period."
        ),
        site_traffic_trend,
        title = "Site traffic trend"
      )
    ),
    context_layer = context_layer("context/site-traffic.md"),
    instructions = paste(
      "Answer site traffic questions concisely.",
      "Lead with the trend and percentage change."
    )
  )
}

greeting <- paste(
  "Ask about traffic to the company website.",
  "\n\nHere are some example questions:\n\n",
  "- <span class='suggestion'>How is traffic trending for our site?</span>\n",
  "- <span class='suggestion'>Which day had the most site visits?</span>\n",
  paste0(
    "- <span class='suggestion'>",
    "Why are pageview events falling while site visits are rising?",
    "</span>\n"
  )
)

ui <- page_chat(
  "Site traffic",
  id = "chat",
  greeting = greeting,
  theme = commons_theme()
)

server <- function(input, output, session) {
  commons_server(
    "chat",
    new_vp_agent(),
    history = history_options(restore_mode = "none", store = "memory")
  )
}

site_traffic_trend <- function(warehouse) {
  DBI::dbGetQuery(
    warehouse,
    "
    WITH ranked AS (
      SELECT
        visit_date,
        visits,
        row_number() OVER (ORDER BY visit_date) AS first_rank,
        row_number() OVER (ORDER BY visit_date DESC) AS last_rank
      FROM sessions_daily
    ),
    windows AS (
      SELECT
        min(visit_date) AS period_start,
        max(visit_date) AS period_end,
        avg(CASE WHEN first_rank <= 14 THEN visits END) AS baseline_visits,
        avg(CASE WHEN last_rank <= 14 THEN visits END) AS current_visits
      FROM ranked
    )
    SELECT
      period_start,
      period_end,
      round(baseline_visits) AS baseline_daily_visits,
      round(current_visits) AS current_daily_visits,
      round(100 * (current_visits / baseline_visits - 1), 1) AS percent_change,
      CASE
        WHEN current_visits > baseline_visits THEN 'increased'
        WHEN current_visits < baseline_visits THEN 'decreased'
        ELSE 'held steady'
      END AS direction,
      'Average daily sessions: latest 14 days versus first 14 days' AS method
    FROM windows
    "
  )
}

model_client <- function(call = rlang::caller_env()) {
  if (nzchar(Sys.getenv("ANTHROPIC_API_KEY"))) {
    return(ellmer::chat_anthropic())
  }
  if (nzchar(Sys.getenv("OPENAI_API_KEY"))) {
    return(ellmer::chat_openai())
  }

  cli::cli_abort(
    c(
      "The VP agent needs a model provider API key.",
      i = "Set {.envvar ANTHROPIC_API_KEY} or {.envvar OPENAI_API_KEY}."
    ),
    call = call
  )
}

sessions_data <- function() {
  end_date <- as.Date("2026-09-05")
  dates <- seq(end_date - 89, end_date, by = "day")
  weekly_noise <- rep(
    c(-1200L, -600L, -200L, 0L, 300L, 700L, 1000L),
    2
  )
  middle_noise <- rep(weekly_noise, length.out = 62)

  data.frame(
    visit_date = dates,
    visits = c(
      41000L + weekly_noise,
      round(seq(42000, 49000, length.out = 62) + middle_noise),
      50020L + weekly_noise
    )
  )
}

pageview_data <- function() {
  end_date <- as.Date("2026-09-05")
  dates <- seq(end_date - 89, end_date, by = "day")
  weekly_noise <- rep(
    c(-1500L, -700L, -250L, 0L, 400L, 850L, 1200L),
    length.out = 90
  )

  data.frame(
    event_date = dates,
    pageview_events = round(
      seq(72000, 25920, length.out = 90) + weekly_noise
    )
  )
}

shinyApp(ui, server)

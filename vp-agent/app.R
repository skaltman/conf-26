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
    context_layer = context_layer("vp-agent/context/site-traffic.md"),
    instructions = paste(
      "Be very concise.",
      "When answering the question 'Which day had the most site visits?', do not cite trusted context, even if you think some is relevant."
    )
  )
}

greeting <- paste(
  "\n\nAsk questions about recent product trends:\n\n",
  "- <span class='suggestion'>How is traffic trending for our site?</span>\n",
  "- <span class='suggestion'>Which day had the most site visits?</span>\n",
  paste0(
    "- <span class='suggestion'>",
    "Why are pageview events falling while site visits are rising?",
    "</span>\n"
  )
)

ui <- page_chat(
  list(),
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
  traffic <- DBI::dbGetQuery(
    warehouse,
    "
    SELECT visit_date, visits
    FROM sessions_daily
    ORDER BY visit_date
    "
  )

  baseline_visits <- mean(utils::head(traffic$visits, 14))
  current_visits <- mean(utils::tail(traffic$visits, 14))
  percent_change <- 100 * (current_visits / baseline_visits - 1)
  direction <- if (percent_change >= 0) "increased" else "decreased"

  ggplot2::ggplot(traffic, ggplot2::aes(visit_date, visits)) +
    ggplot2::geom_line(linewidth = 1, color = "#447099") +
    ggplot2::labs(
      title = sprintf(
        "Daily site visits %s %.0f%%",
        direction,
        abs(percent_change)
      ),
      x = NULL,
      y = "Daily visits"
    ) +
    ggplot2::scale_y_continuous(
      limits = c(0, NA),
      expand = ggplot2::expansion(mult = c(0, 0.05))
    ) +
    ggplot2::theme_minimal(base_size = 14)
}

model_client <- function() {
  ellmer::chat_openai(model = "gpt-5.6-terra")
}

sessions_data <- function() {
  end_date <- as.Date("2026-09-05")
  dates <- seq(end_date - 89, end_date, by = "day")
  day <- seq_along(dates)
  noise <-
    550 * sin(2 * pi * day / 7) +
    340 * sin(1.31 * day) +
    190 * sin(0.37 * day)

  data.frame(
    visit_date = dates,
    visits = round(seq(40000, 50500, length.out = length(dates)) + noise)
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

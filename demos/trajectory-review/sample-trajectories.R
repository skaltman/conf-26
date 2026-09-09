vp_sample_trajectories <- function() {
  conversations <- list(
    sample_conversation(
      "2026-08-20 09:15:00",
      list(
        sample_exchange(
          "A",
          "How is traffic trending for our site?",
          paste(
            "Daily site visits increased 22.0%, from an average of 41,000",
            "in the first 14 days to 50,020 in the latest 14 days."
          ),
          trusted_tools(
            "site traffic trend",
            "site_traffic_trend",
            paste(
              "period_start: 2026-05-23",
              "period_end: 2026-08-20",
              "baseline_daily_visits: 41000",
              "current_daily_visits: 50020",
              "percent_change: 22.0",
              "direction: increased",
              sep = "\n"
            )
          )
        ),
        sample_exchange(
          "A",
          "Is the increase still showing up in the latest two weeks?",
          paste(
            "Yes. The latest 14-day average is 50,020 visits per day,",
            "22.0% above the 41,000 baseline."
          ),
          trusted_tools(
            "latest two week site traffic trend",
            "site_traffic_trend",
            paste(
              "baseline_window: 2026-05-23 through 2026-06-05",
              "current_window: 2026-08-07 through 2026-08-20",
              "baseline_daily_visits: 41000",
              "current_daily_visits: 50020",
              "percent_change: 22.0",
              sep = "\n"
            )
          )
        ),
        sample_exchange(
          "A",
          "Did that beat our 15% quarterly growth target?",
          paste(
            "Yes. Site traffic growth is 22.0%, which is 7 percentage",
            "points above the 15.0% target."
          ),
          trusted_tools(
            "site traffic quarterly target",
            "site_traffic_growth_vs_target",
            paste(
              "actual_growth_percent: 22.0",
              "target_growth_percent: 15.0",
              "difference_percentage_points: 7.0",
              "target_met: true",
              sep = "\n"
            )
          )
        )
      )
    ),
    sample_conversation(
      "2026-08-30 10:05:00",
      list(
        sample_exchange(
          "C",
          "Which day had the most site visits?",
          "August 29 had the most site visits, with 51,020.",
          sql_tools(
            "daily site visits",
            "sessions_daily",
            "visit_date DATE\nvisits INTEGER",
            paste(
              "SELECT visit_date, visits",
              "FROM sessions_daily",
              "WHERE visit_date <= DATE '2026-08-29'",
              "ORDER BY visits DESC, visit_date",
              "LIMIT 3"
            ),
            paste(
              "2026-08-29 | 51020",
              "2026-08-22 | 50480",
              "2026-08-15 | 49960",
              sep = "\n"
            )
          )
        ),
        sample_exchange(
          "C",
          "Was August 29 also our strongest Saturday?",
          "Yes. August 29 was the strongest Saturday at 51,020 visits.",
          sql_tools(
            "Saturday site visits",
            "sessions_daily",
            "visit_date DATE\nvisits INTEGER",
            paste(
              "SELECT visit_date, visits",
              "FROM sessions_daily",
              "WHERE strftime(visit_date, '%w') = '6'",
              "  AND visit_date <= DATE '2026-08-29'",
              "ORDER BY visits DESC",
              "LIMIT 3"
            ),
            paste(
              "2026-08-29 | 51020",
              "2026-08-22 | 50480",
              "2026-08-15 | 49960",
              sep = "\n"
            )
          )
        )
      )
    ),
    sample_conversation(
      "2026-08-31 13:40:00",
      list(
        sample_exchange(
          "B",
          "Why are pageview events falling while site visits are rising?",
          paste(
            "The measures come from different instrumentation. Sessions are",
            "the reviewed traffic metric, while the pageview event is legacy",
            "debugging telemetry that newer Chrome versions no longer emit."
          ),
          context_tools(
            "pageview events sessions Chrome",
            paste(
              "Use sessions_daily for reporting site traffic.",
              "pageview_events_daily contains legacy debugging telemetry.",
              "Chrome 126 and newer no longer emit the pageview debugging event.",
              sep = "\n"
            )
          ),
          citation = sample_citation(
            paste(
              "Chrome 126 and newer no longer emit the pageview debugging",
              "event."
            ),
            "Site traffic instrumentation"
          )
        ),
        sample_exchange(
          "B",
          "Can leadership use pageviews for the current reporting period?",
          paste(
            "No. Use sessions_daily for reporting. The pageview event is",
            "incomplete as browser adoption changes."
          ),
          context_tools(
            "approved traffic metric current reporting period",
            paste(
              "Use sessions_daily for reporting site traffic.",
              "Do not use pageview_events_daily for business reporting.",
              "Its coverage changes with browser-version adoption.",
              sep = "\n"
            )
          ),
          citation = sample_citation(
            "Do not use pageview_events_daily for business reporting.",
            "Site traffic instrumentation"
          )
        ),
        sample_exchange(
          "B",
          "What exactly counts as a visit in the approved metric?",
          paste(
            "A visit is one analytics session in sessions_daily. Multiple",
            "pageviews within the same session still count as one visit."
          ),
          context_tools(
            "site visit definition sessions",
            paste(
              "A site visit is one analytics session in sessions_daily.",
              "Multiple pageviews in one session count as one visit.",
              sep = "\n"
            )
          ),
          citation = sample_citation(
            "A site visit is one analytics session in sessions_daily.",
            "Site traffic metric definitions"
          )
        )
      )
    ),
    sample_conversation(
      "2026-09-01 11:30:00",
      list(
        sample_exchange(
          "C",
          "Which referral source grew fastest in August?",
          "Partner referrals grew fastest in August, up 31.0%.",
          sql_tools(
            "visits by referral source",
            "sessions_by_source_daily",
            paste(
              "visit_date DATE",
              "source VARCHAR",
              "visits INTEGER",
              sep = "\n"
            ),
            paste(
              "SELECT source,",
              "  round(100 * (sum(current_visits) / sum(prior_visits) - 1), 1)",
              "    AS growth_percent",
              "FROM monthly_source_comparison",
              "WHERE month = DATE '2026-08-01'",
              "GROUP BY source",
              "ORDER BY growth_percent DESC"
            ),
            paste(
              "partner | 31.0",
              "organic_search | 18.7",
              "paid_campaign | 12.4",
              "direct | 8.9",
              sep = "\n"
            )
          )
        ),
        sample_exchange(
          "C",
          "What share of August visits came from paid campaigns?",
          "Paid campaigns accounted for 18.4% of August visits.",
          sql_tools(
            "paid campaign share of visits",
            "sessions_by_source_daily",
            paste(
              "visit_date DATE",
              "source VARCHAR",
              "visits INTEGER",
              sep = "\n"
            ),
            paste(
              "SELECT round(100 * sum(visits) FILTER (",
              "  WHERE source = 'paid_campaign') / sum(visits), 1)",
              "  AS paid_share_percent",
              "FROM sessions_by_source_daily",
              "WHERE visit_date BETWEEN DATE '2026-08-01'",
              "  AND DATE '2026-08-31'"
            ),
            "18.4"
          )
        )
      )
    ),
    sample_conversation(
      "2026-09-04 14:20:00",
      list(
        sample_exchange(
          "C",
          "Which landing page had the best conversion rate last week?",
          paste(
            "The pricing page had the highest conversion rate last week",
            "at 7.8%."
          ),
          sql_tools(
            "landing page conversion",
            "landing_page_daily",
            paste(
              "visit_date DATE",
              "landing_page VARCHAR",
              "sessions INTEGER",
              "conversions INTEGER",
              sep = "\n"
            ),
            paste(
              "SELECT landing_page,",
              "  round(100 * sum(conversions) / sum(sessions), 1)",
              "    AS conversion_rate",
              "FROM landing_page_daily",
              "WHERE visit_date BETWEEN DATE '2026-08-24'",
              "  AND DATE '2026-08-30'",
              "GROUP BY landing_page",
              "ORDER BY conversion_rate DESC"
            ),
            paste(
              "/pricing | 7.8",
              "/demo | 6.4",
              "/products | 4.9",
              sep = "\n"
            )
          )
        ),
        sample_exchange(
          "C",
          "How many conversions did the pricing page generate?",
          "The pricing page generated 1,248 conversions last week.",
          sql_tools(
            "pricing page conversions",
            "landing_page_daily",
            paste(
              "visit_date DATE",
              "landing_page VARCHAR",
              "sessions INTEGER",
              "conversions INTEGER",
              sep = "\n"
            ),
            paste(
              "SELECT sum(conversions) AS conversions",
              "FROM landing_page_daily",
              "WHERE landing_page = '/pricing'",
              "  AND visit_date BETWEEN DATE '2026-08-24'",
              "  AND DATE '2026-08-30'"
            ),
            "1248"
          )
        )
      )
    ),
    sample_conversation(
      "2026-09-06 08:40:00",
      list(
        sample_exchange(
          "A",
          "Give me the latest site traffic update.",
          paste(
            "Daily site visits remain up 22.0%: the latest 14-day average is",
            "50,020 compared with the 41,000 baseline."
          ),
          trusted_tools(
            "latest site traffic trend",
            "site_traffic_trend",
            paste(
              "period_start: 2026-06-09",
              "period_end: 2026-09-06",
              "baseline_daily_visits: 41000",
              "current_daily_visits: 50020",
              "percent_change: 22.0",
              "direction: increased",
              sep = "\n"
            )
          )
        ),
        sample_exchange(
          "C",
          "What was average weekend traffic in August?",
          "Average weekend traffic in August was 45,880 visits per day.",
          sql_tools(
            "weekend site visits",
            "sessions_daily",
            "visit_date DATE\nvisits INTEGER",
            paste(
              "SELECT round(avg(visits)) AS average_weekend_visits",
              "FROM sessions_daily",
              "WHERE visit_date BETWEEN DATE '2026-08-01'",
              "  AND DATE '2026-08-31'",
              "  AND strftime(visit_date, '%w') IN ('0', '6')"
            ),
            "45880"
          )
        ),
        sample_exchange(
          "B",
          "Why doesn't that match the pageview dashboard?",
          paste(
            "The dashboard uses legacy pageview telemetry, while this answer",
            "uses the approved session-based visit metric. Browser-version",
            "changes make the pageview series incomplete."
          ),
          context_tools(
            "pageview dashboard session metric mismatch",
            paste(
              "The legacy dashboard reads pageview_events_daily.",
              "Approved traffic reporting uses sessions_daily.",
              "Browser-version changes make pageview_events_daily incomplete.",
              sep = "\n"
            )
          ),
          citation = sample_citation(
            "Approved traffic reporting uses sessions_daily.",
            "Site traffic instrumentation"
          )
        )
      )
    )
  )

  trajectories <- lapply(
    seq_along(conversations),
    \(i) conversation_trajectory(conversations[[i]], i)
  )
  names(trajectories) <- sprintf(
    "vp-agent-%s",
    c(
      "executive-update",
      "peak-traffic",
      "metric-discrepancy",
      "acquisition",
      "conversion",
      "weekly-check-in"
    )
  )
  attr(trajectories, "source") <- list(
    kind = "local",
    path = normalizePath("logs", mustWork = FALSE)
  )
  trajectories
}

sample_conversation <- function(last_active, exchanges) {
  list(last_active = last_active, exchanges = exchanges)
}

sample_exchange <- function(
  tag,
  question,
  answer,
  tools,
  citation = NULL
) {
  list(
    tag = tag,
    question = question,
    answer = answer,
    tools = tools,
    citation = citation
  )
}

sample_citation <- function(quote, label) {
  list(
    quote = quote,
    status = "accepted",
    label = label,
    kind = "context"
  )
}

conversation_trajectory <- function(conversation, index) {
  turns <- list(
    ellmer::SystemTurn(
      paste(
        "Answer the VP's site traffic questions concisely.",
        "Use approved metrics and preserve the evidence behind each answer."
      )
    )
  )

  for (exchange_index in seq_along(conversation$exchanges)) {
    turns <- c(
      turns,
      exchange_turns(
        conversation$exchanges[[exchange_index]],
        index,
        exchange_index
      )
    )
  }

  attr(turns, "provenance") <- lapply(
    conversation$exchanges,
    exchange_provenance
  )
  attr(turns, "last_active") <- as.POSIXct(
    conversation$last_active,
    tz = "America/Los_Angeles"
  )
  turns
}

exchange_turns <- function(exchange, conversation_index, exchange_index) {
  turns <- list(ellmer::UserTurn(exchange$question))

  for (tool_index in seq_along(exchange$tools)) {
    tool <- exchange$tools[[tool_index]]
    request <- ellmer::ContentToolRequest(
      id = sprintf(
        "tool-%02d-%02d-%02d",
        conversation_index,
        exchange_index,
        tool_index
      ),
      name = tool$name,
      arguments = tool$arguments
    )
    turns <- c(
      turns,
      list(
        ellmer::AssistantTurn(list(request)),
        ellmer::UserTurn(list(ellmer::ContentToolResult(
          value = tool$result,
          request = request
        )))
      )
    )
  }

  c(turns, list(ellmer::AssistantTurn(exchange$answer)))
}

trusted_tools <- function(query, measure, result) {
  list(
    tool_record(
      "search_pool",
      list(query = query),
      sprintf("%s: trusted calculation", measure)
    ),
    tool_record(
      "call_measure",
      list(name = measure),
      result
    )
  )
}

context_tools <- function(query, result) {
  list(
    tool_record(
      "search_context",
      list(query = query),
      result
    )
  )
}

sql_tools <- function(query, table, schema, sql, result) {
  list(
    tool_record(
      "search_pool",
      list(query = query),
      "No matching trusted calculation found."
    ),
    tool_record(
      "describe_table",
      list(table = table),
      schema
    ),
    tool_record(
      "run_sql",
      list(sql = sql),
      result
    )
  )
}

tool_record <- function(name, arguments, result) {
  list(name = name, arguments = arguments, result = result)
}

exchange_provenance <- function(exchange) {
  list(
    provenance_tag = exchange$tag,
    citation_decisions = if (is.null(exchange$citation)) {
      list()
    } else {
      list(exchange$citation)
    }
  )
}

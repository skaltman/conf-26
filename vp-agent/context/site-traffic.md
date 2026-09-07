---
source: Internal web analytics guidance
---

# Measuring site traffic

`sessions_daily` is the canonical source for site traffic. It has one row per
day, and `visits` is the reviewed daily sessions metric used in leadership
reporting.

`pageview_events_daily` is browser instrumentation used for debugging. It is not
a measure of site traffic. A Chrome update progressively stopped emitting this
event during the current reporting period, so its apparent decline reflects
collection coverage rather than visitor behavior.

When describing a traffic trend, compare average daily sessions over meaningful
windows rather than comparing two individual days.

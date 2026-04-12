+++
title = "Exploring the MBTA public dataset using DuckDB"
author = ["Alán F. Muñoz"]
date = 2026-04-12T12:40:00-04:00
tags = ["duckdb", "datascience", "opendata"]
categories = ["workflow"]
draft = false
+++

To showcase the real-life usefulness of [Duckdb](https://duckdb.org/) (and SQL-adjacent Domain Specific Languages in general) I decided to use the public [datasets](https://mbta-massdot.opendata.arcgis.com/) made available by the Massachusetts Bay Transport Authority (MBTA). I have lived in Boston for a couple of years and wanted to test if my intuition of the busy lines and stations lined up with their data.

There are multiple available (tabular) datasets:

-   Ridership by Trip, Route line and stop
-   Monthly ridership by month
-   Gated station entries
-   Passenger surveys

<!--listend-->

```sql
.maxrows 11

INSTALL httpfs;
LOAD httpfs;

CREATE OR REPLACE TABLE monthly_ridership AS (SELECT * FROM read_csv('https://hub.arcgis.com/api/v3/datasets/a2d15ddd86b34867a31cd4b8e0a83932_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1'));

SELECT column_name, column_type FROM (DESCRIBE monthly_ridership);
```

```text
┌─────────────────────────────────┬──────────────────────────┐
│           column_name           │       column_type        │
│             varchar             │         varchar          │
├─────────────────────────────────┼──────────────────────────┤
│ service_date                    │ TIMESTAMP WITH TIME ZONE │
│ mode                            │ VARCHAR                  │
│ route_or_line                   │ VARCHAR                  │
│ total_monthly_weekday_ridership │ BIGINT                   │
│ average_monthly_weekday_ridersh │ BIGINT                   │
│ countofdates_weekday            │ BIGINT                   │
│ total_monthly_ridership         │ DOUBLE                   │
│ average_monthly_ridership       │ BIGINT                   │
│ countofdates                    │ BIGINT                   │
│ ObjectId                        │ BIGINT                   │
├─────────────────────────────────┴──────────────────────────┤
│ 10 rows                                          2 columns │
└────────────────────────────────────────────────────────────┘
```

We first loaded the `httpfs` extension to pull the data directly from their website. I am using a local database but this should also work without writing to a file thanks to the [in-memory](https://duckdb.org/docs/stable/connect/overview) database capabilities of duckdb.

Then we created a new table `monthly_ridership` by running a subquery (another valid SQL expression surrounded by parentheses). This will download and save the CSV table into a table in the database (in-memory or into a file that works as a database).

Lastly, we describe the table and I like to filter out other columns that are not informative. I predominantly care about the column names and data types. Here the ones we care about are either `total_monthly_weekday_ridership` or `average_monthly_weekday_ridership` alongside `route_or_line`.

We will thus group by route or line to see the average ridership per route.

```sql
SELECT route_or_line, CAST(MEAN(total_monthly_weekday_ridership) AS INTEGER) AS mean_monthly_weekday_ridership FROM monthly_ridership GROUP BY route_or_line ORDER BY mean_monthly_weekday_ridership DESC;
```

```text
┌───────────────┬────────────────────────────────┐
│ route_or_line │ mean_monthly_weekday_ridership │
│    varchar    │             int32              │
├───────────────┼────────────────────────────────┤
│ Bus           │                        7395469 │
│ Red Line      │                        5326706 │
│ Orange Line   │                        4410355 │
│ Green Line    │                        3893135 │
│ Commuter Rail │                        2684943 │
│ Blue Line     │                        1392658 │
│ Silver Line   │                         724622 │
│ The RIDE      │                         138221 │
│ Boat-F1       │                          66248 │
│ Boat-F3       │                          23922 │
│ Boat-F4       │                          19975 │
├───────────────┴────────────────────────────────┤
│ 11 rows                              2 columns │
└────────────────────────────────────────────────┘
```

We can see here all 5 lines of the metro system, in addition to commuter rail, buses, The RIDE (a door-to-door service for folks unable to ride the fixed routes) and several boat routes that cross the Boston Harbour.

Gated entries give info on specific entrances. We first fetch the table and print the schema.

```sql
CREATE OR REPLACE TABLE gated_entries AS (SELECT * FROM read_csv('https://hub.arcgis.com/api/v3/datasets/001c177f07594e7c99f193dde32284c9_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1'));
SELECT column_name, column_type FROM (DESCRIBE gated_entries);
```

```text
┌───────────────┬──────────────────────────┐
│  column_name  │       column_type        │
│    varchar    │         varchar          │
├───────────────┼──────────────────────────┤
│ service_date  │ TIMESTAMP WITH TIME ZONE │
│ time_period   │ VARCHAR                  │
│ stop_id       │ VARCHAR                  │
│ station_name  │ VARCHAR                  │
│ route_or_line │ VARCHAR                  │
│ gated_entries │ DOUBLE                   │
│ ObjectId      │ BIGINT                   │
└───────────────┴──────────────────────────┘
```

The schema makes sense in general, we care the most about `station_name`, `route_or_line` and `gated_entries`. Before aggregating, it is worth checking the time span the data covers.

```sql
SELECT MIN(service_date) AS start_date, MAX(service_date) AS end_date FROM gated_entries;
```

```text
┌──────────────────────────┬──────────────────────────┐
│        start_date        │         end_date         │
│ timestamp with time zone │ timestamp with time zone │
├──────────────────────────┼──────────────────────────┤
│ 2024-08-25 00:00:00-04   │ 2026-02-28 00:00:00-05   │
└──────────────────────────┴──────────────────────────┘
```

So the dataset covers about a year and a half, from August 2024 to February 2026. We can perform "quality control" to check if there are stations with very few records.

```sql
SELECT days_recorded,
COUNT(*) AS num_stations,
FIRST(route_or_line) AS example_line
FROM (
  SELECT station_name, route_or_line,
  COUNT(DISTINCT service_date) AS days_recorded
  FROM gated_entries
  GROUP BY station_name, route_or_line
)
GROUP BY days_recorded
ORDER BY days_recorded DESC;
```

```text
┌───────────────┬──────────────┬──────────────┐
│ days_recorded │ num_stations │ example_line │
│     int64     │    int64     │   varchar    │
├───────────────┼──────────────┼──────────────┤
│           553 │           26 │ Red Line     │
│           552 │            3 │ Orange Line  │
│           551 │            4 │ Orange Line  │
│           550 │            2 │ Blue Line    │
│           549 │            4 │ Orange Line  │
│           548 │            3 │ Blue Line    │
│            ·  │            · │     ·        │
│            ·  │            · │     ·        │
│            ·  │            · │     ·        │
│           536 │            1 │ Green Line   │
│           526 │            1 │ Green Line   │
│           523 │            3 │ Green Line   │
│           518 │            1 │ Green Line   │
│           512 │            1 │ Green Line   │
├───────────────┴──────────────┴──────────────┤
│ 22 rows (11 shown)                3 columns │
└─────────────────────────────────────────────┘
```

My first impression is that the Green Line has fewer records than the others. If you have lived in Boston this should make sense, since part of the Green Line runs like a tram/light rail, I would thus expect the logistics of data collection to be trickier in above-ground stations.

```sql
SELECT route_or_line, ROUND(AVG(days_recorded),1) AS avg_days_per_station
FROM (
  SELECT route_or_line, station_name, COUNT(DISTINCT service_date) AS days_recorded
  FROM gated_entries
  GROUP BY route_or_line, station_name
)
GROUP BY route_or_line
ORDER BY avg_days_per_station DESC;
```

```text
┌───────────────┬──────────────────────┐
│ route_or_line │ avg_days_per_station │
│    varchar    │        double        │
├───────────────┼──────────────────────┤
│ Silver Line   │                551.7 │
│ Orange Line   │                549.7 │
│ Red Line      │                549.0 │
│ Blue Line     │                546.3 │
│ Green Line    │                538.3 │
│ Mattapan Line │                538.0 │
└───────────────┴──────────────────────┘
```

Are the stations above ground the ones with fewer records?

```sql
SELECT station_name, COUNT(DISTINCT service_date) AS days_recorded
FROM gated_entries
WHERE route_or_line = 'Green Line'
GROUP BY station_name
ORDER BY days_recorded
LIMIT 10;
```

```text
┌─────────────────┬───────────────┐
│  station_name   │ days_recorded │
│     varchar     │     int64     │
├─────────────────┼───────────────┤
│ Union Square    │           512 │
│ Magoun Square   │           518 │
│ Ball Square     │           523 │
│ Medford/Tufts   │           523 │
│ East Somerville │           523 │
│ Gilman Square   │           526 │
│ Copley          │           536 │
│ Boylston        │           537 │
│ Kenmore         │           538 │
│ Arlington       │           541 │
├─────────────────┴───────────────┤
│ 10 rows               2 columns │
└─────────────────────────────────┘
```

Indeed all the stations under 530 days recorded are part of the [Green Line extension](https://en.wikipedia.org/wiki/Green_Line_Extension), opened in 2022. We know that they were running at the time this dataset was collected, so it is a bit surprising that they have the most missing data (even if less than 10%). I am curious about the stations that people use the most. Let's look at the top 10 stations with the most gated entries.

```sql
SELECT station_name, route_or_line, CAST(SUM(gated_entries) AS INT) AS gated_entries
FROM gated_entries
GROUP BY station_name, route_or_line
ORDER BY gated_entries DESC;
```

```text
┌───────────────────┬───────────────┬───────────────┐
│   station_name    │ route_or_line │ gated_entries │
│      varchar      │    varchar    │     int32     │
├───────────────────┼───────────────┼───────────────┤
│ Harvard           │ Red Line      │       5359023 │
│ Back Bay          │ Orange Line   │       4772945 │
│ Copley            │ Green Line    │       4184767 │
│ North Station     │ Orange Line   │       4099727 │
│ Central           │ Red Line      │       4094223 │
│ Kendall/MIT       │ Red Line      │       4054482 │
│      ·            │    ·          │           ·   │
│      ·            │    ·          │           ·   │
│      ·            │    ·          │           ·   │
│ Government Center │ Blue Line     │        258449 │
│ Union Square      │ Green Line    │        186641 │
│ Ball Square       │ Green Line    │        174971 │
│ Magoun Square     │ Green Line    │        154011 │
│ East Somerville   │ Green Line    │         92067 │
├───────────────────┴───────────────┴───────────────┤
│ 78 rows (11 shown)                      3 columns │
└───────────────────────────────────────────────────┘
```

There are two issues with naive aggregation: First, some stations are part of multiple routes. We thus should remove the route_or_line grouping. Second, the raw sums are skewed if not all stations have records covering the same time span. Since the dataset has a `service_date` column, we can normalise by the number of distinct dates each station appears in to get a fairer average daily figure.

We thus adjust our query to make these changes: Aggregate data from different lines and normalize it by the number of days recorded for each station.

```sql
SELECT
  station_name,
  LIST(DISTINCT route_or_line) AS lines,
  CAST(SUM(gated_entries) / COUNT(DISTINCT service_date) AS INT) AS avg_daily_entries
FROM gated_entries
GROUP BY station_name
ORDER BY avg_daily_entries DESC;
```

```text
┌───────────────────┬───────────────────────────┬───────────────────┐
│   station_name    │           lines           │ avg_daily_entries │
│      varchar      │         varchar[]         │       int32       │
├───────────────────┼───────────────────────────┼───────────────────┤
│ North Station     │ [Orange Line, Green Line] │             11315 │
│ South Station     │ [Red Line, Silver Line]   │             10342 │
│ Harvard           │ [Red Line]                │              9691 │
│ Downtown Crossing │ [Red Line, Orange Line]   │              9492 │
│ Back Bay          │ [Orange Line]             │              8774 │
│ Park Street       │ [Green Line, Red Line]    │              8017 │
│      ·            │      ·                    │                ·  │
│      ·            │      ·                    │                ·  │
│      ·            │      ·                    │                ·  │
│ Medford/Tufts     │ [Green Line]              │               540 │
│ Suffolk Downs     │ [Blue Line]               │               483 │
│ Union Square      │ [Green Line]              │               365 │
│ Ball Square       │ [Green Line]              │               335 │
│ Magoun Square     │ [Green Line]              │               297 │
│ East Somerville   │ [Green Line]              │               176 │
├───────────────────┴───────────────────────────┴───────────────────┤
│ 71 rows (12 shown)                                      3 columns │
└───────────────────────────────────────────────────────────────────┘
```

This better matches my intuitive impression from being in those areas. Harvard, despite being a major transit hub for buses and the T, is outranked by North and South Station once considering all lines. Park Street jumped from 19th before all the way up to sixth. The new Green Line stations in Cambridge still rank at the bottom of daily entries. There is a stark difference between the most and least "popular" stations. For every person recording their entry on East Somerville there are 62 in North Station. East Somerville (and all the other Green Line stations in Cambridge) do not enforce checks on ticket purchases. The same can be said for stations west of Kenmore, but those are located in an area with much denser population, since multiple universities are based in that area.

Overall, I really like duckdb due to the flexibility and speed for data crunching analysis. It is fast, simple and it integrates well with notebook-like workflows and Command-Line Interface (CLI) usage. The translation from questions to queries to tables is seamless. I believe it is a tool worth mastering, since it provides a Swiss Army Knife for everyday data processing.

There are some caveats worth mentioning. For instance, it is unclear to me how they are differentiating the Red and the Green Line entries in Park Street, since it is a two-layered station with the green lines on top, and one can only access the Red line from the Green Line. While it seemed negligible for these questions, the frequency and data acquisition differs across stations. There may be a weekday vs weekend bias that we are not accounting for. That said, I'm glad that my intuition of the usage of stations and lines matches my mental model.

Meta conclusion: I used this post also to test literate programming to incrementally build a data crunching workflow. In this case I coupled with an org-mode notebook (that is how I generate this blog) to explore a public dataset for fun. When wrapping up, I had a couple of lingering questions and a notion of the necessary query, but not enough time. I used an agent to add those in the middle of the analysis, which I evaluated via org-babel in a quick feedback loop. It worked shockingly well. Turns out this is quite similar to the recently released [marimo-pair](https://github.com/marimo-team/marimo-pair), an extension for reproducible data analysis notebooks using agents. I want to further explore the potential of having an agent as an interface for data analysis, where I still review and check that the code fulfills its intended purpose. In the end the goal is a reproducible artifact that gives us new insights on the data we are processing, and I think this approach facilitates rapid and reproducible data exploration and analysis.

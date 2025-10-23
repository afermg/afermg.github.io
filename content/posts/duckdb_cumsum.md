+++
title = "Calculate the cumulative sum of a column using DuckDB"
author = ["Alán F. Muñoz"]
date = 2025-10-22T20:34:00-04:00
tags = ["duckdb", "datascience", "gnuplot", "dataviz", "terminal-viz"]
categories = ["script"]
draft = false
+++

Duckdb, the (tabular) data exploration tool I use supports window operations. I recently discovered that it can also perform cumulative sums in a very efficient manner.

Let us generate a toy dataset where we want to calculate the sum of one column relative to the order of another one.

```duckdb
CREATE OR REPLACE TABLE seed AS SELECT SETSEED(0.1); -- seeding for reproducibility,  creating a table to hide output

-- Create a mock dataset with two integer columns
CREATE OR REPLACE TABLE my_table AS
SELECT
    #1 AS column_1,
    CAST(FLOOR(RANDOM() * 100) AS INT) AS column_2
FROM generate_series(1, 10);  -- This generates 10 rows
SELECT * FROM my_table;

-- We write it to a csv for future use
COPY my_table TO my_table.csv;
```

```text
┌──────────┬──────────┐
│ column_1 │ column_2 │
│  int64   │  int32   │
├──────────┼──────────┤
│        1 │       27 │
│        2 │       45 │
│        3 │        2 │
│        4 │       84 │
│        5 │       84 │
│        6 │       26 │
│        7 │       18 │
│        8 │       65 │
│        9 │       97 │
│       10 │       11 │
├──────────┴──────────┤
│ 10 rows   2 columns │
└─────────────────────┘
```

If we wanted to calculate the distribution of the cumulative sum of the table we could use the `OVER` clause to perform the sum of `column_2` in the order defined by `column_1`.

```duckdb
SELECT *, sum(column_2) OVER (ORDER by column_1) AS cumulative_sum FROM my_table
```

```text
┌──────────┬──────────┬────────────────┐
│ column_1 │ column_2 │ cumulative_sum │
│  int64   │  int32   │     int128     │
├──────────┼──────────┼────────────────┤
│        1 │       27 │             27 │
│        2 │       45 │             72 │
│        3 │        2 │             74 │
│        4 │       84 │            158 │
│        5 │       84 │            242 │
│        6 │       26 │            268 │
│        7 │       18 │            286 │
│        8 │       65 │            351 │
│        9 │       97 │            448 │
│       10 │       11 │            459 │
├──────────┴──────────┴────────────────┤
│ 10 rows                    3 columns │
└──────────────────────────────────────┘
```

The cumulative sum can be pretty handy to get a general notion of a distribution. As a bonus tip, I'll show how to use duckdb in a one-liner to plot the data
 directly in a terminal by using [gnuplot](https://gnuplotting.org/).

```shell
duckdb -csv -c "
    SELECT *, sum(column_2) OVER (ORDER by column_1) AS cumulative_sum
    FROM read_csv('my_table.csv');" |
    gnuplot -e "
    set terminal dumb;
    set datafile separator ',';
    set style data histograms;
    set style fill solid 1.00 border -1;
    set xlabel 'Column 1';
    set ylabel 'CSum';
    set title 'Cumulative Sum of values';
    plot '-' using 3:xtic(1);" |
    tr -d '\014' # Remove a pesky ^L at the top
```

```text


                              Cumulative Sum of values
     500 +-----------------------------------------------------------------+
         |          +     +    +     +    +     +    +     +    +    ++    |
     450 |-+                                   '-' using 3:xtic+-+ +-||--+-|
     400 |-+                                                   |#|   ||  +-|
         |                                                     |#|   ||    |
     350 |-+                                              ++   |#|   ||  +-|
         |                                                ||   |#|   ||    |
     300 |-+                                        +-+   ||   |#|   ||  +-|
     250 |-+                                   ++   |#|   ||   |#|   ||  +-|
CSum     |                               +-+   ||   |#|   ||   |#|   ||    |
     200 |-+                             |#|   ||   |#|   ||   |#|   ||  +-|
         |                               |#|   ||   |#|   ||   |#|   ||    |
     150 |-+                        ++   |#|   ||   |#|   ||   |#|   ||  +-|
         |                          ||   |#|   ||   |#|   ||   |#|   ||    |
     100 |-+                  +-+   ||   |#|   ||   |#|   ||   |#|   ||  +-|
      50 |-+             ++   |#|   ||   |#|   ||   |#|   ||   |#|   ||  +-|
         |         +-+   ||   |#|   ||   |#|   ||   |#|   ||   |#|   ||    |
       0 +-----------------------------------------------------------------+
                    1     2    3     4    5     6    7     8    9    10
                                      Column 1

```

We get a cute ascii-like plot! That is a bit too long of a "one-liner", I'll go through the commands:

-   Run a `duckdb` command (`-c`) that reads the previously-saved table. The `-csv` flag at the starts converts the output to csv.
-   Run gnuplot with certain specifications:
    -   The flag `-e` Allows to pass a series of commands without an interactive session.
    -   `set terminal dumb`: it will send as plain text to stdout.
    -   `set datafiler separator ","`: The input is a CSV file.
    -   `set style data histograms`: Changes the plotting style into a barplot.
    -   `set style fill solid ...`: Visual adjustments to the bars for clarity.
    -   `set xlabel ...` Adds the axis labels. Similar for `ylabel` and `title`.
    -   `plot '-' using 3:xtic(1)`: Use stdin data to Plot the columns 3 on the y axis (`cumulative_sum`) and the first column in the x-axis (`column_1`).
-   Lastly, use the `tr` command line tool to remove a `^L` That appeared at the start of the output and was bothering me too much.

While there are a many other ways to wrangle tables such as via pandas or polars in Python, I find duckdb to be a powerful tool for exploratory analyses and data wrangling (often from within Python). It is flexible enough to be used by itself, via bindings in another language, or directly on the command line. Lastly, I showed that when used as a Command Line Interface (CLI) duckdb synergises with other tools for data visualisation from the comfort(?) of the terminal.

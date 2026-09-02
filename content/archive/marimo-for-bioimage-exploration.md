+++
title = "A workflow for bioimaging and data exploration"
author = ["Alán F. Muñoz"]
date = 2025-07-30T13:05:00-04:00
tags = ["marimo", "dataviz", "tools", "demo"]
categories = ["post"]
draft = false
+++

One of the common challenges when analysing large bioimaging datasets is to bring it all together in one place. I usually use tools like [DuckDB](https://duckdb.org/) for database querying and [copairs](https://github.com/cytomining/copairs) for selecting statistically significant subsets of the data. For one of my recent projects I built a [marimo](https://github.com/marimo-team/marimo) interface to explore the result of large-scale (~2TB images, ~2GB feature profiles) image-based profiles, then performs dimensionality reduction of the data, and finally retrieves back the images. This I think is the ideal workflow, one where you can be nimble and pull up the images alongside statistical analyses to be able to interpret the data structure in the biological context. The code is not yet available to the public, but you can find the demo [here](https://youtu.be/l0ujUNGEXMc).

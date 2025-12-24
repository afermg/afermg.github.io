+++
title = "Use dired-do-shell to explore the parquet schema from Emacs"
author = ["Alán F. Muñoz"]
date = 2025-10-23T15:21:00-04:00
tags = ["emacs", "dired", "duckdb"]
categories = ["til"]
draft = false
+++

I use `dired-do-shell` command in Emacs to run CLI commands from within its file manager [dired](https://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html). This workflow makes it easy to perform batch operations on files that would be annoying otherwise. The trouble arose when trying to use the `duckdb` CLI to print the schema of a parquet file, as the notation for wildcards in emacs (`*` and `?`) conflicts with duckdb's usage of the former. Thus running the following after `M-x dired-do-shell` (bound to `!` in `dired-mode`) did not work:

```shell
duckdb -c "DESCRIBE * FROM read_parquet('?')"
```

I am trying to get Emacs to substitute `?` for the selected file(s) in dired and retain `*` as a normal duckdb wildcard (for which it means "get all columns"), but Emacs interprets the star as a wildcard and not the question mark. Thus Emacs yapped about it:

> dired-do-shell-command: You can not combine ‘\*’ and ‘?’ substitution marks

The trick is that we need to surround `?` with backquotes (`` ` ``), otherwise the spaces will be in the file name that `read_parquet` ingests. To fix the "naked star" problem (which Emacs will try to substitute) we can envelop it with the `COLUMNS()` command, and the lack of spaces around `*` will prevent Emacs from substituting its value. Thus the following command in the Emacs command line does the trick:

```shell
duckdb -c "DESCRIBE COLUMNS(*) FROM read_parquet('`?`')"
```

Which is a bit verbose but I can easily reuse from my command history to explore the schemas or parquets without leaving the dired buffer.

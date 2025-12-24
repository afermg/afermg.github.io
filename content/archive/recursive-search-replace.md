+++
title = "Recursive search and replace"
author = ["Alán F. Muñoz"]
date = 2025-08-12T13:07:00-04:00
tags = ["ripgrep", "oneliner", "textediting"]
categories = ["til"]
draft = false
+++

I needed to rename all occurrences of a pattern with another, where I knew there was no ambiguous situations. This uses `ripgrep`, `xargs` and `GNU sed`. [source](https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#search-and-replace).

```shell
rg old_pattern --files-with-matches | xargs sed -i 's/old_pattern/new_pattern/g'
```

+++
title = "Recursive search and replace"
author = ["Alán F. Muñoz"]
tags = ["rg"]
categories = ["til"]
draft = false
+++

It uses `ripgrep`, `xargs` and `GNU sed`. [source](https://github.com/BurntSushi/ripgrep/blob/master/FAQ.md#search-and-replace).

```shell
rg old_pattern --files-with-matches | xargs sed -i 's/old_pattern/new_pattern/g'
```

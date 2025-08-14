+++
title = "Update figure numbering"
author = ["Alán F. Muñoz"]
date = 2025-08-14T15:42:00-04:00
tags = ["awk", "textediting"]
categories = ["script"]
draft = false
+++

I was editing some markdown and had to insert a new figure in the middle. The problem is that this document already has an explicit figure numbering (e.g., "Figure 5"), so changing tens of figures felt dull. I like to run small (GNU) `awk` scripts for this type of tasks.

```awk
# update_figures.awk
{
    if (match($0, "Figure ([0-9]+)", num)){
           if (num[1] > after){
               gsub("Figure ([0-9]+)", "Figure " num[1] + increase_by)
           }
    };
    print $0
}
```

This changes Figure `X`  into Figure `X` + `increase_by` starting after the variable "after".  And we can run it as follows:

```shell
awk -v after=4 -v increase_by=1 -f update_figures.awk input_file.md
```

To edit the file in-place add the `-i` flag.

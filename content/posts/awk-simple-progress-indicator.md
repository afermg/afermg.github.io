+++
title = "Simple progress indicators with awk"
author = ["Alán F. Muñoz"]
date = 2025-08-19T18:58:00-04:00
tags = ["awk", "find", "watch"]
categories = ["script"]
draft = false
+++

I wanted a simple way to see the progress of a data processing pipeline, and the internal progress bar tools were messed up by threading. I thus decided to use the number of output files in each folder as an indicator of progress. In my case the output of \`tree .\` looks like this:

> .
> └── steps
>     ├── A01_001
>     │   ├── segment_nuclei
>     │   │   ├── 0000.npz
>     │   │   ├── 0001.npz
>     │   │   ├── ...
>     │   │   └── 0019.npz
>     │   ├── tile
>     │   │   ├── 0000.npz
>     │   │   ├── 0001.npz
>     │   │   ├── ...

I can get the info I need by counting the total number of files and the occurrences of the \`A01_001\`-&gt;\`P24_005\` (these are fields of view from a microscopy experiment). Using this simple `find` command we get all the files in the current folder.

```bash
`find . -type f`
```

which results in this:

> ./steps:
> ./steps/A01_003/tile/0007.npz
> ./steps/A01_003/tile/0009.npz
> ./steps/A01_003/tile/0018.npz
> ./steps/A01_003/tile/0016.npz
> ...

We could easily use \`wc -l\` to get the number of files per directory, we want a bunch of progress bars to get a better sense of change over time. For this I use \`awk\`, my swiss-army knife for text processing, and I write a short script that counts, [sorts](https://stackoverflow.com/a/68371463) and [prints](https://stackoverflow.com/a/68371463) the number of occurrences as a number of dots:

```awk
# progress_bar.awk
{
  if (match($0,"([A-P][0-9]{2}_[0-9]{3})", capture)){
      count[capture[1]] += 1
    }

}
END{
    n=asorti(count, sorted)
    for (i=1; i<=n; i++){
        s = sprintf(key "%*s", count[sorted[i]], "");
        gsub(".", ".", s)
        print sorted[i] " " s
    }
}
```

Running the \`find\` command and the \`awk\` script (\`find . type -f | awk -f progress_bar.awk\`) yields the following snapshot of the processing progess

> A01_001 ...............................................................
> A01_002 ...............................................................
> A01_003 ...............................................................
> A01_004 ...............................................................
> A01_005 ...............................................................
> A02_001 ...............................................................
> A02_002 ...............................................................
> A02_003 .................................................
> A02_004 ..........................................
> A02_005 ........................................
> A03_001 ..............................................

Thus the last thing to do is to use \`watch\` to automatically refresh the status:

\`watch --interval 1 'find . type -f | awk -f progress_bar.awk'\`

Which I like to keep running somewhere in another terminal or in a \`screen\` terminal multiplexer. When the number of rows becomes too many it may be useful find a heuristic to remove uninformative lines.

+++
title = "Run multiple python scripts in the background"
author = ["Alán F. Muñoz"]
date = 2025-08-26T14:29:00-04:00
tags = ["screen", "nahual", "shell", "nix"]
categories = ["script"]
draft = false
+++

To solve a multitude of challenges I have faced when processing high throughput microscopy data, have developed [Nahual](https://github.com/afermg/nahual), a tool that allows me to move data across multiple Python environments that deploy deep learning models in the background. I usually keep these models "listening" in the background for the main analysis pipeline ([aliby](https://github.com/afermg/aliby)) to send them data to process. To be able to monitor what's going on inside of these scripts I use [GNU screen](https://www.gnu.org/software/screen/), which allows me to detach and reattach into these sessions whenever I need to. At some point I had to reboot my server and had rerun all these in independent screens. This rudimentary shell script did the job:

```shell
cd cellpose
screen -d -S cellpose1 -m bash -c 'nix develop . --command bash -c "python server.py ipc:///tmp/cellpose1.ipc"'
screen -d -S cellpose2 -m bash -c 'nix develop . --command bash -c "python server.py ipc:///tmp/cellpose2.ipc"'
cd ../trackastra
screen -d -S trackastra -m bash -c 'nix develop . --command bash -c "python server.py ipc:///tmp/trackastra.ipc"'
cd ..
```

Basically the screen runs my Nix environment and deploys the model (in this case, my [fork](https://github.com/afermg/nahual) of cellpose with Nix dependency management) while detached. This executes a `server.py` file within the Nix enviroment, it runs on a loop waiting to receive data and process it. Automatically deploying to multiple screens reduces the annoyance of having to the usual steps of (go to the folder -&gt; run screen -&gt; Nix environment -&gt; run Python server -&gt; Detach screen session). I just add more models if I want further deployments, put it in a bash script and call it a day.

To access any of these screens for inspection I just use the name indicated after the `-S` flag (e.g., `screen -r cellpose1`). This way I can check if any issue crops up in the main analysis script or pipeline.

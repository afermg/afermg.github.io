```nix
{
  pkgs,
  nix2container,
  outputs,
  ...
}:
pkgs.dockerTools.buildImage {
  name = "ghcr.io/GROUP/NAME";
  tag = "dev";
  config = {
    Cmd = [
      "${outputs.packages.${pkgs.system}.package}/python"
      "server.py"
    ];
  };
}
```

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs_master.url = "github:NixOS/nixpkgs/master";
    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.cudaSupport = true;
        };

        mpkgs = import inputs.nixpkgs_master {
          inherit system;
          config.allowUnfree = true;
          config.cudaSupport = true;
        };

        libList =
          [
            # Add needed packages here
            pkgs.stdenv.cc.cc
            pkgs.libGL
            pkgs.glib
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            # This is required for most app that uses graphics api
            pkgs.linuxPackages.nvidia_x11
          ];
      in
      with pkgs;
      {
        devShells = {
          default = mkShell {
              packages = [
                    texliveFull
                    python311Packages.pygments
                    # texliveBasic.withPackages("minted")
	                  emacs29
                    line-awesome
                    crimson-pro
                    noto-fonts
              ];
          };
        };
      }
    );
}

{
  description = "A flake to set up minimal devShells outputs with flake-parts module.";

  inputs = {
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
  };

  outputs = inputs: {
    lib = import ./lib.nix {
      inherit (inputs.nixpkgs-lib) lib;
    };

    overlay = inputs.self.overlays.default;
    overlays.default = final: prev: {
      mkMinimalShell = final.callPackage ./package.nix {
        minimal-shell-lib = inputs.self.lib;
      };
    };

    flakeModule = inputs.self.flakeModules.default;
    flakeModules.default = ./flake-module.nix;
  };
}

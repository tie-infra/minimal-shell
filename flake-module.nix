{ lib, flake-parts-lib, minimal-shell-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (minimal-shell-lib) minimalShellType;
in
{
  config._module.args.minimal-shell-lib = import ./lib.nix {
    inherit lib;
  };

  options = {
    perSystem = mkPerSystemOption ({ pkgs, config, ... }:
      let
        mkMinimalShell = pkgs.callPackage ./package.nix {
          inherit minimal-shell-lib;
        };
      in
      {
        options.minimalShells = lib.mkOption {
          type = lib.types.lazyAttrsOf minimalShellType;
          default = { };
          description = lib.mdDoc ''
            Configure `devShells` with minimal shell environment for direnv.
          '';
        };

        config.devShells = lib.mapAttrs
          (name: cfg: mkMinimalShell {
            inherit name;
            exports = cfg.exports or [ ];
            packages = cfg.packages or cfg;
          })
          config.minimalShells;
      });
  };
}

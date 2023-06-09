{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;

  mkMinimalShell = pkgs: name: programs: exports: builtins.derivation {
    inherit (pkgs) system;
    inherit name;

    builder = pkgs.stdenv.shell;
    args = [ "-c" "export >$out" ];
    outputs = [ "out" ];

    stdenv = pkgs.writeTextFile {
      name = "setup-${name}";
      executable = true;
      destination = "/setup";
      text = ''
        export -n outputs out
        export -n builder name stdenv system
        export -n dontAddDisableDepTrack
        export -n NIX_BUILD_CORES NIX_STORE
        export -n IN_NIX_SHELL
        PATH=${lib.makeBinPath programs}
        ${lib.concatLines (map (env: "export ${lib.escapeShellArg env}") exports)}
      '';
    };
  };

  packageListType = lib.types.listOf lib.types.package;

  minimalShellType = lib.types.either packageListType (lib.types.submodule {
    options = {
      packages = lib.mkOption {
        type = packageListType;
        default = [ ];
        description = lib.mdDoc ''
          Packages to add to the PATH environment variable.
        '';
      };
      exports = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = lib.mdDoc ''
          Additional environment variables to export.
        '';
      };
    };
  });
in
{
  options = {
    perSystem = mkPerSystemOption ({ pkgs, config, ... }: {
      options.minimalShells = lib.mkOption {
        type = lib.types.lazyAttrsOf minimalShellType;
        default = { };
        description = lib.mdDoc ''
          Configure `devShells` with minimal shell environment for direnv.
        '';
      };

      config.devShells = lib.mapAttrs
        (name: cfg:
          mkMinimalShell pkgs
            (lib.strings.sanitizeDerivationName name)
            (cfg.packages or cfg)
            (cfg.exports or [ ])
        )
        config.minimalShells;
    });
  };
}

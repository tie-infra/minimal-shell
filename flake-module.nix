{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;

  mkMinimalShell = pkgs: name: programs: builtins.derivation {
    inherit (pkgs) system;
    inherit name;

    builder = pkgs.stdenv.shell;
    args = [ "-c" "export >$out" ];
    outputs = [ "out" ];

    stdenv = pkgs.writeTextFile {
      name = "setup";
      executable = true;
      destination = "/setup";
      text = ''
        export -n outputs out
        export -n builder name stdenv system
        export -n dontAddDisableDepTrack
        export -n NIX_BUILD_CORES NIX_STORE
        export -n IN_NIX_SHELL
        PATH=${lib.makeBinPath programs}
      '';
    };
  };
in
{
  options = {
    perSystem = mkPerSystemOption ({ pkgs, config, ... }: {
      options.minimalShells = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.listOf lib.types.package);
        default = { };
        description = lib.mdDoc ''
          Configure `devShells` with minimal shell environment for direnv.
        '';
      };

      config.devShells = lib.mapAttrs (name: programs: mkMinimalShell pkgs (lib.strings.sanitizeDerivationName name) programs) config.minimalShells;
    });
  };
}

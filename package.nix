{ lib, stdenv, minimal-shell-lib }:
let
  inherit (lib.strings) sanitizeDerivationName escapeShellArg;
  inherit (minimal-shell-lib) mkMinimalShell;
in
{ name ? "minimal-shell", ... }@args:
mkMinimalShell (builtins.removeAttrs args [ "name" ] // {
  drvAttrs = {
    name = sanitizeDerivationName name;
    inherit (stdenv.buildPlatform) system;
    builder = stdenv.shell;
    args = [ "-c" "export >${escapeShellArg (placeholder "out")}" ];
  };
})

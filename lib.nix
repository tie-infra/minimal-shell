{ lib }:
let
  packageListType = lib.types.listOf lib.types.package;
  drvAttrsStub = {
    name = "minimal-shell";
    system = "x";
    builder = "x";
  };
in
lib.makeExtensible (self: {
  stdenv = ./stdenv;

  mkMinimalShell =
    { drvAttrs ? drvAttrsStub
    , exports ? [ ]
    , packages ? [ ]
    }:
      assert builtins.langVersion >= 5; # For structured attributes.
      builtins.derivation (drvAttrs // {
        outputs = [ "out" ];
        stdenv = self.stdenv;
        inherit exports;
        # Reverse packages list so that paths are prepended to the PATH in the
        # list order.
        packages = lib.reverseList packages;
        __structuredAttrs = true;
      });

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
})

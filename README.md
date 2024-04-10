# Minimal Shell

A module for [flake-parts](https://flake.parts) to set up minimal `devShell` outputs, mostly intended for use with [direnv](https://direnv.net).

Example:

<details>
<summary>.envrc</summary>

```
use flake
```
</details>

<details>
<summary>flake.nix</summary>

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs";
    systems.url = "systems";
    flake-parts.url = "flake-parts";
    minimal-shell.url = "github:tie-infra/minimal-shell";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [ inputs.minimal-shell.flakeModules.default ];
    perSystem = { system, pkgs, ... }: {
      minimalShells = {
        # Add packages to PATH.
        default = with pkgs; [
          nixpkgs-fmt
        ];
        # Set additional environment variables.
        direnv-nocolor = {
          packages = [ pkgs.nixpkgs-fmt ];
          exports = [ "NO_COLOR=1" ];
        };
      };
      # Use with Nixpkgs overlay.
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.minimal-shell.overlays.default ];
      };
      devShells.direnv-python = pkgs.mkMinimalShell {
        name = "direnv-python";
        packages = [ pkgs.python3 ];
        exports = [ "PYTHONDONTWRITEBYTECODE=1" ];
      };
    };
  };
}
```
</details>

Minimal shell is similar to [devshell](https://numtide.github.io/devshell), except that there are no bells and whistles.

```
direnv: export ~PATH
```

With devshell:
```
direnv: export +DEVSHELL_DIR +PRJ_DATA_DIR +PRJ_ROOT +IN_NIX_SHELL +NIXPKGS_PATH ~PATH
```

With mkShell from nixpkgs:
```
direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_aarch64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_aarch64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_LDFLAGS +NIX_STORE +NM +OBJCOPY +OBJDUMP +RANLIB +READELF +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +__structuredAttrs +buildInputs +buildPhase +builder +cmakeFlags +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +dontAddDisableDepTrack +mesonFlags +name +nativeBuildInputs +out +outputs +patches +phases +preferLocalBuild +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH ~XDG_DATA_DIRS
```

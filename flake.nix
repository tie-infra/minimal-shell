{
  description = "A module for flake-parts to set up minimal devShells outputs.";
  outputs = _:
    let flakeModule = import ./flake-module.nix; in {
      inherit flakeModule;
      flakeModules.default = flakeModule;
    };
}

{
  description = "Per-project Tokyo Night background colors for iTerm2";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./package.nix { };
      });

      # Usage (home-manager):
      #   imports = [ inputs.iterm-color.homeManagerModules.default ];
      #   programs.iterm-color.enable = true;
      homeManagerModules.default = import ./module.nix self;
    };
}

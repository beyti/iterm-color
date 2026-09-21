self:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.iterm-color;
in
{
  options.programs.iterm-color = {
    enable = lib.mkEnableOption "per-project iTerm2 background colors";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "iterm-color.packages.\${system}.default";
      description = "The iterm-color package to source.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.initContent = ''
      # per-project iTerm2 background colors
      source ${cfg.package}/share/iterm-color/iterm-color.zsh
    '';
  };
}

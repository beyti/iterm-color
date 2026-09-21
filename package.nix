{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "iterm-color";
  version = "0.1.0";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = ./iterm-color.zsh;
  };

  dontBuild = true;
  installPhase = ''
    install -Dm644 iterm-color.zsh $out/share/iterm-color/iterm-color.zsh
  '';

  meta = {
    description = "Per-project Tokyo Night background colors for iTerm2";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}

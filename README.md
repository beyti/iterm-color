# iterm-color

Per-project background colors for iTerm2, in the [Tokyo Night](https://tokyonight.org/palette/)
palette. Every window/tab colors itself from the git repo root (or directory
name) you're sitting in — same project, same color, every time.

Backgrounds take each Tokyo Night accent's hue, strongly saturated and kept dark
enough for light text; the tab color is the accent itself.

## Install

### Nix (home-manager)

```nix
# flake.nix
inputs.iterm-color.url = "github:beyti/iterm-color";
inputs.iterm-color.inputs.nixpkgs.follows = "nixpkgs";

# home.nix
imports = [ inputs.iterm-color.homeManagerModules.default ];
programs.iterm-color.enable = true;
```

This appends a `source` line to `programs.zsh.initContent`, so it needs
`programs.zsh.enable = true`.

### Manually

    source /path/to/iterm-color/iterm-color.zsh   # in ~/.zshrc

## Usage

    itc              # show current project + color
    itc colors       # list the palette
    itc pin magenta   # force this project's color (or a raw hex: itc pin 2a1b3d)
    itc unpin
    itc pins         # ~/.config/iterm-color/pins
    itc off          # restore the profile's default for this session

Colors: blue cyan sky mint green yellow orange red magenta.

Colors are picked by `cksum` of the project name, so they're stable across
shells and reboots. 9 colors means occasional collisions — `itc pin` those.
Disabled under tmux and over ssh.

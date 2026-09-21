# iterm-color

Per-project background colors for iTerm2, in the [Tokyo Night](https://tokyonight.org/palette/)
palette. Every window/tab colors itself from the git repo root (or directory
name) you're sitting in — same project, same color, every time.

Backgrounds are each Tokyo Night accent blended 16% into the Night background
(`#1a1b26`), so text stays readable; the tab color is the accent itself.

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
    itc pin purple   # force this project's color (or a raw hex: itc pin 2a1b3d)
    itc unpin
    itc pins         # ~/.config/iterm-color/pins
    itc off          # restore the profile's default for this session

Colors: blue cyan sky green mint teal magenta purple orange yellow red crimson.

Colors are picked by `cksum` of the project name, so they're stable across
shells and reboots. 12 colors means occasional collisions — `itc pin` those.
Disabled under tmux and over ssh.

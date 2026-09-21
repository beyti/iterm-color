# iterm-color.zsh — per-project background colors for iTerm2
#
#   source /path/to/iterm-color.zsh   # from ~/.zshrc (or use the Nix flake)
#
# Each project (git repo root, else the current directory) gets a stable
# Tokyo Night color derived from a hash of its name — the same color in
# every window you open, forever.
# Pin a specific color with:  itc pin blue

# --- guards -----------------------------------------------------------------
[[ -o interactive ]] || return 0
[[ "$TERM_PROGRAM" == "iTerm.app" ]] || return 0
[[ -n "$TMUX" || -n "$SSH_TTY" ]] && return 0

# --- palette ----------------------------------------------------------------
# Tokyo Night accents (https://tokyonight.org/palette/). Tab = the accent
# itself; background = the accent's hue at 75% saturation, 14% lightness —
# vivid but dark enough for light text. Near-identical hues were dropped.
typeset -gA ITC_BG ITC_TAB
ITC_BG=(
  blue    091a3e  cyan    092b3e  sky     09363e  mint    093e36  green   253e09
  yellow  3e2909  orange  3e1d09  red     3e0913  pink    3e0923  magenta 1c093e
)
ITC_TAB=(
  blue    7aa2f7  cyan    7dcfff  sky     2ac3de  mint    73daca  green   9ece6a
  yellow  e0af68  orange  ff9e64  red     f7768e  pink    ff007c  magenta bb9af7
)
typeset -ga ITC_NAMES=(blue cyan sky mint green yellow orange red pink magenta)

ITC_PIN_FILE="${ITC_PIN_FILE:-$HOME/.config/iterm-color/pins}"

# --- helpers ----------------------------------------------------------------
_itc_project() {
  local root
  root=$(command git rev-parse --show-toplevel 2>/dev/null)
  [[ -n "$root" ]] && { print -r -- "${root:t}"; return }
  # Not a repo: only color named project dirs, not $HOME or /
  [[ "$PWD" == "$HOME" || "$PWD" == "/" ]] && return 1
  print -r -- "${PWD:t}"
}

_itc_pinned() {
  [[ -f "$ITC_PIN_FILE" ]] || return 1
  local line
  line=$(command grep -m1 "^${1}=" "$ITC_PIN_FILE" 2>/dev/null) || return 1
  print -r -- "${line#*=}"
}

_itc_hash_color() {
  # stable across shells and reboots (unlike $RANDOM or zsh hashing)
  local sum=$(print -rn -- "$1" | command cksum | command awk '{print $1}')
  print -r -- "${ITC_NAMES[$(( sum % ${#ITC_NAMES} + 1 ))]}"
}

_itc_apply() {
  local bg=$1 tab=$2
  if [[ "$bg" == "default" ]]; then
    printf '\033]1337;SetColors=bg=default\007'
    printf '\033]6;1;bg;*;default\007'
  else
    printf '\033]1337;SetColors=bg=%s\007' "$bg"
    printf '\033]6;1;bg;red;brightness;%d\007'   $((16#${tab:0:2}))
    printf '\033]6;1;bg;green;brightness;%d\007' $((16#${tab:2:2}))
    printf '\033]6;1;bg;blue;brightness;%d\007'  $((16#${tab:4:2}))
  fi
}

_itc_update() {
  local proj color
  proj=$(_itc_project) || { _itc_apply default; ITC_CURRENT=; return }
  color=$(_itc_pinned "$proj") || color=$(_itc_hash_color "$proj")
  # allow a pin to be a raw hex value too
  local bg=${ITC_BG[$color]:-$color} tab=${ITC_TAB[$color]:-$color}
  ITC_CURRENT="$proj:$color"
  _itc_apply "$bg" "$tab"
}

# --- the `itc` command ------------------------------------------------------
itc() {
  local proj
  case "$1" in
    pin)
      proj=$(_itc_project) || { print -u2 "itc: not in a project"; return 1 }
      [[ -n "$2" ]] || { print -u2 "usage: itc pin <color|hex>"; return 1 }
      command mkdir -p "${ITC_PIN_FILE:h}"
      command touch "$ITC_PIN_FILE"
      command sed -i '' "/^${proj}=/d" "$ITC_PIN_FILE" 2>/dev/null
      print -r -- "${proj}=${2}" >> "$ITC_PIN_FILE"
      _itc_update
      print "pinned $proj -> $2"
      ;;
    unpin)
      proj=$(_itc_project) || return 1
      [[ -f "$ITC_PIN_FILE" ]] && command sed -i '' "/^${proj}=/d" "$ITC_PIN_FILE"
      _itc_update
      print "unpinned $proj"
      ;;
    pins)   [[ -f "$ITC_PIN_FILE" ]] && command cat "$ITC_PIN_FILE" ;;
    colors) local c; for c in $ITC_NAMES; do print -r -- "  $c  #${ITC_BG[$c]}"; done ;;
    which)  print -r -- "${ITC_CURRENT:-none}" ;;
    off)    _itc_apply default; ITC_CURRENT= ;;
    on|"")  _itc_update; print -r -- "${ITC_CURRENT:-none}" ;;
    *)      print -u2 "usage: itc [pin <color>|unpin|pins|colors|which|off|on]"; return 1 ;;
  esac
}

# --- hooks ------------------------------------------------------------------
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _itc_update
_itc_update

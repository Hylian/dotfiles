# Setup Antigen
ANTIGEN_PATH_DEBIAN=/usr/share/zsh-antigen/antigen.zsh
ANTIGEN_PATH_ARCH=/usr/share/zsh/share/antigen.zsh
ANTIGEN_PATH_MAC=/opt/homebrew/share/antigen/antigen.zsh
has_antigen=false

if [[ "$OSTYPE" == "darwin"* ]]; then
  source $ANTIGEN_PATH_MAC
  has_antigen=true
elif test -f "$ANTIGEN_PATH_ARCH"; then
  source $ANTIGEN_PATH_ARCH
  has_antigen=true
elif test -f "$ANTIGEN_PATH_DEBIAN"; then
  source $ANTIGEN_PATH_DEBIAN
  has_antigen=true
fi

if [ "$has_antigen" = true ]; then
  antigen use oh-my-zsh

  antigen bundle direnv
  antigen bundle fd
  antigen bundle pip
  antigen bundle ripgrep
  antigen bundle jeffreytse/zsh-vi-mode
  antigen bundle zsh-users/zsh-autosuggestions
  antigen bundle fzf

  antigen theme minimal

  antigen apply
fi

plugins=(direnv)

DISABLE_UNTRACKED_FILES_DIRTY="true"
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

export PATH="$HOME/.local/bin:$PATH"
if test -f "$HOME/dotfiles/.config/zsh/paths"; then
  source $HOME/dotfiles/.config/zsh/aliases
fi

export KEYTIMEOUT=5
export WINEARCH=win32
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export BAT_THEME="ansi"

if test -f "$HOME/dotfiles/.config/zsh/aliases"; then
  source $HOME/dotfiles/.config/zsh/aliases
fi

if test -f "$HOME/dotfiles/.config/zsh/galiases"; then
  source $HOME/dotfiles/.config/zsh/galiases
fi

eval "$(zellij setup --generate-auto-start zsh)"
eval "$(zoxide init zsh --cmd j)"
eval "$(starship init zsh)"

# Zsh Hooks
function refresh {
  if [ -n "$TMUX" ] && [ -n "$SSH_TTY" ] && [ -n "$WAYLAND_DISPLAY" ]; then
    export $(tmux show-env WAYLAND_DISPLAY 2> /dev/null)
  elif [ -n "$ZELLIJ" ] && [ -f /tmp/wayland_display ]; then
    export WAYLAND_DISPLAY=$(< /tmp/wayland_display)
  fi
}

function preexec {
  refresh
}

precmd() {
    print -Pn "\e]133;A\e\\"
}

function osc7 {
  local LC_ALL=C
  export LC_ALL

  setopt localoptions extendedglob
  input=( ${(s::)PWD} )
  uri=${(j::)input/(#b)([^A-Za-z0-9_.\!~*\'\(\)-\/])/%${(l:2::0:)$(([##16]#match))}}
  print -n "\e]7;file://${HOSTNAME}${uri}\e\\"
}
add-zsh-hook -Uz chpwd osc7

# FZF
export FZF_ALT_C_OPTS="--preview 'tree -L 1 -C {}'"
export FZF_ALT_C_COMMAND="fd -t d -t l -d 3"
export FZF_DEFAULT_OPTS='--color=bg+:#f3f5d9,fg:#5c6a72,fg+:#5c6a72,border:#8da101,spinner:#f85552,hl:#f85552,header:#dfa000,info:#35a77c,pointer:#f85552,marker:#f85552,prompt:#fffbef,hl+:#fa8987'

zvm_after_init_commands+=('source <(fzf --zsh)')

# Widgets
if test -f "$HOME/dotfiles/.config/zsh/widgets"; then
  source $HOME/dotfiles/.config/zsh/widgets
fi

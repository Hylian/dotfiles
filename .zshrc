# Setup Antigen
ANTIGEN_PATH_DEBIAN=/usr/share/zsh-antigen/antigen.zsh
ANTIGEN_PATH_ARCH=/usr/share/zsh/share/antigen.zsh
has_antigen=false

if test -f "$ANTIGEN_PATH_ARCH"; then
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
  antigen bundle fzf
  antigen bundle pip
  antigen bundle ripgrep
  antigen bundle rust
  antigen bundle zsh-users/zsh-autosuggestions

  antigen theme minimal

  antigen apply
fi

DISABLE_UNTRACKED_FILES_DIRTY="true"

export PATH="$HOME/.local/bin:$PATH"
export KEYTIMEOUT=1
export WINEARCH=win32

source $HOME/.aliases

if (( $+commands[nvim] )); then
  export VISUAL=nvim
  export EDITOR="$VISUAL"
fi

if (( $+commands[sccache] )); then
  export RUSTC_WRAPPER=sccache
fi

if (( $+commands[exa] )); then
  function chpwd() {
    emulate -L zsh
    exa
  }
fi

if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=rg 
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias rg=tag
fi

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND="fd"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi


eval "$(zoxide init zsh --cmd j)"
eval "$(starship init zsh)"

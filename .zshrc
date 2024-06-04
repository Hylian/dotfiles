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
  antigen bundle pip
  antigen bundle ripgrep
  #antigen bundle rust
  antigen bundle vi-mode
  antigen bundle zsh-users/zsh-autosuggestions
  antigen bundle fzf

  antigen theme minimal

  antigen apply
fi

DISABLE_UNTRACKED_FILES_DIRTY="true"

VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/t32/bin/pc_linux64:$PATH"
#export PATH="/usr/lib/ccache/bin:$PATH"
export KEYTIMEOUT=200
export WINEARCH=win32
#export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"


function refresh {
  if [ -n "$TMUX" ] && [ -n "$SSH_TTY" ] && [ -n "$WAYLAND_DISPLAY" ]; then
    export $(tmux show-env WAYLAND_DISPLAY 2> /dev/null)
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

if test -f "$HOME/dotfiles/.aliases"; then
  source $HOME/dotfiles/.aliases
fi

if test -f "$HOME/dotfiles/.galiases"; then
  source $HOME/dotfiles/.galiases
fi

if (( $+commands[fdfind] )); then
  alias fd="fdfind"
fi

if (( $+commands[batcat] )); then
  alias bat="batcat"
fi

if (( $+commands[nvim] )); then
  export VISUAL=nvim
  export EDITOR="$VISUAL"
fi

if (( $+commands[sccache] )); then
  export RUSTC_WRAPPER=sccache
fi

if (( $+commands[eza] )); then
  function chpwd() {
    if [[ $(pwd) != /google* ]] then
      emulate -L zsh
      eza -s modified --reverse
    fi
  }
fi

if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=rg 
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias rg=tag
fi

if (( $+commands[fdfind] )); then
  alias fd=fdfind
fi

if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND="fd"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

export FZF_ALT_C_OPTS="--preview 'tree -L 1 -C {}'"
export FZF_ALT_C_COMMAND="fd -t d -t l -d 3"

fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse --scheme=path --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} ${FZF_ALT_C_OPTS-}" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="builtin cd -- ${(q)dir}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}

# fzf to cd to a directory
cd-fzf-helper() {
  local dirlist=$(eza -1 -D -s modified -r $2)
  dirlist="$dirlist\n.."
  local fzfret=$(echo $dirlist | fzf --ansi \
    --height '40%' \
    --color prompt:green \
    --prompt 'cd> ' \
    --header "${2:2}" \
    --preview "eza -G --color=always --icons --group-directories-first -s modified ./$2/{1}" \
    --preview-window 'right,50%' \
    --bind 'pgup:preview-half-page-up' \
    --bind 'pgdn:preview-half-page-down' \
    --bind 'ctrl-delete:clear-query' \
    --bind 'btab:become(echo up)' \
    --bind 'esc:become(echo up)' \
    --bind '.:become(echo up)' \
    --bind 'tab:become(echo continue {1})' \
    --bind 'enter:become(echo done {1})' \
    --bind 'space:become(echo done .)')

  local ret=( ${=fzfret} )
  dir="$2/${ret[2]}"

  if [[ ${ret[1]} = "continue" ]]; then
    local numdirs=$(fd -I -d 1 -td --base-directory $dir | wc -l)
    if [[ $numdirs = "0" ]]; then
      # No-Op
      #cd-fzf-helper $1 $2

      # Just open the dir
      finaldir=$dir
    else
      cd-fzf-helper $(( $1 + 1 )) $dir
    fi
  elif [[ ${ret[1]} = "up" ]]; then
    local parentdir=$(dirname $dir)
    if [[ $parentdir = "." ]]; then
      finaldir=""
    else
      cd-fzf-helper $(( $1 - 1 )) $(dirname $dir)
    fi
  elif [[ ${ret[1]} = "cancel" ]]; then
    finaldir=""
  elif [[ ${ret[1]} = "done" ]]; then
    finaldir=$dir
  fi
}
zle     -N            cd-fzf-helper

cd-fzf() {
  local finaldir=""
  cd-fzf-helper 0 '.'

  if [[ -z "$finaldir" || $finaldir = "" ]]; then
    return 0
  fi

  zle push-line
  BUFFER="builtin cd -- ${(q)finaldir}"
  zle accept-line
  local ret=$?
  zle reset-prompt
  return $ret

  #echo "\n"
  #_z_cd ${finaldir}
  #zle reset-prompt
}
zle     -N            cd-fzf
bindkey -M emacs '^g' cd-fzf
bindkey -M vicmd '^g' cd-fzf
bindkey -M viins '^g' cd-fzf

# zoxide + fzf
zoxide-fzf() {
  local zoxide_prefix="zoxide query -l -s "
  local dir=$(fzf --ansi --disabled \
    --height '40%' \
    --color prompt:green \
    --prompt 'z> ' \
    --header "${2:2}" \
    --preview "eza -G --color=always --icons --group-directories-first -s modified {2}" \
    --preview-window 'top,50%' \
    --bind "start:reload:$zoxide_prefix {q}" \
    --bind "change:reload:sleep 0.02; $zoxide_prefix '{q}' || true" \
    --bind 'pgup:preview-half-page-up' \
    --bind 'pgdn:preview-half-page-down' \
    --bind 'ctrl-delete:clear-query' \
    --bind 'esc:become(echo "")' \
    --bind 'enter:become(echo {2})')

  if [[ -z "$dir" || $dir = "" ]]; then
    return 0
  fi

  zle push-input
  BUFFER="cd ${dir}"
  zle accept-line
  zle reset-prompt
}
zle     -N            zoxide-fzf
bindkey -M emacs '^j' zoxide-fzf
bindkey -M vicmd '^j' zoxide-fzf
bindkey -M viins '^j' zoxide-fzf

zoxide-fzf-curdir() {
  local zoxide_prefix="zoxide query -l -s "
  local curdir="${PWD}\/"
  local dir=$(fzf --ansi --disabled \
    --height '40%' \
    --color prompt:green \
    --prompt 'z (curdir)> ' \
    --header "${2:2}" \
    --preview "eza -G --color=always --icons --group-directories-first -s modified {2}" \
    --preview-window 'top,50%' \
    --bind "start:reload:$zoxide_prefix {q} | rg '$curdir' --replace=''" \
    --bind "change:reload:sleep 0.02; $zoxide_prefix {q} | rg '$curdir' --replace='' || true" \
    --bind 'pgup:preview-half-page-up' \
    --bind 'pgdn:preview-half-page-down' \
    --bind 'ctrl-delete:clear-query' \
    --bind 'esc:become(echo "")' \
    --bind 'enter:become(echo {2})')

  if [[ -z "$dir" || $dir = "" ]]; then
    zle reset-prompt
    return 0
  fi

  zle push-input
  BUFFER="cd ${dir}"
  zle accept-line
  zle reset-prompt
}
zle     -N            zoxide-fzf-curdir
bindkey -M emacs '^k' zoxide-fzf-curdir
bindkey -M vicmd '^k' zoxide-fzf-curdir
bindkey -M viins '^k' zoxide-fzf-curdir

# rg + fzf
rg-fzf() {
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
INITIAL_QUERY="${*:-}"
local path=$(: | fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --color prompt:green \
    --prompt "rg> " \
    --header "" \
    --bind "start:reload:$RG_PREFIX {q}" \
    --bind "change:change-header()+reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind "alt-c:change-header([C])+reload:$RG_PREFIX -tc {q} || true" \
    --bind "alt-v:change-header([C++])+reload:$RG_PREFIX -tcpp {q} || true" \
    --bind "alt-m:change-header([Makefile])+reload:$RG_PREFIX -tmake {q} || true" \
    --bind "alt-a:change-header([Android])+reload:$RG_PREFIX -tandroid {q} || true" \
    --delimiter : \
    --preview 'batcat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,40%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:become(echo {1} +{2})' \
    --bind 'ctrl-space:execute(nvim {1} +{2})' \
    --bind 'tab:execute(batcat --color=always {1} --highlight-line {2} | less)')

if [[ $path ]]; then
  zle push-input
  BUFFER="nvim $path"
  zle accept-line
fi

local ret=$?
zle reset-prompt
return $ret
}
zle     -N            rg-fzf
bindkey -M emacs '^f' rg-fzf
bindkey -M vicmd '^f' rg-fzf
bindkey -M viins '^f' rg-fzf

# vim + fzf
vim-fzf() {
local path=$(fd --type f | fzf --ansi \
    --color prompt:green \
    --prompt "nvim> " \
    --header "" \
    --height '40%' \
    --preview 'batcat --color=always {1}' \
    --preview-window 'right,50%' \
    --bind 'enter:become(echo {1})' \
    --bind 'pgup:preview-half-page-up' \
    --bind 'pgdn:preview-half-page-down' \
    --bind 'ctrl-delete:clear-query')

if [[ $path ]]; then
  zle push-input
  BUFFER="nvim $path"
  zle accept-line
fi

local ret=$?
zle reset-prompt
return $ret
}
zle     -N            vim-fzf
bindkey -M emacs '^v' vim-fzf
bindkey -M vicmd '^v' vim-fzf
bindkey -M viins '^v' vim-fzf

eval "$(zoxide init zsh --cmd j)"
eval "$(starship init zsh)"

export FZF_DEFAULT_OPTS='--color=bg+:#f3f5d9,fg:#5c6a72,fg+:#5c6a72,border:#8da101,spinner:#f85552,hl:#f85552,header:#dfa000,info:#35a77c,pointer:#f85552,marker:#f85552,prompt:#fffbef,hl+:#fa8987'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

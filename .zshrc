export ZSH="/home/shined/.oh-my-zsh"

ZSH_THEME="minimal"

DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(fzf-tab zsh-autosuggestions)
fpath=(~/.fpath $fpath)

source $ZSH/oh-my-zsh.sh

export KEYTIMEOUT=1

source /home/shined/.aliases
#export RUSTC_WRAPPER=sccache
export VISUAL=nvim
export EDITOR=nvim

function chpwd() {
  emulate -L zsh
  exa
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

. /usr/share/autojump/autojump.sh

if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=rg
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias rg=tag
fi

export C_INCLUDE_PATH="/lib/gcc/arm-none-eabi/10.3.1/include/"

export ANACONDA_HOME=$HOME/miniconda3
source $ANACONDA_HOME/etc/profile.d/conda.sh

export PATH="$HOME/.local/bin:$PATH"
export PATH="/home/shined/fitbit/bin/releases/bootstrap:${PATH}"
export PATH="/home/shined/.scripts:${PATH}"
export PATH="/home/shined/.local/bin:${PATH}"
export PATH="/home/shined/git-fuzzy/bin:$PATH"

eval "$(starship init zsh)"

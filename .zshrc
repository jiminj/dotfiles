#zmodload zsh/zprof

export EDITOR=vim

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=5000
HISTDUP=erase
setopt appendhistory
# setopt sharehistory
setopt incappendhistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

export GPG_TTY=`tty`
export LANG=en_us.UTF-8
export LC_ALL=en_us.UTF-8

[ -f ~/.zshrc-private-preload ] && source ~/.zshrc-private-preload
#
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The following lines were added by compinstall
zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename "${HOME}/.zshrc"

# End of lines added by compinstall

#For X11
#export DISPLAY=:0

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

#  Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light zsh-users/zsh-completions

# fzf-tab
zinit light Aloxaf/fzf-tab
# Ctrl+Space: select multiple results, can be configured by fzf-bindings tag
# F1/F2: switch between groups, can be configured by switch-group tag
# /: trigger continuous completion (useful when completing a deep path), can be configured by continuous-trigger tag
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 50 8
zstyle ':fzf-tab:complete:diff:*' popup-min-size 80 12
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit ice depth=1; zinit light romkatv/powerlevel10k

# history-substring-search
zinit light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
# bindkey '-e' # disable vi mode

zinit light gradle/gradle-completion
zinit light MichaelAquilina/zsh-you-should-use

# zsh-vi-mode
zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode

function zvm_before_init() {
  # ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
  # ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
  # ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
  zvm_bindkey viins '^[[A' history-substring-search-up
  zvm_bindkey viins '^[OA' history-substring-search-up
  zvm_bindkey viins '^[[B' history-substring-search-down
  zvm_bindkey viins '^[OB' history-substring-search-down
  zvm_bindkey vicmd '^[[A' history-substring-search-up
  zvm_bindkey vicmd '^[OA' history-substring-search-up
  zvm_bindkey vicmd '^[[B' history-substring-search-down
  zvm_bindkey vicmd '^[OB' history-substring-search-down
}

autoload -Uz compinit
compinit
zinit cdreplay -q

### End of Zinit's installer chunk

alias ls="ls --color=auto"

# general use
alias ls='eza'   # ls
alias l='eza -lbF --git'    # list, size, type, git
alias ll='eza -lbGF --git'  # long list
alias llm='eza -lbGd --git --sort=modified'  # long list, modified date sort
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list
# specialty views
alias lS='eza -1'   # one column, just names
alias lt='eza --tree --level=2'   # tree

source $HOME/.zshrc-local
source $HOME/.zshrc-private

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
#plugins=(git svn virtualenv apache2-macports mysql-macports macports)

# plugins=(git virtualenv docker docker-compose wd zsh-autosuggestions fast-syntax-highlighting)


#function docker_machine_active() {
    #local ref
    #if [[ ! -z $DOCKER_MACHINE_NAME ]]; then
        #ref=$DOCKER_MACHINE_NAME || return 0
        #echo "docker:(%{$fg[red]%}$ref%{$reset_color%})"
    #fi
#}
#
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
source $HOME/lazy-nvm.sh

### ALIAS
alias sudo='sudo '
alias vim='nvim'
eval $(thefuck --alias)
eval "$(zoxide init zsh)"

#zprof


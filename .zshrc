# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/.oh-my-zsh-custom

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
#ZSH_THEME="kphoen"
#ZSH_THEME="blinks"
ZSH_THEME="af-magic-docker"

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

plugins=(git svn virtualenv docker docker-compose git wd fast-syntax-highlighting)

export EDITOR=vim
eval "$(thefuck --alias)"

#For X11
#export DISPLAY=:0

source $ZSH/oh-my-zsh.sh

source $HOME/.zshrc-local
source $HOME/.zshrc-private

export LANG=en_us.UTF-8

setopt noincappendhistory
setopt nosharehistory

#function docker_machine_active() {
    #local ref
    #if [[ ! -z $DOCKER_MACHINE_NAME ]]; then
        #ref=$DOCKER_MACHINE_NAME || return 0
        #echo "docker:(%{$fg[red]%}$ref%{$reset_color%})"
    #fi
#}

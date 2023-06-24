#!/bin/bash
###########################################################
# REF: https://stackoverflow.com/questions/6883760/git-for-windows-bashrc-or-equivalent-configuration-files-for-git-bash-shell
###########################################################

## Simon's aliases and customisations

alias gotoMQL5='cd $HOME/AppData/Roaming/MetaQuotes/Terminal/9B101088254A9C260A9790D5079A7B11/MQL5'
alias python='winpty python.exe'

#eval "$(register-python-argcomplete pipx)"

set bell-style visible


# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

if [ -n "${TX_APP_NAME}" ]; then
    prompt_host="${TX_APP_NAME}(${TX_APP_ENV:-})"
else
    prompt_host=$(hostname)
fi

# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${prompt_host}: ${PWD}\007"'
    ;;
*)
    ;;
esac


# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

case "$TERM" in
    xterm*|rxvt*|*color*) color_prompt=yes;;
esac

if ! shopt -oq posix; then
    if [ -r /etc/bash_completion.d/git-prompt ]; then
        . /etc/bash_completion.d/git-prompt
    elif [ -f /usr/share/git/git-prompt.sh ]; then
        . /usr/share/git/git-prompt.sh
    fi

    if declare -F __git_ps1 > /dev/null ; then
        if [ "$color_prompt" = yes ] ; then
            if [ "$(id -u)" -eq 0 ] ; then
                # Print the root username in yellow
                PS1='\[\033[0m\]${debian_chroot:+($debian_chroot)}\n\[\033[01;33m\]\u\[\033[00;32m\]@$prompt_host \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n# '
            else
                PS1='\[\033[0m\]${debian_chroot:+($debian_chroot)}\n\[\033[32m\]\u@$prompt_host \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n\$ '
            fi
        else
            if [ "$(id -u)" -eq 0 ]; then
                PS1='${debian_chroot:+($debian_chroot)}\n\u@$prompt_host \w`__git_ps1`\n# '
            else
                PS1='${debian_chroot:+($debian_chroot)}\n\u@$prompt_host \w`__git_ps1`\n\$ '
            fi
        fi
    fi
fi

#/dev/null <<EOF
###########################################################
# Starting the SSH Agent
# REF: https://help.github.com/en/github/authenticating-to-github/working-with-ssh-key-passphrases

env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
#EOF


# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
if [ -r ~/LS_COLORS/lscolors.sh ] ; then
    source ~/LS_COLORS/lscolors.sh
else
    eval "$(dircolors)"
fi
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# Make it so that Grep puts in colour by default
# export GREP_OPTIONS='--color=auto'
alias grep='grep --color=auto'

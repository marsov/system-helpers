#!/usr/bin/env bash

#
# Common shell aliases for all Linux distributions
# This script can be sourced in your .bashrc or .zshrc
#
# Usage:
#   Add to your shell configuration file:
#   source /path/to/common-aliases.sh
#

# Docker aliases
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dprune='docker system prune -af'

# Directory listing aliases
alias l='ls -la'
alias ll='ls -lh'
alias la='ls -A'
alias lt='ls -ltr'

# Directory navigation aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Common commands
alias cls='clear'
alias h='history'
alias grep='grep --color=auto'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# System information
alias meminfo='free -h'
alias diskinfo='df -h'
alias ports='netstat -tulanp'

# Quick edit
alias edit='${EDITOR:-nano}'

# Update system (distro-specific detection)
if command -v apt-get &> /dev/null; then
	alias update='sudo apt-get update && sudo apt-get upgrade -y'
elif command -v dnf &> /dev/null; then
	alias update='sudo dnf update -y'
elif command -v yum &> /dev/null; then
	alias update='sudo yum update -y'
elif command -v pacman &> /dev/null; then
	alias update='sudo pacman -Syu'
elif command -v zypper &> /dev/null; then
	alias update='sudo zypper update -y'
fi

# Show all aliases
alias aliases='alias | less'

# Confirm aliases loaded
echo "✓ Common aliases loaded successfully"

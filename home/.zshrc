HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_FCNTL_LOCK HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

autoload -U compinit && compinit

eval "$(starship init zsh)"
nix-your-shell zsh | source /dev/stdin

alias eza='eza --icons=always --color=always --sort=type --oneline --classify=always --hyperlink=always'
alias ls=eza
alias la='eza -a'
alias ll='eza -l'
alias lla='eza -la'
alias lt='eza --tree'

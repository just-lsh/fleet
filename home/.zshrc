# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY HIST_FCNTL_LOCK HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE \
  HIST_REDUCE_BLANKS HIST_VERIFY SHARE_HISTORY

# Behaviour
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS

# Completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Up/Down search history for lines starting with what's already typed
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n ${terminfo[kcuu1]} ]] && bindkey ${terminfo[kcuu1]} up-line-or-beginning-search
[[ -n ${terminfo[kcud1]} ]] && bindkey ${terminfo[kcud1]} down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Autosuggestions: Ctrl+Space accepts the suggestion
bindkey '^ ' autosuggest-accept

# Tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
nix-your-shell zsh | source /dev/stdin

# eza as ls
alias ls='eza --icons=auto --color=auto --hyperlink=auto --classify=auto --sort=type --group-directories-first --oneline'
alias la='ls -a'
alias ll='ls -l --git'
alias lla='ls -la --git'
alias lt='ls --tree --level=2'

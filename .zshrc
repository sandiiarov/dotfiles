# ALIASES
alias ls="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first"

# ZSH plugins

## autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

## syntax highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

## fzf
source ~/.zsh/zsh-fzf/fzf-zsh-plugin.plugin.zsh
source <(fzf --zsh)

export PATH=$PATH:~/.zsh/zsh-fzf/bin
export FZF_DEFAULT_OPTS='--color=gutter:-1 --pointer=""'
export FZF_COLOR_SCHEME=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#89b4fa,hl:#a6e3a1 \
--color=fg:#cdd6f4,header:#a6e3a1,info:#cba6f7,pointer:#313244 \
--color=marker:#89b4fa,fg+:#cdd6f4,prompt:#cba6f7,hl+:#a6e3a1"

eval "$(starship init zsh)"

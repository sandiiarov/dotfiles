# ZSH plugins
# make cursor a vertical line
echo '\e[5 q'
# autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# syntax highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# fzf
export FZF_COLOR_SCHEME=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#89b4fa,hl:#a6e3a1 \
--color=fg:#cdd6f4,header:#a6e3a1,info:#cba6f7,pointer:#313244 \
--color=marker:#89b4fa,fg+:#cdd6f4,prompt:#cba6f7,hl+:#a6e3a1"
source ~/.zsh/zsh-fzf/fzf-zsh-plugin.plugin.zsh

eval "$(starship init zsh)"

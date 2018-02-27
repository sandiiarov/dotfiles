function node_prompt_version {
    if which node &> /dev/null; then
        echo "%{$fg[green]%}$(node -v) %{$reset_color%}"
    fi
}

local ret_status="%(?:%{$fg_bold[cyan]%}➜:%{$fg_bold[red]%}➜)"
PROMPT='${ret_status} $(node_prompt_version)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

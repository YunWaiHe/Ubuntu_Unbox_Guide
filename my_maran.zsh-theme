PROMPT='%{$fg[cyan]%}%n%{%f%}@%{$fg[yellow]%}%M:%{$fg[magenta]%}%~ $(git_prompt_info)$(git_prompt_status)%{%f%u%}%(?,,%{$fg[red]%})$%(?,,%{%f%}) '
RPROMPT='%{$fg[blue]%}%*%{$fg[default]%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}-dirty%{$fg[blue]%}]%{%U%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}-clean%{$fg[blue]%}]"

ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[190]%}-untracked"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[082]%}}-added"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[166]%}-modified"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[220]%}-renamed"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[160]%}-deleted"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[082]%}-unmerged"
ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg[cyan]%}-AHEAD"
ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg[magenta]%}-BEHIND"
ZSH_THEME_GIT_PROMPT_DIVERGED="%{$fg_bold[red]%}--DIVERGED"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[blue]%}-STASHED"

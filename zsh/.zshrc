# ------------------------------------------------------------------------------
# 1. Powerlevel10k instant prompt (Should stay close to the top of ~/.zshrc)
# ------------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# 2. Environment Variables
# ------------------------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR="nvim"
export BAT_THEME="TwoDark"

# ------------------------------------------------------------------------------
# 3. Zsh Options & Keymaps
# ------------------------------------------------------------------------------
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE         # Commands starting with a space are not saved in history
bindkey -v
WORDCHARS=${WORDCHARS//[\/]}

# Group directories before files in completion menus
zstyle ':completion:*' list-dirs-first true

# Keep ordinary globs from matching hidden files; use *(D) to include them explicitly
unsetopt GLOB_DOTS
# Exclude these entries from completion menus
zstyle ':completion:*' ignored-patterns '(.DS_Store|.git)'

# ------------------------------------------------------------------------------
# 4. Zim Framework
# ------------------------------------------------------------------------------
# Zim module settings
zstyle ':zim:input' double-dot-expand yes
zstyle ':zim:termtitle' hooks 'preexec' 'precmd'
zstyle ':zim:termtitle:preexec' format '%25<..<%~%<<: ${${(Az)1}[1]}'
zstyle ':zim:termtitle:precmd' format '%25<..<%~%<<'

# Highlighting & Autosuggestions settings
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing (portable across macOS/Linux)
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules, and update init.zsh if missing or outdated
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules
source ${ZIM_HOME}/init.zsh

# Include hidden files only during completion (must follow compinit)
_comp_options+=(globdots)

# Post-init: history-substring-search keybindings
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# ------------------------------------------------------------------------------
# 5. Prompt Configuration
# ------------------------------------------------------------------------------
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ------------------------------------------------------------------------------
# 6. Modern CLI Tools Integrations
# ------------------------------------------------------------------------------
# git
alias g="git"

# 1. Unified preview commands (Shared across tools)
if (( $+commands[eza] )); then
  preview_dir_cmd="eza -1 --icons --color=always --group-directories-first --all --git-ignore --ignore-glob='.git'"
else
  preview_dir_cmd="ls -1A"
fi

if (( $+commands[bat] )); then
  preview_file_cmd="bat --color=always --style=numbers --line-range=:200"
else
  preview_file_cmd="head -n 200"
fi

# 2. Global fzf configuration (Base settings inherited by other tools)
if (( $+commands[fzf] )); then
  source <(fzf --zsh)

  # Use fd for fast search: includes dotfiles, respects .gitignore, excludes .git/
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
    export FZF_CTRL_T_COMMAND="fd --hidden --exclude .git"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --exclude .git"
  fi

  # Show preview on the right by default
  export FZF_DEFAULT_OPTS="--height=70% --layout=reverse --border --info=right \
    --preview 'if [ -d {} ]; then $preview_dir_cmd {}; elif [ -f {} ]; then $preview_file_cmd {}; fi' \
    --preview-window=right:50%:wrap"

  # History search: compact and clean (no preview)
  export FZF_CTRL_R_OPTS="--no-preview"
fi

# 3. fzf-tab (IntelliSense-like completion popup on Tab)
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-flags '--preview-window=right:50%:wrap'

# Disable preview for command options and flags to keep them 100% full-width
zstyle ':fzf-tab:complete:*:*option*' fzf-preview ''

# Directory previews for navigation commands (cd and zoxide)
zstyle ':fzf-tab:complete:(cd|__zoxide_z|z):*' fzf-preview "$preview_dir_cmd \$realpath"

# General file & directory preview for all commands (ls, cat, nvim, cp, etc.)
# Mutually exclusive: previews directory contents if directory, or file content if file
zstyle ':fzf-tab:complete:*:*' fzf-preview "if [[ -d \$realpath ]]; then $preview_dir_cmd \"\$realpath\"; elif [[ -f \$realpath ]]; then $preview_file_cmd \"\$realpath\"; fi"

# zoxide
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# eza
if (( $+commands[eza] )); then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -lh --icons --git --group-directories-first"
  alias la="eza -lah --icons --git --group-directories-first"
  alias lt="eza --tree --level=2 --icons"
fi

# fnm
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd)"
fi

# mole
if (( $+commands[mole] )); then
  eval "$(mole completion zsh 2>/dev/null)"
fi

# ------------------------------------------------------------------------------
# 7. Custom Helper Functions
# ------------------------------------------------------------------------------
cstrict() {
  cc -std=c23 \
     -Wall -Wextra -Wpedantic -pedantic-errors \
     -Wconversion -Wsign-conversion -Wshadow \
     -Wformat=2 -Wundef -Wvla -Werror \
     "$@"
}

cdebug() {
  cc -std=c23 \
     -Wall -Wextra -Wpedantic -pedantic-errors \
     -Wconversion -Wsign-conversion -Wshadow \
     -Wformat=2 -Wundef -Wvla -Werror \
     -g -O1 \
     -fsanitize=address,undefined \
     -fno-omit-frame-pointer \
     "$@"
}

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
setopt INC_APPEND_HISTORY        # Write to history immediately to share across sessions
bindkey -v
WORDCHARS=${WORDCHARS//[\/]}

# Case-insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

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

# fzf
if (( $+commands[fzf] )); then
  source <(fzf --zsh)
fi
if (( $+commands[bat] )); then
  file_preview_cmd="bat --color=always --style=numbers --line-range=:500"
else
  file_preview_cmd="cat -n"
fi
if (( $+commands[tree] )); then
  dir_preview_cmd="tree -a -C -L 1"
else
  dir_preview_cmd="ls -a"
fi
export FZF_DEFAULT_OPTS="--height=70% --layout=reverse --border --info=right \
  --bind '?:change-preview-window:right|down|hidden' \
  --preview '[[ -d {} ]] && $dir_preview_cmd {} || $file_preview_cmd {}' \
  --preview-window=hidden"

# zoxide
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# eza
if (( $+commands[eza] )); then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -lh --icons --git --group-directories-first"
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

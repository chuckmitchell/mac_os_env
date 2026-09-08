# Homebrew is loaded in ~/.zprofile (login shells).
export PATH="$HOME/.local/bin:$PATH"

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # all tabs share one history
setopt HIST_IGNORE_DUPS       # skip consecutive duplicates
setopt HIST_IGNORE_SPACE      # lines starting with space are not saved
setopt EXTENDED_HISTORY       # timestamps in the history file

# --- Completion ---
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # case-insensitive
zstyle ':completion:*' menu select                   # tab through matches

# --- Quality of life ---
setopt AUTO_CD                # `~/Projects` without typing cd
setopt INTERACTIVE_COMMENTS   # allow # comments in the shell
bindkey -e                    # emacs keys (Ctrl+A / Ctrl+E)

# --- Prompt ---
eval "$(starship init zsh)"

# --- fzf (Ctrl+R history, Ctrl+T files, Alt+C cd) ---
source <(fzf --zsh)
# --- zoxide (z dirname) ---
eval "$(zoxide init zsh)"
# --- eza / bat ---
export BAT_THEME="Catppuccin Mocha"
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --git --group-directories-first"
alias la="eza -la --icons --git --group-directories-first"
alias tree="eza --tree --icons"
alias cat="bat --paging=never"
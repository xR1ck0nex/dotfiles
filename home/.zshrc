# ~/.zshrc

nitch

# --- environment -----------------------------------------------------
# EDITOR / VISUAL live in /etc/environment (PAM — applies to TTY and ssh too).
# Other vars live in hyprland.lua via hl.env(). 
# Only shell-computed variables stay here.

# LS_COLORS drives ls, fd, dust and tree. `vivid themes` lists what's bundled;
# custom themes go in ~/.config/vivid/themes/ or pass a path to `vivid generate`.
export LS_COLORS="$(vivid generate rose-pine)"


# --- history ---------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=25000
SAVEHIST=25000

setopt EXTENDED_HISTORY          # timestamps
setopt SHARE_HISTORY             # sync across open shells
setopt HIST_IGNORE_ALL_DUPS      # drop older duplicates
setopt HIST_IGNORE_SPACE         # leading space = not recorded
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # expand !! before running, don't fire blind


# --- shell options ---------------------------------------------------
setopt AUTO_CD                   # `..` instead of `cd ..`
setopt AUTO_PUSHD                # cd builds a directory stack
setopt PUSHD_IGNORE_DUPS
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS      # # comments allowed at the prompt
setopt NO_BEEP


# --- completion ------------------------------------------------------
autoload -Uz compinit
compinit -d ~/.cache/zsh/zcompdump

zstyle ':completion:*' menu select                          # arrow-key menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'      # case-insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}       # coloured candidates
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/zcompcache


# --- keybindings -----------------------------------------------------
bindkey -v
export KEYTIMEOUT=1

# backspace and ^h keep working after returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# history search — viins doesn't give you these
bindkey '^r' history-incremental-search-backward
bindkey -M vicmd '/' history-incremental-search-forward
bindkey -M vicmd '?' history-incremental-search-backward

# k/j search history by what's already typed
bindkey -M vicmd 'k' up-line-or-beginning-search
bindkey -M vicmd 'j' down-line-or-beginning-search


# --- aliases ---------------------------------------------------------
alias ls='ls --color=auto --group-directories-first -h'
alias ll='ls -l'
alias la='ls -la'
alias grep='grep --color=auto'
alias cat='bat --paging=never'
alias df='duf'
alias du='dust'
alias lg='lazygit'
alias clear='clear && nitch'


# --- functions -------------------------------------------------------
# yazi wrapper: cd to the directory yazi exited in (from yazi's docs)
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}


# --- fzf -------------------------------------------------------------
# ArchWiki: source these from .zshrc (after vi-mode, if using it)
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ]   && source /usr/share/fzf/completion.zsh

export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}'"


# --- plugins ---------------------------------------------------------
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
bindkey '^[[C' forward-char          # right arrow accepts the suggestion

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# --- prompt ----------------------------------------------------------
# Config in ~/.config/starship.toml — rose-pine port:
# https://github.com/rose-pine/starship (copy rose-pine.toml as starship.toml)
eval "$(starship init zsh)"

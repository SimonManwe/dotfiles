#
# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Cargo (Rust) binaries
export PATH="$HOME/.cargo/bin:$PATH"

# Go binaries
export PATH="$HOME/go/bin:$PATH"
#
# path to composer
if [[ -d ~/.config/composer/vendor/bin ]]; then
	export PATH="$HOME/.config/composer/vendor/bin:$PATH"
fi

ZSH_THEME="robbyrussell"

export TERM=xterm-256color

plugins=(git zsh-syntax-highlighting zsh-autosuggestions fzf)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
fi
# source fzf keybindings
# fzf fallback if OMZ plugin didn't catch it
if ! type _fzf_complete > /dev/null 2>&1; then
    for f in /usr/share/fzf/key-bindings.zsh \
              /usr/share/doc/fzf/examples/key-bindings.zsh; do
        [[ -f $f ]] && source $f && break
    done
    for f in /usr/share/fzf/completion.zsh \
              /usr/share/doc/fzf/examples/completion.zsh; do
        [[ -f $f ]] && source $f && break
    done
fi

# ---- fd / fzf integration (cross-distro: Arch ships `fd`, Debian/Ubuntu may ship `fdfind`) ----
if command -v fd &> /dev/null; then
  FD_CMD="fd"
elif command -v fdfind &> /dev/null; then
  FD_CMD="fdfind"
fi

if [[ -n $FD_CMD ]]; then
  export FZF_DEFAULT_COMMAND="$FD_CMD --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="$FD_CMD --type=d --hidden --strip-cwd-prefix --exclude .git"

  _fzf_compgen_path() {
    $FD_CMD --hidden --exclude .git . "$1"
  }

  _fzf_compgen_dir() {
    $FD_CMD --type=d --hidden --exclude .git . "$1"
  }
fi

# bat may be `bat` or `batcat` depending on the distro/version
if command -v bat &> /dev/null; then
  BAT_CMD="bat"
elif command -v batcat &> /dev/null; then
  BAT_CMD="batcat"
fi

if [[ -n $BAT_CMD ]] && command -v eza &> /dev/null; then
  show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else $BAT_CMD -n --color=always --line-range :500 {}; fi"
  export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
fi


# Load aliases
if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi
#
# Yazi shell wrapper - allows cd on quit
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Hyperland ssh setup
if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# other shit
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(zoxide init zsh)"
export PATH=$HOME/.local/bin:$PATH

if command -v claude &> /dev/null; then
  export ANTHROPIC_BASE_URL="http://localhost:4141"
  export ANTHROPIC_AUTH_TOKEN="sk-dummytokenshit"
  export DISABLE_NON_ESSENTIAL_MODEL_CALLS="1"
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

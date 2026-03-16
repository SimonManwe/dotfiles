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


plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

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
if [[ -d /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
	source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
# arch keybinding
if [[ -d /usr/share/fzf/key-bindings.zsh ]]; then
	source /usr/share/fzf/key-bindings.zsh
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

#ssh setup via keychain
eval $(keychain --eval --agents ssh --quiet sgail)

# fzf auto-completion
if [[ -d /usr/share/doc/fzf/examples/completion.zsh ]]; then
	source /usr/share/doc/fzf/examples/completion.zsh
fi
#arch keybinding
if [[ -d /usr/share/fzf/completion.zsh ]]; then
	source /usr/share/fzf/completion.zsh
fi
# other shit
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(zoxide init zsh)"
export PATH=$HOME/.local/bin:$PATH

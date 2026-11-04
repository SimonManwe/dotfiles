# zsh/.zshenv
typeset -U path   # keep entries unique

path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/go/bin
  $HOME/.config/composer/vendor/bin
  $HOME/.opencode/bin
  $HOME/.atuin/bin
  $path
)
path=(${^path}(N-/))

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
fi

# Hyperland ssh setup
if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi


# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Omit theme as starship is used
ZSH_THEME=""

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

for f in ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/*.zsh(N); do
  source "$f"
done

# source fzf keybindings
command -v fzf &> /dev/null && source <(fzf --zsh)   # needs fzf ≥ 0.48

# node version manager but fast
command -v fnm &> /dev/null && eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"

# Init Starship
command -v starship &> /dev/null && eval "$(starship init zsh)"

# Init Zoxide
command -v zoxide   &> /dev/null && eval "$(zoxide init zsh)"

# Init Atuin
command -v atuin    &> /dev/null && eval "$(atuin init zsh --disable-up-arrow)"

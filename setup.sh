#!/bin/bash

PACKAGES=(
    nvim
    kitty
    zsh
    tmux
	yazi
)

echo "Setting up dotfiles..."

if ! command -v stow &> /dev/null; then
    echo "stow not found, please install gnu stow"
fi

for pkg in "${PACKAGES[@]}"; do
    echo "Stowing $pkg..."
    stow --target="$HOME" "$pkg"
    if [ $? -eq 0 ]; then
        echo "✓ $pkg symlink creation successfull"
    else
        echo "✗ Error: $pkg – is there an existing config already?"
    fi
done

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM for tmux..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "✓ TPM successfully installed"
else
    echo "✓ TPM already installed"
fi

if [ ! -d "$HOME/.tmux/plugins/catppuccin" ]; then
    echo "Installing catppuccin tmux..."
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.tmux/plugins/catppuccin/tmux
    echo "✓ Catppuccin installed successfully"
else
    echo "✓ Catppuccin  installed"
fi

echo "Dotfiles setup complete! Start tmux and press prefix + I to install plugins"

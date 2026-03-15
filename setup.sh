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
    echo "stow not found, attempting install..."
    sudo pacman -S stow
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

echo "Dotfiles setup complete!"

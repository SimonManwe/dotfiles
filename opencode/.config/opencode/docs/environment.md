# Environment & Workflow

## Terminal-first philosophy

Simon prefers to work entirely in the terminal. When suggesting tools, workflows, or solutions:

- Prefer CLI/TUI tools over GUI alternatives
- Suggest Neovim-native solutions where applicable (e.g., telescope, quickfix lists)
- Assume tmux is available for multi-pane workflows
- Shell scripts and aliases are welcome suggestions for repetitive tasks

## Ghostty + tmux

- Terminal multiplexing via tmux (assume session persistence)
- When suggesting multi-process workflows, frame them as tmux panes/windows

## Neovim

- Custom config (not a distro like LazyVim/AstroNvim)
- When suggesting editor integrations, reference the underlying plugin (e.g., nvim-lspconfig, telescope.nvim) rather
  than distro-specific abstractions
- LSP-based workflow assumed (completions, diagnostics, go-to-definition)

## Git workflow

- **Work (GitLab):** Merge requests, CI/CD pipelines
- **Personal (GitHub):** Pull requests, GitHub Actions
- **TUI client:** lazygit for day-to-day git operations
- When suggesting git operations, CLI commands or lazygit shortcuts are both fine

## Platform awareness

- **Work machine:** Linux Mint / Ubuntu (apt, deb-based)
- **Home machine:** Arch Linux (pacman, yay for AUR)
- When suggesting system packages, mention both if they differ (e.g., `apt install X` / `pacman -S X`)

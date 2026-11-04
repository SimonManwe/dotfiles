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

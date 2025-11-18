# Neovim Configuration - Keybindings & Features

> **Leader Key**: `Space`  
> **Local Leader Key**: `\`

---

## 📑 Table of Contents

- [General](#general)
- [File Explorer (Neo-tree)](#file-explorer-neo-tree)
- [Telescope (Fuzzy Finder)](#telescope-fuzzy-finder)
- [Buffer Management](#buffer-management)
- [LSP (Language Server)](#lsp-language-server)
- [Git Integration (Gitsigns)](#git-integration-gitsigns)
- [GitHub Copilot](#github-copilot)
- [GitHub Copilot Chat](#github-copilot-chat)
- [Debugging (DAP)](#debugging-dap)
- [Undo Tree](#undo-tree)
- [Code Completion (nvim-cmp)](#code-completion-nvim-cmp)
- [Spryker Tools](#spryker-tools)

---

## General

### Basic Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + pv` | Normal | `:Ex` | Open file explorer (netrw) |

### Editor Options
- **Line Numbers**: Absolute + Relative
- **Tabs**: 4 spaces (tabs, not spaces)
- **Auto-save**: Enabled on buffer leave
- **Clipboard**: Shared with system (`unnamedplus`)
- **Update Time**: 250ms (for faster git signs, etc.)

---

## File Explorer (Neo-tree)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + e` | Normal | Toggle Neo-tree | Open/close file tree |

### Neo-tree Window Settings
- **Position**: Right side
- **Width**: 50 columns
- **Git Status**: Enabled
- **Hidden Files**: Visible (dotfiles shown)

### Inside Neo-tree
- `Enter` - Open file/folder
- `a` - Add file/folder
- `d` - Delete
- `r` - Rename
- `y` - Copy
- `x` - Cut
- `p` - Paste
- `q` - Close Neo-tree

---

## Telescope (Fuzzy Finder)

### File Finding
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + ?` | Normal | Recent Files | Recently opened files |
| `Space + Space` | Normal | Find Buffers | List open buffers |
| `Space + /` | Normal | Fuzzy Search Buffer | Search in current file |
| `Space + gf` | Normal | Git Files | Find files tracked by Git |
| `Space + sf` | Normal | Find Files | Find all files (including hidden) |

### Search & Grep
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + sg` | Normal | Live Grep | Search text in workspace |
| `Space + sG` | Normal | Grep Git Root | Search in Git root directory |
| `Space + sw` | Normal | Search Word | Search current word under cursor |
| `Space + s/` | Normal | Grep Open Files | Search in all open buffers |
| `Space + sr` | Normal | Resume Search | Resume last Telescope picker |

### Help & Diagnostics
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + sh` | Normal | Help Tags | Search Neovim help |
| `Space + sd` | Normal | Diagnostics | List all diagnostics |
| `Space + ss` | Normal | Select Telescope | Choose Telescope picker |

### Telescope Window Settings
- **Layout**: Vertical split
- **Width**: 90% of screen
- **Position**: Top
- **Preview**: Enabled

---

## Buffer Management

### Buffer Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Shift + h` | Normal | Previous Buffer | Cycle to previous buffer |
| `Shift + l` | Normal | Next Buffer | Cycle to next buffer |
| `[b` | Normal | Previous Buffer | Alternative: previous buffer |
| `]b` | Normal | Next Buffer | Alternative: next buffer |

### Buffer Organization
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `[B` | Normal | Move Buffer Left | Move current buffer left in line |
| `]B` | Normal | Move Buffer Right | Move current buffer right in line |
| `Space + br` | Normal | Close Right Buffers | Close all buffers to the right |
| `Space + bl` | Normal | Close Left Buffers | Close all buffers to the left |

### Bufferline Features
- **Diagnostics**: Shows LSP errors/warnings
- **Icons**: File type icons
- **Auto-hide**: Only shows when multiple buffers open
- **Neo-tree Offset**: Adjusts for file explorer

---

## LSP (Language Server)

### Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `gd` | Normal | Go to Definition | Jump to definition (Telescope) |
| `gr` | Normal | Go to References | List all references (Telescope) |
| `gI` | Normal | Go to Implementation | Jump to implementation |
| `gD` | Normal | Go to Declaration | Jump to declaration |
| `Space + D` | Normal | Type Definition | Show type definition |

### Code Actions
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + rn` | Normal | Rename | Rename symbol |
| `Space + ca` | Normal | Code Action | Show available code actions |
| `K` | Normal | Hover | Show documentation |
| `Ctrl + k` | Normal | Signature Help | Show function signature |

### Symbols & Workspace
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + ds` | Normal | Document Symbols | List symbols in current file |
| `Space + ws` | Normal | Workspace Symbols | Search symbols in workspace |

### LSP Features
- **Auto-formatting**: Configured per language
- **Diagnostics**: Inline error/warning display
- **Document Highlight**: Highlights symbol under cursor
- **Spryker PHP**: Custom configuration for Spryker projects

---

## Git Integration (Gitsigns)

### Hunk Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `]h` | Normal | Next Hunk | Jump to next Git change |
| `[h` | Normal | Previous Hunk | Jump to previous Git change |

### Hunk Actions
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + hs` | Normal/Visual | Stage Hunk | Stage Git hunk |
| `Space + hr` | Normal/Visual | Reset Hunk | Discard Git hunk |
| `Space + hS` | Normal | Stage Buffer | Stage entire file |
| `Space + hR` | Normal | Reset Buffer | Reset entire file |
| `Space + hu` | Normal | Undo Stage | Undo staged hunk |
| `Space + hp` | Normal | Preview Hunk | Show hunk diff in popup |

### Git Information
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + hb` | Normal | Blame Line | Show full Git blame for line |
| `Space + tb` | Normal | Toggle Blame | Toggle inline blame display |
| `Space + hd` | Normal | Diff This | Show file diff |

### Gitsigns Features
- **Current Line Blame**: Always visible
- **Signs in Gutter**: Icons for add/change/delete
- **Preview on Hover**: Available via keybinding

---

## GitHub Copilot

### Inline Suggestions (during typing)
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Alt + l` | Insert | Accept Suggestion | Accept Copilot suggestion |
| `Alt + ]` | Insert | Next Suggestion | Cycle to next suggestion |
| `Alt + [` | Insert | Previous Suggestion | Cycle to previous suggestion |
| `Ctrl + ]` | Insert | Dismiss | Dismiss current suggestion |

### Copilot Panel
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Alt + Enter` | Insert | Open Panel | Show alternative suggestions |
| `Space + cp` | Normal | Copilot Panel | Open suggestions panel |

### Copilot Management
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + cs` | Normal | Copilot Status | Show Copilot status |
| `Space + ce` | Normal | Enable Copilot | Enable Copilot |
| `Space + cd` | Normal | Disable Copilot | Disable Copilot |

### Copilot Features
- **Auto-trigger**: Suggestions appear automatically
- **nvim-cmp Integration**: Shows in completion menu with `[Copilot]` label
- **Priority**: Highest priority in completion menu
- **Disabled For**: YAML, Markdown, Git commits
- **Debounce**: 75ms for performance

### First Time Setup
```vim
:Copilot auth
```
Then authenticate via browser with your GitHub account.

---

## GitHub Copilot Chat

### Chat Window
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + cc` | Normal/Visual | Toggle Chat | Open/close Copilot Chat |
| `Space + cq` | Normal | Quick Chat | Ask quick question |

### Visual Mode Actions (select code first)
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + ce` | Visual | Explain Code | Get explanation of selected code |
| `Space + ct` | Visual | Generate Tests | Generate unit tests |
| `Space + cf` | Visual | Fix Code | Suggest bug fixes |
| `Space + co` | Visual | Optimize Code | Suggest optimizations |
| `Space + cd` | Visual | Generate Docs | Generate documentation |
| `Space + cr` | Visual | Review Code | Code review suggestions |

### Normal Mode Actions
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + cm` | Normal | Commit Message | Generate Git commit message |

### Inside Chat Window
| Key | Action | Description |
|-----|--------|-------------|
| `Enter` | Submit | Send message |
| `q` | Close | Close chat window |
| `Ctrl + r` | Reset | Clear chat history |
| `Ctrl + c` | Cancel | Cancel input |
| `Tab` | Complete | Auto-complete @ and / commands |

### Chat Commands
- `@buffer` - Reference current buffer
- `@buffers` - Reference all open buffers
- `@file` - Reference specific file
- `@selection` - Reference visual selection
- `/explain` - Explain code
- `/fix` - Fix bugs
- `/tests` - Generate tests
- `/optimize` - Optimize code

### Chat Window Settings
- **Layout**: Floating window
- **Size**: 80% width × 80% height
- **Border**: Rounded corners

---

## Debugging (DAP)

### Debug Control
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `F5` | Normal | Start/Continue | Start debugging or continue |
| `F10` | Normal | Step Over | Step over function |
| `F6` | Normal | Step Into | Step into function |
| `F12` | Normal | Step Out | Step out of function |

### Breakpoints
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + bp` | Normal | Toggle Breakpoint | Add/remove breakpoint |
| `Space + Bp` | Normal | Conditional Breakpoint | Set breakpoint with condition |

### Debug UI & Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + dt` | Normal | Toggle Debug UI | Open/close debug UI |
| `Space + dr` | Normal | Open REPL | Open debug REPL |
| `Space + dl` | Normal | Run Last | Rerun last debug config |
| `Space + dh` | Normal | Hover Variables | Show variable values on hover |

### Stack Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + du` | Normal | Stack Up | Move up in stack trace |
| `Space + dd` | Normal | Stack Down | Move down in stack trace |
| `Space + df` | Normal | Floating Stack | Show stack trace in float |
| `Space + dF` | Normal | Frames Sidebar | Open frames sidebar widget |
| `Space + ds` | Normal | Toggle Stack Panel | Toggle stack panel |

### Debug Configuration
**PHP/Spryker XDebug:**
- **Port**: 9003
- **Path Mapping**: `/data` → Workspace folder
- **Max Children**: 256
- **Max Data**: 1024 bytes
- **Max Depth**: 5 levels

**Breakpoint Icons:**
- 🔴 Normal breakpoint
- 🟡 Conditional breakpoint
- 🔵 Rejected breakpoint
- ➡️ Current execution line

### Debug UI Layout
**Left Panel (50 cols):**
- Scopes (variables)
- Breakpoints
- Stack trace
- Watches

**Bottom Panel (10 rows):**
- REPL
- Console output

---

## Undo Tree

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Space + u` | Normal | Toggle Undotree | Open/close undo tree |

### Undotree Settings
- **Layout**: Vertical split
- **Width**: 30 columns
- **Feature**: Visual undo history tree
- **Navigation**: Browse through undo/redo branches

---

## Code Completion (nvim-cmp)

### Completion Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Tab` | Insert | Next Item | Select next completion |
| `Shift + Tab` | Insert | Previous Item | Select previous completion |
| `Enter` | Insert | Confirm | Accept completion (only if selected) |
| `Ctrl + Space` | Insert | Trigger | Manually trigger completion |
| `Ctrl + e` | Insert | Abort | Close completion menu |

### Documentation Scrolling
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `Ctrl + f` | Insert | Scroll Down | Scroll docs down |
| `Ctrl + b` | Insert | Scroll Up | Scroll docs up |

### Completion Sources (by priority)
1. **[Copilot]** - AI suggestions (priority: 1100)
2. **[LSP]** - Language server (priority: 1000)
3. **[Snip]** - Snippets (priority: 750)
4. **[Buf]** - Buffer words (priority: 500, max 1MB files)
5. **[Path]** - File paths (priority: 250)

### Features
- **Auto-trigger**: After 2 characters
- **Bordered Windows**: Pretty UI
- **Snippet Support**: LuaSnip + Friendly Snippets
- **Performance**: Debounced, throttled, max 50 entries
- **Ghost Text**: Disabled

---

## Spryker Tools

### Spryker PYZ Generator (Telescope)
Custom Telescope picker to generate Spryker PYZ classes:

**How to use:**
1. Open Telescope
2. Select a Spryker module
3. Choose application (Zed/Client/Glue/etc.)
4. Choose layer (Business/Communication/etc.)
5. Select class type (Factory/Facade/Config/etc.)
6. File is automatically created in correct PYZ structure

**Features:**
- Auto-detects available Spryker modules
- Only shows valid applications for each module
- Only shows valid layers for each application
- Generates proper namespace and extends parent class
- Creates directory structure automatically

### Spryker LSP Configuration
Custom PHP LSP settings optimized for Spryker:
- Increased memory limit
- Optimized for large projects
- Spryker-specific path mappings

---

## Additional Plugins

### Installed Plugins
- **Colorscheme**: Tokyo Night / Catppuccin / Rose Pine
- **Treesitter**: Syntax highlighting (PHP, Lua, JavaScript, etc.)
- **Auto-close**: Auto-close brackets, quotes
- **PHP Docblocks**: Generate PHPDoc comments
- **Formatting**: conform.nvim (Prettier, PHP CS Fixer)
- **Mason**: LSP/DAP/Formatter installer

### Formatter Keybindings
Auto-formatting is typically configured via LSP or conform.nvim.
Check `:ConformInfo` for available formatters.

---

## Tips & Tricks

### General Workflow
1. **Open Project**: `nvim .`
2. **File Explorer**: `Space + e` (Neo-tree)
3. **Find File**: `Space + sf` or `Space + gf`
4. **Search Text**: `Space + sg`
5. **Git Changes**: `]h` and `[h` to navigate

### Debugging Workflow
1. **Set Breakpoint**: `Space + bp`
2. **Start Debug**: `F5`
3. **Step Through**: `F10` (over), `F6` (into), `F12` (out)
4. **Inspect**: `Space + dh` (hover) or check left panel
5. **Stack Trace**: `Space + df` (floating) or `Space + dF` (sidebar)

### Copilot Workflow
1. **Type Code**: Copilot suggests inline (accept with `Alt + l`)
2. **Need Explanation**: Select code + `Space + ce`
3. **Need Tests**: Select code + `Space + ct`
4. **Need Fix**: Select code + `Space + cf`
5. **Quick Question**: `Space + cq`

### LSP Workflow
1. **Jump to Definition**: `gd`
2. **Find Usages**: `gr`
3. **Rename Symbol**: `Space + rn`
4. **Quick Fix**: `Space + ca`
5. **Documentation**: `K`

---

## Configuration Files Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lazy-lock.json             # Plugin versions lock file
├── lua/
│   ├── tron/
│   │   ├── init.lua           # Main config loader
│   │   ├── lazy.lua           # Lazy.nvim setup
│   │   ├── options.lua        # Vim options
│   │   ├── remap.lua          # Custom keymaps
│   │   └── sprykerOptions.lua # Spryker-specific settings
│   └── plugins/
│       ├── autoclose.lua
│       ├── bufferline.lua     # Buffer tabs
│       ├── cmp.lua            # Completion engine
│       ├── colorscheme.lua
│       ├── copilot.lua        # GitHub Copilot
│       ├── copilot-chat.lua   # Copilot Chat
│       ├── debug.lua          # DAP debugger
│       ├── formatting.lua
│       ├── gitsigns.lua       # Git integration
│       ├── neo-tree.lua       # File explorer
│       ├── php-docblocks.lua
│       ├── sprykerPlugins.lua # Spryker tools
│       ├── telescope.lua      # Fuzzy finder
│       ├── treesitter.lua     # Syntax highlighting
│       ├── undotree.lua
│       └── lsp/
│           ├── lsp.lua               # LSP config
│           ├── mason-config.lua     # LSP installer
│           └── spryker-lsp-options.lua
└── docs/
    ├── keybindings.md         # This file
    └── spryker-pyz.md         # Spryker documentation
```

---

## Troubleshooting

### Copilot Not Working
```vim
:Copilot status           " Check status
:Copilot auth            " Re-authenticate
:checkhealth copilot     " Diagnostic check
```

### LSP Not Attaching
```vim
:LspInfo                 " Check LSP status
:Mason                   " Install/update LSP servers
:checkhealth             " Full health check
```

### Debugger Not Starting
```vim
:checkhealth dap         " Check DAP status
:Mason                   " Install php-debug-adapter
```
Verify XDebug is running on port 9003.

### Telescope Empty Results
- Check if you're in a Git repository for `:Telescope git_files`
- Try `:Telescope find_files` for non-Git files
- Make sure `ripgrep` is installed for live_grep

---

## External Dependencies

### Required
- **Neovim**: >= 0.9.0
- **Git**: For lazy.nvim and plugins
- **Node.js**: >= 18.x (for Copilot)

### Recommended
- **ripgrep**: For Telescope grep features
- **fd**: For faster file finding
- **make**: For building telescope-fzf-native
- **PHP**: >= 8.0 (for LSP and debugging)
- **Composer**: For PHP tools

### Optional
- **XDebug**: For PHP debugging
- **php-cs-fixer**: For PHP formatting
- **prettier**: For JS/TS/CSS formatting

---

## Version Info

**Last Updated**: 2025-01-18  
**Neovim Version**: 0.10+  
**Plugin Manager**: lazy.nvim

---

## Quick Reference Card

### Most Used Commands
```
Files:     Space + e, Space + sf, Space + gf
Search:    Space + sg, Space + sw, Space + /
LSP:       gd, gr, Space + rn, K
Git:       ]h, [h, Space + hs, Space + hp
Buffers:   Shift + h/l, Space + br/bl
Debug:     F5, F10, F6, Space + bp, Space + df
Copilot:   Alt + l, Space + cc, Space + ce (visual)
Help:      Space + sh, :help <topic>
```

### Emergency Commands
```
:qa!                     " Quit without saving
:wqa                     " Save all and quit
:Lazy                    " Plugin manager
:Mason                   " LSP/DAP installer
:checkhealth             " Health check
:LspRestart              " Restart LSP
:messages                " Show messages
```

---

**Need more help?** 
- `:help <topic>` - Built-in Neovim help
- `Space + sh` - Search help with Telescope
- `:Telescope keymaps` - See all keybindings
- Check individual plugin docs in their GitHub repos

**Configuration by**: tron  
**Optimized for**: Spryker PHP Development


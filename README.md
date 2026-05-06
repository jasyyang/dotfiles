# dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## What's Included

```
.
├── dot_claude/                # Claude Code config
├── dot_config/
│   ├── direnv/                # direnv config
│   ├── ghostty/               # Ghostty terminal
│   ├── git/                   # Other global git configs
│   ├── nvim/                  # Neovim (kickstart-based)
│   ├── shell/                 # Profile-specific env & aliases
│   └── starship.toml          # Starship prompt
├── dot_zprofile.tmpl          # Login shell (sources env.{profile}.zsh)
└── dot_zshrc.tmpl             # Interactive shell (sources aliases.{profile}.zsh)
```

## Install

```sh
brew install chezmoi neovim ghostty starship direnv zoxide git-delta
chezmoi init git@github.com:jasyyang/dotfiles.git
chezmoi apply
```

Profile is auto-detected by hostname (`kensho` or `personal`).

## Local Config (not tracked)

Some files are kept local and not tracked:

- `~/.zprofile.secrets`
- `~/.local/bin/` # some scripts that must be stored locally
- `~/.config/shell/aliases.local.zsh` # aliases that must be stored locally

## Usage

```sh
chezmoi add <file>       # Track a new file
chezmoi edit <file>      # Edit a tracked file
chezmoi diff             # See pending changes
chezmoi apply            # Apply changes
chezmoi update           # Pull and apply latest
```

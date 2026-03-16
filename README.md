# config

My configuration files.

- `nvim/` - Neovim config
- `ghostty/` - Ghostty terminal config
- `starship.toml` - Starship prompt config
- `direnv/` - direnv config with helper functions for venv activation
- `claude/` - Claude Code config (symlinked to `~/.claude/CLAUDE.md`)

## Profiles

Set `CONFIG_PROFILE=kensho` to enable work-specific configuration.

## Install

```sh
brew install neovim
brew install ghostty
brew install starship
brew install direnv
```

## Symlinks

```sh
ln -sf ~/.config/claude/CLAUDE.md ~/.claude/CLAUDE.md
```

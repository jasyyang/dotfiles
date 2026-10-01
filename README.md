# dotfiles

My dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## What's Included

```
.
├── dot_claude/                # Claude Code config
├── dot_clang-format           # Fallback C/C++ style for anything under $HOME
├── dot_config/
│   ├── clangd/                # clangd defaults (C++23, clang-tidy checks)
│   ├── direnv/                # direnv config
│   ├── ghostty/               # Ghostty terminal
│   ├── git/                   # Other global git configs
│   ├── nvim/                  # Neovim (kickstart-based)
│   ├── shell/                 # Profile-specific env & aliases
│   └── starship.toml          # Starship prompt
├── dot_local/bin/cxx          # C++ compile-and-run helper
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

## C++

`cxx` compiles and runs C++ with debug diagnostics turned up. Objects and
binaries go under `~/.cache/cxx` keyed by source dir, so source trees stay free
of `.o`/`.d`/`.dSYM` clutter. Incremental rebuilds come from a generated
Makefile, so header changes propagate and helper objects are shared.

```sh
cxx                   # Makefile in this dir? -> make run. Else run the one main()
cxx ex1.cpp           # build+run ex1, linking any helper .cpp in the dir
cxx main.cpp io.cpp   # explicit translation units; the one with main() names it
cxx ex1.cpp -- 5 7    # pass args to the program
cxx -O bench.cpp      # -O2, no sanitizers (for timing)
cxx -l                # list runnable targets (files defining main)
cxx --clean           # drop this dir's build cache
```

Default flags: `-std=c++23 -Wall -Wextra -Wpedantic -g`, ASan + UBSan, and
libc++ hardening — so out-of-bounds indexing, use-after-free and signed overflow
abort with a readable report instead of silently misbehaving.

In Neovim, `<leader>r` in a C/C++ buffer writes the file and runs `cxx` on it in
a floating terminal (interactive, so `std::cin` works). `q` closes it.

Indent width is pinned in three places that must agree, or format-on-save fights
what you type: `dot_clang-format` (`IndentWidth`), `init.lua`'s indent options,
and whatever a project's own `.clang-format` says. Currently 4 spaces.

## Local Config (not tracked)

Some files are kept local and not tracked:

- `~/.zprofile.secrets`
- `~/.local/bin/` # mostly local scripts; `cxx` is the exception and is tracked
- `~/.config/shell/aliases.local.zsh` # aliases that must be stored locally

## Usage

```sh
chezmoi add <file>       # Track a new file
chezmoi edit <file>      # Edit a tracked file
chezmoi diff             # See pending changes
chezmoi apply            # Apply changes
chezmoi update           # Pull and apply latest
```

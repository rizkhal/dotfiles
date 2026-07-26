# Dotfiles — rizkhal/universe
Portable dotfiles for macOS/Linux dev environments. Plug and play on any new machine.

## Quick Start

```bash
# Clone the repo
git clone git@github.com:rizkhal/universe.git ~/.dotfiles
cd ~/.dotfiles

# Run the installer (safe mode — backs up existing configs)
./setup.sh

# Or force overwrite (not recommended)
./setup.sh --force

# Test without making changes
./setup.sh --dry-run

# Install Brew packages
brew bundle --file ~/.dotfiles/Brewfile
```

## What It Installs

| File | Description |
|------|-------------|
| `.zshrc` | zsh config — Oh My Zsh, nvm, bun, brew paths, macOS Android SDK |
| `.zshrc.local.example` | Template for machine-specific overrides (API keys, project paths) |
| `.zshrc.local` | Created automatically on first run (copy from `.example`) |
| `Brewfile` | Brew formulas + casks for restoring dev packages |
| `setup.sh` | Installer script with OS detection and safe symlink logic |

## How It Works

- **Safe symlinks**: `setup.sh` backs up any existing file to `~/.dotfiles-backup/` before replacing. No data loss.
- **`.zshrc.local`**: Machine-specific config (API keys, project paths) lives here — never committed to git.
- **`X_STORAGE` variable**: Paths use `$X_STORAGE` so the dotfiles work on machines with different volume layouts.
- **OS-conditional**: macOS-specific blocks (Android SDK, JDK) are auto-detected. Linux machines get a clean shell setup.

## What's Excluded From Dotfiles

- SSH private keys (`~/.ssh/id_*/`)
- `.env`, `.env.local`
- `.npmrc` with tokens
- `.netrc` with credentials
- GPG passphrases

## Updating Dotfiles

```bash
cd ~/.dotfiles
git pull
./setup.sh       # backed up old configs automatically
```

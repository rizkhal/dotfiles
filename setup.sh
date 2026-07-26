#!/bin/bash
set -euo pipefail

# ──────────────────────────────────────────
# setup.sh — Portable dotfiles installer
# Source: ~/.dotfiles ( cloned from rizkhal/universe )
# Usage: ./setup.sh          — safe (backup existing first)
#        ./setup.sh --force  — overwrite without backup (dangerous)
# ──────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup"
DRY_RUN=false
FORCE=false

for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        --dry-run) DRY_RUN=true ;;
        *) echo "Unknown flag: $arg" >&2; exit 1 ;;
    esac
done

log()   { echo "  $1"; }
done_() { echo "  ✅ $1"; }
skip_() { echo "  ⏭️  Skipped: $1"; }

ensure_dir() {
    if [ ! -d "$1" ]; then
        $DRY_RUN && log "[dry-run] mkdir -p $1" || mkdir -p "$1"
    fi
}

safe_link() {
    # $1 = source file (in dotfiles repo)
    # $2 = target path (in $HOME)
    local src="$1"
    local tgt="$2"
    local name
    name="$(basename "$tgt")"

    if [ ! -f "$src" ] && [ ! -d "$src" ]; then
        log "  ⚠️  Source not found: $src — skipping"
        return 1
    fi

    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
        if $FORCE; then
            # Overwrite — symlink replaces existing
            if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
                $DRY_RUN && log "[dry-run] rm -f $tgt" || rm -f "$tgt"
            fi
            $DRY_RUN && log "[dry-run] ln -s $tgt → $src" || ln -sf "$src" "$tgt"
            done_ "Overwrote $name → $(basename "$src")"
        else
            # Safe mode: backup first, then symlink
            ensure_dir "$BACKUP_DIR"
            local stamp
            stamp="$(date '+%Y%m%d-%H%M%S')"
            local backup_base="$BACKUP_DIR/$name.$stamp"
            if [ -L "$tgt" ]; then
                # Already a symlink — just remove and recreate
                $DRY_RUN && log "[dry-run] ln -s $tgt → $src" || ln -sf "$src" "$tgt"
                done_ "Updated $name → $(basename "$src")"
            else
                # Real file — backup it first
                $DRY_RUN && log "[dry-run] mv $tgt → $backup_base" || mv "$tgt" "$backup_base"
                $DRY_RUN && log "[dry-run] ln -s $tgt → $src" || ln -sf "$src" "$tgt"
                done_ "Backed up $name → $backup_base, linked to $(basename "$src")"
            fi
        fi
    else
        # No existing file — just symlink
        ensure_dir "$(dirname "$tgt")"
        $DRY_RUN && log "[dry-run] ln -s $tgt → $src" || ln -sf "$src" "$tgt"
        done_ "Linked $name → $(basename "$src")"
    fi
}

detect_os() {
    if [[ "$(uname -s)" == "Darwin" ]]; then
        echo "darwin"
    else
        echo "linux"
    fi
}

OS=$(detect_os)
echo ""
echo "════════════════════════════════════════"
echo "  Dotfiles Setup"
echo "  OS: $OS"
echo "  Repo: $DOTFILES_ROOT"
echo "  Backup dir: $BACKUP_DIR"
echo "  Force: $FORCE / Dry-run: $DRY_RUN"
echo "════════════════════════════════════════"
echo ""

# ── 1. Oh My Zsh ──────────────────────────
log "Checking Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "  Installing Oh My Zsh..."
    $DRY_RUN || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    done_ "Oh My Zsh installed"
else
    done_ "Oh My Zsh already present"
fi

# ── 2. Zsh plugins ────────────────────────
log "Checking zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    dest="$ZSH_CUSTOM/plugins/$plugin"
    if [ ! -d "$dest" ]; then
        $DRY_RUN && log "[dry-run] git clone $plugin → $dest" || git clone --depth 1 "https://github.com/zsh-users/$plugin.git" "$dest" 2>/dev/null
        done_ "Installed $plugin"
    else
        done_ "$plugin already present"
    fi
done

# ── 3. nvm ────────────────────────────────
log "Checking nvm..."
if [ ! -d "$HOME/.nvm" ]; then
    log "  Installing nvm..."
    $DRY_RUN || curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    # Source nvm for this shell
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    done_ "nvm installed"
else
    done_ "nvm already present"
fi

# ── 4. Core symlinks ──────────────────────
log "Linking dotfiles..."
ensure_dir "$HOME"

safe_link "$DOTFILES_ROOT/.zshrc"          "$HOME/.zshrc"
safe_link "$DOTFILES_ROOT/.zshrc.local.example" "$HOME/.zshrc.local.example"

# Create .zshrc.local if it doesn't exist (machine-specific overrides)
if [ ! -e "$HOME/.zshrc.local" ] && [ ! -L "$HOME/.zshrc.local" ]; then
    log "  Creating .zshrc.local (copy from .example for machine overrides)"
    $DRY_RUN || cp "$DOTFILES_ROOT/.zshrc.local.example" "$HOME/.zshrc.local"
    done_ "Created .zshrc.local from example template"
fi

# ── 5. OS-specific symlinks ────────────────
if [ "$OS" = "darwin" ]; then
    log "macOS detected — linking macOS-specific config..."
    # macOS hosts file (only if not already modified)
    # safe_link "$DOTFILES_ROOT/etc/hosts" "/etc/hosts" 2>/dev/null || true
    done_ "macOS dotfile handling complete"
fi

# ── 6. Brewfile (display only — manual or `brew bundle`) ──
log "Brewfile found — review and run manually:"
log "  brew bundle --file ~/.dotfiles/Brewfile"
log "  Or: ./setup.sh (add brew bundle step here if you want automation)"

# ── Summary ────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo "  Setup complete!"
echo "  Backup dir: $BACKUP_DIR"
echo "  Next steps:"
echo "    1. Review ~/.zshrc.local for machine overrides"
echo "    2. Run: brew bundle --file ~/.dotfiles/Brewfile"
echo "    3. Restart terminal (or exec zsh)"
echo "════════════════════════════════════════"
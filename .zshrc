# ──────────────────────────────────────────
# .zshrc — Portable zsh configuration
# Source: ~/.dotfiles (rizkhal/universe)
# Machine-specific overrides go in ~/.zshrc.local
# ──────────────────────────────────────────

# ── Oh My Zsh ──────────────────────────
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

# ── Editor ─────────────────────────────
export EDITOR="nano"

# ── nvm ────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ── Bun ─────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ── PATH helpers ───────────────────────
# Homebrew (macOS)
if [[ "$(uname -s)" == "Darwin" ]]; then
    # Use the brew prefix dynamically
    BREW_PREFIX="$(brew --prefix 2>/dev/null || echo "/opt/homebrew")"
    export PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"

    # ── Mobile Android ───────────────────
    export ANDROID_SDK_ROOT="$X_STORAGE/Android"
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
    export JAVA_HOME="$BREW_PREFIX/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
    export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$JAVA_HOME/bin:$PATH"

    # ── Gradle JVM options ───────────────
    # Directs Android SDK temp to XStorage to avoid system disk full
    export GRADLE_USER_HOME="$X_STORAGE/.gradle"
    export TMPDIR="$X_STORAGE/.tmp"
    export GRADLE_OPTS="-Djava.io.tmpdir=$X_STORAGE/.tmp"
fi

# ── GPG ─────────────────────────────────
export GPG_TTY="$(tty)"
export GPG_SIGNING_KEY="7CC0CF8875615D09"

# ── npm global prefix ──────────────────
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

# ── Machine-specific overrides ─────────
# Any per-machine config (API keys, project paths, aliases)
# goes in ~/.zshrc.local — that file is gitignored
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
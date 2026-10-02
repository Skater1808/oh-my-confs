#!/bin/bash
# Komplettes Setup-Skript für oh-my-confs
# Erstellt Symlinks, installiert Services, richtet Wallpapers & Scripts ein

set -euo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================
# HILFSFUNKTIONEN
# ============================================
create_symlink() {
    local src="$1"
    local dest="$2"
    local dest_dir="$(dirname "$dest")"

    mkdir -p "$dest_dir"

    if [[ -L "$dest" ]]; then
        local current="$(readlink "$dest")"
        if [[ "$current" == "$src" ]]; then
            log_info "Schon verlinkt: $dest -> $src"
            return 0
        fi
        log_warn "Entferne alten Symlink: $dest"
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        log_warn "Backup: $dest -> $dest.backup.$(date +%s)"
        mv "$dest" "$dest.backup.$(date +%s)"
    fi

    ln -s "$src" "$dest"
    log_success "Verlinkt: $dest -> $src"
}

# ============================================
# 1. CONFIGS SYMLINKEN
# ============================================
log_info "=== Erstelle Config-Symlinks ==="

# Hyprland
create_symlink "$DOTFILES_DIR/.config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
create_symlink "$DOTFILES_DIR/.config/hypr/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"

# Kitty
create_symlink "$DOTFILES_DIR/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Waybar
create_symlink "$DOTFILES_DIR/.config/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
create_symlink "$DOTFILES_DIR/.config/waybar/style.css" "$HOME/.config/waybar/style.css"

# Bashrc
create_symlink "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"

# ============================================
# 2. WALLPAPERS
# ============================================
log_info "=== Richte Wallpapers ein ==="
WALLPAPER_DIR="$HOME/Bilder/Wallpaper"
mkdir -p "$WALLPAPER_DIR"

for wallpaper in "$DOTFILES_DIR/wallpaper/"*; do
    if [[ -f "$wallpaper" ]]; then
        filename="$(basename "$wallpaper")"
        dest="$WALLPAPER_DIR/$filename"
        if [[ ! -e "$dest" ]]; then
            cp "$wallpaper" "$dest"
            log_success "Kopiert: $filename"
        else
            log_info "Schon vorhanden: $filename"
        fi
    fi
done

# Hyprpaper Config anpassen (Pfad korrigieren)
if [[ -f "$HOME/.config/hypr/hyprpaper.conf" ]]; then
    sed -i "s|/home/emil/Bilder/Wallpaper/|$WALLPAPER_DIR/|g" "$HOME/.config/hypr/hyprpaper.conf"
    log_success "Hyprpaper-Pfade angepasst"
fi

# ============================================
# 3. SCRIPTS
# ============================================
log_info "=== Richte Scripts ein ==="
SCRIPTS_DIR="$HOME/.local/bin"
mkdir -p "$SCRIPTS_DIR"

for script in "$DOTFILES_DIR/Scripte/"*.sh; do
    if [[ -f "$script" ]]; then
        filename="$(basename "$script")"
        dest="$SCRIPTS_DIR/$filename"
        create_symlink "$script" "$dest"
        chmod +x "$dest"
    fi
done

# PATH in bashrc ergänzen falls nicht vorhanden
if ! grep -q 'export PATH.*\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$HOME/.bashrc"
    log_success "PATH um ~/.local/bin erweitert"
fi

# ============================================
# 4. KEYD (Systemweit - braucht sudo)
# ============================================
log_info "=== Richte keyd ein ==="
KEYD_CONF="/etc/keyd/default.conf"

if [[ -f "$DOTFILES_DIR/keyd.conf" ]]; then
    if sudo mkdir -p /etc/keyd; then
        sudo cp "$DOTFILES_DIR/keyd.conf" "$KEYD_CONF"
        log_success "keyd.conf nach $KEYD_CONF kopiert"

        # keyd Service aktivieren
        if systemctl list-unit-files | grep -q keyd; then
            sudo systemctl enable keyd
            sudo systemctl restart keyd 2>/dev/null || sudo systemctl start keyd
            log_success "keyd Service aktiviert & gestartet"
        else
            log_warn "keyd Service nicht gefunden - ist keyd installiert?"
        fi
    else
        log_error "Konnte /etc/keyd nicht erstellen (sudo nötig)"
        log_info "Führe manuell aus: sudo mkdir -p /etc/keyd && sudo cp $DOTFILES_DIR/keyd.conf /etc/keyd/default.conf && sudo systemctl enable --now keyd"
    fi
else
    log_warn "keyd.conf nicht gefunden in $DOTFILES_DIR"
fi

# ============================================
# 5. SYSTEMD USER SERVICES
# ============================================
log_info "=== Richte User Services ein ==="

# hyprpaper service (falls nicht via hyprland autostart)
# Wir nutzen den hyprland autostart (siehe hyprland.lua Zeile 49)

# ============================================
# 6. GTK THEMES / CURSOR
# ============================================
log_info "=== GTK/Cursor Settings ==="

# GTK3
mkdir -p "$HOME/.config/gtk-3.0"
printf '[Settings]\ngtk-cursor-theme-name=Banana\ngtk-cursor-theme-size=24\ngtk-theme-name=Adwaita-dark\ngtk-icon-theme-name=Adwaita\ngtk-font-name=JetBrainsMono Nerd Font 11\n' > "$HOME/.config/gtk-3.0/settings.ini"

# GTK4
mkdir -p "$HOME/.config/gtk-4.0"
printf '[Settings]\ngtk-cursor-theme-name=Banana\ngtk-cursor-theme-size=24\ngtk-theme-name=Adwaita-dark\ngtk-icon-theme-name=Adwaita\ngtk-font-name=JetBrainsMono Nerd Font 11\n' > "$HOME/.config/gtk-4.0/settings.ini"

log_success "GTK3/GTK4 Cursor-Theme auf Banana gesetzt"

# ============================================
# 7. FONT CACHE
# ============================================
log_info "=== Aktualisiere Font-Cache ==="
fc-cache -fv >/dev/null 2>&1 && log_success "Font-Cache aktualisiert"

# ============================================
# 8. FERTIG
# ============================================
log_success "============================================"
log_success "Setup abgeschlossen!"
log_success "============================================"
echo
log_info "Nächste Schritte:"
echo "  1. Neustarten (für keyd, kernel module, docker group)"
echo "  2. Hyprland neu starten: SUPER+ESC (oder hyprctl reload)"
echo "  3. Wallpaper testen: SUPER+CTRL+SPACE"
echo "  4. Kitty neu starten für neues Theme"
echo
log_warn "WICHTIG: Hyprland Config nutzt Lua-Format (hyprland.lua)"
log_warn "         Stelle sicher dass hyprland mit Lua-Support gebaut ist"
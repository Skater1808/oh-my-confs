#!/bin/bash
# Installations-Skript für Arch Linux
# Erstellt am: $(date '+%Y-%m-%d')
# Installiert alle explizit installierten Pakete (pacman + AUR)

set -euo pipefail

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Prüfen ob root (nicht empfohlen für yay)
if [[ $EUID -eq 0 ]]; then
    log_error "Nicht als root ausführen! yay funktioniert nicht als root."
    exit 1
fi

# Prüfen ob yay installiert ist
if ! command -v yay &>/dev/null; then
    log_warn "yay nicht gefunden. Installiere yay zuerst..."
    sudo pacman -S --needed --noconfirm base-devel git
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# System aktualisieren
log_info "Aktualisiere Paketdatenbank..."
sudo pacman -Sy

# ============================================
# OFFIZIELLE REPOSITORY PAKETE (pacman)
# ============================================
PACMAN_PACKAGES=(
    7zip
    amd-ucode
    base
    base-devel
    bluez
    bluez-utils
    btop
    chromium
    cmake
    docker
    dunst
    efibootmgr
    git
    grim
    grub
    gst-plugin-pipewire
    hyprland
    hyprpaper
    intel-media-driver
    kate
    kdenlive
    keyd
    kitty
    layer-shell-qt
    lazydocker
    lazygit
    libpulse
    libva-intel-driver
    limine
    linux
    linux-firmware
    mkinitcpio
    mpv
    nano
    nasm
    nemo
    networkmanager
    ninja
    obs-studio
    openssh
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    polkit-kde-agent
    qemu-base
    qt5-wayland
    qt6-wayland
    rustup
    sddm
    slurp
    smartmontools
    steam
    sudo
    tesseract
    tesseract-data-eng
    tigervnc
    ttf-jetbrains-mono-nerd
    ufw
    uwsm
    vlc
    vulkan-intel
    vulkan-nouveau
    vulkan-radeon
    wget
    wireplumber
    wl-clipboard
    wofi
    xdg-desktop-portal-hyprland
    xdg-utils
    xf86-video-amdgpu
    xf86-video-ati
    xf86-video-nouveau
    zram-generator
)

log_info "Installiere ${#PACMAN_PACKAGES[@]} pacman-Pakete..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
log_success "Pacman-Pakete installiert!"

# ============================================
# AUR PAKETE (yay)
# ============================================
AUR_PACKAGES=(
    i686-linux-gnu-binutils
    bibata-cursor-theme-bin
    lmstudio-bin
    localsend-bin
    omasnap-bin
    visual-studio-code-bin
    waybar-git
    yay
)

log_info "Installiere ${#AUR_PACKAGES[@]} AUR-Pakete..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
log_success "AUR-Pakete installiert!"

# ============================================
# POST-INSTALLATION
# ============================================
log_info "Führe Post-Installation durch..."

# Docker Gruppe
if getent group docker >/dev/null; then
    sudo usermod -aG docker "$USER"
    log_info "Benutzer '$USER' zur docker-Gruppe hinzugefügt (Neuanmeldung erforderlich)"
fi

# Services aktivieren
SERVICES=(NetworkManager bluetooth docker sddm ufw)
for svc in "${SERVICES[@]}"; do
    if systemctl list-unit-files | grep -q "^$svc"; then
        sudo systemctl enable "$svc" 2>/dev/null && log_info "Service '$svc' aktiviert"
    fi
done

# Grub konfigurieren (falls limine nicht verwendet wird)
if [[ -f /etc/default/grub ]]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null && log_info "GRUB konfiguriert"
fi

# Initramfs neu generieren
sudo mkinitcpio -P 2>/dev/null && log_info "Initramfs neu generiert"

log_success "============================================"
log_success "Installation abgeschlossen!"
log_success "============================================"
log_warn "WICHTIG: Bitte System neu starten für:"
log_warn "  - Kernel-Module (amd-ucode, graphics drivers)"
log_warn "  - Docker-Gruppe (neu anmelden)"
log_warn "  - Display Manager (sddm)"
log_warn "  - Limine/GRUB Bootloader"
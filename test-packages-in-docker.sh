#!/bin/bash
# Test-Skript für Docker-Container - MIT Paket-Installation

set -euo pipefail

echo "============================================"
echo "Starte Container und installiere Pakete..."
echo "============================================"

# Container starten mit gemounteten dotfiles
docker run --rm \
    -v /home/emil/oh-my-confs:/home/testuser/oh-my-confs:ro \
    arch-dotfiles-test \
    bash -c "
        set -e
        cd /home/testuser/oh-my-confs
        
        echo '=== Installiere pacman-Pakete ==='
        # Multilib für steam hinzufügen (Container hat minimales pacman.conf)
        echo -e '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist' | sudo tee -a /etc/pacman.conf
        sudo pacman -Sy
        
        # Nur die pacman-Pakete installieren (schneller, keine AUR-Kompilierung)
        sudo pacman -S --needed --noconfirm \
            7zip \
            amd-ucode \
            base-devel \
            bluez \
            bluez-utils \
            btop \
            chromium \
            cmake \
            docker \
            dunst \
            efibootmgr \
            git \
            grim \
            grub \
            gst-plugin-pipewire \
            hyprland \
            hyprpaper \
            intel-media-driver \
            kate \
            kdenlive \
            keyd \
            kitty \
            layer-shell-qt \
            lazydocker \
            lazygit \
            libpulse \
            libva-intel-driver \
            limine \
            linux \
            linux-firmware \
            mkinitcpio \
            mpv \
            nano \
            nasm \
            nemo \
            networkmanager \
            ninja \
            obs-studio \
            openssh \
            pipewire \
            pipewire-alsa \
            pipewire-jack \
            pipewire-pulse \
            polkit-kde-agent \
            qemu-base \
            qt5-wayland \
            qt6-wayland \
            rustup \
            sddm \
            slurp \
            smartmontools \
            steam \
            sudo \
            tesseract \
            tesseract-data-eng \
            tigervnc \
            ttf-jetbrains-mono-nerd \
            ufw \
            uwsm \
            vlc \
            vulkan-intel \
            vulkan-nouveau \
            vulkan-radeon \
            wget \
            wireplumber \
            wl-clipboard \
            wofi \
            xdg-desktop-portal-hyprland \
            xdg-utils \
            xf86-video-amdgpu \
            xf86-video-ati \
            xf86-video-nouveau \
            zram-generator
        
        echo ''
        echo '=== Prüfe AUR-Pakete (nur dry-run mit yay -Si) ==='
        for pkg in banana-cursor-bin i686-linux-gnu-binutils lmbionic-bin lmstudio-bin localsend-bin omasnap-bin visual-studio-code-bin waybar-git yay; do
            yay -Si \"\$pkg\" >/dev/null 2>&1 && echo \"✓ \$pkg in AUR verfügbar\" || echo \"✗ \$pkg NICHT in AUR\"
        done
        
        echo ''
        echo '=== Installation erfolgreich! ==='
        echo 'Installierte Pakete:'
        pacman -Q | wc -l
    "

echo "============================================"
echo "Paket-Test abgeschlossen!"
echo "============================================"
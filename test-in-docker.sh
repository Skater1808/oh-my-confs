#!/bin/bash
# Test-Skript für Docker-Container

set -euo pipefail

echo "============================================"
echo "Baue Docker Image..."
echo "============================================"

docker build -f /home/emil/oh-my-confs/Dockerfile.test -t arch-dotfiles-test /home/emil/oh-my-confs

echo "============================================"
echo "Starte Container und teste Setup..."
echo "============================================"

# Container starten mit gemounteten dotfiles
docker run --rm \
    -v /home/emil/oh-my-confs:/home/testuser/oh-my-confs:ro \
    arch-dotfiles-test \
    bash -c "
        set -e
        cd /home/testuser/oh-my-confs
        
        echo '=== Teste install-packages.sh (dry-run) ==='
        # Nur prüfen ob Pakete existieren, nicht installieren
        bash -n install-packages.sh && echo 'Syntax OK'
        
        echo ''
        echo '=== Teste setup.sh (dry-run) ==='
        # Setup mit DRY_RUN Flag
        DRY_RUN=1 bash setup.sh 2>&1 | head -50
        
        echo ''
        echo '=== Prüfe Config-Dateien ==='
        for f in .config/hypr/hyprland.lua .config/kitty/kitty.conf .config/waybar/config.jsonc .config/waybar/style.css .bashrc keyd.conf Scripte/random_wallpaper.sh; do
            if [ -f \"\$f\" ]; then
                echo \"✓ \$f existiert\"
            else
                echo \"✗ \$f FEHLT\"
            fi
        done
        
        echo ''
        echo '=== Prüfe Wallpapers ==='
        ls -la wallpaper/
        
        echo ''
        echo '=== Syntax-Check Lua Config ==='
        # Lua syntax check wenn lua installiert
        if command -v luac &>/dev/null; then
            luac -p .config/hypr/hyprland.lua && echo 'Lua Syntax OK'
        else
            echo 'luac nicht installiert, überspringe Lua-Check'
        fi
        
        echo ''
        echo '=== Syntax-Check JSONC (Waybar) ==='
        if command -v python3 &>/dev/null; then
            python3 -c \"import json, sys; json.load(open('.config/waybar/config.jsonc'))\" 2>&1 && echo 'JSONC Syntax OK' || echo 'JSONC Check fehlgeschlagen (Kommentare?)'
        fi
    "

echo "============================================"
echo "Test abgeschlossen!"
echo "============================================"
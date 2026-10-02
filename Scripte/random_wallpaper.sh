#!/bin/bash

# 1. Pfad zu Ihrem Wallpaper-Ordner (Hier Ihren Pfad anpassen!)
WALLPAPER_DIR="$HOME/Bilder/Wallpaper/"

# 2. Alle unterstützten Bilder alphabetisch sortiert in ein Array einlesen
mapfile -d '' WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -print0 | sort -z)

# Falls der Ordner leer ist, abbrechen
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "Keine Bilder im Ordner $WALLPAPER_DIR gefunden!"
    exit 1
fi

# 3. Das aktuell aktive Wallpaper über hyprctl ermitteln
CURRENT_WALL=$(hyprctl hyprpaper listactive | awk -F': ' '{print $2}' | head -n 1)

# Index des nächsten Bildes bestimmen
NEXT_INDEX=0

if [ -n "$CURRENT_WALL" ]; then
    # Suche die Position des aktuellen Bildes im Array
    for i in "${!WALLPAPERS[@]}"; do
        if [ "${WALLPAPERS[$i]}" = "$CURRENT_WALL" ]; then
            # Wenn gefunden, nimm das nächste Element
            NEXT_INDEX=$(( (i + 1) % ${#WALLPAPERS[@]} ))
            break
        fi
    done
fi

# 4. Das nächste Wallpaper in der Reihenfolge setzen
NEXT_WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"
hyprctl hyprpaper wallpaper ,"$NEXT_WALLPAPER"

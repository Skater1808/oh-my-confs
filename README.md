# oh-my-confs

Meine persönlichen Dotfiles für Arch Linux mit Hyprland, Waybar, Kitty & Co.

![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?logo=arch-linux&logoColor=fff)
![Hyprland](https://img.shields.io/badge/Hyprland-0.56+-8EC07C)
![Waybar](https://img.shields.io/badge/Waybar-0.15+-F5C2E7)

---

## 📦 Inhalt

| Kategorie | Tools |
|-----------|-------|
| **Window Manager** | Hyprland (Lua Config), hyprpaper |
| **Bar** | Waybar (Catppuccin Mocha) |
| **Terminal** | Kitty (Catppuccin Mocha, JetBrainsMono Nerd Font) |
| **Launcher** | Wofi |
| **Editor** | Kate, Neovim (via kitty) |
| **File Manager** | Nemo |
| **Cursor** | Banana (AUR: `banana-cursor-bin`) |
| **Keyboard** | keyd (CapsLock → Navigation Layer) |
| **Container** | Docker, Podman, QEMU |
| **Media** | MPV, VLC, OBS Studio, Kdenlive |

---

## 🚀 Installation

### 1. Repository klonen
```bash
git clone https://github.com/dein-user/oh-my-confs.git ~/oh-my-confs
cd ~/oh-my-confs
```

### 2. Pakete installieren
```bash
./install-packages.sh
```
Installiert alle Pakete aus den offiziellen Repos + AUR (via yay).

### 3. Configs einrichten
```bash
./setup.sh
```
Erstellt Symlinks, kopiert Wallpapers, richtet GTK/Cursor ein, verlinkt Scripts.

### 4. keyd aktivieren (braucht sudo)
```bash
sudo mkdir -p /etc/keyd
sudo cp keyd.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
```

### 5. Neustarten
```bash
reboot
```

---

## ⌨️ Tastenkürzel (Hyprland)

| Shortcut | Aktion |
|----------|--------|
| `SUPER + Return` | Kitty Terminal öffnen |
| `SUPER + SPACE` | Wofi App Launcher |
| `SUPER + W` | Fenster schließen |
| `SUPER + SHIFT + F` | Nemo Dateimanager |
| `SUPER + O` | Fenster float/tile togglen |
| `SUPER + P` | Pseudo-Tiling |
| `SUPER + J` | Split togglen (dwindle) |
| `SUPER + SHIFT + S` | Screenshot (omasnap) |
| `SUPER + 1-0` | Workspace 1-10 wechseln |
| `SUPER + SHIFT + 1-0` | Fenster zu Workspace 1-10 bewegen |
| `SUPER + S` | Scratchpad (special:magic) togglen |
| `SUPER + CTRL + SPACE` | Nächstes Wallpaper |
| `SUPER + ESC` | Hyprland beenden / Shutdown-Menü |
| `SUPER + Mausrad` | Workspace wechseln |
| `SUPER + LMB` | Fenster verschieben |
| `SUPER + RMB` | Fenster resize |

**Multimedia Keys:**
| Taste | Aktion |
|-------|--------|
| `XF86AudioRaiseVolume` | Lauter |
| `XF86AudioLowerVolume` | Leiser |
| `XF86AudioMute` | Stumm schalten |
| `XF86MonBrightnessUp` | Helligkeit + |
| `XF86MonBrightnessDown` | Helligkeit - |

---

## 🖱️ keyd Config (CapsLock Layer)

```ini
[ids]
*

[main]
capslock = layer(nav)

[nav]
w = up
a = left
s = down
d = right
q = shift + 2  # @
```

**CapsLock gedrückt + WASD** = Pfeiltasten
**CapsLock + Q** = @

---

## 🎨 Themes & Colors

- **Farbschema:** Catppuccin Mocha
- **Font:** JetBrainsMono Nerd Font (11-13pt)
- **Cursor:** Banana (4 Varianten: Standard, Blue, Green, Red)
- **GTK Theme:** Adwaita-dark

---

## 📁 Struktur

```
oh-my-confs/
├── install-packages.sh      # Paket-Installation (pacman + yay)
├── setup.sh                 # Symlinks, Wallpapers, GTK, Scripts
├── test-in-docker.sh        # Docker-Test (Configs)
├── test-packages-in-docker.sh # Docker-Test (Pakete)
├── Dockerfile.test          # Test-Container
├── keyd.conf                # keyd Keyboard Remapping
├── .bashrc                  # Bash Config + PATH
├── .config/
│   ├── hypr/
│   │   ├── hyprland.lua     # Hyprland Config (Lua)
│   │   └── hyprpaper.conf   # Wallpaper Config
│   ├── kitty/
│   │   └── kitty.conf       # Kitty Terminal Config
│   └── waybar/
│       ├── config.jsonc     # Waybar Module/Layout
│       └── style.css        # Waybar Styling (Catppuccin)
├── Scripte/
│   └── random_wallpaper.sh  # Wallpaper-Rotation via hyprctl
└── wallpaper/               # Wallpaper-Sammlung (8 Bilder)
```

---

## 🔧 Anpassungen

### Monitor Setup (hyprland.lua)
```lua
hl.monitor({
    output   = "DP-1",     -- oder "HDMI-A-1", "eDP-1"
    mode     = "2560x1440@120",
    position = "auto",
    scale    = "auto",
})
```

### Cursor Theme wechseln
```bash
# GNOME/GTK
gsettings set org.gnome.desktop.interface cursor-theme Banana-Blue

# Hyprland (hyprland.lua)
hl.env("XCURSOR_THEME", "Banana-Blue")
```

### Wallpaper Ordner
Standard: `~/Bilder/Wallpaper/` (wird von `setup.sh` befüllt)

Eigenen Ordner in `hyprpaper.conf` und `random_wallpaper.sh` anpassen.

---

## 🐳 Docker Test

Configs & Pakete in sauberer Arch-Umgebung testen:

```bash
# Config-Test (schnell)
./test-in-docker.sh

# Paket-Installation testen (länger, ~5-10 Min)
./test-packages-in-docker.sh
```

---

## 📋 Paket-Listen

### Offizielle Repos (pacman) - 87 Pakete
```bash
pacman -Qqe > pacman-packages.txt
```

### AUR (yay) - 9 Pakete
```bash
pacman -Qqm > aur-packages.txt
```

**AUR Pakete:**
- `banana-cursor-bin` - Cursor Theme
- `i686-linux-gnu-binutils` - 32-bit Cross-Compiler
- `lmbionic-bin` - LM Studio (local LLMs)
- `lmstudio-bin` - LM Studio GUI
- `localsend-bin` - Dateitransfer LAN
- `omasnap-bin` - Screenshot Tool
- `visual-studio-code-bin` - VS Code
- `waybar-git` - Waybar (Git Version)
- `yay` - AUR Helper

---

## 🔄 Update

```bash
cd ~/oh-my-confs
git pull
./install-packages.sh  # neue Pakete installieren
./setup.sh             # neue Configs verlinken
```

---

## 🛠️ Troubleshooting

### Hyprland Lua Config lädt nicht
```bash
# Prüfen ob hyprland mit Lua gebaut ist
hyprctl version | grep -i lua
```

### Waybar startet nicht
```bash
# Logs prüfen
waybar &
# oder
journalctl --user -u waybar -f
```

### keyd funktioniert nicht
```bash
sudo systemctl status keyd
sudo keyd -d  # Debug Modus
```

### Cursor Theme wird nicht angewendet
```bash
# GTK Settings neu laden
gsettings reset org.gnome.desktop.interface cursor-theme
gsettings set org.gnome.desktop.interface cursor-theme Banana

# Oder Hyprland neu starten
hyprctl reload
```

---

## 📸 Screenshots

*(Platzhalter - füge Screenshots in `screenshots/` Ordner hinzu)*

---

## 📄 Lizenz

MIT License -自由に使ってね

---

## 🙏 Credits

- [Hyprland](https://hypr.land) - Dynamic tiling Wayland compositor
- [Waybar](https://github.com/Alexays/Waybar) - Highly customizable Wayland bar
- [Catppuccin](https://catppuccin.com) - Soothing pastel theme
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/font-page-jetbrains-mono)
- [Banana Cursor](https://github.com/ful1e5/banana-cursor) - Cute cursor theme
- [keyd](https://github.com/rvaiya/keyd) - Key remapping daemon
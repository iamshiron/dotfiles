# Dotfiles

Personal configuration for an Arch Linux workstation with KDE Plasma, managed via GNU Stow.

## Preview

![Desktop](./assets/desktop.png)

## Capabilities

- **Shell environment** — fish shell with Starship prompt, startup benchmarking, uv/pnpm path setup, and Podman alias
- **Terminal** — Alacritty with translucent background, blur, custom purple/dark color scheme, and blinking beam cursor
- **System overview** — fastfetch dashboard displaying hardware info, disk usage across multiple mount points, Podman container/image/volume counts, and local IP
- **KDE Plasma desktop** — Klassy widget style with purple accent theme, bottom panel layout (launcher, pager, icon tasks, system tray, clock), KWin tiling rules (25/50/25 split), and animated Wallpaper Engine backgrounds
- **Container management** — Podman configured with overlay storage driver and persistent volume path (`/mnt/docker/volumes`), plus a systemd template unit for declarative per-service compose stacks
- **Self-hosted services** — Forgejo (Git hosting) defined as a Podman Compose stack, managed via the systemd template
- **Audio processing** — Easy Effects preset for the Audio-Technica M50X microphone with noise suppression (RNNoise), gate, EQ, de-esser, compressor, and limiter
- **Package provisioning** — Maintained lists of official repo, AUR, and NVIDIA packages for full system reproduction
- **AUR helper setup** — Script to bootstrap `paru` from source

## Stack

Arch Linux / KDE Plasma 6 / fish / Alacritty / Starship / fastfetch / Podman / systemd / Easy Effects

## Structure

```
.
├── alacritty/        # Terminal emulator config
├── easy-effects/     # Audio processing presets
├── fastfetch/        # System info dashboard
├── fish/             # Shell config and aliases
├── kde/              # Plasma desktop, KWin, color scheme
├── opencode/         # CLI tool command definitions
├── podman/           # Container engine config
├── server/           # Self-hosted service compose files and systemd units
├── starship/         # Shell prompt config
├── pkglist-repo.txt  # Official Arch packages
├── pkglist-aur.txt   # AUR packages
├── pkglist-nvidia.txt
└── install-paru.sh   # AUR helper bootstrap
```

## Usage

Clone and symlink configurations with Stow:

```bash
git clone <repo-url> ~/.dotfiles
cd ~/.dotfiles
stow alacritty easy-effects fastfetch fish kde opencode podman server starship
```

Install all tracked packages:

```bash
# Official repos
sudo pacman -S --needed - < pkglist-repo.txt

# AUR (requires paru or similar helper)
paru -S --needed - < pkglist-aur.txt
```

Bootstrap the AUR helper:

```bash
bash install-paru.sh
```

Enable a self-hosted service:

```bash
systemctl --user enable --now docker-compose@forgejo
```

## License

MIT

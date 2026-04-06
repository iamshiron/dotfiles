# Dotfiles

Personal configuration files for Arch Linux system running fish shell.

## Preview

![Desktop](./assets/desktop.png)

## System

- **OS**: Arch Linux (kernel 6.19.11-arch1-1)
- **Shell**: fish
- **Terminal**: Alacritty
- **Font**: MapleMono NF (12pt)

## Structure

```
.
├── alacritty/        # Alacritty terminal configuration
├── fastfetch/        # Fastfetch system info display
├── fish/             # Fish shell configuration
├── podman/           # Podman container configuration
└── starship/         # Starship prompt configuration
```

## Installation

1. Clone the repository:
   ```bash
   git clone <repo-url> ~/.dotfiles
   cd ~/.dotfiles
   ```

2. Create symlinks to configuration files:
   ```bash
   stow alacritty fastfetch fish podman starship
   ```

3. Install required packages:
   - `alacritty`
   - `fastfetch`
   - `fish`
   - `starship`
   - `podman`
   - `maple-mono-nf` (or set your preferred font)

## Configuration

### Alacritty
- Window dimensions: 130x35
- Opacity: 0.3 with blur
- Custom color scheme with purple/dark theme
- Shell: /usr/bin/fish

### Starship
- Powerline-style prompt with colored segments
- Shows: OS, user, directory, git branch, languages, docker context, time
- Active on all prompts

### Fastfetch
- System information display on shell startup
- Shows OS, kernel, uptime, packages, shell, terminal, CPU, GPU, memory, disk usage
- Displays running containers, images, and volumes
- Shows local IP address

### Podman
- Default volume path: `/mnt/docker/volumes`
- Docker alias mapped to podman

## License

MIT

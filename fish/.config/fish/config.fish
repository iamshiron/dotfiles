#oset -l _start (date +%s%N)

starship init fish | source
fastfetch

alias docker=podman

# uv
fish_add_path "/home/shiron/.local/bin"

# pnpm
set -gx PNPM_HOME "/home/shiron/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

mise activate fish | source

# opencode
fish_add_path /home/shiron/.opencode/bin

# pnpm
fish_add_path /home/shiron/.local/share/pnpm/bin

# Podman / Docker
set --export DOCKER_HOST "unix:///run/user/$(id -u)/podman/podman.sock"

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

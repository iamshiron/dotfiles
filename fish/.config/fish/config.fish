set -l _start (date +%s%N)

starship init fish | source
fastfetch

alias docker=podman

# uv
fish_add_path "/home/shiron/.local/bin"

set -l _elapsed (math -s0 "($(date +%s%N) - $_start) / 1000000")
echo (set_color brblack)"fish started in $_elapsed ms"(set_color normal)

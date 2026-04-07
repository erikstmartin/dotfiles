#!/bin/sh
# macOS memory usage in GB (anonymous + wired + compressed pages)
# Outputs tmux color codes based on vm.memory_pressure: >=2 red, >=1 yellow, else normal
# (matches wezterm ram_pressure_color logic)

pressure=$(sysctl -n vm.memory_pressure 2>/dev/null || echo 0)

color=$(awk -v p="$pressure" 'BEGIN {
  if (p >= 2) print "#f38ba8"
  else if (p >= 1) print "#f9e2af"
  else print "#cdd6f4"
}')

mem=$(vm_stat | awk '
  /page size of/                { ps = $8 + 0 }
  /^Anonymous pages/            { gsub(/\./, "", $NF); a = $NF + 0 }
  /^Pages purgeable/            { gsub(/\./, "", $NF); p = $NF + 0 }
  /^Pages wired down/           { gsub(/\./, "", $NF); w = $NF + 0 }
  /^Pages occupied by compressor/ { gsub(/\./, "", $NF); c = $NF + 0 }
  END { printf "%.2f GB", (a - p + w + c) * ps / 1073741824 }
')

printf "#[fg=%s]%s#[fg=#cdd6f4]" "$color" "$mem"

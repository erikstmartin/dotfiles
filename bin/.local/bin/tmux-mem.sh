#!/bin/sh
# Memory usage in GB (macOS + Linux)
# macOS: anonymous + wired + compressed pages; color from vm.memory_pressure: >=2 red, >=1 yellow
#        (matches wezterm ram_pressure_color logic)
# Linux: MemTotal - MemAvailable; color from used %: >=90 red, >=75 yellow

case "$(uname -s)" in
Darwin)
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
  ;;
Linux)
  set -- $(LC_NUMERIC=C awk '
    /^MemTotal:/     { t = $2 }
    /^MemAvailable:/ { a = $2 }
    END {
      used = t - a; pct = (t > 0 ? used * 100 / t : 0)
      color = (pct >= 90 ? "#f38ba8" : (pct >= 75 ? "#f9e2af" : "#cdd6f4"))
      printf "%s %.2f", color, used / 1048576
    }' /proc/meminfo)
  color=$1
  mem="$2 GB"
  ;;
*)
  exit 0
  ;;
esac

printf "#[fg=%s]%s#[fg=#cdd6f4]" "$color" "$mem"

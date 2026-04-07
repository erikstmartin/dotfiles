#!/bin/sh
# CPU usage % averaged across all logical cores (macOS + Linux)
# Outputs tmux color codes based on threshold: >=90% red, >=75% yellow, else normal
case "$(uname -s)" in
Darwin)
  ncpu=$(sysctl -n hw.ncpu)
  pct=$(ps -A -o %cpu | LC_NUMERIC=C awk -v ncpu="$ncpu" '{s+=$1} END {printf "%.2f", s/ncpu}')
  ;;
Linux)
  # Sample the aggregate "cpu" line of /proc/stat twice and diff busy vs total jiffies
  s1=$(awk '/^cpu /{print $2+$3+$4+$7+$8+$9, $5+$6; exit}' /proc/stat)
  sleep 0.5
  s2=$(awk '/^cpu /{print $2+$3+$4+$7+$8+$9, $5+$6; exit}' /proc/stat)
  pct=$(echo "$s1 $s2" | LC_NUMERIC=C awk '{
    busy = $3 - $1; idle = $4 - $2; total = busy + idle
    printf "%.2f", (total > 0 ? busy * 100 / total : 0)
  }')
  ;;
*)
  exit 0
  ;;
esac

# Determine color based on thresholds (matches wezterm threshold_color logic)
color=$(awk -v p="$pct" 'BEGIN {
  if (p >= 90) print "#f38ba8"
  else if (p >= 75) print "#f9e2af"
  else print "#cdd6f4"
}')

printf "#[fg=%s]%.2f%%#[fg=#cdd6f4]" "$color" "$pct"

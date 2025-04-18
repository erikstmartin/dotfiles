#!/bin/sh
# CPU usage % averaged across all logical cores (macOS)
# Outputs tmux color codes based on threshold: >=90% red, >=75% yellow, else normal
ncpu=$(sysctl -n hw.ncpu)
pct=$(ps -A -o %cpu | LC_NUMERIC=C awk -v ncpu="$ncpu" '{s+=$1} END {printf "%.2f", s/ncpu}')

# Determine color based on thresholds (matches wezterm threshold_color logic)
color=$(awk -v p="$pct" 'BEGIN {
  if (p >= 90) print "#f38ba8"
  else if (p >= 75) print "#f9e2af"
  else print "#cdd6f4"
}')

printf "#[fg=%s]%.2f%%#[fg=#cdd6f4]" "$color" "$pct"

# Theme & Font Standards

Font, colors and cursor settings shared by the terminal emulators and UI tools. Keep configs in line with this file.

---

## Font

| Property    | Value                          |
|-------------|--------------------------------|
| Family      | `JetBrainsMono Nerd Font Mono` |
| Size        | `14`                           |
| Variant     | Mono (not Propo, not NL)       |

**Applies to:** Ghostty, WezTerm

**Does not apply to:** tmux, starship (defer to terminal), neovim (sets `have_nerd_font = true` only)

---

## Theme

**Catppuccin Mocha — Pitch Black variant**

Catppuccin Mocha with the background set to `#11111b` (Crust) instead of the default `#1e1e2e` (Base).

### Core Colors

| Role                 | Hex       | Catppuccin Name  |
|----------------------|-----------|------------------|
| Background           | `#11111b` | Crust (override) |
| Foreground           | `#cdd6f4` | Text             |
| Cursor               | `#f5e0dc` | Rosewater        |
| Cursor text          | `#1e1e2e` | Base             |
| Selection background | `#f5e0dc` | Rosewater        |
| Selection foreground | `#1e1e2e` | Base             |

### ANSI Palette (16 colors)

| Index | Role            | Hex       | Catppuccin Name |
|-------|-----------------|-----------|-----------------|
| 0     | Black           | `#45475a` | Surface 1       |
| 1     | Red             | `#f38ba8` | Red             |
| 2     | Green           | `#a6e3a1` | Green           |
| 3     | Yellow          | `#f9e2af` | Yellow          |
| 4     | Blue            | `#89b4fa` | Blue            |
| 5     | Magenta         | `#f5c2e7` | Pink            |
| 6     | Cyan            | `#94e2d5` | Teal            |
| 7     | White           | `#bac2de` | Subtext 1       |
| 8     | Bright Black    | `#585b70` | Surface 2       |
| 9     | Bright Red      | `#f38ba8` | Red             |
| 10    | Bright Green    | `#a6e3a1` | Green           |
| 11    | Bright Yellow   | `#f9e2af` | Yellow          |
| 12    | Bright Blue     | `#89b4fa` | Blue            |
| 13    | Bright Magenta  | `#f5c2e7` | Pink            |
| 14    | Bright Cyan     | `#94e2d5` | Teal            |
| 15    | Bright White    | `#a6adc8` | Subtext 0       |

### UI Chrome Colors

| Role                    | Hex       | Catppuccin Name |
|-------------------------|-----------|-----------------|
| Tab bar background      | `#11111b` | Crust           |
| Active tab background   | `#313244` | Surface 0       |
| Active tab foreground   | `#cdd6f4` | Text            |
| Inactive tab background | `#181825` | Mantle          |
| Inactive tab foreground | `#6c7086` | Overlay 0       |
| Border / pane divider   | `#313244` | Surface 0       |
| Active border           | `#89b4fa` | Blue            |
| Status bar background   | `#11111b` | Crust           |

---

## Cursor

| Property | Value          |
|----------|----------------|
| Style    | Blinking Block |
| Rate     | 500ms          |
| Ease     | Constant       |

**Applies to:** WezTerm (explicit), Ghostty (default block cursor behavior)

---
## Known Exceptions / Intentional Overrides

- **tmux**: Uses the `catppuccin` tmux plugin; color values are set via plugin variables, not raw hex in most cases.
- **Neovim**: if `vim.g.have_nerd_font = true` is set, the configured terminal font must be Nerd Font 3.0+ for plugin icons to render correctly.

# Keyboard Shortcut Conflicts

This document lists all conflicts between the WM keybindings (skhd/yabai) and standard macOS application shortcuts.

Since `cmd` (⌘) is used as the primary WM modifier — matching the Hyprland `SUPER` paradigm — it will intercept keystrokes before most applications can handle them.

## Legend

| Symbol | Meaning |
|--------|---------|
| 🔴 **BLOCKS** | skhd intercepts the key; app **never receives it** |
| 🟡 **CONTEXT** | Only blocks when the focused app is in a specific state |
| 🟢 **SAFE** | No conflict — app receives the key normally |

---

## skhd (Window Manager) — `cmd` based

### 🔴 Navigation — cmd + Arrow Keys

| Shortcut | WM Action | macOS Default | Affected Apps |
|----------|-----------|---------------|---------------|
| `⌘ ←` | Focus window west | Move cursor to line start / navigate back | **All text fields**: TextEdit, VS Code, browser URL bars, Notes, Slack |
| `⌘ →` | Focus window east | Move cursor to line end / navigate forward | **All text fields**: same as above |
| `⌘ ↑` | Focus window north | Scroll to top / go to parent folder | **Finder**: go up folder. **Safari/Chrome**: scroll to top. **Mail**: go to top of list |
| `⌘ ↓` | Focus window south | Scroll to bottom / open selected item | **Finder**: open file. **Safari/Chrome**: scroll to bottom. **Mail**: go to bottom of list |

### 🔴 Space Switching — cmd + Number

| Shortcut | WM Action | macOS Default | Affected Apps |
|----------|-----------|---------------|---------------|
| `⌘ 1` | Focus space 1 | Switch to tab 1 | **Every app with tabs**: Chrome, Safari, Firefox, Finder, Terminal, VS Code, Slack, Spotify |
| `⌘ 2` | Focus space 2 | Switch to tab 2 | Same as above |
| `⌘ 3` | Focus space 3 | Switch to tab 3 | Same as above |
| `⌘ 4` | Focus space 4 | Switch to tab 4 | Same as above |

### 🔴 Toggle — cmd + Letter

| Shortcut | WM Action | macOS Default | Affected Apps |
|----------|-----------|---------------|---------------|
| `⌘ Space` | Toggle window float | **Spotlight** / Alfred search | **System-wide**: completely blocks Spotlight or Alfred. This is the most critical conflict |
| `⌘ f` | Toggle zoom-parent | Find / Search | **Every app**: browser find, VS Code search, Finder search, Mail search |
| `⌘ h` | Focus first window in space | Hide current application | **System-wide**: macOS hides the frontmost app. You **cannot hide any app** |
| `⌘ p` | Focus last window in space | Print | **Every app with print**: browsers, TextEdit, Preview, etc. |
| `⌘ s` | Split window east | Save | **Every app with save**: you **cannot save files** with ⌘S. Critical |
| `⌘ v` | Split window south | Paste | **System-wide**: you **cannot paste** text. Critical |

### 🟡 Window Movement — Shift + cmd

| Shortcut | WM Action | macOS Default | Affected Apps |
|----------|-----------|---------------|---------------|
| `⇧⌘ ←` | Warp window west | Select to line start / extend selection | Text editors (VS Code, TextEdit) |
| `⇧⌘ →` | Warp window east | Select to line end / extend selection | Text editors |
| `⇧⌘ ↑` | Warp window north | Select to document start | Text editors |
| `⇧⌘ ↓` | Warp window south | Select to document end | Text editors |
| `⇧⌘ 1`–`⇧⌘ 4` | Move window to space 1–4 | Switch to tab (some apps use ⇧⌘+n) | **Chrome**: switch to first n tabs. **Safari**: same |
| `⇧⌘ f` | Toggle zoom-fullscreen | Full screen / Enter full screen | **Safari, Chrome, Finder, most apps**: entering fullscreen mode is blocked |
| `⇧⌘ s` | Toggle split orientation | Save As… / Screenshot (macOS Mojave+) | **TextEdit, Pages**: Save As blocked. **System**: screenshot tool partially blocked |
| `⇧⌘ x` | Mirror space x-axis | (no default, but used by some apps) | Relatively safe |
| `⇧⌘ y` | Mirror space y-axis | (no default) | Safe |
| `⇧⌘ Space` | Toggle sketchybar | (no default) | Safe |
| `⇧⌘ n` | Move window to next space | New window / New folder | **Finder**: New Folder blocked. **Chrome**: New Window blocked. **Many apps**: New window blocked |
| `⇧⌘ p` | Move window to prev space | Page setup (print dialog) | **Print dialogs**: blocked |

### 🟢 Stacks — Shift + Ctrl

| Shortcut | WM Action | macOS Default | Affected Apps |
|----------|-----------|---------------|---------------|
| `⇧⌃ ←/→/↑/↓` | Stack window directionally | No standard macOS binding | Generally safe |
| `⇧⌃ n` | Focus stack next | No standard macOS binding | Safe |
| `⇧⌃ p` | Focus stack prev | No standard macOS binding | Safe |

### 🟢 Resize — Ctrl + cmd

| Shortcut | WM Action | macOS Default | Affected Apps |
|----------|-----------|---------------|---------------|
| `⌃⌘ ←/→/↑/↓` | Resize window | No standard macOS binding | Generally safe |
| `⌃⌘ e` | Balance space | No standard macOS binding | Safe |
| `⌃⌘ g` | Toggle gaps | No standard macOS binding | Safe |

### 🟢 Insertion — Shift + Ctrl + cmd

| Shortcut | WM Action | macOS Default | Affected Apps |
|----------|-----------|---------------|---------------|
| `⇧⌃⌘ ←/→/↑/↓` | Set insertion point | No standard macOS binding | Safe |
| `⇧⌃⌘ s` | Set insertion stack | No standard macOS binding | Safe |

---

## Summary — Critical Conflicts

These shortcuts are **unusable in their original macOS function**:

| Shortcut | Lost Function | Severity |
|----------|---------------|----------|
| `⌘ Space` | Spotlight / Alfred | 🔴 **Critical** |
| `⌘ s` | Save | 🔴 **Critical** |
| `⌘ v` | Paste | 🔴 **Critical** |
| `⌘ c` | Copy (if ever mapped) | 🔴 **Critical** |
| `⌘ f` | Find / Search | 🔴 **Critical** |
| `⌘ h` | Hide Application | 🔴 **High** |
| `⌘ 1`–`⌘ 4` | Switch tabs | 🔴 **High** |
| `⌘ ←/→/↑/↓` | Cursor navigation | 🔴 **High** |
| `⇧⌘ n` | New window/folder | 🟡 **Medium** |
| `⇧⌘ f` | Toggle fullscreen | 🟡 **Medium** |
| `⇧⌘ s` | Save As / Screenshot | 🟡 **Medium** |
| `⌘ p` | Print | 🟡 **Low** |
| `⌘ n` | New (not mapped yet, but ⌘s triggers it) | 🟡 **Low** |

---

## Recommended Fixes

### Option A: Switch to `lalt` (Option) — Recommended

Change `cmd` to `lalt` in `skhdrc`. Minimal conflicts, standard in yabai setups:

- `⌥ ←/→/↑/↓` — focus windows
- `⌥ 1`–`⌥ 4` — switch spaces
- All `⌘` shortcuts work normally in apps

### Option B: Use Hyper key via Karabiner

Map **Caps Lock → Hyper** (⌘+⌃+⌥ simultaneously) via Karabiner-Elements, then use `hyper` as the skhd modifier:

```
hyper - left  : yabai -m window --focus west
hyper - 1     : focus space 1
```

Zero conflicts. Every `⌘` shortcut works normally.

### Option C: Partial — keep some `cmd`, move the critical ones

Keep `⌘ ←/→/↑/↓` for window focus (acceptable tradeoff) but move these to `lalt`:

| Move to `lalt` | Reason |
|-----------------|--------|
| `lalt - space` | Restore Spotlight |
| `lalt - s` | Restore ⌘S Save |
| `lalt - v` | Restore ⌘V Paste |
| `lalt - f` | Restore ⌘F Find |
| `lalt - h` | Restore ⌘H Hide |

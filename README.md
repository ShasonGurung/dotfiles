# `.sgdotfiles`

Personal dotfiles with a Wayland-first Linux setup and a smaller cross-platform shell layer.

## What is in this repo

- `~/.zshenv` sets `XDG_CONFIG_HOME` and points `ZDOTDIR` at `.config/zsh`
- `.config/zsh` contains the portable shell setup
- `.config/alacritty`, `.config/fastfetch` are terminal tools
- `.config/sway`, `.config/waybar`, `.config/wlogout`, `.config/wofi`, `.config/dunst` are Linux desktop configs
- `.config/Wallpapers` contains local wallpaper assets and is optional

## Platform notes

### Linux

This repo is primarily maintained for Linux. The desktop stack is built around:

- `sway`
- `waybar`
- `wofi`
- `wlogout`
- `dunst`

### macOS

Only the shell and terminal pieces are expected to be useful as-is:

- `.zshenv`
- `.config/zsh`
- `.config/alacritty`
- `.config/fastfetch`

The Linux desktop configs are not meant to run on macOS.

### WSL

The shell layer should work with minor adjustments, but the Wayland desktop pieces are not assumed to work. Treat WSL support as partial and opt-in.

## Clone

```bash
git clone --recurse-submodules https://github.com/Jivanam/dotfiles.git ~/.sgdotfiles
cd ~/.sgdotfiles
git submodule update --init --recursive
```

## Install

The installer is split into groups:

- `shell`: zsh and terminal tooling
- `desktop`: Linux desktop configs
- `wallpapers`: wallpaper assets only
- `deps`: print dependency hints for the current OS
- `check`: verify expected commands are installed
- `all`: shell, desktop, and wallpapers

Examples:

```bash
./setup.sh
./setup.sh shell
./setup.sh desktop
./setup.sh wallpapers
./setup.sh deps
./setup.sh check
./setup.sh check shell
./setup.sh check desktop
./setup.sh all
./setup.sh --dry-run all
./setup.sh status
```

By default, `./setup.sh` installs `shell`.

Before replacing an existing managed path, the installer moves it to a
timestamped `.backup.YYYYMMDDhhmmss` path. Use `--dry-run` to preview these
changes. `status` reports `ok`, `missing`, or `conflict` for every managed path
and exits non-zero unless all links are correct.

## Prerequisites

### Fonts

These configs assume Nerd Font glyph support. The two relevant fonts here are:

- `JetBrainsMono Nerd Font`
- `MesloLGS NF`

`JetBrainsMono Nerd Font` is used by terminal/UI configs. `MesloLGS NF` is useful for the Powerlevel10k prompt.

### Shell tools

Expected shell-side commands:

- `zsh`
- `git`
- `fastfetch`
- `eza`

### Linux desktop tools

Expected desktop-side commands:

- `sway`
- `swaymsg`
- `swaylock`
- `swayidle`
- `waybar`
- `wofi`
- `wlogout`
- `dunst`
- `grim`
- `slurp`
- `jq`
- `pavucontrol`
- `thunar`
- `udiskie`

Optional but used by some features:

- `mpvpaper`
- `azote`

Use:

```bash
./setup.sh deps
./setup.sh check
```

to print package hints and verify what is currently installed.

`./setup.sh check` is platform-aware by default:

- on Linux it checks both shell and desktop commands
- on macOS and other non-Linux systems it checks shell commands only

You can also force a scope:

```bash
./setup.sh check shell
./setup.sh check desktop
./setup.sh check all
```

## What the installer links

### Shell

- `.zshenv` -> `~/.zshenv`
- `.gitconfig` -> `~/.gitconfig`
- `.config/zsh` -> `~/.config/zsh`
- `.config/alacritty` -> `~/.config/alacritty`
- `.config/fastfetch` -> `~/.config/fastfetch`
- `.config/eza-themes/one_dark.yml` -> `~/.config/eza/theme.yml`

### Desktop

- `.config/dunst`
- `.config/sway`
- `.config/waybar`
- `.config/wlogout`
- `.config/wofi`

### Wallpapers

- `.config/Wallpapers` -> `~/.config/Wallpapers`

The tracked `.gitconfig` contains shared settings only. Put your identity in
the untracked `~/.gitconfig.local`:

```gitconfig
[user]
    name = Your Name
    email = you@example.com
```

## Update

```bash
git pull --recurse-submodules
git submodule update --init --recursive
```

## TTY startup

`sway` starts from `.config/zsh/.zlogin`, and only when all of the following are true:

- the OS is Linux
- `START_SWAY_FROM_TTY` is not disabled
- the active terminal is `/dev/tty1`
- `~/.config/sway/start-sway.sh` exists and is executable

## Sway layout

The sway config is split into small files under `.config/sway/config.d`:

- `00-base.conf`: shared defaults and variables
- `10-startup.conf`: startup programs
- `20-inputs.conf`: keyboard/input defaults
- `30-outputs.conf`: machine-specific monitor examples
- `40-bindings.conf`: keybindings and resize mode
- `50-bar.conf`: bar setup

The default repo intentionally avoids forcing a specific monitor or workspace-to-output mapping. Put machine-specific output tweaks in `30-outputs.conf`.

Outputs are applied at startup by `~/.config/sway/configure-outputs.sh`. By default it:

- uses the laptop panel when it is the only display
- uses the external display when it is the only display
- places one external display above the laptop when both are present

For local overrides, copy `.config/sway/local/outputs.env.example` to `~/.config/sway/local/outputs.env`.

Named profiles are also supported through `SWAY_OUTPUT_PROFILE`. The script will load:

- `~/.config/sway/local/profiles/desktop.env`
- `~/.config/sway/local/profiles/laptop.env`
- `~/.config/sway/local/profiles/docked.env`

Examples are included under `.config/sway/examples/outputs-profiles/`.

Scale is configurable already, but not auto-detected. Use:

- `SWAY_SCALE` for a shared default
- `SWAY_PRIMARY_SCALE` for single-display profiles
- `SWAY_EXTERNAL_SCALE` and `SWAY_INTERNAL_SCALE` for dual-display profiles

Useful command inside Sway:

```bash
swaymsg -t get_outputs -r | jq -r '.[] | select(.active) | "\(.name) \(.rect.width)x\(.rect.height) @ \(.rect.x),\(.rect.y)"'
```

## Structure

```text
.
├── .zshenv
├── .config
│   ├── alacritty
│   ├── fastfetch
│   ├── Wallpapers
│   ├── sway
│   ├── waybar
│   ├── wlogout
│   ├── wofi
│   └── zsh
└── setup.sh
```

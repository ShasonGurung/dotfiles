#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_home="${HOME}"
target_config="${target_home}/.config"
mode="shell"
check_scope="auto"
dry_run=0

usage() {
  cat <<'EOF'
usage: ./setup.sh [--dry-run] [shell|desktop|wallpapers|all|deps|check [auto|shell|desktop|all]|status]

shell      install portable shell and terminal config (default)
desktop    install Linux desktop config
wallpapers install wallpaper assets
all        install shell, desktop, and wallpapers
deps       print platform-specific dependency hints
check      verify required commands; auto checks shell on macOS, all on Linux
status     show whether every managed path is linked correctly
--dry-run  print filesystem changes without applying them
EOF
}

while (($#)); do
  case "$1" in
    --dry-run) dry_run=1 ;;
    shell|desktop|wallpapers|all|deps|status) mode="$1" ;;
    check)
      mode="check"
      if (($# > 1)) && [[ "$2" =~ ^(auto|shell|desktop|all)$ ]]; then
        check_scope="$2"
        shift
      fi
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'unknown argument: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

shell_packages_common=(
  zsh
  git
  fastfetch
  eza
)

desktop_packages_linux=(
  sway
  swaylock
  swayidle
  waybar
  wofi
  wlogout
  dunst
  grim
  slurp
  jq
  pavucontrol
  thunar
  udiskie
)

desktop_packages_optional_linux=(
  mpvpaper
  azote
)

required_commands_shell=(
  zsh
  git
  fastfetch
  eza
)

required_commands_desktop=(
  sway
  swaymsg
  swaylock
  swayidle
  waybar
  wofi
  wlogout
  dunst
  grim
  slurp
  jq
  pavucontrol
  thunar
  udiskie
)

optional_commands_desktop=(
  mpvpaper
  azote
)

detect_os() {
  case "$(uname -s)" in
    Linux) echo "linux" ;;
    Darwin) echo "macos" ;;
    *) echo "unknown" ;;
  esac
}

detect_linux_pkg_manager() {
  if command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  else
    echo "unknown"
  fi
}

print_list() {
  local title="$1"
  shift
  printf '%s\n' "$title"
  printf '  %s\n' "$@"
}

show_deps() {
  local os_name pkg_manager
  os_name="$(detect_os)"

  print_list "Fonts:" "JetBrainsMono Nerd Font" "MesloLGS NF"
  echo

  case "$os_name" in
    linux)
      pkg_manager="$(detect_linux_pkg_manager)"
      print_list "Required shell packages:" "${shell_packages_common[@]}"
      echo
      print_list "Required desktop packages:" "${desktop_packages_linux[@]}"
      echo
      print_list "Optional desktop packages:" "${desktop_packages_optional_linux[@]}"
      echo
      case "$pkg_manager" in
        pacman)
          printf 'Suggested install:\n  sudo pacman -S %s %s\n' \
            "${shell_packages_common[*]}" "${desktop_packages_linux[*]}"
          ;;
        apt)
          printf 'Suggested install:\n  sudo apt-get install %s %s\n' \
            "${shell_packages_common[*]}" "${desktop_packages_linux[*]}"
          ;;
        dnf)
          printf 'Suggested install:\n  sudo dnf install %s %s\n' \
            "${shell_packages_common[*]}" "${desktop_packages_linux[*]}"
          ;;
        *)
          printf 'Install the packages above with your distro package manager.\n'
          ;;
      esac
      ;;
    macos)
      print_list "Suggested Homebrew packages:" "${shell_packages_common[@]}"
      echo
      printf 'Suggested install:\n  brew install %s\n' "${shell_packages_common[*]}"
      ;;
    *)
      printf 'Unsupported platform for dependency hints.\n'
      ;;
  esac
}

check_commands() {
  local missing=0 cmd
  local os_name scope

  os_name="$(detect_os)"
  scope="${1:-auto}"

  if [[ "$scope" == "auto" ]]; then
    case "$os_name" in
      linux) scope="all" ;;
      *) scope="shell" ;;
    esac
  fi

  print_list "Expected fonts:" "JetBrainsMono Nerd Font" "MesloLGS NF"
  echo

  if [[ "$scope" == "shell" || "$scope" == "all" ]]; then
    printf 'Shell commands:\n'
    for cmd in "${required_commands_shell[@]}"; do
      if command -v "$cmd" >/dev/null 2>&1; then
        printf '  ok   %s\n' "$cmd"
      else
        printf '  miss %s\n' "$cmd"
        missing=1
      fi
    done
  fi

  if [[ "$scope" == "desktop" || "$scope" == "all" ]]; then
    echo
    printf 'Desktop commands:\n'
    for cmd in "${required_commands_desktop[@]}"; do
      if command -v "$cmd" >/dev/null 2>&1; then
        printf '  ok   %s\n' "$cmd"
      else
        printf '  miss %s\n' "$cmd"
        missing=1
      fi
    done

    echo
    printf 'Optional desktop commands:\n'
    for cmd in "${optional_commands_desktop[@]}"; do
      if command -v "$cmd" >/dev/null 2>&1; then
        printf '  ok   %s\n' "$cmd"
      else
        printf '  skip %s\n' "$cmd"
      fi
    done
  fi

  return "$missing"
}

link_path() {
  local source_path="$1"
  local target_path="$2"
  local backup_path

  if [[ -L "$target_path" ]] && [[ "$(readlink "$target_path")" == "$source_path" ]]; then
    printf 'ok     %s -> %s\n' "$target_path" "$source_path"
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    backup_path="${target_path}.backup.$(date +%Y%m%d%H%M%S)"
    if ((dry_run)); then
      printf 'backup %s -> %s\n' "$target_path" "$backup_path"
    else
      mv "$target_path" "$backup_path"
      printf 'backed up %s -> %s\n' "$target_path" "$backup_path"
    fi
  fi

  if ((dry_run)); then
    printf 'link   %s -> %s\n' "$target_path" "$source_path"
  else
    mkdir -p "$(dirname "$target_path")"
    ln -s "$source_path" "$target_path"
    printf 'linked %s -> %s\n' "$target_path" "$source_path"
  fi
}

status_path() {
  local source_path="$1"
  local target_path="$2"

  if [[ -L "$target_path" ]] && [[ "$(readlink "$target_path")" == "$source_path" ]]; then
    printf 'ok       %s -> %s\n' "$target_path" "$source_path"
  elif [[ -e "$target_path" || -L "$target_path" ]]; then
    printf 'conflict %s (expected link to %s)\n' "$target_path" "$source_path"
    return 1
  else
    printf 'missing  %s (expected link to %s)\n' "$target_path" "$source_path"
    return 1
  fi
}

show_status() {
  local result=0

  status_path "${repo_root}/.zshenv" "${target_home}/.zshenv" || result=1
  status_path "${repo_root}/.gitconfig" "${target_home}/.gitconfig" || result=1
  status_path "${repo_root}/.config/zsh" "${target_config}/zsh" || result=1
  status_path "${repo_root}/.config/alacritty" "${target_config}/alacritty" || result=1
  status_path "${repo_root}/.config/fastfetch" "${target_config}/fastfetch" || result=1
  status_path "${repo_root}/.config/eza-themes/one_dark.yml" "${target_config}/eza/theme.yml" || result=1
  status_path "${repo_root}/.config/dunst" "${target_config}/dunst" || result=1
  status_path "${repo_root}/.config/sway" "${target_config}/sway" || result=1
  status_path "${repo_root}/.config/waybar" "${target_config}/waybar" || result=1
  status_path "${repo_root}/.config/wlogout" "${target_config}/wlogout" || result=1
  status_path "${repo_root}/.config/wofi" "${target_config}/wofi" || result=1
  status_path "${repo_root}/.config/Wallpapers" "${target_config}/Wallpapers" || result=1

  return "$result"
}

install_shell() {
  link_path "${repo_root}/.zshenv" "${target_home}/.zshenv"
  link_path "${repo_root}/.gitconfig" "${target_home}/.gitconfig"
  link_path "${repo_root}/.config/zsh" "${target_config}/zsh"
  link_path "${repo_root}/.config/alacritty" "${target_config}/alacritty"
  link_path "${repo_root}/.config/fastfetch" "${target_config}/fastfetch"
  link_path "${repo_root}/.config/eza-themes/one_dark.yml" "${target_config}/eza/theme.yml"
}

install_desktop() {
  link_path "${repo_root}/.config/dunst" "${target_config}/dunst"
  link_path "${repo_root}/.config/sway" "${target_config}/sway"
  link_path "${repo_root}/.config/waybar" "${target_config}/waybar"
  link_path "${repo_root}/.config/wlogout" "${target_config}/wlogout"
  link_path "${repo_root}/.config/wofi" "${target_config}/wofi"
}

install_wallpapers() {
  link_path "${repo_root}/.config/Wallpapers" "${target_config}/Wallpapers"
}

case "${mode}" in
  shell)
    install_shell
    ;;
  desktop)
    install_desktop
    ;;
  deps)
    show_deps
    ;;
  check)
    check_commands "$check_scope"
    ;;
  wallpapers)
    install_wallpapers
    ;;
  all)
    install_shell
    install_desktop
    install_wallpapers
    ;;
  status)
    show_status
    ;;
  *)
    usage
    exit 1
    ;;
esac

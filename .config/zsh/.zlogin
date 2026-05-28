if [[ "$(uname -s)" == "Linux" ]] && [[ "${START_SWAY_FROM_TTY:-1}" == "1" ]] && [[ "$(tty)" == "/dev/tty1" ]] && [[ -x "$HOME/.config/sway/start-sway.sh" ]]; then
    exec "$HOME/.config/sway/start-sway.sh"
fi

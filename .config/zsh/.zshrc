if [[ -o interactive ]] \
  && [[ -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]] \
  && [[ -z "${FASTFETCH_SHOWN:-}" ]] \
  && [[ "${TERM:-}" != "dumb" ]] \
  && command -v fastfetch >/dev/null 2>&1; then
  export FASTFETCH_SHOWN=1
  fastfetch
fi

# Enable Powerlevel10k instant prompt. Console output belongs above this block,
# otherwise it appears after the prompt has already rendered.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

for config_file in "$HOME/.config/zsh/conf.d/"*.zsh; do
  [[ -r "$config_file" ]] && source "$config_file"
done

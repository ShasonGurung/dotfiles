if command -v eza >/dev/null 2>&1; then
  alias ls='eza -l -a --icons=always --color=always --group-directories-first'
  alias l.='eza -a | egrep "^\."'
fi

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

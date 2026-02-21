fastfetch

export ANDROID_SDK_HOME=$HOME/.config
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$HOME/.local/bin

# Get the PID of the gnome-keyring-daemon via systemd
export GNOME_KEYRING_PID=$(systemctl --user show -p MainPID gnome-keyring-daemon | sed 's/MainPID=//')

# Query the socket or environment variables if needed (example method using systemd's environment)
export GNOME_KEYRING_CONTROL=$(systemctl --user show gnome-keyring-daemon | grep -oP 'GNOME_KEYRING_CONTROL=\K.+' )


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Changing "ls" to "exa"
alias ls='eza -l -a --icons=always --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'

# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# autocompletion
fpath=(~/.config/zsh/plugin/zsh-completions/src $fpath)
autoload -Uz compinit
compinit

# theme/plugins
source ~/.config/zsh/plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/plugin/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/plugin/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# dotnet
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

# nvm
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

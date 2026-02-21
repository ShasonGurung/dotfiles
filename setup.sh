#!/bin/bash

sgdotfiles="$HOME/.sgdotfiles" #dot files location
# gitthings="$HOME/Downloads/gitthings"
# scripts="$HOME/Downloads/gitthings/scripts"

# #Installing Dependencies (arch only)
# echo "Installing Dependencies"
# sudo pacman -S wofi alacritty dunst fastfetch zsh git waybar thunar blueman waybar zsh

#Download Dots
# echo "Downloading Dotfiles"
# cd && git clone https://gitlab.com/shason/dotfiles.git

# Create the symbolic links
ln -sfn $sgdotfiles/.zshenv ~/

# Create symlinks for the directories in .config/
ln -sfn $sgdotfiles/.config/alacritty ~/.config/
ln -sfn $sgdotfiles/.config/dunst ~/.config/
ln -sfn $sgdotfiles/.config/fastfetch ~/.config/
ln -sfn $sgdotfiles/.config/zsh ~/.config/
ln -sfn $sgdotfiles/.config/wofi ~/.config/
ln -sfn $sgdotfiles/.config/sway ~/.config/
ln -sfn $sgdotfiles/.config/wlogout ~/.config/
ln -sfn $sgdotfiles/.config/waybar ~/.config/

# For individual files like one_dark.yml
mkdir -p $HOME/.config/eza
nano $HOME/.config/eza/theme.yml
ln -sfn $sgdotfiles/.config/eza-themes/themes/one_dark.yml ~/.config/eza/theme.yml

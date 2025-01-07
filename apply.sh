#!/usr/bin/env bash
#
# apply.sh
# Replaces existing files/folders in your HOME directory with those from ~/Documents/dotfiles

set -euo pipefail # exit on error, treat undefined vars as errors, etc.

# Change this path to wherever you store your dotfiles
DOTFILES_DIR="$HOME/Documents/dotfiles"

##############################################################################
# HELPER FUNCTION:
# Copies or moves an item from the dotfiles directory to your HOME.
# If the target already exists, it will be backed up.
##############################################################################
replace_item() {
  local src="$1"
  local dest="$2"

  # If the destination exists, back it up before replacing
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "Backing up existing: $dest -> $dest.bak"
    mv "$dest" "$dest.bak.$(date +%s)"
  fi

  # Ensure the parent directory exists
  mkdir -p "$(dirname "$dest")"

  echo "Copying $src -> $dest"
  cp -r "$src" "$dest"
}

##############################################################################
# MAIN
##############################################################################

# 1. Replace your .zshrc
# replace_item "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# 2. Replace all desired folders/files under .config
#    e.g. ghostty, lazygit, nvim, starship.toml, etc.
for item in "$DOTFILES_DIR"/.config/*; do
  name="$(basename "$item")"
  replace_item "$item" "$HOME/.config/$name"
done

echo "All dotfiles and config items have been replaced!"

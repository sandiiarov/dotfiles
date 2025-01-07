#!/usr/bin/env bash
#
# apply.sh
# Replaces existing files/folders in your HOME directory with those from
# your dotfiles repo, but only appends a 'source' line to ~/.zshrc (no overwrite).

set -euo pipefail # Exit on error, treat undefined vars as errors, etc.

##############################################################################
# DETERMINE DOTFILES DIRECTORY & BACKUP DIRECTORY
##############################################################################
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$DOTFILES_DIR/backups"

echo "[INFO] Using dotfiles directory: $DOTFILES_DIR"
echo "[INFO] Backups will be saved in: $BACKUP_DIR"

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

##############################################################################
# FUNCTION: backup_and_copy
#   - If the destination already exists, move it into BACKUP_DIR.
#   - Then copy the source to the destination.
##############################################################################
backup_and_copy() {
  local src="$1"
  local dest="$2"

  if [[ -e "$dest" || -L "$dest" ]]; then
    local filename
    # For example: "myfile-05.23.24-12:03PM"
    filename="$(basename "$dest")-$(date +%m.%d.%y-%I:%M%p)"
    local backup_path="$BACKUP_DIR/$filename"

    echo "[INFO] Backing up existing: $dest -> $backup_path"
    mv "$dest" "$backup_path"
  fi

  mkdir -p "$(dirname "$dest")"
  echo "[INFO] Copying $src -> $dest"
  cp -r "$src" "$dest"
}

##############################################################################
# FUNCTION: append_line_if_missing
#   - Appends a line to a file, but only if that exact line is not present.
##############################################################################
append_line_if_missing() {
  local file="$1"
  local line="$2"

  if grep -Fxq "$line" "$file" 2>/dev/null; then
    echo "[INFO] '$line' is already in $file, skipping."
  else
    echo "[INFO] Appending '$line' to $file"
    echo "$line" >>"$file"
  fi
}

##############################################################################
# FUNCTION: sync_dir_contents
#   - For every file/folder in source_dir, back up any existing target, then copy.
##############################################################################
sync_dir_contents() {
  local source_dir="$1"
  local target_dir="$2"

  # If source_dir doesn’t exist (or is empty), just skip
  if [[ ! -d "$source_dir" ]]; then
    echo "[WARN] Directory '$source_dir' does not exist or is empty, skipping."
    return
  fi

  for item in "$source_dir"/*; do
    # If the glob doesn't match anything, skip
    [[ -e "$item" ]] || continue

    local name
    name="$(basename "$item")"
    backup_and_copy "$item" "$target_dir/$name"
  done
}

##############################################################################
# MAIN SCRIPT ACTIONS
##############################################################################

# 1. Append a source line to ~/.zshrc (instead of overwriting it)
append_line_if_missing "$HOME/.zshrc" "source $DOTFILES_DIR/.zshrc"

# 2. Replace (back up + copy) ~/.fzf.zsh
backup_and_copy "$DOTFILES_DIR/.fzf.zsh" "$HOME/.fzf.zsh"

# 3. Replace (back up + copy) everything under .zsh
sync_dir_contents "$DOTFILES_DIR/zsh-plugins" "$HOME/.zsh"

# 4. Replace (back up + copy) everything under .config
sync_dir_contents "$DOTFILES_DIR/.config" "$HOME/.config"

echo "[INFO] All dotfiles and config items have been processed!"

# Dotfiles Setup

This repo contains personal config files (dotfiles) and an `apply.sh` script to install/replace them in your home directory.

## Usage

1. **Clone** this repo (e.g., to `~/Documents/dotfiles`) and **make the script executable**:

   ```bash
   cd ~/Documents/dotfiles
   chmod +x apply.sh
   ```

2. **Run** the script:

   ```bash
   ./apply.sh
   ```

   - Existing files/folders are backed up (moved to `.bak.<timestamp>`).
   - Dotfiles in this repo are copied into your home directory (`$HOME`).

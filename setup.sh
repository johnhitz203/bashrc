#!/usr/bin/env bash

set -euo pipefail

# Define paths
REPO_DIR=~/config_repos/bashrc
BASHRC_SYMLINK=~/.bashrc
BASHRC_REPO_FILE="$REPO_DIR/.bashrc"

echo "🔧 Setting up ~/.bashrc symlink..."

# Ensure the symlink is correct
if [ -L "$BASHRC_SYMLINK" ]; then
  CURRENT_TARGET=$(readlink "$BASHRC_SYMLINK")
  if [ "$CURRENT_TARGET" != "$BASHRC_REPO_FILE" ]; then
    echo "⚠️  Existing ~/.bashrc symlink points to $CURRENT_TARGET — replacing it."
    ln -sf "$BASHRC_REPO_FILE" "$BASHRC_SYMLINK"
  else
    echo "✅ ~/.bashrc already correctly symlinked."
  fi
elif [ -e "$BASHRC_SYMLINK" ]; then
  echo "⚠️  ~/.bashrc exists but is not a symlink — backing up and replacing."
  mv "$BASHRC_SYMLINK" "$BASHRC_SYMLINK.backup.$(date +%s)"
  ln -s "$BASHRC_REPO_FILE" "$BASHRC_SYMLINK"
else
  echo "🔗 Creating new symlink to $BASHRC_REPO_FILE"
  ln -s "$BASHRC_REPO_FILE" "$BASHRC_SYMLINK"
fi

echo "🧹 Ensuring clean PATH export in .bashrc..."

# Define the guarded export block
GUARDED_EXPORT=$'# Add ~/bin to PATH if not already present\ncase ":$PATH:" in\n  *":$HOME/bin:"*) ;;\n  *) export PATH="$HOME/bin:$PATH" ;;\nesac'

# Remove any duplicate lines first (optional)
sed -i '/^export PATH=~\/bin:\$PATH$/d' "$BASHRC_REPO_FILE"

# Add guarded block if not already present
if ! grep -Fq 'case ":$PATH:" in' "$BASHRC_REPO_FILE"; then
  echo -e "\n$GUARDED_EXPORT" >> "$BASHRC_REPO_FILE"
  echo "✅ Added clean, guarded PATH export."
else
  echo "✅ Guarded PATH export already present."
fi

echo "🎉 Setup complete!"

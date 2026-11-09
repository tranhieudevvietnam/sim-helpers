#!/bin/sh
# Removes sim. Your app names in ~/.config/sim stay unless you pass --purge:
#   ./uninstall.sh --purge
#   curl -fsSL https://raw.githubusercontent.com/tranhieudevvietnam/sim-helpers/main/uninstall.sh | sh -s -- --purge
set -eu

rm -f "$HOME/.local/bin/sim"
rm -rf "$HOME/.local/share/sim"
echo "✔ Removed sim"

if [ "${1:-}" = "--purge" ]; then
  rm -rf "$HOME/.config/sim"
  echo "✔ Removed your config in ~/.config/sim"
else
  echo "Kept your config in ~/.config/sim (add --purge to remove it too)"
fi

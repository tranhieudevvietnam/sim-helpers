#!/bin/sh
# Installs sim: the command goes to ~/.local/bin, sim.mk to ~/.local/share/sim.
# Run it from a clone (./install.sh) or piped:
#   curl -fsSL https://raw.githubusercontent.com/tranhieudevvietnam/sim-helpers/main/install.sh | sh
# Running it again updates sim and keeps your config.
set -eu

RAW_URL="${SIM_RAW_URL:-https://raw.githubusercontent.com/tranhieudevvietnam/sim-helpers/main}"
BIN_DIR="$HOME/.local/bin"
SHARE_DIR="$HOME/.local/share/sim"

fail() { printf '✘ %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || fail "sim needs macOS (it drives the iOS Simulator)."
command -v xcrun >/dev/null 2>&1 || fail "xcrun not found. Install Xcode first."
command -v make >/dev/null 2>&1 || fail "make not found. Run: xcode-select --install"

mkdir -p "$BIN_DIR" "$SHARE_DIR"

# Puts one file in place: copied from the clone, or downloaded when piped.
fetch() { # <path in repo> <destination>
  if [ -n "$src_dir" ]; then
    cp "$src_dir/$1" "$2"
  else
    tmp="$2.download"
    curl -fsSL "$RAW_URL/$1" -o "$tmp" || { rm -f "$tmp"; fail "Download failed: $RAW_URL/$1"; }
    mv "$tmp" "$2"
  fi
}

src_dir=$(cd "$(dirname "$0")" 2>/dev/null && pwd) || src_dir=""
if [ -z "$src_dir" ] || [ ! -f "$src_dir/sim.mk" ] || [ ! -f "$src_dir/bin/sim" ]; then
  src_dir=""
fi

fetch sim.mk "$SHARE_DIR/sim.mk"
fetch bin/sim "$BIN_DIR/sim"
chmod +x "$BIN_DIR/sim"

echo "✔ Installed $(make --no-print-directory -f "$SHARE_DIR/sim.mk" version) → $BIN_DIR/sim"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo ""
    echo "⚠ $BIN_DIR is not on your PATH. Add this line to ~/.zshrc, then open a new terminal:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

echo ""
echo "Next: run 'sim config' to name your apps, then 'sim' to see every command."

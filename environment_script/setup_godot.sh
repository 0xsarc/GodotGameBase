
#!/usr/bin/env bash
set -euo pipefail

GODOT_VER="4.6.1-stable"
BASE="$HOME/tools/godot/$GODOT_VER"
BIN="$BASE/godot"
TPL_DIR="$HOME/.local/share/godot/export_templates/4.6.1.stable"

mkdir -p "$BASE" "$HOME/.local/bin" "$TPL_DIR"

# 1) Baixa o editor Linux
cd "$BASE"
if [ ! -f "$BIN" ]; then
  curl -L -o godot.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VER}/Godot_v${GODOT_VER}_linux.x86_64.zip"
  unzip -q godot.zip
  mv "Godot_v${GODOT_VER}_linux.x86_64" "$BIN"
  chmod +x "$BIN"
fi

ln -sf "$BIN" "$HOME/.local/bin/godot"

# 2) Baixa export templates (necessário pra exportar)
if [ ! -f "$TPL_DIR/.installed" ]; then
  curl -L -o templates.tpz "https://github.com/godotengine/godot/releases/download/${GODOT_VER}/Godot_v${GODOT_VER}_export_templates.tpz"
  unzip -q templates.tpz -d "$TPL_DIR"
  touch "$TPL_DIR/.installed"
fi

godot --version

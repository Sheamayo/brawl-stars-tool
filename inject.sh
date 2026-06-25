#!/bin/bash

# Brawl Stars Tool - Simple Injection
# 1. Extract IPA
# 2. Add BrawlStarsTool.swift as plugin
# 3. Repackage
# 4. Send to gbox

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <original.ipa> [output.ipa]"
    exit 1
fi

IPA="$1"
OUTPUT="${2:-brawlstars_tool.ipa}"

echo "[*] Extracting IPA..."
TEMP=$(mktemp -d)
trap "rm -rf $TEMP" EXIT

unzip -q "$IPA" -d "$TEMP"

# Find app
APP=$(find "$TEMP" -name "*.app" -type d | head -1)
[ -n "$APP" ] || { echo "App not found"; exit 1; }

echo "[*] Found: $(basename $APP)"

# Create PlugIns directory
mkdir -p "$APP/PlugIns"

# Copy Swift source as plugin resource
cp BrawlStarsTool.swift "$APP/PlugIns/BrawlStarsTool.swift"

echo "[*] Added: BrawlStarsTool.swift to PlugIns/"

# Repackage
echo "[*] Repackaging..."
rm -f "$OUTPUT"
cd "$TEMP"
zip -q -r "$OLDPWD/$OUTPUT" .
cd "$OLDPWD"

echo ""
echo "✅ Done: $OUTPUT"
echo ""
echo "Next:"
echo "  1. Upload $OUTPUT to gbox.io"
echo "  2. Sign with Certificate"
echo "  3. Install on iPhone"
echo "  4. Launch Brawl Stars"
echo "  5. Tool auto-launches (Password: Ezstash0)"

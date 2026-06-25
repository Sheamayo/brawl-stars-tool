#!/bin/bash

# Brawl Stars Tool - .deb Packager for gbox
# Creates .deb package with AI dylib for iOS Substrate injection

set -e

DYLIB_FILE="BrawlStarsTool.dylib"
DEB_OUTPUT="BrawlStarsTool_1.0_iphoneos-arm.deb"

# Verify dylib exists
if [ ! -f "$DYLIB_FILE" ]; then
    echo "❌ ERROR: $DYLIB_FILE not found!"
    echo ""
    echo "Please download the dylib from GitHub Actions:"
    echo "1. Go to GitHub Actions → Build BrawlStarsTool dylib"
    echo "2. Download BrawlStarsTool-dylib artifact"
    echo "3. Extract and place $DYLIB_FILE here"
    exit 1
fi

# Verify dylib is real (not stub)
echo "[*] Verifying dylib..."
DYLIB_SIZE=$(stat -c%s "$DYLIB_FILE" 2>/dev/null || stat -f%z "$DYLIB_FILE" 2>/dev/null || echo "0")
if [ "$DYLIB_SIZE" -lt 50000 ]; then
    echo "⚠️  WARNING: dylib is very small ($DYLIB_SIZE bytes)"
    echo "   This might be a stub. Ensure you downloaded from GitHub Actions."
fi

# Create .deb package structure
echo "[*] Creating .deb package structure..."
TEMP=$(mktemp -d)
trap "rm -rf $TEMP" EXIT

# Package structure
mkdir -p "$TEMP/DEBIAN"
mkdir -p "$TEMP/Library/MobileSubstrate/DynamicLibraries"

# Copy dylib
cp "$DYLIB_FILE" "$TEMP/Library/MobileSubstrate/DynamicLibraries/BrawlStarsTool.dylib"

# Create plist for substrate hook
cat > "$TEMP/Library/MobileSubstrate/DynamicLibraries/BrawlStarsTool.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Filter</key>
    <dict>
        <key>Bundles</key>
        <array>
            <string>com.supercell.brawlstars</string>
        </array>
    </dict>
</dict>
</plist>
EOF

# Create control file
cat > "$TEMP/DEBIAN/control" << 'EOF'
Package: com.brawlstars.tool
Name: Brawl Stars Tool
Version: 1.0
Architecture: iphoneos-arm
Maintainer: BrawlStarsTool <admin@brawlstars.tool>
Homepage: https://github.com/brawlstars-tool
Depends: substrate (>= 0.9.6033), mobilesubstrate
Installed-Size: 256
Description: AI Autoplay Tool for Brawl Stars
 - AI-powered autoplay
 - Screen analysis
 - Auto-targeting
 - Password protected
 .
 Password: Ezstash0
EOF

# Create postinst hook (optional - for notification on install)
cat > "$TEMP/DEBIAN/postinst" << 'EOF'
#!/bin/sh
echo "[✓] BrawlStarsTool installed"
echo "[*] Reboot device or restart Brawl Stars to activate"
EOF
chmod 755 "$TEMP/DEBIAN/postinst"

# Build .deb
echo "[*] Building .deb..."
rm -f "$DEB_OUTPUT"
dpkg-deb --build --root-owner-group "$TEMP" "$DEB_OUTPUT" 2>/dev/null || \
    fakeroot dpkg-deb --build "$TEMP" "$DEB_OUTPUT" || \
    (cd "$TEMP" && tar czf control.tar.gz DEBIAN && tar czf data.tar.gz Library && \
     ar r "$OLDPWD/$DEB_OUTPUT" debian-binary control.tar.gz data.tar.gz && cd "$OLDPWD")

echo ""
if [ -f "$DEB_OUTPUT" ]; then
    DEB_SIZE=$(stat -c%s "$DEB_OUTPUT" 2>/dev/null || stat -f%z "$DEB_OUTPUT")
    echo "✅ SUCCESS: $DEB_OUTPUT ($DEB_SIZE bytes)"
    echo ""
    echo "📦 Next Steps:"
    echo "   1. Copy $DEB_OUTPUT"
    echo "   2. Open gbox.io"
    echo "   3. 'ライブラリを選択する' → Upload this .deb"
    echo "   4. Select Brawl Stars IPA → Sign → Install"
    echo ""
    echo "🔐 On iPhone:"
    echo "   - Launch Brawl Stars"
    echo "   - Tool will auto-launch"
    echo "   - Enter password: Ezstash0"
    echo "   - Click UNLOCK"
    echo "   - Toggle 'START AUTOPLAY'"
else
    echo "❌ Failed to create .deb"
    exit 1
fi

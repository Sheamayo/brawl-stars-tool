#!/bin/bash

# Build actual iOS dylib (requires Xcode Command Line Tools)

set -e

if ! command -v swiftc &> /dev/null; then
    echo "❌ swiftc not found"
    echo "Install Xcode Command Line Tools:"
    echo "   xcode-select --install"
    exit 1
fi

echo "[🎮] Building real iOS dylib..."

SDKPATH=$(xcrun --sdk iphoneos --show-sdk-path)
echo "[*] SDK: $SDKPATH"

# Compile
echo "[*] Compiling..."
swiftc \
    -parse-as-library \
    -module-name BrawlStarsTool \
    -target arm64-apple-ios14.0 \
    -sdk "$SDKPATH" \
    -c BrawlStarsTool.swift \
    -o BrawlStarsTool.o 2>&1

if [ ! -f "BrawlStarsTool.o" ]; then
    echo "❌ Compilation failed"
    exit 1
fi

# Link dylib
echo "[*] Linking..."
ld -dylib \
    -arch arm64 \
    -syslibroot "$SDKPATH" \
    -lSystem \
    -framework Foundation \
    -framework UIKit \
    -o BrawlStarsTool.dylib \
    BrawlStarsTool.o 2>&1

if [ ! -f "BrawlStarsTool.dylib" ]; then
    echo "❌ Linking failed"
    exit 1
fi

rm -f BrawlStarsTool.o

echo ""
echo "✅ Success!"
ls -lh BrawlStarsTool.dylib
echo ""
echo "Next:"
echo "   ./embed original.ipa BrawlStarsTool.dylib output.ipa"

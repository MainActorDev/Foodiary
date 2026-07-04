#!/bin/bash
# regenerate.sh — Regenerate Xcode project and clear stale DerivedData
# Prevents "multiple commands produce" errors after xcodegen
set -e

cd "$(dirname "$0")"

echo "🧹 Clearing Foodiary DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Foodiary-*
rm -rf build/DerivedData

echo "🔧 Regenerating project..."
/opt/homebrew/bin/xcodegen --spec project.yml --project .

echo "✅ Done. Open Foodiary.xcodeproj in Xcode."

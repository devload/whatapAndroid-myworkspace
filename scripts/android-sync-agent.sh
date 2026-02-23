#!/bin/bash
# BOM AAR을 모든 샘플 앱의 libs/ 디렉토리에 복사
# Usage: ./scripts/android-sync-agent.sh

set -e

WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BOM_AAR="$WORKSPACE_DIR/androidAgent/whatap-agent-bom/build/outputs/aar/whatap-agent-bom-complete.aar"

if [ ! -f "$BOM_AAR" ]; then
    echo "ERROR: BOM AAR not found at $BOM_AAR"
    echo "Run: cd androidAgent && ./gradlew :whatap-agent-bom:assembleRelease"
    exit 1
fi

echo "=== Syncing Agent BOM AAR ==="
echo "Source: $BOM_AAR ($(du -h "$BOM_AAR" | cut -f1))"
echo ""

TARGETS=(
    "whatap-webview-sample"
    "NativeWebviewCrashExample"
)

# android-business-sample-apps 내 서브디렉토리도 탐색
if [ -d "$WORKSPACE_DIR/android-business-sample-apps" ]; then
    for APP_DIR in "$WORKSPACE_DIR/android-business-sample-apps"/*/; do
        if [ -d "$APP_DIR/app" ]; then
            TARGETS+=("android-business-sample-apps/$(basename "$APP_DIR")")
        fi
    done
fi

SYNCED=0
for TARGET in "${TARGETS[@]}"; do
    TARGET_DIR="$WORKSPACE_DIR/$TARGET"
    if [ -d "$TARGET_DIR/app" ]; then
        mkdir -p "$TARGET_DIR/app/libs"
        cp "$BOM_AAR" "$TARGET_DIR/app/libs/"
        echo "  [OK] $TARGET/app/libs/"
        SYNCED=$((SYNCED + 1))
    else
        echo "  [SKIP] $TARGET (no app/ directory)"
    fi
done

echo ""
echo "=== Sync Complete: $SYNCED app(s) updated ==="

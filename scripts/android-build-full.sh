#!/bin/bash
# Android 전체 빌드: Agent BOM + Plugin JAR + 샘플 앱
# Usage: ./scripts/android-build-full.sh [sample-app-name]

set -e

WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SAMPLE_APP="${1:-whatap-webview-sample}"

echo "=== Android Full Build Pipeline ==="
echo "Workspace: $WORKSPACE_DIR"
echo ""

# Step 1: Agent BOM AAR 빌드
echo "[1/4] Building Agent BOM AAR..."
cd "$WORKSPACE_DIR/androidAgent"
./gradlew :whatap-agent-bom:assembleRelease --quiet
BOM_AAR="$WORKSPACE_DIR/androidAgent/whatap-agent-bom/build/outputs/aar/whatap-agent-bom-complete.aar"

if [ ! -f "$BOM_AAR" ]; then
    echo "ERROR: BOM AAR not found at $BOM_AAR"
    exit 1
fi
echo "  -> BOM AAR: $(du -h "$BOM_AAR" | cut -f1)"

# Step 2: Plugin JAR 빌드
echo "[2/4] Building Gradle Plugin JAR..."
cd "$WORKSPACE_DIR/whatapAndroidPlugin"
./gradlew clean jar -x test --quiet
PLUGIN_JAR=$(find build/libs -name "*.jar" -type f | head -1)
echo "  -> Plugin JAR: $(du -h "$PLUGIN_JAR" | cut -f1)"

# Step 3: BOM AAR을 샘플 앱에 복사
echo "[3/4] Copying BOM AAR to $SAMPLE_APP..."
SAMPLE_DIR="$WORKSPACE_DIR/$SAMPLE_APP"
if [ ! -d "$SAMPLE_DIR" ]; then
    echo "ERROR: Sample app not found at $SAMPLE_DIR"
    exit 1
fi

mkdir -p "$SAMPLE_DIR/app/libs"
cp "$BOM_AAR" "$SAMPLE_DIR/app/libs/"
echo "  -> Copied to $SAMPLE_DIR/app/libs/"

# Step 4: 샘플 앱 빌드
echo "[4/4] Building sample app: $SAMPLE_APP..."
cd "$SAMPLE_DIR"
./gradlew assembleDebug --quiet
APK=$(find app/build/outputs/apk -name "*.apk" -type f | head -1)
echo "  -> APK: $(du -h "$APK" | cut -f1)"

echo ""
echo "=== Build Complete ==="
echo "BOM AAR: $BOM_AAR"
echo "Plugin JAR: $WORKSPACE_DIR/whatapAndroidPlugin/$PLUGIN_JAR"
echo "Sample APK: $SAMPLE_DIR/$APK"

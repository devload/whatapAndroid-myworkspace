#!/bin/bash
# APK를 디바이스에 설치하고 실행 후 로그 확인
# Usage: ./scripts/android-deploy-device.sh <apk-path> [package-name]

set -e

APK_PATH="$1"
PACKAGE_NAME="$2"

if [ -z "$APK_PATH" ]; then
    echo "Usage: $0 <apk-path> [package-name]"
    echo "Example: $0 app/build/outputs/apk/debug/app-debug.apk com.example.app"
    exit 1
fi

if [ ! -f "$APK_PATH" ]; then
    echo "ERROR: APK not found: $APK_PATH"
    exit 1
fi

# 디바이스 확인
DEVICE_COUNT=$(adb devices | grep -v "List" | grep -c "device$" || true)
if [ "$DEVICE_COUNT" -eq 0 ]; then
    echo "ERROR: No Android device connected"
    echo "Run 'adb devices' to check"
    exit 1
fi
echo "=== Device Found ($DEVICE_COUNT device(s)) ==="

# 패키지명 자동 추출
if [ -z "$PACKAGE_NAME" ]; then
    PACKAGE_NAME=$(aapt dump badging "$APK_PATH" 2>/dev/null | grep "package:" | sed "s/.*name='\([^']*\)'.*/\1/" || true)
    if [ -z "$PACKAGE_NAME" ]; then
        echo "WARNING: Could not extract package name. Provide it as second argument."
    fi
fi
echo "Package: $PACKAGE_NAME"
echo "APK: $APK_PATH ($(du -h "$APK_PATH" | cut -f1))"
echo ""

# APK 설치
echo "[1/3] Installing APK..."
adb install -r "$APK_PATH"

# 앱 실행
if [ -n "$PACKAGE_NAME" ]; then
    echo "[2/3] Launching app..."
    adb shell monkey -p "$PACKAGE_NAME" -c android.intent.category.LAUNCHER 1 2>/dev/null

    # 프로세스 확인
    sleep 3
    echo "[3/3] Checking process..."
    PROC=$(adb shell "ps -A | grep $PACKAGE_NAME" || true)
    if [ -n "$PROC" ]; then
        echo "  -> App is running"
    else
        echo "  -> WARNING: App process not found (may have crashed)"
    fi

    # WhatAp 로그 수집
    echo ""
    echo "=== WhatAp Logs (last 20 lines) ==="
    adb logcat -d | grep -E "whatap|WhatAp|WHATAP" | tail -20 || echo "(no WhatAp logs found)"
else
    echo "[2/3] Skipping launch (no package name)"
    echo "[3/3] Skipping process check"
fi

echo ""
echo "=== Deploy Complete ==="

#!/bin/bash
# WhaTap Android Workspace 개발환경 초기 세팅
# Usage: ./scripts/setup.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
log() { echo -e "${BLUE}[SETUP]${NC} $1"; }
ok()  { echo -e "${GREEN}[OK]${NC} $1"; }
skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; }
err() { echo -e "${RED}[ERR]${NC} $1"; }

WORKSPACE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$WORKSPACE"

echo ""
echo "========================================="
echo "  WhaTap Android Workspace Setup"
echo "========================================="
echo ""

# 1. Submodules
log "Git submodules 초기화 (13개)..."
git submodule init 2>/dev/null
git submodule update --recursive
ok "Submodules 준비 완료"

# 2. Java 확인
log "Java 확인..."
if command -v java &>/dev/null; then
  JAVA_VER=$(java -version 2>&1 | head -1)
  ok "Java: $JAVA_VER"
else
  err "Java 미설치. JDK 17 필요 (brew install openjdk@17)"
fi

# 3. Android SDK 확인
log "Android SDK 확인..."
if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME" ]; then
  ok "ANDROID_HOME: $ANDROID_HOME"
elif [ -d "$HOME/Library/Android/sdk" ]; then
  ok "Android SDK: $HOME/Library/Android/sdk"
else
  skip "ANDROID_HOME 미설정. Android Studio 설치 필요"
fi

# 4. ADB 확인
if command -v adb &>/dev/null; then
  ok "ADB: $(adb --version | head -1)"
else
  skip "ADB 미설치 — Android SDK Platform-Tools 필요"
fi

# 5. Node.js 프로젝트 의존성 설치
NODE_PROJECTS=(
  "demo-generator"
  "whatap-mobile-proxy-server"
)

log "Node.js 프로젝트 의존성 설치..."
for proj in "${NODE_PROJECTS[@]}"; do
  if [ -f "$proj/package.json" ]; then
    log "  $proj..."
    cd "$proj" && npm install --silent 2>/dev/null && cd "$WORKSPACE"
    ok "  $proj"
  else
    skip "  $proj (package.json 없음)"
  fi
done

# 6. Scripts 실행 권한
log "스크립트 실행 권한 설정..."
chmod +x scripts/*.sh
ok "스크립트 준비 완료"

echo ""
echo "========================================="
echo "  Setup 완료!"
echo "========================================="
echo ""
echo "  워크스페이스: $WORKSPACE"
echo ""
echo "  서브모듈 ($(git submodule status | wc -l | tr -d ' ')개):"
git submodule status | while read -r line; do echo "    $line"; done
echo ""
echo "  카테고리:"
echo "    Agent SDK:        androidAgent, whatapAndroidPlugin"
echo "    Mobile Spec:      whatap-mobile-agent-spec"
echo "    Crash Decoding:   proguardApi, whatap-stack-repository"
echo "    Testing & QA:     whatap-webview-sample, android-business-sample-apps,"
echo "                      NativeWebviewCrashExample"
echo "    Tools:            apk2project, whatap-device-cli, demo-generator,"
echo "                      whatap-mobile-proxy-server"
echo "    로컬:             docs/"
echo ""
echo "  다음 단계:"
echo "    - Agent 빌드: cd androidAgent && ./gradlew :whatap-agent-bom:assembleRelease"
echo "    - Plugin 빌드: cd whatapAndroidPlugin && ./gradlew clean jar -x test"
echo "    - 프록시 서버: cd whatap-mobile-proxy-server && npm start"
echo ""

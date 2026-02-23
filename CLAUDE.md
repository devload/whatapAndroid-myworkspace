# WhaTap Android Workspace

이 워크스페이스는 WhaTap Android 모니터링 관련 13개 프로젝트를 git submodule로 통합 관리하는 개발 환경입니다.
Android Agent SDK, Gradle Plugin, Proguard 디코딩, QA/테스트, 도구 프로젝트 포함.

## 프로젝트 구조

```
whatapAndroid-myworkspace/
├── # Android Agent SDK
├── androidAgent/                  (whatap) Android Agent SDK (27 모듈 멀티프로젝트)
├── whatapAndroidPlugin/           (whatap) Android Gradle Plugin (AGP 7.x/8.x)
│
├── # Mobile Spec
├── whatap-mobile-agent-spec/     (whatap) 모바일 Agent 프로토콜 스펙
│
├── # Crash Decoding (Proguard)
├── proguardApi/                   (whatap) Proguard Mapping 디코딩 API
├── whatap-stack-repository/      (whatap) Stack Trace 디코딩 서비스
│
├── # Testing & QA
├── whatap-webview-sample/        (devload) WebView 모니터링 샘플
├── android-business-sample-apps/ (devload) 비즈니스 샘플 앱 모음
├── NativeWebviewCrashExample/    (devload) 네이티브 크래시 재현 앱
│
├── # Tools
├── apk2project/                   (devload) APK → Gradle 프로젝트 변환
├── whatap-device-cli/            (whatap) 디바이스 APK 추출/주입
├── demo-generator/                (whatap) Mock 모니터링 데이터 생성
├── whatap-mobile-proxy-server/   (whatap) 모바일 SDK 프록시 서버
│
├── docs/                          (로컬) 통합 문서
├── scripts/                       유틸리티 스크립트
└── .claude/commands/              Claude Code slash commands
```

## 주의사항

- whatap org 레포는 push 시 조직 권한 필요
- devload 레포는 개인 소유 — 자유롭게 push 가능
- `docs/`는 submodule이 아닌 일반 디렉토리
- 새 프로젝트 추가: `git submodule add https://github.com/{org}/{repo}.git {name}`

## Android 개발 환경

### 빌드 환경 요구사항

| 도구 | 버전 | 용도 |
|------|------|------|
| Java | 17 | Agent/Plugin 빌드 |
| Gradle | 7.5 / 8.10 | Agent(7.5), Plugin(8.10) |
| AGP | 7.4.2 / 8.7.x | Android Gradle Plugin |
| Android SDK | API 34+ | 컴파일 타겟 |
| ADB | latest | 디바이스 테스트 |
| Node.js | 18+ | demo-generator, proxy-server |
| Rust | latest | (선택) atosw 관련 빌드 |

### Android Agent 빌드 플로우

```
androidAgent/ (27 모듈 멀티프로젝트)
│
├── whatap-agent-bom/            ← 최종 산출물: BOM AAR (Fat AAR)
├── core/                        ← 핵심 모듈
├── instrumentation/             ← 계측 모듈 (OkHttp, Retrofit, WebView 등)
├── plugin/                      ← 런타임 플러그인
└── transport/                   ← 네트워크 전송
```

```bash
# Agent BOM AAR 빌드
cd androidAgent
./gradlew :whatap-agent-bom:assembleDebug      # debug
./gradlew :whatap-agent-bom:assembleRelease     # release
./gradlew clean :whatap-agent-bom:assembleRelease  # 클린 빌드

# 산출물 위치
# androidAgent/whatap-agent-bom/build/outputs/aar/whatap-agent-bom-complete.aar
```

### Gradle Plugin 빌드

```bash
cd whatapAndroidPlugin

# Plugin JAR 빌드
./gradlew clean jar -x test

# 로컬 Maven 배포 (샘플 앱에서 사용)
./gradlew publishToMavenLocal

# 산출물 위치
# whatapAndroidPlugin/build/libs/whatapAndroidPlugin-*.jar
```

### 핵심 개발 워크플로우

```
1. Agent 소스 수정 (androidAgent/)
   ↓
2. BOM AAR 빌드 (./gradlew :whatap-agent-bom:assembleRelease)
   ↓
3. Plugin 빌드 (whatapAndroidPlugin/ → ./gradlew clean jar -x test)
   ↓
4. 샘플 앱에 적용 & 빌드
   ↓
5. 디바이스 설치 & 로그 확인
   ↓
6. WhatAp 대시보드에서 데이터 확인
```

### BOM AAR을 샘플 앱에 복사

```bash
# Agent BOM AAR → 샘플 앱의 libs/ 디렉토리
cp androidAgent/whatap-agent-bom/build/outputs/aar/whatap-agent-bom-complete.aar \
   whatap-webview-sample/app/libs/

cp androidAgent/whatap-agent-bom/build/outputs/aar/whatap-agent-bom-complete.aar \
   android-business-sample-apps/<app>/app/libs/
```

### Worktree 관리

Agent와 Plugin은 여러 버전/브랜치를 동시에 작업하기 위해 git worktree를 활용합니다.

```bash
# Agent worktree 목록 확인
cd androidAgent && git worktree list

# Plugin worktree 목록 확인
cd whatapAndroidPlugin && git worktree list

# 새 worktree 생성
git worktree add ../androidAgent-feature-branch feature/my-feature

# worktree 제거
git worktree remove ../androidAgent-feature-branch
```

주요 worktree 패턴:
- `androidAgent/` — main 브랜치 (기본)
- `androidAgent-v1/` — v1 릴리즈 브랜치
- `whatapAndroidPlugin/` — main 브랜치 (기본)
- `whatapAndroidPlugin-agp8/` — AGP 8.x 전용 브랜치

### ADB 디바이스 테스트

```bash
# 연결된 디바이스 확인
adb devices

# APK 설치
adb install -r app/build/outputs/apk/debug/app-debug.apk

# 앱 실행
adb shell monkey -p <package-name> -c android.intent.category.LAUNCHER 1

# WhatAp 로그 필터링
adb logcat | grep -E "whatap|WhatAp|WHATAP"

# 앱 프로세스 확인 (크래시 여부)
adb shell "ps -A | grep <package-name>"

# 스크린샷
adb exec-out screencap -p > /tmp/device_screen.png
```

### APK 주입 워크플로우

apk2project를 사용하여 기존 APK를 Gradle 프로젝트로 변환 후 WhatAp Agent를 주입합니다.

```bash
# APK → Gradle 프로젝트 변환
cd apk2project
./gradlew run --args="--apk /path/to/target.apk --output /tmp/target_project"

# whatap-device-cli로 디바이스에서 APK 추출
cd whatap-device-cli
./gradlew run --args="pull com.target.app /tmp/extracted"
```

### Proguard Mapping 디코딩

```bash
# proguardApi로 난독화된 스택 트레이스 디코딩
cd proguardApi
./gradlew bootRun

# whatap-stack-repository REST API
cd whatap-stack-repository
./gradlew bootRun
```

### 프록시 서버 (데이터 전송 테스트)

```bash
cd whatap-mobile-proxy-server
npm install && npm start
# http://localhost:6600 에서 프록시 서버 실행
# Android Agent의 서버 주소를 프록시로 변경하여 데이터 확인 가능
```

## Claude Code Slash Commands

| 명령어 | 설명 |
|--------|------|
| `/build-agent` | Agent BOM AAR 빌드 (debug/release/clean) |
| `/build-plugin` | Gradle Plugin JAR 빌드 |
| `/deploy-device` | APK 디바이스 설치/실행/로그 확인 |
| `/test-sample` | 샘플 앱에 Agent 적용 후 빌드/테스트 |
| `/adb-logs` | WhatAp logcat 필터링 |
| `/worktree-status` | Agent/Plugin worktree 상태 확인 |
| `/proxy-server` | 모바일 프록시 서버 시작/중지 |

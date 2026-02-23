# WhaTap Android Workspace

WhaTap Android 모니터링 관련 프로젝트 통합 개발 환경. 13개 서비스를 git submodule로 관리합니다.

## Quick Start

```bash
# 클론 (submodule 포함)
git clone --recursive https://github.com/devload/whatapAndroid-myworkspace.git
cd whatapAndroid-myworkspace

# 초기 세팅
./scripts/setup.sh
```

## 아키텍처

```
Android App → WhatAp Agent (androidAgent) → WhaTap Server
                   ↑                              ↕
      whatapAndroidPlugin            proguardApi → whatap-stack-repository
      (빌드 타임 계측)                (Proguard 디코딩)
```

## 프로젝트 구조

```
whatapAndroid-myworkspace/
│
├── # ── Android Agent SDK ─────────────────────────────
├── androidAgent/                  ← Android Agent SDK 소스 (27 모듈) (whatap)
├── whatapAndroidPlugin/           ← Android Gradle Plugin (AGP 7.x/8.x) (whatap)
│
├── # ── Mobile Spec & Protocol ────────────────────────
├── whatap-mobile-agent-spec/     ← 모바일 Agent 데이터 전송 프로토콜 스펙 (whatap)
│
├── # ── Crash Decoding (Proguard) ─────────────────────
├── proguardApi/                   ← Proguard Mapping 디코딩 API (whatap)
├── whatap-stack-repository/      ← Stack Trace 디코딩 서비스 (whatap)
│
├── # ── Testing & QA ──────────────────────────────────
├── whatap-webview-sample/        ← WebView 모니터링 샘플 앱 (devload)
├── android-business-sample-apps/ ← 비즈니스 도메인 샘플 앱 모음 (devload)
├── NativeWebviewCrashExample/    ← 네이티브/WebView 크래시 재현 앱 (devload)
│
├── # ── Tools ─────────────────────────────────────────
├── apk2project/                   ← APK → Gradle 프로젝트 변환 도구 (devload)
├── whatap-device-cli/            ← 디바이스 APK 추출/주입 CLI (whatap)
├── demo-generator/                ← Mock 모니터링 데이터 생성 (whatap)
├── whatap-mobile-proxy-server/   ← 모바일 SDK 데이터 전송 프록시 서버 (whatap)
│
├── # ── Workspace ─────────────────────────────────────
├── docs/                          ← 통합 문서 (로컬)
├── scripts/                       ← 유틸리티 스크립트
└── .claude/commands/              ← Claude Code slash commands
```

## 카테고리별 서비스

### Android Agent SDK

| 서비스 | 역할 | 기술 스택 | 소유 |
|--------|------|-----------|------|
| **androidAgent** | Android Agent SDK 소스 (27 모듈 멀티프로젝트) | Java/Kotlin, Gradle 7.5 | whatap |
| **whatapAndroidPlugin** | Android Gradle Plugin (빌드 타임 계측) | Java/Kotlin, Gradle 8.10 | whatap |

### Mobile Spec & Protocol

| 서비스 | 역할 | 소유 |
|--------|------|------|
| **whatap-mobile-agent-spec** | 모바일 Agent 데이터 전송 프로토콜 스펙 | whatap |

### Crash Decoding (Proguard)

| 서비스 | 역할 | 기술 스택 | 소유 |
|--------|------|-----------|------|
| **proguardApi** | Proguard Mapping 디코딩 API | Kotlin, Spring Boot | whatap |
| **whatap-stack-repository** | Stack Trace 디코딩 서비스 (SourceMap/Proguard/dSYM) | Kotlin, Spring Boot | whatap |

### Testing & QA

| 서비스 | 역할 | 기술 스택 | 소유 |
|--------|------|-----------|------|
| **whatap-webview-sample** | WebView 모니터링 샘플 앱 | Java/Kotlin | devload |
| **android-business-sample-apps** | 비즈니스 도메인 샘플 앱 모음 | Java/Kotlin | devload |
| **NativeWebviewCrashExample** | 네이티브/WebView 크래시 재현 앱 | Java/Kotlin | devload |

### Tools

| 서비스 | 역할 | 기술 스택 | 소유 |
|--------|------|-----------|------|
| **apk2project** | APK → Gradle 프로젝트 변환 | Kotlin, Gradle | devload |
| **whatap-device-cli** | 디바이스 APK 추출/주입 CLI | Kotlin, Gradle | whatap |
| **demo-generator** | Mock 모니터링 데이터 생성 | TypeScript | whatap |
| **whatap-mobile-proxy-server** | 모바일 SDK 데이터 전송 프록시 서버 | JavaScript | whatap |

## 개발 환경

### 빌드 환경 요구사항

| 도구 | 버전 | 용도 |
|------|------|------|
| Java | 17 | Agent/Plugin 빌드 |
| Gradle | 7.5 / 8.10 | Agent(7.5), Plugin(8.10) |
| AGP | 7.4.2 / 8.7.x | Android Gradle Plugin |
| Android SDK | API 34+ | 컴파일 타겟 |
| ADB | latest | 디바이스 테스트 |
| Node.js | 18+ | demo-generator, proxy-server |

### Android Agent 빌드 플로우

```
androidAgent/ (27 모듈)
│
├── whatap-agent-bom/            ← 최종 산출물: BOM AAR (Fat AAR)
├── core/                        ← 핵심 모듈
├── instrumentation/             ← 계측 모듈 (OkHttp, Retrofit, WebView 등)
├── plugin/                      ← 런타임 플러그인
└── transport/                   ← 네트워크 전송

→ 빌드 산출물: whatap-agent-bom/build/outputs/aar/whatap-agent-bom-complete.aar
```

### Gradle Plugin 빌드

```bash
cd whatapAndroidPlugin
./gradlew clean jar -x test         # JAR 빌드
./gradlew publishToMavenLocal       # 로컬 Maven 배포

→ 산출물: build/libs/whatapAndroidPlugin-*.jar
```

### 핵심 개발 워크플로우

```
Agent 소스 수정 → BOM AAR 빌드 → Plugin 빌드 → 샘플 앱 적용 → 디바이스 설치 → 로그 확인
```

```bash
# 1. Agent BOM AAR 빌드
cd androidAgent && ./gradlew :whatap-agent-bom:assembleRelease

# 2. Plugin JAR 빌드
cd whatapAndroidPlugin && ./gradlew clean jar -x test

# 3. BOM AAR → 샘플 앱 복사
./scripts/android-sync-agent.sh

# 4. 샘플 앱 빌드
cd whatap-webview-sample && ./gradlew assembleDebug

# 5. 디바이스 배포 & 로그 확인
./scripts/android-deploy-device.sh app/build/outputs/apk/debug/app-debug.apk
```

### 프록시 서버

```bash
cd whatap-mobile-proxy-server
npm install && npm start
# http://localhost:6600 에서 프록시 서버 실행
```

## 주의사항

- whatap org 레포는 push 시 조직 권한 필요
- devload 레포는 개인 소유 — 자유롭게 push 가능
- `docs/`는 submodule이 아닌 일반 디렉토리
- 새 프로젝트 추가: `git submodule add https://github.com/{org}/{repo}.git {name}`

## 서브모듈 관리

```bash
# 전체 업데이트
git submodule update --remote --merge

# 특정 서브모듈 업데이트
git submodule update --remote androidAgent

# 새 서브모듈 추가
git submodule add https://github.com/{org}/{repo}.git {name}

# 서브모듈 제거
git submodule deinit -f {name}
git rm -f {name}
rm -rf .git/modules/{name}
```

## Claude Code Skills

| 명령어 | 설명 |
|--------|------|
| `/build-agent` | Agent BOM AAR 빌드 |
| `/build-plugin` | Gradle Plugin JAR 빌드 |
| `/deploy-device` | APK 디바이스 설치/실행/로그 확인 |
| `/test-sample` | 샘플 앱에 Agent 적용 후 빌드/테스트 |
| `/adb-logs` | WhatAp logcat 필터링 |
| `/worktree-status` | Git worktree 상태 확인 |
| `/proxy-server` | 모바일 프록시 서버 시작/중지 |

# Deploy to Device

빌드된 APK를 연결된 Android 디바이스에 설치하고 실행합니다.

## Arguments

- `$ARGUMENTS` — APK 경로 또는 패키지명. 없으면 자동 탐색.

## Instructions

1. `adb devices`로 연결된 디바이스 확인. 디바이스 없으면 안내 후 종료.
2. APK 경로가 제공되면 해당 APK 설치. 없으면 현재 디렉토리에서 `**/build/outputs/apk/**/*.apk` 탐색.
3. `adb install -r <apk>` 실행
4. 설치 성공 시 앱 실행:
   - APK에서 패키지명 추출: `aapt dump badging <apk> | grep package:`
   - `adb shell monkey -p <package> -c android.intent.category.LAUNCHER 1`
5. 3초 대기 후 프로세스 확인: `adb shell "ps -A | grep <package>"`
6. WhatAp 로그 5초간 수집: `adb logcat -d | grep -E "whatap|WhatAp|WHATAP" | tail -20`

## Output

- 설치 결과 (성공/실패)
- 앱 실행 상태
- WhatAp Agent 초기화 로그

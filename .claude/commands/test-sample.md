# Test Sample App

샘플 앱에 최신 Agent BOM AAR을 적용하고 빌드/테스트합니다.

## Arguments

- `$ARGUMENTS` — 샘플 앱 이름: `webview` (whatap-webview-sample), `crash` (NativeWebviewCrashExample), 또는 `android-business-sample-apps` 내 앱 이름

## Instructions

1. 최신 BOM AAR 존재 여부 확인: `androidAgent/whatap-agent-bom/build/outputs/aar/whatap-agent-bom-complete.aar`
   - 없으면 빌드 필요 안내
2. 인자에 따라 대상 앱 결정:
   - `webview`: `whatap-webview-sample/`
   - `crash`: `NativeWebviewCrashExample/`
   - 기타: `android-business-sample-apps/<name>/`
3. BOM AAR을 대상 앱의 `app/libs/`에 복사
4. `./gradlew assembleDebug` 실행
5. 빌드 성공 시 APK 경로 출력
6. 디바이스가 연결되어 있으면 설치 여부 확인

## Output

- BOM AAR 복사 결과
- 빌드 결과 (성공/실패)
- APK 경로

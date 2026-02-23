# Build Agent BOM AAR

Android Agent SDK의 BOM AAR을 빌드합니다.

## Arguments

- `$ARGUMENTS` — 빌드 타입: `debug` (기본), `release`, `clean`

## Instructions

1. `androidAgent/` 디렉토리로 이동
2. 인자에 따라 빌드 실행:
   - `debug` 또는 인자 없음: `./gradlew :whatap-agent-bom:assembleDebug`
   - `release`: `./gradlew :whatap-agent-bom:assembleRelease`
   - `clean`: `./gradlew clean :whatap-agent-bom:assembleRelease`
3. 빌드 성공 시 AAR 파일 크기와 경로 출력
4. 빌드 실패 시 에러 메시지 분석 후 해결 방안 제시

## Output

빌드 결과:
- 산출물: `androidAgent/whatap-agent-bom/build/outputs/aar/whatap-agent-bom-complete.aar`
- 파일 크기, 빌드 시간 포함

# ADB Logs

연결된 Android 디바이스에서 WhatAp 관련 logcat을 필터링하여 보여줍니다.

## Arguments

- `$ARGUMENTS` — 옵션: `live` (실시간 스트리밍, 기본 30초), `dump` (현재 버퍼 덤프), `clear` (로그 클리어 후 새로 수집), 숫자 (수집 시간 초)

## Instructions

1. `adb devices`로 디바이스 확인
2. 인자에 따라 동작:
   - `dump` 또는 인자 없음: `adb logcat -d | grep -E "whatap|WhatAp|WHATAP" | tail -50`
   - `live` 또는 숫자: `timeout <초> adb logcat | grep -E "whatap|WhatAp|WHATAP"`
   - `clear`: `adb logcat -c` 후 10초간 새 로그 수집
3. 로그에서 에러/경고 패턴 하이라이트
4. Agent 초기화, 네트워크 전송, 에러 등 주요 이벤트 요약

## Output

- WhatAp 관련 로그 (최근 50줄 또는 실시간)
- 에러/경고 요약 (있는 경우)

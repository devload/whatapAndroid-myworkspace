# Proxy Server

모바일 SDK 데이터 전송 프록시 서버를 시작/중지합니다.

## Arguments

- `$ARGUMENTS` — `start` (기본), `stop`, `status`, `logs`

## Instructions

1. `whatap-mobile-proxy-server/` 디렉토리로 이동
2. 인자에 따라 동작:
   - `start` 또는 인자 없음:
     - `node_modules/` 없으면 `npm install` 먼저 실행
     - `npm start` 또는 `node index.js` 실행 (백그라운드)
     - 포트 확인 (기본 6600)
   - `stop`:
     - `lsof -ti:6600 | xargs kill` 로 프로세스 종료
   - `status`:
     - `lsof -i:6600` 으로 실행 여부 확인
     - `curl -s http://localhost:6600/health` 헬스체크
   - `logs`:
     - 최근 로그 출력 (프록시 서버에서 캡처한 모바일 SDK 데이터)

## Output

- 서버 상태 (실행 중/중지)
- 포트 번호
- 최근 수신 데이터 요약 (logs 모드)

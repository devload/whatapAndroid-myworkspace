# Build Gradle Plugin

WhatAp Android Gradle Plugin JAR을 빌드합니다.

## Arguments

- `$ARGUMENTS` — 옵션: `jar` (기본), `publish` (로컬 Maven 배포), `clean`

## Instructions

1. `whatapAndroidPlugin/` 디렉토리로 이동
2. 인자에 따라 빌드 실행:
   - `jar` 또는 인자 없음: `./gradlew clean jar -x test`
   - `publish`: `./gradlew publishToMavenLocal`
   - `clean`: `./gradlew clean`
3. 빌드 성공 시 JAR 파일 크기와 경로 출력
4. 빌드 실패 시 에러 메시지 분석 후 해결 방안 제시

## Output

빌드 결과:
- 산출물: `whatapAndroidPlugin/build/libs/whatapAndroidPlugin-*.jar`
- `publish` 시: `~/.m2/repository/io/whatap/` 경로에 배포됨

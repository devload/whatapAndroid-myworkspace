# Worktree Status

androidAgent와 whatapAndroidPlugin의 git worktree 상태를 확인합니다.

## Instructions

1. `androidAgent/` 디렉토리에서 `git worktree list` 실행
2. `whatapAndroidPlugin/` 디렉토리에서 `git worktree list` 실행
3. 각 worktree의 브랜치, 커밋 해시, 경로를 정리하여 출력
4. 각 worktree에서 `git status --short` 실행하여 변경사항 유무 확인

## Output

테이블 형식으로 출력:

| 프로젝트 | 경로 | 브랜치 | 변경사항 |
|----------|------|--------|----------|
| androidAgent | /path | main | clean |
| androidAgent | /path-v1 | release/v1 | 2 modified |
| whatapAndroidPlugin | /path | main | clean |

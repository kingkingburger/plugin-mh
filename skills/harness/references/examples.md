# Harness — 실행 예시

## 예시 1: 포모도로 타이머 (웹 앱, 단일 HTML)

### Phase 0
```
요청: "브라우저에서 돌아가는 포모도로 타이머 만들어줘"
타입: 웹 앱 (단일 HTML)
```

### Phase 1 플래너 출력 (요약)
```
Sprint 1: 핵심 타이머 (시작/일시정지/리셋, 25:00 카운트다운)
Sprint 2: 세션 흐름 (작업→휴식 전환, 세션 카운터, 알림)
Sprint 3: 디자인 & 설정 (고유 비주얼, 시간 커스터마이징)
```

### Sprint 1 계약
```
AC1: 페이지 로드 → 25:00 표시
AC2: 시작 클릭 → 1초마다 감소
AC3: 일시정지 → 멈춤
AC4: 리셋 → 25:00 복귀
AC5: 0:00 → 멈춤
```

### 이밸루에이터 테스트 시퀀스
```
browser_navigate → file:///path/index.html
browser_snapshot → "25:00" 확인
browser_click → 시작 버튼
browser_wait_for → 2초
browser_snapshot → 24:58 이하 확인
browser_click → 일시정지
browser_snapshot → 시간 고정 확인
browser_click → 리셋
browser_snapshot → 25:00 복귀 확인
browser_console_messages → 에러 없음 확인
browser_take_screenshot → .harness/screenshots/sprint-1-eval-1.png
```

### 이밸루에이터 보고서 예시 (CONDITIONAL)
```
기능성: 7/10 — 리셋 시 자동 재시작 버그
디자인: 5/10 — 기본 버튼, 커스텀 스타일 없음
독창성: 4/10 — 평범한 텍스트 카운트다운
완성도: 6/10 — 0:00 이후 음수 진행 버그
총점: 55 → CONDITIONAL
수정: 리셋 버그 + 0:00 정지 로직
```

## 예시 2: CLI 도구

### Phase 0
```
요청: "마크다운을 정적 블로그로 변환하는 CLI"
타입: CLI (Python)
```

### 이밸루에이터 (Bash 기반)
```bash
# AC1: MD → HTML 변환
echo "# Hello" > test.md && python blog.py build test.md
# 확인: output/test.html 존재, <h1>Hello</h1> 포함

# AC2: 에러 처리
python blog.py build nonexistent.md
# 확인: 에러 메시지, exit code != 0

# AC3: 일괄 변환
python blog.py build docs/
# 확인: docs/*.md → output/*.html
```

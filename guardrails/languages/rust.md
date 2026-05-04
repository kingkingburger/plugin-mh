# Rust Guardrails

## 기본값

- 포맷, 린트, 테스트는 `cargo fmt`, `cargo clippy`, `cargo test`를 기본으로 한다.
- 오류는 `Result`로 모델링한다.
- `panic!`은 복구 불가능한 불변식 위반에만 사용한다.
- `unsafe`는 사용하지 않는 것을 기본값으로 한다.

## 코드 기준

- 소유권 모델을 우회하려고 불필요한 clone을 남발하지 않는다.
- trait는 실제 다형성이나 테스트 경계가 필요할 때 도입한다.
- lifetime 복잡도가 높아지면 API 경계를 다시 설계한다.
- 외부 입력 파싱과 내부 도메인 타입을 분리한다.
- 동시성 코드는 공유 상태보다 메시지 전달이나 명확한 소유권 이전을 우선 검토한다.

## 테스트 기준

- 순수 함수와 도메인 규칙은 단위 테스트로 고정한다.
- 파일, 네트워크, 프로세스 경계는 통합 테스트로 검증한다.
- 버그 수정은 실패 입력을 재현하는 테스트를 추가한다.

## 선호 명령

```bash
cargo fmt --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-features
```

프로젝트가 workspace를 쓰면 `--workspace` 적용 여부를 먼저 확인한다.

# 데일리루트 인증 백엔드

Python 3.11 이상 / MySQL 8 이상. FastAPI + SQLAlchemy + MySQL.

## 구현 범위
- POST /api/auth/signup: nickname, email, password → 201
- POST /api/auth/login: email, password → 200, 7일 액세스 토큰
- GET /api/users/me: Authorization: Bearer <token> → 200, 회원 정보
- 공통 JSON: success(boolean), message(string), data(object 또는 null)
- 가입 성공 후 로그인 필요. 비밀번호 찾기 API, 리프레시 토큰 없음.
- 입력 오류 400 / 로그인 또는 토큰 오류 401 / 중복 이메일 409 / DB 오류 503.
- error_code는 별도 확정하지 않았으므로 추가하지 않았습니다.

## 적용한 기본 규칙 (변경 가능)
이전 논의에서 제안했던 닉네임 2~20자, 중복 허용 / 가입 비밀번호 8~64자를 기본값으로 구현했습니다.
닉네임 앞뒤 공백 제거. 이메일 앞뒤 공백 제거 및 전체 소문자 통일, DB UNIQUE 제약 적용.
비밀번호는 공백을 제거하지 않고 Argon2로 해시 저장. 비밀번호 확인은 Flutter에서 검사.
회원 테이블 users만 구현했습니다. 프로젝트 전체의 10개 이상 테이블 조건은 아직 충족하지 않습니다.

## 1. MySQL 준비
MySQL 관리 도구(예: Workbench)에서 setup.sql을 열고 비밀번호를 변경한 뒤 실행하세요.
이미 계정이 있으면 CREATE USER IF NOT EXISTS는 비밀번호를 바꾸지 않습니다.
기존 계정을 사용할 경우 .env를 그 계정 정보로 설정하면 됩니다.

## 2. Windows PowerShell 설치 및 실행
압축을 풀고 프로젝트 폴더에서:

```powershell
py -3.11 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
Copy-Item .env.example .env
.\.venv\Scripts\python.exe -c "import secrets; print(secrets.token_urlsafe(48))"
```

생성된 무작위 값을 .env의 JWT_SECRET에 넣고 DB_PASSWORD도 MySQL 계정 비밀번호로 변경하세요.
실제 .env는 Git에 올리지 마세요. 같은 서명 키를 유지해야 재시작해도 기존 토큰이 유효합니다.

```powershell
.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Python 3.12 등이 설치되어 있으면 첫 명령의 버전을 설치된 버전으로 바꾸세요.
실행 시 DB에 users 테이블을 자동 생성합니다. DB 자체와 계정은 먼저 만들어야 합니다.
테이블 구조 변경을 자동 적용하지 않으므로 이후에는 마이그레이션이 필요합니다.
서버 종료는 Ctrl+C입니다.

## 3. Swagger 테스트
PC 브라우저: http://127.0.0.1:8000/docs

1. signup → Try it out → 아래 JSON으로 Execute (201).
2. 같은 이메일 재가입 → 409 및 success:false 확인.
3. login → 같은 이메일/비밀번호 입력 → access_token 복사.
4. Swagger 상단 Authorize → 토큰 문자열만 입력 (Bearer 접두어 제외).
5. users/me 실행 → 회원 정보 반환 확인.
6. 잘못된 비밀번호 → 401 확인. Authorize 해제 후 me → 401 확인.

```json
{"nickname":"서현","email":"student@example.com","password":"Route1234!"}
```

로그인에는 nickname을 빼고 email/password만 보냅니다.
로그인 성공 응답:
```json
{"success":true,"message":"로그인되었습니다.","data":{"access_token":"발급 토큰","token_type":"Bearer","expires_in":604800,"user":{"id":1,"nickname":"서현","email":"student@example.com"}}}
```

## 4. Flutter 연결
Android 에뮬레이터: http://10.0.2.2:8000
실제 휴대폰: 같은 Wi-Fi에 연결하고 http://PC의_로컬_IP:8000 사용.
iOS 시뮬레이터(Mac): http://127.0.0.1:8000
휴대폰에서 localhost는 PC가 아닌 휴대폰 자신을 의미합니다.
필요하면 Windows 방화벽에서 사설 네트워크에 한해 8000 포트를 허용하세요.
Android INTERNET 권한과 개발용 HTTP 허용 설정이 필요할 수 있습니다.
iOS 역시 개발용 로컬 HTTP 예외 설정이 필요할 수 있습니다. 운영은 HTTPS를 사용하세요.
Flutter 네이티브 앱에는 브라우저 CORS가 필요하지 않습니다. Flutter Web은 별도 허용 출처 설정 필요.
Dio 등은 4xx 응답을 예외로 처리하므로 예외의 response.data에서도 success/message를 읽으세요.
토큰은 OS 보안 저장소에 저장하세요. me의 401일 때만 삭제하고 연결 실패·500·503에서는 유지하세요.
expires_in은 초 단위이며 발급부터 7일입니다. 앱 실행이나 me 호출로 연장되지 않습니다.

## 5. DB 확인
```sql
USE daily_route;
SHOW TABLES;
SELECT id, nickname, email, created_at FROM users;
SHOW CREATE TABLE users;
```
created_at은 UTC입니다. 비밀번호 원문은 저장하지 않습니다.

## 주의사항 및 검증 범위
서버 실행에는 실제 MySQL이 필요합니다. 제공 시 실제 사용자의 MySQL 연결·이메일 중복 동시 요청·모바일 연결은 실행 검증하지 않았습니다.
별도 토큰 폐기 목록은 없으므로 로그아웃은 앱에서 토큰을 삭제하는 방식입니다. 탈취된 토큰을 개별 폐기하는 기능은 없습니다.
시연용 구성입니다. 공개 운영 전 HTTPS, 로그인 시도 제한, 비밀키 관리, DB 마이그레이션, 관측/백업 등을 추가하세요.

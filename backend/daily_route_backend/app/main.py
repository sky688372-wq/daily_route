from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
from typing import Annotated
import logging

import jwt
from fastapi import Depends, FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from fastapi.responses import JSONResponse
from jwt.exceptions import InvalidTokenError
from pydantic import BaseModel, EmailStr, Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from pwdlib import PasswordHash
from sqlalchemy import DateTime, String, URL, create_engine, select
from sqlalchemy.exc import IntegrityError, SQLAlchemyError
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column, sessionmaker
from starlette.exceptions import HTTPException as StarletteHTTPException


# 1. 환경 설정: 비밀번호와 토큰 서명 키는 코드에 넣지 않습니다.
class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', extra='ignore')
    db_host: str = '127.0.0.1'
    db_port: int = 3306
    db_user: str = 'daily_route'
    db_password: str
    db_name: str = 'daily_route'
    jwt_secret: str

    @field_validator('jwt_secret')
    @classmethod
    def check_secret(cls, value: str) -> str:
        if len(value) < 32 or value.startswith('CHANGE_ME'):
            raise ValueError('JWT_SECRET은 새로 생성한 32자 이상의 무작위 값이어야 합니다.')
        return value


settings = Settings()
TOKEN_SECONDS = 604800
engine = create_engine(URL.create(
    'mysql+pymysql', username=settings.db_user, password=settings.db_password,
    host=settings.db_host, port=settings.db_port, database=settings.db_name,
    query={'charset': 'utf8mb4'},
), pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, expire_on_commit=False)
password_hash = PasswordHash.recommended()
# 존재하지 않는 이메일도 해시 검증을 수행해 응답 시간 차이를 줄입니다.
DUMMY_HASH = password_hash.hash('dummy-password-not-used-for-login')


# 2. 회원 테이블
class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = 'users'
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    nickname: Mapped[str] = mapped_column(String(20))
    email: Mapped[str] = mapped_column(String(254), unique=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None)
    )


def get_db():
    with SessionLocal() as db:
        yield db


DB = Annotated[Session, Depends(get_db)]


# 3. 요청 검증: 닉네임 중복 허용, 이메일은 앞뒤 공백 제거 후 소문자로 통일
class EmailInput(BaseModel):
    email: EmailStr = Field(max_length=254)

    @field_validator('email', mode='before')
    @classmethod
    def normalize_email(cls, value):
        return value.strip().lower() if isinstance(value, str) else value


class SignupInput(EmailInput):
    nickname: str = Field(min_length=2, max_length=20)
    password: str = Field(min_length=8, max_length=64)

    @field_validator('nickname', mode='before')
    @classmethod
    def normalize_nickname(cls, value):
        return value.strip() if isinstance(value, str) else value


class LoginInput(EmailInput):
    password: str = Field(min_length=1, max_length=64)


class ApiResponse(BaseModel):
    success: bool
    message: str
    data: dict | None = None


class ApiError(Exception):
    def __init__(self, status: int, message: str):
        self.status = status
        self.message = message


def failure(status: int, message: str, headers=None):
    return JSONResponse(status_code=status, headers=headers, content={
        'success': False, 'message': message, 'data': None,
    })


@asynccontextmanager
async def lifespan(app: FastAPI):
    # 시연용 초기 테이블 생성. 기존 테이블의 스키마 변경은 수행하지 않습니다.
    Base.metadata.create_all(engine)
    yield
    engine.dispose()


app = FastAPI(title='데일리루트 인증 API', version='1.0.0', lifespan=lifespan)


@app.exception_handler(ApiError)
async def api_error_handler(request: Request, exc: ApiError):
    headers = {'WWW-Authenticate': 'Bearer'} if exc.status == 401 else None
    return failure(exc.status, exc.message, headers)


@app.exception_handler(RequestValidationError)
async def validation_handler(request: Request, exc: RequestValidationError):
    # 입력 원문(특히 비밀번호)을 응답이나 로그에 포함하지 않습니다.
    return failure(400, '입력값을 확인해 주세요. 닉네임 2~20자, 비밀번호 8~64자 및 이메일 형식을 확인해 주세요.')


@app.exception_handler(StarletteHTTPException)
async def http_error_handler(request: Request, exc: StarletteHTTPException):
    return failure(exc.status_code, '요청 주소 또는 요청 방식을 확인해 주세요.', exc.headers)


@app.exception_handler(SQLAlchemyError)
async def database_error_handler(request: Request, exc: SQLAlchemyError):
    return failure(503, '데이터베이스 연결 또는 처리에 실패했습니다. 잠시 후 다시 시도해 주세요.')


@app.exception_handler(Exception)
async def unknown_error_handler(request: Request, exc: Exception):
    logging.getLogger(__name__).error('Unhandled error type: %s', type(exc).__name__)
    return failure(500, '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.')


# 4. 회원가입
@app.post('/api/auth/signup', status_code=201, response_model=ApiResponse)
def signup(body: SignupInput, db: DB):
    email = str(body.email)
    if db.scalar(select(User).where(User.email == email)):
        raise ApiError(409, '이미 사용 중인 이메일입니다.')
    user = User(nickname=body.nickname, email=email,
                password_hash=password_hash.hash(body.password))
    db.add(user)
    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        # 동시에 같은 이메일로 가입해도 DB 고유 제약조건으로 중복 차단
        if getattr(exc.orig, 'args', (None,))[0] == 1062:
            raise ApiError(409, '이미 사용 중인 이메일입니다.') from exc
        raise
    return ApiResponse(success=True, message='회원가입이 완료되었습니다.')


def user_data(user: User):
    return {'id': user.id, 'nickname': user.nickname, 'email': user.email}


# 5. 로그인: 토큰은 발급 시각부터 7일, 자동 연장 없음
@app.post('/api/auth/login', response_model=ApiResponse)
def login(body: LoginInput, db: DB):
    user = db.scalar(select(User).where(User.email == str(body.email)))
    valid = password_hash.verify(body.password, user.password_hash if user else DUMMY_HASH)
    if user is None or not valid:
        raise ApiError(401, '이메일 또는 비밀번호를 확인해 주세요.')
    now = datetime.now(timezone.utc)
    token = jwt.encode({
        'sub': str(user.id), 'iat': now,
        'exp': now + timedelta(seconds=TOKEN_SECONDS),
        'iss': 'daily-route', 'aud': 'daily-route-app',
    }, settings.jwt_secret, algorithm='HS256')
    return ApiResponse(success=True, message='로그인되었습니다.', data={
        'access_token': token, 'token_type': 'Bearer',
        'expires_in': TOKEN_SECONDS, 'user': user_data(user),
    })


# 6. 내 정보 조회 및 자동 로그인 확인
security = HTTPBearer(auto_error=False)


@app.get('/api/users/me', response_model=ApiResponse)
def me(db: DB, credentials: Annotated[
    HTTPAuthorizationCredentials | None, Depends(security)
]):
    if credentials is None:
        raise ApiError(401, '로그인이 필요합니다.')
    try:
        payload = jwt.decode(
            credentials.credentials, settings.jwt_secret, algorithms=['HS256'],
            issuer='daily-route', audience='daily-route-app',
            options={'require': ['sub', 'iat', 'exp', 'iss', 'aud']},
        )
        user_id = int(payload['sub'])
        if user_id <= 0:
            raise ValueError()
    except (InvalidTokenError, ValueError, TypeError):
        raise ApiError(401, '로그인이 만료되었거나 유효하지 않습니다. 다시 로그인해 주세요.')
    user = db.get(User, user_id)
    if user is None:
        raise ApiError(401, '회원 정보를 확인할 수 없습니다. 다시 로그인해 주세요.')
    return ApiResponse(success=True, message='회원 정보를 조회했습니다.', data=user_data(user))

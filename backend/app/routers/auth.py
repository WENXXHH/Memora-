"""认证路由 — 第四周返回 Mock 响应，第五周接入真实鉴权。"""

from fastapi import APIRouter

from app.schemas.auth import (
    LoginRequest,
    TokenResponse,
    UserCreate,
    UserResponse,
)

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", response_model=UserResponse, status_code=201)
def register(body: UserCreate) -> UserResponse:
    """注册新用户 — Mock only。

    第四周：直接返回用户名和邮箱，不写数据库。
    第五周：校验重复 → 哈希密码 → 写 DB → 返回。
    """
    return UserResponse(id=1, username=body.username, email=body.email)


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest) -> TokenResponse:
    """登录 — Mock only。

    第四周：不做任何校验，直接返回假 token。
    第五周：校验密码 → 签发 JWT。
    """
    return TokenResponse(access_token="mock-token-第四周仅骨架第五周实现JWT")

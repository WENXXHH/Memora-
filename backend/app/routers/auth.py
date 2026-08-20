"""认证路由 — 第五周真实实现。

端点：
- POST /auth/register  注册（用户名/邮箱重复 → 409）
- POST /auth/login     登录（成功返回 JWT + user）
- GET  /auth/me        获取当前用户（需 Bearer Token）

原则 6：当前用户由 Token 决定。
原则 7：Router 处理 HTTP，Service 处理业务。
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_session
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.schemas.auth import (
    LoginRequest,
    TokenResponse,
    UserCreate,
    UserResponse,
)
from app.services.auth_service import (
    AuthService,
    EmailAlreadyExistsError,
    InvalidCredentialsError,
    UsernameAlreadyExistsError,
)

router = APIRouter(prefix="/auth", tags=["Auth"])


def _to_response(user: User) -> UserResponse:
    """ORM User → UserResponse，过滤 password_hash。"""
    return UserResponse(
        id=user.id,
        username=user.username,
        email=user.email,
    )


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(
    body: UserCreate,
    db: Session = Depends(get_session),
) -> UserResponse:
    """注册新用户。

    - 用户名/邮箱重复 → 409 Conflict
    - 密码由 AuthService 哈希后写入，不存明文（Bug 1 防御）
    - 响应绝不含 password / password_hash
    """
    auth_service = AuthService(db)
    try:
        user = auth_service.register(
            username=body.username,
            email=body.email,
            password=body.password,
        )
    except UsernameAlreadyExistsError as e:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e),
        ) from e
    except EmailAlreadyExistsError as e:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e),
        ) from e
    return _to_response(user)


@router.post("/login", response_model=TokenResponse)
def login(
    body: LoginRequest,
    db: Session = Depends(get_session),
) -> TokenResponse:
    """登录。

    - 校验密码（含 dummy hash 防时序攻击）
    - 签发 JWT
    - 响应含 access_token + token_type + user
    - access_token 字段名不可改：客户端 auth_interceptor.dart 用 'access_token' 常量读取
    """
    auth_service = AuthService(db)
    try:
        user = auth_service.authenticate(
            username=body.username,
            password=body.password,
        )
    except InvalidCredentialsError as e:
        # 不区分"用户不存在"与"密码错误"
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"},
        ) from e

    token = auth_service.create_token_for(user)
    return TokenResponse(
        access_token=token,
        token_type="bearer",
        user=_to_response(user),
    )


@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)) -> UserResponse:
    """获取当前登录用户信息。

    用于：
    - App 启动后验证已保存 Token 是否仍然有效
    - 获取当前用户信息（避免登录后再请求一次）
    - 判断 Token 是否已经过期
    """
    return _to_response(current_user)

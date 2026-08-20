"""FastAPI 依赖：当前用户解析。

职责：从 Authorization: Bearer <token> 解析 JWT → 查 User → 注入到路由。
原则 6：当前用户由 Token 决定，不由请求体中的 userId 决定。

使用方式：
    @router.get("/me", response_model=UserResponse)
    def get_me(current_user: User = Depends(get_current_user)) -> UserResponse:
        ...
"""

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.security import TokenData, decode_access_token
from app.db.session import get_session
from app.models.user import User
from app.services.user_service import UserService

# tokenUrl 用于 Swagger /docs 的"Authorize"按钮展示登录端点路径
# 实际登录端点是 POST /api/v1/auth/login，这里写相对路径
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_session),
) -> User:
    """解析 Bearer Token 并返回当前 User。

    失败路径一律返回 401（Bug 2 排查清单：Authorization/SECRET/ALGORITHM/sub）。
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="无法验证凭据",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = decode_access_token(token)
        token_data = TokenData.from_payload(payload)
    except ValueError:
        # sub 缺失或非法
        raise credentials_exception
    except jwt.PyJWTError:
        # 过期 / 签名非法 / 格式错误
        raise credentials_exception

    user_service = UserService(db)
    user = user_service.get_by_id(token_data.user_id)
    if user is None:
        # Token 合法但用户已被删除
        raise credentials_exception
    return user

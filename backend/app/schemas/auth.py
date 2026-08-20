"""用户/认证相关 Pydantic Schema —— 输入与输出严格分离。

原则：响应模型绝不含 password / password_hash。
字段命名：API JSON 一律 snake_case（与 DB 列名一致），客户端 Dart 端做 camelCase 转换。
"""

from pydantic import BaseModel, EmailStr, Field


class UserCreate(BaseModel):
    """注册请求体。

    客户端校验只是改善体验，服务端必须重新验证全部规则（原则：服务端必验）。
    """

    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)


class UserResponse(BaseModel):
    """用户信息响应 —— 绝不含 password / password_hash。"""

    id: int
    username: str
    email: str


class LoginRequest(BaseModel):
    """登录请求体。"""

    username: str
    password: str


class TokenResponse(BaseModel):
    """Token 响应。

    含 user 字段，减少登录后再请求一次用户资料。
    access_token 字段名不可改：客户端 auth_interceptor.dart 用 'access_token' 常量读取。
    """

    access_token: str
    token_type: str = "bearer"
    user: UserResponse

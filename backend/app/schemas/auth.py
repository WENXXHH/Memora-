"""用户/认证相关 Pydantic Schema —— 输入与输出严格分离。"""

from pydantic import BaseModel, EmailStr


class UserCreate(BaseModel):
    """注册请求体。

    密码在第四周暂不哈希，第五周后由 Service 层接管。
    """

    username: str
    email: str
    password: str


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

    第四周返回 mock-token，第五周实现 JWT。
    """

    access_token: str
    token_type: str = "bearer"

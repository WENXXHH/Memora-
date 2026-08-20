"""Memora 后端全局配置。

使用 pydantic-settings 管理配置：
- 静态默认值写在代码里
- 敏感字段（JWT_SECRET）必须由环境变量或 .env 提供，不进入 Git
- 现有常量 DATABASE_URL / API_TITLE / API_VERSION / API_DESCRIPTION 保持兼容
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """后端配置。

    优先级：环境变量 > .env 文件 > 代码默认值。
    """

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # 数据库
    DATABASE_URL: str = "sqlite:///./memora.db"

    # API 元信息
    API_TITLE: str = "Memora API"
    API_VERSION: str = "0.1.0"
    API_DESCRIPTION: str = "Memora 单词背诵 App 后端服务"

    # JWT 配置
    JWT_SECRET: str = ""  # 必须由 .env 提供，空字符串时启动会抛错
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRE_DAYS: int = 7

    # Argon2 哈希兜底（pwdlib PasswordHash.recommended() 已自带合理默认）
    # 以下字段预留给未来细调 Argon2 参数，目前未使用
    ARGON2_TIME_COST: int = 3
    ARGON2_MEMORY_COST: int = 65536
    ARGON2_PARALLELISM: int = 1


settings = Settings()

# 兼容旧 import：保留模块级常量
DATABASE_URL: str = settings.DATABASE_URL
API_TITLE: str = settings.API_TITLE
API_VERSION: str = settings.API_VERSION
API_DESCRIPTION: str = settings.API_DESCRIPTION


def get_jwt_secret() -> str:
    """获取 JWT 密钥，空字符串时抛错。

    原则 5：Secret 只来自环境变量，不进入 Git。
    """
    if not settings.JWT_SECRET:
        raise RuntimeError(
            "JWT_SECRET 未配置：请在 backend/.env 中设置 JWT_SECRET=xxx，"
            "或通过环境变量 JWT_SECRET 提供。开发期可用："
            "JWT_SECRET=dev-secret-please-change"
        )
    return settings.JWT_SECRET

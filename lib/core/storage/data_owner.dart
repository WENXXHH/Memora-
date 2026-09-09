/// 本地学习数据的"所有者"命名空间约定。
///
/// 背景：本地 reviews Box 过去是全局单份（无账号维度），多账号/游客
/// 切换时数据互相污染。改为在 key 层面加 owner 前缀隔离：
///
/// ```
/// key = '<owner>|<wordBookId>:<wordId>'
/// owner ∈ { 'guest', 'user:<userId>' }
/// ```
///
/// - 游客学习的数据写入 `guest|` 空间；
/// - 登录成功时由 UserDataSpaceService 把 guest 空间数据迁移进
///   对应 `user:<id>|` 空间（升级账号不丢学习成果）；
/// - 各账号空间互不可见，从根源上杜绝账号间数据混淆。
library;

/// auth Box 中存储当前数据所有者的 key。
const String kDataOwnerKey = 'data_owner';

/// 游客（未登录）空间前缀。
const String kGuestOwner = 'guest';

/// 指定用户的空间前缀。
String userOwnerKey(String userId) => 'user:$userId';

/// 缺省 owner：未设置时视为游客。
const String kDefaultOwner = kGuestOwner;

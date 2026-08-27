import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// 集中管理 Hive 的初始化生命周期。
///
/// 遵循规范：统一由一个 Initializer 打开 Box，
/// 其他层（Repository / DataSource / Interceptor）只获取已打开实例，
/// 不在多处重复调用 openBox()。
class HiveInitializer {
  HiveInitializer._();

  /// Box 名称常量
  static const String reviewsBoxName = 'reviews';

  /// 鉴权 Box 名称，存储 JWT 等凭证。
  static const String authBoxName = 'auth';

  /// 设置 Box 名称，存储设备级轻量偏好（如当前词库选择）。
  ///
  /// 与 reviews / auth 分离：不参与业务学习记录，也不参与凭证存储。
  static const String settingsBoxName = 'settings';

  /// 自建词库 Box 名称（doc 24）。
  ///
  /// 单独一个 Box 存储全部自建词库元数据，key 为 wordBookId（doc 25）；
  /// 自建单词另用 custom_words Box，不要为每个词库开一个 Box（doc 24）。
  /// 沿用 Box<Map> + JSON 序列化，与 reviews Box 一致，无需 TypeAdapter。
  static const String customWordBooksBoxName = 'custom_word_books';

  /// 自建单词 Box 名称（doc 24 / 26）。
  ///
  /// 全部自建单词存同一个 Box，key 为联合 Key `$wordBookId:$wordId`（doc 26）。
  /// 与 custom_word_books 分开，避免词库元数据与单词数据互相污染。
  static const String customWordsBoxName = 'custom_words';

  /// 初始化 Hive 引擎并打开所有业务 Box。
  ///
  /// 必须在 WidgetsFlutterBinding.ensureInitialized() 之后、
  /// configureDependencies() 之前调用。
  ///
  /// 返回 [HiveBoxes] 包含所有已打开的 Box，由调用方注册到 DI 容器。
  static Future<HiveBoxes> initialize() async {
    await Hive.initFlutter();

    final reviewsBox = await Hive.openBox<Map<dynamic, dynamic>>(
      reviewsBoxName,
    );
    final authBox = await Hive.openBox<String>(authBoxName);
    final settingsBox = await Hive.openBox<String>(settingsBoxName);
    final customWordBooksBox = await Hive.openBox<Map<dynamic, dynamic>>(
      customWordBooksBoxName,
    );
    final customWordsBox = await Hive.openBox<Map<dynamic, dynamic>>(
      customWordsBoxName,
    );

    return HiveBoxes(
      reviews: reviewsBox,
      auth: authBox,
      settings: settingsBox,
      customWordBooks: customWordBooksBox,
      customWords: customWordsBox,
    );
  }
}

/// 已打开的 Box 集合，便于 main.dart 一次性注册到 getIt。
class HiveBoxes {
  const HiveBoxes({
    required this.reviews,
    required this.auth,
    required this.settings,
    required this.customWordBooks,
    required this.customWords,
  });

  /// 学习记录 Box，存储 SM-2 复习状态。
  final Box<Map<dynamic, dynamic>> reviews;

  /// 鉴权 Box，存储 JWT access token。
  final Box<String> auth;

  /// 设置 Box，存储设备级轻量偏好（当前词库选择等）。
  final Box<String> settings;

  /// 自建词库元数据 Box，key 为 wordBookId（doc 25）。
  final Box<Map<dynamic, dynamic>> customWordBooks;

  /// 自建单词 Box，key 为联合 Key `$wordBookId:$wordId`（doc 26）。
  final Box<Map<dynamic, dynamic>> customWords;
}

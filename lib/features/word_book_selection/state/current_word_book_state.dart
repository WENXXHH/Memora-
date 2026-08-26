import '../../../core/utils/built_in_word_books.dart';

/// 当前词库选择状态（doc 6）。
///
/// 字段说明：
/// - [currentWordBookId]：当前词库 Domain ID（cet6 / cet4），默认 CET-6
/// - [isInitialized]：是否已完成本地选择恢复（doc 7）
/// - [errorMessage]：初始化失败 / 非法选择的错误提示
///
/// 区分"默认值"与"已恢复"：
/// 若用户上次选择 CET-4 而启动时先按默认 CET-6 渲染，会产生页面闪烁 /
/// 重复加载（doc 7），因此用 [isInitialized] 显式表达恢复完成。
class CurrentWordBookState {
  final String currentWordBookId;
  final bool isInitialized;
  final String? errorMessage;

  const CurrentWordBookState({
    // 与 BuiltInWordBooks.cet6.id 保持一致（const 表达式限制，无法引用
    // 常量对象属性，故用字面量；Domain ID 由文档 §63 固定为 cet6/cet4）
    this.currentWordBookId = 'cet6',
    this.isInitialized = false,
    this.errorMessage,
  });

  /// 创建副本，更新指定字段。
  ///
  /// 使用 sentinel 模式区分"未传参"与"显式传 null"（约束 21，
  /// 与 [SpellingQuizState] 等保持一致），供 errorMessage 清空使用。
  CurrentWordBookState copyWith({
    String? currentWordBookId,
    bool? isInitialized,
    Object? errorMessage = _sentinel,
  }) {
    return CurrentWordBookState(
      currentWordBookId: currentWordBookId ?? this.currentWordBookId,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// sentinel 值，用于 copyWith 区分"未传参"与"显式传 null"。
const Object _sentinel = Object();

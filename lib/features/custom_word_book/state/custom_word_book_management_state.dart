import '../../../data/dto/custom_word_book_model.dart';

/// 自建词库管理状态（doc 63）。
///
/// 字段说明：
/// - [isLoading]：是否正在加载词库列表
/// - [wordBooks]：全部自建词库（按创建时间升序）
/// - [errorMessage]：加载 / 创建 / 重命名 / 删除失败的错误提示
class CustomWordBookManagementState {
  final bool isLoading;
  final List<CustomWordBook> wordBooks;
  final String? errorMessage;

  const CustomWordBookManagementState({
    this.isLoading = false,
    this.wordBooks = const [],
    this.errorMessage,
  });

  /// 创建副本，更新指定字段。
  ///
  /// 使用 sentinel 模式区分"未传参"与"显式传 null"，
  /// 供 errorMessage 清空使用（与 CurrentWordBookState 等保持一致）。
  CustomWordBookManagementState copyWith({
    bool? isLoading,
    List<CustomWordBook>? wordBooks,
    Object? errorMessage = _sentinel,
  }) {
    return CustomWordBookManagementState(
      isLoading: isLoading ?? this.isLoading,
      wordBooks: wordBooks ?? this.wordBooks,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// sentinel 值，用于 copyWith 区分"未传参"与"显式传 null"。
const Object _sentinel = Object();

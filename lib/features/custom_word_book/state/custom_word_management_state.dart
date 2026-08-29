import '../../../data/dto/custom_word_record_model.dart';

/// 自建单词管理状态（doc 64）。
///
/// - [isLoading]：是否正在加载单词列表
/// - [words]：当前词库的全部自建单词（按创建时间升序）
/// - [errorMessage]：加载 / 新增 / 编辑 / 删除失败的错误提示
///
/// 通过 StateNotifierProvider.autoDispose.family(wordBookId) 按词库隔离（doc 64）。
class CustomWordManagementState {
  final bool isLoading;
  final List<CustomWordRecord> words;
  final String? errorMessage;

  const CustomWordManagementState({
    this.isLoading = false,
    this.words = const [],
    this.errorMessage,
  });

  /// 创建副本，更新指定字段。
  ///
  /// 使用 sentinel 模式区分"未传参"与"显式传 null"，
  /// 供 errorMessage 清空使用。
  CustomWordManagementState copyWith({
    bool? isLoading,
    List<CustomWordRecord>? words,
    Object? errorMessage = _sentinel,
  }) {
    return CustomWordManagementState(
      isLoading: isLoading ?? this.isLoading,
      words: words ?? this.words,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// sentinel 值，用于 copyWith 区分"未传参"与"显式传 null"。
const Object _sentinel = Object();

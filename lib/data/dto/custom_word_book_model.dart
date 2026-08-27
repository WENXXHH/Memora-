import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_word_book_model.freezed.dart';
part 'custom_word_book_model.g.dart';

/// 自建词库数据模型（doc 7 / 8）。
///
/// 只承载本地词库元数据，与内置词库（[BuiltInWordBooks]）相互独立。
/// 刻意不加入 isBuiltin / serverId / syncStatus 等字段，
/// 它们属于 feature/自建词库云端同步 分支（doc 8）。
@freezed
class CustomWordBook with _$CustomWordBook {
  const factory CustomWordBook({
    /// 词库 Domain ID，格式 custom_<uuid>，一旦创建永不变化（doc 5）。
    required String id,

    /// 展示名称，trim 后 1~30 字符，同设备唯一（doc 13）。
    required String name,

    /// 创建时间（本地）。
    required DateTime createdAt,

    /// 最后修改时间（本地），重命名时更新。
    required DateTime updatedAt,
  }) = _CustomWordBook;

  factory CustomWordBook.fromJson(Map<String, dynamic> json) =>
      _$CustomWordBookFromJson(json);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/built_in_word_books.dart';
import '../../../data/dto/custom_word_book_model.dart';
import '../../../data/repositories/custom_word_book_repository.dart';
import '../../../domain/use_cases/delete_custom_word_book_use_case.dart';
import '../state/custom_word_book_management_state.dart';

/// 自建词库管理控制器（doc 63）。
///
/// 负责 load / create / rename / delete，不要把 CRUD 塞进
/// CurrentWordBookController（doc 63），两者职责分离：
/// - 本控制器：管理自建词库数据
/// - CurrentWordBookController：维护当前选择
///
/// 删除成功后的当前词库回退由页面组合层调用
/// CurrentWordBookController.resetToDefault()（doc 62 / 71）。
class CustomWordBookManagementController
    extends StateNotifier<CustomWordBookManagementState> {
  CustomWordBookManagementController(this._repository, this._deleteUseCase)
    : super(const CustomWordBookManagementState());

  final CustomWordBookRepository _repository;
  final DeleteCustomWordBookUseCase _deleteUseCase;

  /// 加载全部自建词库。
  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final books = await _repository.getAll();
      state = state.copyWith(isLoading: false, wordBooks: books);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: '加载词库失败');
    }
  }

  /// 创建自建词库，成功返回新词库，失败返回 null 并写入 errorMessage。
  ///
  /// 校验基于最新数据（doc 13 / 14）：trim 非空、长度 1~30、
  /// 不与内置词库重名、同设备自建词库名称唯一。
  Future<CustomWordBook?> create(String name) async {
    List<CustomWordBook> existing;
    try {
      existing = await _repository.getAll();
    } catch (_) {
      state = state.copyWith(errorMessage: '加载词库失败');
      return null;
    }

    final error = _validate(name, existing);
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return null;
    }

    try {
      final book = await _repository.create(name: name.trim());
      final books = await _repository.getAll();
      state = state.copyWith(wordBooks: books, errorMessage: null);
      return book;
    } catch (_) {
      state = state.copyWith(errorMessage: '创建词库失败');
      return null;
    }
  }

  /// 重命名词库，成功返回更新后的词库，失败返回 null。
  ///
  /// 重命名时排除自身 ID（doc 13），ID 不随名称变化（doc 5）。
  Future<CustomWordBook?> rename(String id, String newName) async {
    List<CustomWordBook> existing;
    try {
      existing = await _repository.getAll();
    } catch (_) {
      state = state.copyWith(errorMessage: '加载词库失败');
      return null;
    }

    final error = _validate(newName, existing, excludeId: id);
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return null;
    }

    try {
      final book = await _repository.rename(id: id, newName: newName.trim());
      final books = await _repository.getAll();
      state = state.copyWith(wordBooks: books, errorMessage: null);
      return book;
    } catch (_) {
      state = state.copyWith(errorMessage: '重命名失败');
      return null;
    }
  }

  /// 删除自建词库（级联删除由 [DeleteCustomWordBookUseCase] 编排）。
  ///
  /// 成功返回 true；若删除的是当前词库，页面组合层负责回退（doc 71）。
  Future<bool> delete(String id) async {
    try {
      await _deleteUseCase.execute(id);
      final books = await _repository.getAll();
      state = state.copyWith(wordBooks: books, errorMessage: null);
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '删除词库失败');
      return false;
    }
  }

  /// 名称同步校验（供表单页提交前即时校验，基于当前 state）。
  String? validateName(String name, {String? excludeId}) =>
      _validate(name, state.wordBooks, excludeId: excludeId);

  /// 名称校验核心逻辑（doc 13 / 14）。
  ///
  /// [existing] 必须是调用时最新的自建词库列表；
  /// [excludeId] 为重命名时排除自身的 ID。
  String? _validate(
    String name,
    List<CustomWordBook> existing, {
    String? excludeId,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '词库名称不能为空';
    if (trimmed.length > 30) return '词库名称不能超过 30 个字符';

    final normalized = _normalize(trimmed);
    for (final config in BuiltInWordBooks.all) {
      if (_normalize(config.name) == normalized) {
        return '与内置词库名称重复，请换一个名称';
      }
    }
    for (final book in existing) {
      if (book.id == excludeId) continue;
      if (_normalize(book.name) == normalized) return '词库名称已存在';
    }
    return null;
  }

  /// 规范化：去首尾空格 + 统一小写，用于名称比较（doc 14）。
  String _normalize(String name) => name.trim().toLowerCase();
}

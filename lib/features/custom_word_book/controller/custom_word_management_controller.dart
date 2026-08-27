import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/dto/custom_word_record_model.dart';
import '../../../data/dto/word_model.dart';
import '../../../data/repositories/custom_word_repository.dart';
import '../../../data/repositories/review_repository.dart';
import '../state/custom_word_management_state.dart';

/// 自建单词管理控制器（doc 64）。
///
/// 通过 family(wordBookId) 按词库隔离，负责当前词库单词的
/// load / create / update / delete。
///
/// - 英文保存标准化：trim + lowercase（doc 44，与 CET 数据风格一致）
/// - 重复英文校验：同词库内 trim + lowercase 归一化判重（doc 45）
/// - 删除单词同步删除该词 WordReview，不留孤儿数据（doc 23）
class CustomWordManagementController
    extends StateNotifier<CustomWordManagementState> {
  CustomWordManagementController(
    this._wordRepository,
    this._reviewRepository,
    this.wordBookId,
  ) : super(const CustomWordManagementState());

  final CustomWordRepository _wordRepository;
  final ReviewRepository _reviewRepository;

  /// 所属自建词库 Domain ID。
  final String wordBookId;

  /// 加载当前词库的全部自建单词。
  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final words = await _wordRepository.getAll(wordBookId);
      state = state.copyWith(isLoading: false, words: words);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: '加载单词失败');
    }
  }

  /// 同步名称校验（供表单页提交前即时校验，基于当前 state）。
  ///
  /// [excludeWordId] 为编辑时排除自身的单词 ID（doc 45）。
  String? validateWord(String word, {String? excludeWordId}) {
    final trimmed = word.trim();
    if (trimmed.isEmpty) return '英文不能为空';
    final normalized = _normalize(trimmed);
    for (final record in state.words) {
      if (record.id == excludeWordId) continue;
      if (_normalize(record.word) == normalized) return '该词库已存在此单词';
    }
    return null;
  }

  /// 新增单词，成功返回新记录，失败返回 null 并写入 errorMessage。
  ///
  /// 校验基于最新数据（doc 45）：英文 trim 非空、同词库不重复；
  /// 中文释义 trim 非空（doc 43）。表单只输入中文，生成一条默认
  /// 词性为空串的 MeaningEntry（doc 12）。
  Future<CustomWordRecord?> create({
    required String word,
    required String phonetic,
    required String meaningChinese,
    required String example,
  }) async {
    final trimmedWord = _normalize(word);
    if (trimmedWord.isEmpty) {
      state = state.copyWith(errorMessage: '英文不能为空');
      return null;
    }
    final trimmedMeaning = meaningChinese.trim();
    if (trimmedMeaning.isEmpty) {
      state = state.copyWith(errorMessage: '中文释义不能为空');
      return null;
    }

    final existing = await _getFresh();
    if (existing == null) return null;
    final error = _validateAgainst(trimmedWord, existing);
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return null;
    }

    try {
      final record = await _wordRepository.create(
        wordBookId: wordBookId,
        word: trimmedWord,
        phonetic: phonetic.trim(),
        meaning: [MeaningEntry(pos: '', definitions: [trimmedMeaning])],
        example: example.trim().isEmpty ? const [] : [example.trim()],
      );
      await _refresh();
      return record;
    } catch (_) {
      state = state.copyWith(errorMessage: '创建单词失败');
      return null;
    }
  }

  /// 编辑单词，成功返回更新后的记录，失败返回 null。
  ///
  /// ID 不变（doc 19），重复校验排除自身 wordId（doc 45）。
  Future<CustomWordRecord?> update({
    required String wordId,
    required String word,
    required String phonetic,
    required String meaningChinese,
    required String example,
  }) async {
    final trimmedWord = _normalize(word);
    if (trimmedWord.isEmpty) {
      state = state.copyWith(errorMessage: '英文不能为空');
      return null;
    }
    final trimmedMeaning = meaningChinese.trim();
    if (trimmedMeaning.isEmpty) {
      state = state.copyWith(errorMessage: '中文释义不能为空');
      return null;
    }

    final existing = await _getFresh();
    if (existing == null) return null;
    final error = _validateAgainst(trimmedWord, existing, excludeWordId: wordId);
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return null;
    }

    try {
      final record = await _wordRepository.update(
        wordBookId: wordBookId,
        wordId: wordId,
        word: trimmedWord,
        phonetic: phonetic.trim(),
        meaning: [MeaningEntry(pos: '', definitions: [trimmedMeaning])],
        example: example.trim().isEmpty ? const [] : [example.trim()],
      );
      await _refresh();
      return record;
    } catch (_) {
      state = state.copyWith(errorMessage: '编辑单词失败');
      return null;
    }
  }

  /// 删除单词，成功返回 true。
  ///
  /// 同步删除该单词的 WordReview（doc 23），避免孤儿数据。
  Future<bool> delete(String wordId) async {
    try {
      await _wordRepository.delete(wordBookId, wordId);
      await _reviewRepository.deleteReview(wordBookId, wordId);
      final words = await _wordRepository.getAll(wordBookId);
      state = state.copyWith(words: words, errorMessage: null);
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: '删除单词失败');
      return false;
    }
  }

  /// 读取最新单词列表，失败时写入 errorMessage 并返回 null。
  Future<List<CustomWordRecord>?> _getFresh() async {
    try {
      return await _wordRepository.getAll(wordBookId);
    } catch (_) {
      state = state.copyWith(errorMessage: '加载单词失败');
      return null;
    }
  }

  /// 保存后刷新列表，让新增 / 编辑结果立即可见（doc 65）。
  Future<void> _refresh() async {
    final words = await _wordRepository.getAll(wordBookId);
    state = state.copyWith(words: words, errorMessage: null);
  }

  /// 基于最新列表校验重复（doc 45）。
  String? _validateAgainst(
    String normalizedWord,
    List<CustomWordRecord> existing, {
    String? excludeWordId,
  }) {
    for (final record in existing) {
      if (record.id == excludeWordId) continue;
      if (_normalize(record.word) == normalizedWord) return '该词库已存在此单词';
    }
    return null;
  }

  /// 归一化：trim + lowercase，用于存储与判重（doc 44 / 45）。
  String _normalize(String word) => word.trim().toLowerCase();
}

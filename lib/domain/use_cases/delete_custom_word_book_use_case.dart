/// 删除自建词库的 UseCase（doc 60 / 61）。
///
/// 删除跨 Repository（词库 + Review + 后续分支的单词），
/// 不适合让单个 Repository 或 Controller 承担，故用 UseCase 编排。
/// 遵循 doc 62：UseCase 只删数据，不依赖 CurrentWordBookController，
/// 当前词库回退由页面组合层处理。
library;

import '../../core/utils/built_in_word_books.dart';
import '../../data/repositories/custom_word_book_repository.dart';
import '../../data/repositories/custom_word_repository.dart';
import '../../data/repositories/review_repository.dart';

class DeleteCustomWordBookUseCase {
  DeleteCustomWordBookUseCase(
    this._customWordBookRepository,
    this._customWordRepository,
    this._reviewRepository,
  );

  final CustomWordBookRepository _customWordBookRepository;
  final CustomWordRepository _customWordRepository;
  final ReviewRepository _reviewRepository;

  /// 执行级联删除（doc 15 / 61）：
  /// 1. 内置词库禁止删除（doc 18）
  /// 2. 删除该词库全部自建单词（doc 61）
  /// 3. 删除该词库全部 WordReview（doc 16，避免孤儿数据）
  /// 4. 删除 CustomWordBook 元数据
  ///
  /// 删除成功后若该词库为当前词库，由页面组合层调用
  /// CurrentWordBookController.resetToDefault()（doc 62 / 71）。
  Future<void> execute(String wordBookId) async {
    if (BuiltInWordBooks.contains(wordBookId)) {
      throw ArgumentError('内置词库不能被删除: $wordBookId');
    }
    await _customWordRepository.deleteByWordBookId(wordBookId);
    await _reviewRepository.deleteReviewsByWordBookId(wordBookId);
    await _customWordBookRepository.delete(wordBookId);
  }
}

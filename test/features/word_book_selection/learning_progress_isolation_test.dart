import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memora/core/utils/question_generator.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/repositories/review_repository.dart';
import 'package:memora/data/repositories/word_repository.dart';
import 'package:memora/domain/enums/learning_enums.dart';
import 'package:memora/domain/use_cases/apply_review_feedback_use_case.dart';
import 'package:memora/features/multiple_choice/controller/multiple_choice_controller.dart';
import 'package:memora/features/spelling_quiz/controller/spelling_quiz_controller.dart';

/// 多词库学习进度隔离测试（doc 49 / 50 / 51 / 62 学习进度）。
///
/// 1. Review 隔离（doc 50）：相同 wordId 在不同词库下是两条独立记录，
///    真实 [ApplyReviewFeedbackUseCase] 更新 CET-4 不影响 CET-6。
/// 2. Quiz 词库传递（doc 51）：拼写 / 选择题控制器向 UseCase 传递的
///    wordBookId 与当前词库一致，不存在串库。
void main() {
  group('Review 按 wordBookId 隔离（doc 49 / 50）', () {
    test('cet6:1 与 cet4:1 是两条独立记录，反馈不同互不影响', () async {
      final reviewRepo = _IsolatedReviewRepository();
      final useCase = ApplyReviewFeedbackUseCase(reviewRepo);

      await useCase.execute(
        wordBookId: 'cet6',
        wordId: '1',
        feedback: FeedbackType.known,
      );
      await useCase.execute(
        wordBookId: 'cet4',
        wordId: '1',
        feedback: FeedbackType.unknown,
      );

      final cet6 = await reviewRepo.getWordReview('1', 'cet6');
      final cet4 = await reviewRepo.getWordReview('1', 'cet4');

      expect(cet6, isNotNull);
      expect(cet4, isNotNull);
      expect(cet6!.wordBookId, 'cet6');
      expect(cet4!.wordBookId, 'cet4');
      // known 与 unknown 的掌握度不同，证明两条记录独立演进
      expect(cet6.mastery, isNot(cet4.mastery));
    });

    test('更新 cet4:1 不改变 cet6:1 的复习记录', () async {
      final reviewRepo = _IsolatedReviewRepository();
      final useCase = ApplyReviewFeedbackUseCase(reviewRepo);

      // CET-6 连续答对两次
      await useCase.execute(
        wordBookId: 'cet6',
        wordId: '1',
        feedback: FeedbackType.known,
      );
      await useCase.execute(
        wordBookId: 'cet6',
        wordId: '1',
        feedback: FeedbackType.known,
      );
      final cet6Before = await reviewRepo.getWordReview('1', 'cet6');

      // CET-4 答错，不应影响 CET-6 的间隔
      await useCase.execute(
        wordBookId: 'cet4',
        wordId: '1',
        feedback: FeedbackType.unknown,
      );

      final cet6After = await reviewRepo.getWordReview('1', 'cet6');
      expect(
        cet6After!.interval,
        cet6Before!.interval,
        reason: 'CET-4 的反馈不能改写 CET-6 的 SM-2 状态',
      );
      expect(cet6After.repetitionCount, cet6Before.repetitionCount);
    });
  });

  group('Quiz 提交传递当前词库（doc 51）', () {
    test('拼写复习 cet4 提交 → UseCase 收到 cet4', () async {
      final words = _makeWords('cet4');
      final reviewRepo = _IsolatedReviewRepository()
        ..addDue('w1', wordBookId: 'cet4');
      final useCase = _CaptureUseCase();
      final controller = SpellingQuizController(
        _FakeWordRepository(words),
        reviewRepo,
        useCase,
      );

      await controller.startQuiz('cet4');
      await controller.submitAnswer('ability');

      expect(useCase.lastWordBookId, 'cet4', reason: '拼写提交不能写回其他词库');
      expect(useCase.lastWordId, 'w1');
      expect(useCase.lastFeedback, FeedbackType.known);
    });

    test('选择题 cet4 提交 → UseCase 收到 cet4', () async {
      final words = _makeWords('cet4');
      final reviewRepo = _IsolatedReviewRepository()
        ..addDue('w1', wordBookId: 'cet4');
      final useCase = _CaptureUseCase();
      final controller = MultipleChoiceController(
        _FakeWordRepository(words),
        reviewRepo,
        useCase,
        questionGenerator: QuestionGenerator(Random(42)),
      );

      await controller.startQuiz('cet4');
      final question = controller.state.currentQuestion!;
      await controller.selectOption(question.correctIndex);

      expect(useCase.lastWordBookId, 'cet4', reason: '选择题提交不能写回其他词库');
      expect(useCase.lastWordId, 'w1');
    });
  });
}

/// 构造测试用词（wordBookId 参数保留但内容一致，供干扰项生成）。
List<Word> _makeWords(String wordBookId) {
  Word w(String id, String word, String pos, String def) => Word(
    id: id,
    word: word,
    phonetic: '/test/',
    meaning: [
      MeaningEntry(pos: pos, definitions: [def]),
    ],
    example: ['This is a test sentence.'],
    audio: '',
    wordBookId: wordBookId,
  );

  return [
    w('w1', 'ability', 'n.', '能力'),
    w('w2', 'achieve', 'v.', '实现'),
    w('w3', 'accurate', 'adj.', '准确的'),
    w('w4', 'ancient', 'adj.', '古代的'),
  ];
}

/// Fake ReviewRepository：内存存储按 wordBookId:wordId 隔离。
class _IsolatedReviewRepository implements ReviewRepository {
  final Map<String, WordReview> _store = {};
  final Map<String, Set<String>> _dueByBook = {};

  void addDue(String wordId, {String wordBookId = 'test'}) {
    _dueByBook.putIfAbsent(wordBookId, () => {}).add(wordId);
  }

  @override
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async {
    return _store['$wordBookId:$wordId'];
  }

  @override
  Future<void> saveWordReview(WordReview review) async {
    _store['${review.wordBookId}:${review.wordId}'] = review;
  }

  @override
  Future<List<WordReview>> getDueReviews(String wordBookId) async {
    final dueIds = _dueByBook[wordBookId] ?? {};
    return dueIds.map((id) {
      return _store['$wordBookId:$id'] ??
          WordReview(
            wordId: id,
            wordBookId: wordBookId,
            repetitionCount: 0,
            easinessFactor: 2.5,
            interval: 0,
            nextReviewDate: DateTime.now(),
            lastReviewDate: null,
            learned: false,
            mastery: 0.0,
          );
    }).toList();
  }

  @override
  Future<int> getLearnedCount(String wordBookId) async => 0;

  @override
  Future<int> getMasteredCount(String wordBookId) async => 0;

  @override
  Future<Set<String>> getAllReviewIds(String wordBookId) async => {};

  @override
  Future<List<WordReview>> getAllReviews(String wordBookId) async {
    return _store.values.where((r) => r.wordBookId == wordBookId).toList();
  }

  @override
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async {
    for (final review in reviews) {
      _store['${review.wordBookId}:${review.wordId}'] = review;
    }
  }

  @override
  Future<int> getReviewedCount(String wordBookId) async => 0;

  @override
  Future<void> deleteReviewsByWordBookId(String wordBookId) async {}
}

/// Fake WordRepository：返回固定单词列表。
class _FakeWordRepository implements WordRepository {
  _FakeWordRepository(this._words);

  final List<Word> _words;

  @override
  Future<List<Word>> getWords(String wordBookId) async => _words;

  @override
  Future<int> getWordCount(String wordBookId) async => _words.length;

  @override
  Future<Word?> getWordById(String wordBookId, String wordId) async {
    for (final w in _words) {
      if (w.id == wordId) return w;
    }
    return null;
  }

  @override
  void clearCache() {}
}

/// Fake UseCase：捕获 wordBookId / wordId / feedback，不真正持久化。
class _CaptureUseCase implements ApplyReviewFeedbackUseCase {
  String? lastWordBookId;
  String? lastWordId;
  FeedbackType? lastFeedback;

  @override
  Future<WordReview> execute({
    required String wordBookId,
    required String wordId,
    required FeedbackType feedback,
  }) async {
    lastWordBookId = wordBookId;
    lastWordId = wordId;
    lastFeedback = feedback;
    return WordReview(
      wordId: wordId,
      wordBookId: wordBookId,
      repetitionCount: 1,
      easinessFactor: 2.5,
      interval: 1,
      nextReviewDate: DateTime.now().add(const Duration(days: 1)),
      lastReviewDate: DateTime.now(),
      learned: false,
      mastery: 0.1,
    );
  }
}

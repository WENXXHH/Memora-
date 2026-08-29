import 'package:flutter_test/flutter_test.dart';
import 'package:memora/data/dto/custom_word_record_model.dart';
import 'package:memora/data/dto/word_model.dart';
import 'package:memora/data/dto/word_review_model.dart';
import 'package:memora/data/repositories/custom_word_repository.dart';
import 'package:memora/data/repositories/review_repository.dart';
import 'package:memora/features/custom_word_book/controller/custom_word_management_controller.dart';

/// CustomWordManagementController 单元测试（doc 64 / 44 / 45 / 23）。
///
/// 覆盖：
/// 1. load → state.words
/// 2. create 成功：英文 trim + lowercase 标准化（doc 44），生成默认 MeaningEntry（doc 12）
/// 3. create 空英文 / 空释义 / 重复英文（doc 45）
/// 4. update 成功：id 不变（doc 19），排除自身重复校验（doc 45）
/// 5. delete → 单词 + WordReview 一起删除（doc 23 / 89）
void main() {
  late _FakeCustomWordRepository wordRepo;
  late _FakeReviewRepository reviewRepo;
  late CustomWordManagementController controller;

  setUp(() {
    wordRepo = _FakeCustomWordRepository();
    reviewRepo = _FakeReviewRepository();
    controller = CustomWordManagementController(
      wordRepo,
      reviewRepo,
      'custom_abc',
    );
  });

  group('load（doc 64）', () {
    test('加载当前词库全部单词', () async {
      wordRepo.records.add(_record('w1', 'custom_abc', 'abandon'));
      wordRepo.records.add(_record('w2', 'custom_abc', 'ability'));

      await controller.load();

      expect(controller.state.isLoading, false);
      expect(controller.state.words.length, 2);
      expect(controller.state.errorMessage, isNull);
    });
  });

  group('create（doc 44 / 45 / 12）', () {
    test('成功 → 英文 trim + lowercase 标准化存储', () async {
      final record = await controller.create(
        word: '  Abandon ',
        phonetic: '',
        meaningChinese: '放弃',
        example: 'A test sentence.',
      );

      expect(record, isNotNull);
      expect(record!.word, 'abandon', reason: '英文 trim + lowercase（doc 44）');
      expect(record.wordBookId, 'custom_abc');
      expect(record.meaning.single.pos, '', reason: '表单只输入中文释义（doc 12）');
      expect(record.meaning.single.definitions, ['放弃']);
      expect(record.example, ['A test sentence.']);
      expect(controller.state.errorMessage, isNull);
    });

    test('空英文 → null + errorMessage', () async {
      final record = await controller.create(
        word: '   ',
        phonetic: '',
        meaningChinese: '放弃',
        example: '',
      );

      expect(record, isNull);
      expect(controller.state.errorMessage, '英文不能为空');
    });

    test('空释义 → null + errorMessage（doc 43）', () async {
      final record = await controller.create(
        word: 'abandon',
        phonetic: '',
        meaningChinese: '  ',
        example: '',
      );

      expect(record, isNull);
      expect(controller.state.errorMessage, '中文释义不能为空');
    });

    test('同词库重复英文（大小写 / 空格差异）→ 拒绝（doc 45）', () async {
      await controller.create(
        word: 'abandon',
        phonetic: '',
        meaningChinese: '放弃',
        example: '',
      );

      final dup = await controller.create(
        word: '  ABANDON ',
        phonetic: '',
        meaningChinese: '抛弃',
        example: '',
      );

      expect(dup, isNull);
      expect(controller.state.errorMessage, '该词库已存在此单词');
    });
  });

  group('update（doc 19 / 45 / 80）', () {
    test('成功 → id 不变，内容更新', () async {
      final created = await controller.create(
        word: 'abandon',
        phonetic: '',
        meaningChinese: '放弃',
        example: '',
      );

      final updated = await controller.update(
        wordId: created!.id,
        word: 'abandon',
        phonetic: '/əˈbændən/',
        meaningChinese: '抛弃',
        example: 'New example.',
      );

      expect(updated, isNotNull);
      expect(updated!.id, created.id, reason: '单词 ID 编辑后保持不变（doc 19）');
      expect(updated.meaning.single.definitions, ['抛弃']);
    });

    test('编辑为自身当前英文 → 成功（排除自身，doc 45）', () async {
      final created = await controller.create(
        word: 'abandon',
        phonetic: '',
        meaningChinese: '放弃',
        example: '',
      );

      final updated = await controller.update(
        wordId: created!.id,
        word: 'abandon',
        phonetic: '',
        meaningChinese: '放弃',
        example: '',
      );

      expect(updated, isNotNull);
      expect(controller.state.errorMessage, isNull);
    });

    test('编辑为其他单词的英文 → 拒绝', () async {
      await controller.create(
        word: 'abandon',
        phonetic: '',
        meaningChinese: '放弃',
        example: '',
      );
      final second = await controller.create(
        word: 'bold',
        phonetic: '',
        meaningChinese: '勇敢的',
        example: '',
      );

      final updated = await controller.update(
        wordId: second!.id,
        word: 'abandon',
        phonetic: '',
        meaningChinese: '大胆的',
        example: '',
      );

      expect(updated, isNull);
      expect(controller.state.errorMessage, '该词库已存在此单词');
    });
  });

  group('delete（doc 23 / 89）', () {
    test('删除单词 → 同步删除该词 WordReview', () async {
      final created = await controller.create(
        word: 'abandon',
        phonetic: '',
        meaningChinese: '放弃',
        example: '',
      );
      wordRepo.records.add(_record('other', 'custom_abc', 'bold'));

      final ok = await controller.delete(created!.id);

      expect(ok, isTrue);
      expect(wordRepo.deletedKeys, contains('custom_abc:${created.id}'));
      expect(reviewRepo.deletedKeys, contains('custom_abc:${created.id}'));
      expect(
        wordRepo.records.map((r) => r.id),
        isNot(contains(created.id)),
        reason: '列表刷新后已删除的单词不再出现',
      );
      expect(controller.state.errorMessage, isNull);
    });
  });

  group('validateWord（doc 45 即时校验）', () {
    test('基于当前 state 判重', () async {
      await controller.create(
        word: 'abandon',
        phonetic: '',
        meaningChinese: '放弃',
        example: '',
      );

      expect(controller.validateWord('Abandon'), '该词库已存在此单词');
      expect(controller.validateWord('bold'), isNull);
    });
  });
}

/// 构造指定词库 / id 的测试记录。
CustomWordRecord _record(String id, String wordBookId, String word) {
  return CustomWordRecord(
    id: id,
    wordBookId: wordBookId,
    word: word,
    phonetic: '',
    meaning: const [
      MeaningEntry(pos: '', definitions: ['测试']),
    ],
    example: const [],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
}

/// Fake 单词仓库：内存列表 + 记录删除的联合 Key。
class _FakeCustomWordRepository implements CustomWordRepository {
  final List<CustomWordRecord> records = [];
  final List<String> deletedKeys = [];

  @override
  Future<List<CustomWordRecord>> getAll(String wordBookId) async =>
      records.where((r) => r.wordBookId == wordBookId).toList();

  @override
  Future<CustomWordRecord?> getById(String wordBookId, String wordId) async {
    for (final record in records) {
      if (record.wordBookId == wordBookId && record.id == wordId) {
        return record;
      }
    }
    return null;
  }

  @override
  Future<CustomWordRecord> create({
    required String wordBookId,
    required String word,
    required String phonetic,
    required List<MeaningEntry> meaning,
    required List<String> example,
  }) async {
    final record = CustomWordRecord(
      id: 'w${records.length + 1}',
      wordBookId: wordBookId,
      word: word,
      phonetic: phonetic,
      meaning: meaning,
      example: example,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    records.add(record);
    return record;
  }

  @override
  Future<CustomWordRecord> update({
    required String wordBookId,
    required String wordId,
    required String word,
    required String phonetic,
    required List<MeaningEntry> meaning,
    required List<String> example,
  }) async {
    final index = records.indexWhere(
      (r) => r.wordBookId == wordBookId && r.id == wordId,
    );
    final updated = records[index].copyWith(
      word: word,
      phonetic: phonetic,
      meaning: meaning,
      example: example,
      updatedAt: DateTime(2026, 1, 2),
    );
    records[index] = updated;
    return updated;
  }

  @override
  Future<void> delete(String wordBookId, String wordId) async {
    deletedKeys.add('$wordBookId:$wordId');
    records.removeWhere((r) => r.wordBookId == wordBookId && r.id == wordId);
  }

  @override
  Future<void> deleteByWordBookId(String wordBookId) async {
    records.removeWhere((r) => r.wordBookId == wordBookId);
  }

  @override
  Future<List<Word>> toWords(String wordBookId) async => [];
}

/// Fake Review 仓库：记录按联合 Key 删除的调用。
class _FakeReviewRepository implements ReviewRepository {
  final List<String> deletedKeys = [];

  @override
  Future<WordReview?> getWordReview(String wordId, String wordBookId) async =>
      null;

  @override
  Future<void> saveWordReview(WordReview review) async {}

  @override
  Future<List<WordReview>> getDueReviews(String wordBookId) async => [];

  @override
  Future<int> getLearnedCount(String wordBookId) async => 0;

  @override
  Future<int> getMasteredCount(String wordBookId) async => 0;

  @override
  Future<Set<String>> getAllReviewIds(String wordBookId) async => {};

  @override
  Future<List<WordReview>> getAllReviews(String wordBookId) async => [];

  @override
  Future<void> saveWordReviews(Iterable<WordReview> reviews) async {}

  @override
  Future<int> getReviewedCount(String wordBookId) async => 0;

  @override
  Future<void> deleteReviewsByWordBookId(String wordBookId) async {}

  @override
  Future<void> deleteReview(String wordBookId, String wordId) async {
    deletedKeys.add('$wordBookId:$wordId');
  }
}

import 'package:injectable/injectable.dart';
import '../../../domain/enums/learning_enums.dart';
import '../../models/ai_suggestion_request.dart';
import '../ai_suggestion_data_source.dart';

/// Mock AI 助记数据源 — 模拟 AI 流式返回
///
/// 使用 async* + yield 逐块返回增量文本片段，
/// 每块之间间隔 180ms，模拟真实 AI 流式响应的打字机效果。
///
/// 每个 yield 事件只包含**本次新增的文本片段**，
/// 不包含此前已返回的内容，由 Controller 层负责累加。
@Injectable(as: AiSuggestionDataSource)
class MockAiSuggestionSource implements AiSuggestionDataSource {
  @override
  Stream<String> generateSuggestion(AiSuggestionRequest request) async* {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    yield '联想：';

    await Future<void>.delayed(const Duration(milliseconds: 180));
    yield '${request.word} ';

    await Future<void>.delayed(const Duration(milliseconds: 180));
    final word = request.word;
    final chunks = _generateMockMnemonic(word, request.meaning);
    for (final chunk in chunks) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      yield chunk;
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    yield '\n例句：';

    await Future<void>.delayed(const Duration(milliseconds: 180));
    yield request.example;

    await Future<void>.delayed(const Duration(milliseconds: 250));
    yield '\n提示：';

    await Future<void>.delayed(const Duration(milliseconds: 180));
    yield _getMockHint(request);
  }

  /// 根据单词生成简单的 Mock 助记文本块
  List<String> _generateMockMnemonic(String word, String meaning) {
    // 简单的助记策略：取单词前几个字母做联想
    if (word.length >= 3) {
      final prefix = word.substring(0, 3);
      return [
        '可以拆分记忆：',
        '「$prefix」+「${word.substring(3)}」',
        '，意为「$meaning」。',
      ];
    }
    return ['可以结合拼写「$word」和发音来记忆，意为「$meaning」。'];
  }

  /// 生成 Mock 学习提示
  String _getMockHint(AiSuggestionRequest request) {
    switch (request.feedbackType) {
      case FeedbackType.known:
        return '已掌握，建议定期复习巩固。';
      case FeedbackType.fuzzy:
        return '印象模糊，建议多看例句加深理解。';
      case FeedbackType.unknown:
        return '新词初学，建议先记核心词义，再结合例句逐步掌握。';
    }
  }
}

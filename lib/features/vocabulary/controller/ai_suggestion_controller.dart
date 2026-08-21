import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/ai_suggestion_state.dart';
import '../../../data/repositories/ai_suggestion_repository.dart';
import '../../../domain/entities/ai_suggestion_request.dart';
import '../../../domain/enums/ai_enums.dart';

/// AI 助记生成控制器
///
/// 管理流式 AI 助记内容的生成生命周期：
/// - 发起生成请求
/// - 取消旧请求并开始新请求
/// - 通过 requestId 防止旧事件回写
/// - 累加增量文本片段
/// - 处理完成/错误状态
/// - dispose 时取消订阅
class AiSuggestionController extends StateNotifier<AiSuggestionState> {
  final AiSuggestionRepository _repository;
  StreamSubscription<String>? _subscription;
  int _requestId = 0;

  AiSuggestionController(this._repository) : super(const AiSuggestionState());

  /// 生成 AI 助记内容
  ///
  /// [request] 包含单词上下文和用户反馈类型
  Future<void> generate(AiSuggestionRequest request) async {
    // 取消旧请求
    await _cancelSubscription();

    // 新请求 ID，防止旧事件回写
    final currentRequestId = ++_requestId;

    state = const AiSuggestionState(status: AiSuggestionStatus.loading);

    final stream = _repository.generateSuggestion(request);

    _subscription = stream.listen(
      (chunk) {
        // 如果已有更新的请求，忽略这个事件
        if (currentRequestId != _requestId) return;

        state = state.copyWith(
          status: AiSuggestionStatus.streaming,
          text: state.text + chunk,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (currentRequestId != _requestId) return;

        state = AiSuggestionState(
          status: AiSuggestionStatus.error,
          errorMessage: '助记内容生成失败，请重试',
        );
      },
      onDone: () {
        if (currentRequestId != _requestId) return;

        state = state.copyWith(status: AiSuggestionStatus.success);
      },
    );
  }

  /// 取消当前生成，回到 idle 状态
  Future<void> cancel() async {
    await _cancelSubscription();
    state = const AiSuggestionState(status: AiSuggestionStatus.idle);
  }

  /// 重置到初始状态（用于切换单词时清空旧内容）
  void reset() {
    _cancelSubscription();
    state = const AiSuggestionState(status: AiSuggestionStatus.idle);
  }

  Future<void> _cancelSubscription() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    _cancelSubscription();
    super.dispose();
  }
}

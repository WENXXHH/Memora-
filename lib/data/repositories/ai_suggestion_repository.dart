import 'package:injectable/injectable.dart';
import '../sources/ai_suggestion_data_source.dart';
import '../../domain/entities/ai_suggestion_request.dart';

/// AI 助记仓库
///
/// 封装 AI 助记数据源调用，为业务层提供统一接口。
/// 当前很薄，但为将来的缓存、日志、重试、请求去重预留了扩展空间。
@injectable
class AiSuggestionRepository {
  final AiSuggestionDataSource _dataSource;

  AiSuggestionRepository(this._dataSource);

  /// 生成助记建议
  ///
  /// [request] 包含单词上下文和反馈类型
  /// 返回增量文本片段流
  Stream<String> generateSuggestion(AiSuggestionRequest request) {
    return _dataSource.generateSuggestion(request);
  }
}

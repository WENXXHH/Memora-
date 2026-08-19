import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/dependency_injection.dart';
import '../data/repositories/word_repository.dart';
import '../data/repositories/review_repository.dart';

/// 全局 Provider：DI 容器
final getItProvider = Provider((ref) => getIt);

/// 全局 Provider：单词仓库
final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return ref.read(getItProvider).get<WordRepository>();
});

// 全局 Provider：复习记录仓库
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ref.read(getItProvider).get<ReviewRepository>();
});

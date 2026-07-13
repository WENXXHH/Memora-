import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dependency_injection.dart';
import '../data/repositories/word_repository.dart';
//全局provider
final getItProvider = Provider((ref) => getIt);

final wordRepositoryProvider = Provider<WordRepository>((ref) {
  return ref.read(getItProvider).get<WordRepository>();
});

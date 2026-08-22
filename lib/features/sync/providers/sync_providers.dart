/// 同步相关 Riverpod Provider。
///
/// 手动组装依赖链（与 auth_providers.dart 模式一致）：
/// dioProvider → ReviewSyncRemoteDataSource → ReviewSyncRepository
/// → SyncReviewRecordsUseCase → SyncController
///
/// 原则 15：复用第五周 dioProvider + AuthInterceptor，不创建第二套网络。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/review_sync_repository.dart';
import '../../../data/sources/remote/review_sync_remote_data_source.dart';
import '../../../domain/use_cases/sync_review_records_use_case.dart';
import '../../../providers/network_providers.dart';
import '../../../providers/repository_providers.dart';
import '../controller/sync_controller.dart';
import '../state/sync_state.dart';

/// 远程同步数据源 Provider。
///
/// 复用 [dioProvider]（原则 15），Token 由 AuthInterceptor 自动注入。
final reviewSyncRemoteDataSourceProvider =
    Provider<ReviewSyncRemoteDataSource>((ref) {
      final dio = ref.read(dioProvider);
      return ReviewSyncRemoteDataSource(dio);
    });

/// 同步仓库 Provider。
final reviewSyncRepositoryProvider = Provider<ReviewSyncRepository>((ref) {
  return ReviewSyncRepository(ref.read(reviewSyncRemoteDataSourceProvider));
});

/// 同步 UseCase Provider。
///
/// 依赖：
/// - [reviewRepositoryProvider]：本地 Hive 读写
/// - [wordRepositoryProvider]：本地单词列表（构建 WordIdMap）
/// - [reviewSyncRepositoryProvider]：远端 HTTP 调用
final syncReviewRecordsUseCaseProvider = Provider<SyncReviewRecordsUseCase>((
  ref,
) {
  return SyncReviewRecordsUseCase(
    ref.read(reviewRepositoryProvider),
    ref.read(wordRepositoryProvider),
    ref.read(reviewSyncRepositoryProvider),
  );
});

/// 同步控制器 Provider。
///
/// 不是 autoDispose：同步状态需在 App 生命周期内保持。
final syncControllerProvider = StateNotifierProvider<SyncController, SyncState>((
  ref,
) {
  return SyncController(ref.read(syncReviewRecordsUseCaseProvider));
});

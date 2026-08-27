import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/repository_providers.dart';
import '../controller/custom_word_book_management_controller.dart';
import '../state/custom_word_book_management_state.dart';

/// 自建词库管理相关 Provider。

/// 自建词库管理控制器 Provider。
///
/// 非 autoDispose：管理页与表单页共享同一实例（doc 65），
/// 表单页 create/rename/delete 后管理页 watch 的 State 自动刷新，
/// 避免"返回后仍是旧列表"。
final customWordBookManagementControllerProvider =
    StateNotifierProvider<
      CustomWordBookManagementController,
      CustomWordBookManagementState
    >((ref) {
      return CustomWordBookManagementController(
        ref.watch(customWordBookRepositoryProvider),
        ref.watch(deleteCustomWordBookUseCaseProvider),
      );
    });

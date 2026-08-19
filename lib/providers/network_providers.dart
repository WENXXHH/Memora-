/// 网络层 Riverpod Provider。
///
/// 配合 get_it + Riverpod 双体系：
/// - Box 实例由 [HiveInitializer] 打开后注册到 getIt
/// - 这里通过 [getItProvider] 取出 Box，再用 Riverpod 暴露 Dio
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

import '../core/network/dio_factory.dart';
import '../core/storage/hive_initializer.dart';
import 'repository_providers.dart';

/// 全局 Dio Provider。
///
/// Feature 层通过 `ref.read(dioProvider)` 获取 Dio，
/// 不要在 Repository 内部 new Dio，否则无法被测试替换。
final dioProvider = Provider<Dio>((ref) {
  final authBox = ref.read(getItProvider).get<Box<String>>(
    instanceName: HiveInitializer.authBoxName,
  );
  return createDio(
    authBox: authBox,
    // TODO(wen): 接入登录页后，在此处注册 401 跳转回调
    // 暂时留空，由后续 W5 8/6 接入登录流程时补全
    onUnauthorized: null,
  );
});

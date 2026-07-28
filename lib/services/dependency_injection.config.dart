// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive_ce/hive_ce.dart' as _i1055;
import 'package:injectable/injectable.dart' as _i526;

import '../data/repositories/review_repository.dart' as _i501;
import '../data/repositories/word_repository.dart' as _i237;
import '../data/sources/local/mock_word_source.dart' as _i557;
import '../data/sources/local/review_local_source.dart' as _i293;
import '../data/sources/word_data_source.dart' as _i832;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i293.ReviewLocalDataSource>(
      () =>
          _i293.ReviewLocalDataSource(gh<_i1055.Box<Map<dynamic, dynamic>>>()),
    );
    gh.factory<_i832.WordDataSource>(() => _i557.MockWordSource());
    gh.factory<_i501.ReviewRepository>(
      () => _i501.ReviewRepository(gh<_i293.ReviewLocalDataSource>()),
    );
    gh.factory<_i237.WordRepository>(
      () => _i237.WordRepository(gh<_i832.WordDataSource>()),
    );
    return this;
  }
}

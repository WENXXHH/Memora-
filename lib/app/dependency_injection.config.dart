// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_tts/flutter_tts.dart' as _i50;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive_ce/hive_ce.dart' as _i1055;
import 'package:injectable/injectable.dart' as _i526;

import '../core/services/tts/flutter_tts_service.dart' as _i1021;
import '../core/services/tts/tts_module.dart' as _i838;
import '../core/services/tts/tts_service.dart' as _i931;
import '../data/repositories/ai_suggestion_repository.dart' as _i796;
import '../data/repositories/custom_word_book_repository.dart' as _i456;
import '../data/repositories/review_repository.dart' as _i501;
import '../data/repositories/word_repository.dart' as _i237;
import '../data/sources/ai_suggestion_data_source.dart' as _i740;
import '../data/sources/local/custom_word_book_local_source.dart' as _i821;
import '../data/sources/local/mock_ai_suggestion_source.dart' as _i317;
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
    final ttsModule = _$TtsModule();
    gh.lazySingleton<_i50.FlutterTts>(() => ttsModule.flutterTts);
    gh.factory<_i740.AiSuggestionDataSource>(
      () => _i317.MockAiSuggestionSource(),
    );
    gh.factory<_i293.ReviewLocalDataSource>(
      () =>
          _i293.ReviewLocalDataSource(gh<_i1055.Box<Map<dynamic, dynamic>>>()),
    );
    gh.lazySingleton<_i931.TtsService>(
      () => _i1021.FlutterTtsService(gh<_i50.FlutterTts>()),
    );
    gh.factory<_i796.AiSuggestionRepository>(
      () => _i796.AiSuggestionRepository(gh<_i740.AiSuggestionDataSource>()),
    );
    gh.factory<_i821.CustomWordBookLocalSource>(
      () => _i821.CustomWordBookLocalSource(
        gh<_i1055.Box<Map<dynamic, dynamic>>>(
          instanceName: 'custom_word_books',
        ),
      ),
    );
    gh.factory<_i832.WordDataSource>(() => _i557.MockWordSource());
    gh.factory<_i456.CustomWordBookRepository>(
      () =>
          _i456.CustomWordBookRepository(gh<_i821.CustomWordBookLocalSource>()),
    );
    gh.factory<_i501.ReviewRepository>(
      () => _i501.ReviewRepository(gh<_i293.ReviewLocalDataSource>()),
    );
    gh.factory<_i237.WordRepository>(
      () => _i237.WordRepository(gh<_i832.WordDataSource>()),
    );
    return this;
  }
}

class _$TtsModule extends _i838.TtsModule {}

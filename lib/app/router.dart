import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/pages/home_screen.dart';
import '../features/vocabulary/pages/word_list_page.dart';
import '../features/vocabulary/pages/Word_Detail_Page.dart';
import '../components/PlaceholderPage.dart';
import '../data/models/word_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/learning',
        name: 'learning',
        builder: (context, state) => const PlaceholderPage(title: '学习页'),
      ),
      GoRoute(
        path: '/review',
        name: 'review',
        builder: (context, state) => const PlaceholderPage(title: '复习页'),
      ),
      GoRoute(
        path: '/vocabulary',
        name: 'vocabulary',
        builder: (context, state) {
          final wordBookId = state.uri.queryParameters['wordBookId'] ?? 'cet6';
          final title = state.uri.queryParameters['title'] ?? '词库';
          return WordListPage(wordBookId: wordBookId, title: title);
        },
      ),
      GoRoute(
        path: '/detail',
        name: 'detail',
        builder: (context, state) {
          final word = state.extra as Word;
          return WordDetailPage(word: word);
        },
      ),
    ],
  );
});

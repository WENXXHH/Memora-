import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/pages/home_screen.dart';
import '../features/vocabulary/pages/word_list_page.dart';
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
        builder: (context, state) => const _PlaceholderPage(title: '学习页'),
      ),
      GoRoute(
        path: '/review',
        name: 'review',
        builder: (context, state) => const _PlaceholderPage(title: '复习页'),
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
          return _WordDetailPage(word: word);
        },
      ),
    ],
  );
});

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WordDetailPage extends StatelessWidget {
  final Word word;

  const _WordDetailPage({required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(word.word)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word.word,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              word.phonetic,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            const Text('释义:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...word.meaning.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('${m.pos} ${m.definitions.join('、')}'),
                )),
            const SizedBox(height: 16),
            const Text('例句:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...word.example.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(e),
                )),
          ],
        ),
      ),
    );
  }
}
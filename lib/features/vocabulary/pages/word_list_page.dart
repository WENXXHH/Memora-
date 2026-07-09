import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../components/word_card.dart';
import '../controller/word_list_controller.dart';

class WordListPage extends ConsumerStatefulWidget {
  final String wordBookId;
  final String title;

  const WordListPage({
    super.key,
    this.wordBookId = 'cet6',
    this.title = '词库',
  });

  @override
  ConsumerState<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends ConsumerState<WordListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(wordListControllerProvider(widget.wordBookId).notifier).loadWords(widget.wordBookId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wordListState = ref.watch(wordListControllerProvider(widget.wordBookId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: wordListState.isLoading
          ? _buildLoading()
          : wordListState.hasError
              ? _buildError(wordListState.errorMessage)
              : wordListState.filteredWords.isEmpty
                  ? _buildEmpty(wordListState.searchQuery)
                  : _buildContent(wordListState),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String? message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '加载失败',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(wordListControllerProvider(widget.wordBookId).notifier).loadWords(widget.wordBookId),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(String searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty ? '未找到匹配的单词' : '暂无单词数据',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WordListState state) {
    return Column(
      children: [
        _buildSearchBar(state.searchQuery),
        Expanded(
          child: ListView.builder(
            itemCount: state.filteredWords.length,
            itemBuilder: (context, index) {
              final word = state.filteredWords[index];
              return WordCard(word: word);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(String currentQuery) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => ref.read(wordListControllerProvider(widget.wordBookId).notifier).search(value),
        decoration: InputDecoration(
          hintText: '搜索单词或释义',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: currentQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(wordListControllerProvider(widget.wordBookId).notifier).search('');
                  },
                )
              : null,
        ),
      ),
    );
  }
}
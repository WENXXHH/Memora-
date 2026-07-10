import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/word_card.dart';
import '../controller/word_list_controller.dart';

/// 单词列表页面
///
/// 展示指定词库的单词列表，支持搜索过滤功能
/// 使用 ConsumerStatefulWidget 监听 Riverpod 状态变化
class WordListPage extends ConsumerStatefulWidget {
  /// 词库标识，默认 cet6
  final String wordBookId;

  /// 页面标题，默认 '词库'
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
  /// 搜索框控制器
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 使用 Future.microtask 延迟加载，避免在 widget 树构建期间修改状态
    // 这是解决 "State modifications during build" 错误的关键
    Future.microtask(() {
      ref.read(wordListControllerProvider(widget.wordBookId).notifier).loadWords(widget.wordBookId);
    });
  }

  @override
  void dispose() {
    // 释放搜索框控制器资源
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 监听单词列表状态变化
    final wordListState = ref.watch(wordListControllerProvider(widget.wordBookId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      // 状态驱动的 UI 渲染：加载中 → 错误 → 空数据 → 正常内容
      body: wordListState.isLoading
          ? _buildLoading()
          : wordListState.hasError
              ? _buildError(wordListState.errorMessage)
              : wordListState.filteredWords.isEmpty
                  ? _buildEmpty(wordListState.searchQuery)
                  : _buildContent(wordListState),
    );
  }

  /// 构建加载状态 UI
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// 构建错误状态 UI
  ///
  /// [message] 错误信息，为空时显示默认提示
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

  /// 构建空数据状态 UI
  ///
  /// [searchQuery] 当前搜索关键词，用于区分是搜索无结果还是初始空数据
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

  /// 构建正常内容 UI
  ///
  /// 包含搜索栏和单词列表
  Widget _buildContent(WordListState state) {
    return Column(
      children: [
        _buildSearchBar(state.searchQuery),
        Expanded(
          // 使用 ListView.builder 懒加载渲染，优化性能
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

  /// 构建搜索栏
  ///
  /// [currentQuery] 当前搜索关键词，用于控制清除按钮的显示
  Widget _buildSearchBar(String currentQuery) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        // 实时搜索：输入变化时触发过滤
        onChanged: (value) => ref.read(wordListControllerProvider(widget.wordBookId).notifier).search(value),
        decoration: InputDecoration(
          hintText: '搜索单词或释义',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // 搜索关键词非空时显示清除按钮
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
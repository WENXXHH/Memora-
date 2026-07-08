import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/home_controller.dart';
import '../widgets/today_task_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/statistics_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(homeControllerProvider.notifier).loadData();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memora'),
        centerTitle: true,
        elevation: 0,
      ),
      body: homeState.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGreeting(),
                  const SizedBox(height: 24),
                  TodayTaskCard(
                    reviewCount: homeState.reviewCount,
                    learnedCount: homeState.learnedCount,
                  ),
                  const SizedBox(height: 24),
                  const QuickActions(),
                  const SizedBox(height: 24),
                  StatisticsCard(
                    totalWords: homeState.totalWords,
                    masteredWords: homeState.masteredWords,
                    streakDays: homeState.streakDays,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGreeting() {
    return const Text(
      '你好，学习者！',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}
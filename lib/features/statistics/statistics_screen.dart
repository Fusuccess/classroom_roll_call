import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/student_provider.dart';
import '../../core/providers/call_record_provider.dart';
import '../../core/providers/class_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? selectedClassId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classes = ref.watch(classProvider);
    final allStudents = ref.watch(studentProvider);
    final allRecords = ref.watch(callRecordProvider);

    // 过滤数据
    final students = selectedClassId == null
        ? allStudents
        : allStudents.where((s) => s.classId == selectedClassId).toList();
    
    final records = selectedClassId == null
        ? allRecords
        : allRecords.where((r) {
            final student = allStudents.firstWhere(
              (s) => s.id == r.studentId,
              orElse: () => allStudents.first,
            );
            return student.classId == selectedClassId;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('统计分析'),
        actions: [
          if (classes.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: '筛选班级',
              onSelected: (value) {
                setState(() {
                  selectedClassId = value == 'all' ? null : value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('全部班级'),
                ),
                const PopupMenuDivider(),
                ...classes.map((c) => PopupMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '总览', icon: Icon(Icons.dashboard)),
            Tab(text: '学生排名', icon: Icon(Icons.leaderboard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context, students, records),
          _buildRankingTab(context, students, records),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    List students,
    List records,
  ) {
    final totalCalls = records.length;
    final scoredRecords = records.where((r) => r.score > 0).toList();
    final totalScore = scoredRecords.fold<int>(0, (sum, r) => sum + (r.score as int));
    final avgScore = scoredRecords.isEmpty
        ? 0.0
        : totalScore / scoredRecords.length;
    final participantCount = students.where((s) => s.callCount > 0).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 班级筛选提示
        if (selectedClassId != null)
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '当前筛选：${ref.watch(classProvider).firstWhere((c) => c.id == selectedClassId).name}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => selectedClassId = null);
                    },
                  ),
                ],
              ),
            ),
          ),
        if (selectedClassId != null) const SizedBox(height: 16),

        // 统计卡片
        _buildStatCard(
          '总点名次数',
          totalCalls.toString(),
          Icons.touch_app,
          Colors.blue,
        ),
        _buildStatCard(
          '平均分数',
          avgScore.toStringAsFixed(1),
          Icons.star,
          Colors.orange,
        ),
        _buildStatCard(
          '参与学生',
          '$participantCount / ${students.length}',
          Icons.people,
          Colors.green,
        ),
        _buildStatCard(
          '已评分',
          '${scoredRecords.length} / $totalCalls',
          Icons.check_circle,
          Colors.purple,
        ),

        const SizedBox(height: 24),

        // 分数分布
        _buildScoreDistribution(scoredRecords),

        const SizedBox(height: 24),

        // 最近点名记录
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '最近点名记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (records.isNotEmpty)
              Text(
                '共 ${records.length} 条',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (records.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('还没有点名记录'),
            ),
          )
        else
          ...records
              .take(10)
              .toList()
              .reversed
              .map((record) => _buildRecordItem(record)),
      ],
    );
  }

  Widget _buildRankingTab(
    BuildContext context,
    List students,
    List records,
  ) {
    // 只显示有点名记录的学生
    final rankedStudents = students
        .where((s) => s.callCount > 0)
        .toList()
      ..sort((a, b) {
        // 先按平均分排序，再按点名次数
        final scoreCompare = b.avgScore.compareTo(a.avgScore);
        if (scoreCompare != 0) return scoreCompare;
        return b.callCount.compareTo(a.callCount);
      });

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (rankedStudents.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.leaderboard, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('还没有学生参与点名'),
                ],
              ),
            ),
          )
        else ...[
          // 前三名特殊显示
          if (rankedStudents.isNotEmpty) _buildTopThree(rankedStudents),
          const SizedBox(height: 24),
          const Text(
            '完整排名',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...rankedStudents.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            return _buildRankingItem(context, student, index + 1);
          }),
        ],
      ],
    );
  }

  Widget _buildTopThree(List students) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '🏆 前三名',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (students.length > 1)
                  _buildPodium(students[1], 2, 100, Colors.grey),
                if (students.isNotEmpty)
                  _buildPodium(students[0], 1, 120, Colors.amber),
                if (students.length > 2)
                  _buildPodium(students[2], 3, 80, Colors.brown),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(student, int rank, double height, Color color) {
    final medals = ['🥇', '🥈', '🥉'];
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            student.name[0],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          student.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '${student.avgScore.toStringAsFixed(1)}分',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              medals[rank - 1],
              style: const TextStyle(fontSize: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingItem(BuildContext context, student, int rank) {
    Color? rankColor;
    if (rank == 1) rankColor = Colors.amber;
    if (rank == 2) rankColor = Colors.grey;
    if (rank == 3) rankColor = Colors.brown;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rankColor?.withOpacity(0.2) ??
              Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            rank.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: rankColor ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(student.name),
        subtitle: Text('点名 ${student.callCount} 次'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  student.avgScore.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDistribution(List scoredRecords) {
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = scoredRecords.where((r) => r.score == i).length;
    }

    final maxCount = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '分数分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (scoredRecords.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('暂无评分数据'),
                ),
              )
            else
              ...List.generate(5, (index) {
                final score = 5 - index;
                final count = distribution[score] ?? 0;
                final percentage = maxCount > 0 ? count / maxCount : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Row(
                          children: [
                            Text(
                              '$score分',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, size: 16, color: Colors.orange),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: percentage,
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _getScoreColor(score),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$count次',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(record) {
    final dateFormat = DateFormat('MM-dd HH:mm');
    final isScored = record.score > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isScored
              ? _getScoreColor(record.score)
              : Colors.grey,
          child: isScored
              ? Text(
                  record.score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Icon(Icons.question_mark, color: Colors.white, size: 16),
        ),
        title: Text(record.studentName),
        subtitle: Text(dateFormat.format(record.timestamp)),
        trailing: isScored
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                  Text(' ${record.score}'),
                ],
              )
            : Text(
                '未评分',
                style: TextStyle(color: Colors.grey[600]),
              ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 4) return Colors.green;
    if (score >= 3) return Colors.orange;
    return Colors.red;
  }
}

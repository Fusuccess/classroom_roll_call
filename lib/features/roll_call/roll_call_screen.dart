import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/student.dart';
import '../../core/models/call_record.dart';
import '../../core/providers/student_provider.dart';
import '../../core/providers/class_provider.dart';
import '../../core/providers/call_record_provider.dart';
import 'widgets/roll_call_history_dialog.dart';
import 'widgets/roll_call_settings_dialog.dart';

class RollCallScreen extends ConsumerStatefulWidget {
  final String classId;

  const RollCallScreen({super.key, required this.classId});

  @override
  ConsumerState<RollCallScreen> createState() => _RollCallScreenState();
}

class _RollCallScreenState extends ConsumerState<RollCallScreen>
    with SingleTickerProviderStateMixin {
  Student? selectedStudent;
  bool isAnimating = false;
  List<String> calledStudentIds = []; // 本次已点名的学生
  bool avoidRepeat = true; // 避免重复点名
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(studentProvider);
    final classStudents = students
        .where((s) => s.classId == widget.classId)
        .toList();
    final classGroup = ref
        .watch(classProvider)
        .firstWhere((c) => c.id == widget.classId);

    return Scaffold(
      appBar: AppBar(
        title: Text('${classGroup.name} - 点名'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    RollCallHistoryDialog(classId: widget.classId),
              );
            },
          ),
        ],
      ),
      body: classStudents.isEmpty
          ? _buildEmptyState(context)
          : _buildRollCallContent(context, classStudents),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '班级中还没有学生',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先在班级管理中添加学生',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRollCallContent(BuildContext context, List<Student> students) {
    final availableCount = avoidRepeat
        ? students.where((s) => !calledStudentIds.contains(s.id)).length
        : students.length;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 统计信息
            _buildStatistics(students.length, availableCount),
            const SizedBox(height: 32),
            
            // 点名圆圈
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedStudent?.name ?? '?',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (selectedStudent != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '学号：${selectedStudent!.studentId}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            // 点名按钮
            FilledButton.icon(
              onPressed: (isAnimating || availableCount == 0)
                  ? null
                  : _startRollCall,
              icon: const Icon(Icons.shuffle, size: 28),
              label: Text(
                availableCount == 0 ? '所有学生已点名' : '开始点名',
                style: const TextStyle(fontSize: 18),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),
            ),
            
            if (availableCount == 0 && calledStudentIds.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _resetCalledList,
                icon: const Icon(Icons.refresh),
                label: const Text('重置点名列表'),
              ),
            ],
            
            // 评分按钮
            if (selectedStudent != null) ...[
              const SizedBox(height: 32),
              const Text(
                '回答质量评分',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildScoreButtons(),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(int total, int available) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem(Icons.people, '总人数', total.toString()),
            const SizedBox(width: 24),
            _buildStatItem(
              Icons.check_circle,
              '已点名',
              (total - available).toString(),
            ),
            const SizedBox(width: 24),
            _buildStatItem(
              Icons.pending,
              '未点名',
              available.toString(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreButtons() {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(5, (index) {
        final score = index + 1;
        return ElevatedButton(
          onPressed: () => _recordScore(score),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            backgroundColor: _getScoreColor(score),
            foregroundColor: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score分',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 16),
            ],
          ),
        );
      }),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 4) return Colors.green;
    if (score >= 3) return Colors.orange;
    return Colors.red;
  }

  void _startRollCall() async {
    final students = ref.read(studentProvider);
    final classStudents = students
        .where((s) => s.classId == widget.classId)
        .toList();

    // 过滤可用学生
    List<Student> availableStudents = avoidRepeat
        ? classStudents.where((s) => !calledStudentIds.contains(s.id)).toList()
        : classStudents;

    if (availableStudents.isEmpty) {
      return;
    }

    setState(() => isAnimating = true);

    // 动画效果：快速切换学生名字
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          selectedStudent = availableStudents[
              Random().nextInt(availableStudents.length)];
        });
      }
    }

    // 最终随机选择
    final selected =
        availableStudents[Random().nextInt(availableStudents.length)];
    
    setState(() {
      selectedStudent = selected;
      isAnimating = false;
      if (avoidRepeat) {
        calledStudentIds.add(selected.id);
      }
    });

    // 播放动画
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // 立即创建点名记录（未评分状态）
    final record = CallRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: selected.id,
      studentName: selected.name,
      timestamp: DateTime.now(),
      score: 0,  // 0 表示未评分
      note: '未评分',
    );
    await ref.read(callRecordProvider.notifier).addRecord(record);

    // 更新学生点名次数（不计入平均分）
    await ref.read(studentProvider.notifier).updateStudent(
      selected.copyWith(
        callCount: selected.callCount + 1,
      ),
    );
  }

  void _recordScore(int score) async {
    if (selectedStudent == null) return;

    final student = selectedStudent!;
    
    // 查找最近的未评分记录并更新
    final allRecords = ref.read(callRecordProvider);
    final unscored = allRecords
        .where((r) => r.studentId == student.id && r.score == 0)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (unscored.isNotEmpty) {
      // 更新最近的未评分记录
      final recordToUpdate = unscored.first;
      final updatedRecord = CallRecord(
        id: recordToUpdate.id,
        studentId: recordToUpdate.studentId,
        studentName: recordToUpdate.studentName,
        timestamp: recordToUpdate.timestamp,
        score: score,
        note: '',
      );
      
      // 删除旧记录并添加新记录（Hive 的更新方式）
      await ref.read(callRecordProvider.notifier).updateRecord(updatedRecord);
    }

    // 重新计算学生统计（只计算已评分的记录）
    final scoredRecords = allRecords
        .where((r) => r.studentId == student.id && r.score > 0)
        .toList();
    
    final totalScore = scoredRecords.fold<int>(0, (sum, r) => sum + r.score);
    final avgScore = scoredRecords.isEmpty ? 0.0 : totalScore / scoredRecords.length;

    await ref.read(studentProvider.notifier).updateStudent(
          student.copyWith(
            avgScore: avgScore,
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已记录：${student.name} - $score分'),
          duration: const Duration(seconds: 2),
        ),
      );

      // 清除选中，准备下一次点名
      setState(() => selectedStudent = null);
    }
  }

  void _resetCalledList() {
    setState(() {
      calledStudentIds.clear();
      selectedStudent = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已重置点名列表')),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => RollCallSettingsDialog(
        initialAvoidRepeat: avoidRepeat,
        onSave: (newAvoidRepeat) {
          setState(() {
            avoidRepeat = newAvoidRepeat;
            if (!avoidRepeat) {
              calledStudentIds.clear();
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('设置已保存')),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/class_group.dart';
import '../../core/models/student.dart';
import '../../core/providers/student_provider.dart';
import 'widgets/student_form_dialog.dart';

class StudentManagementScreen extends ConsumerWidget {
  final ClassGroup classGroup;

  const StudentManagementScreen({
    super.key,
    required this.classGroup,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allStudents = ref.watch(studentProvider);
    final students = allStudents
        .where((s) => s.classId == classGroup.id)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        title: Text('${classGroup.name} - 学生管理'),
      ),
      body: students.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentCard(context, ref, student);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
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
            '还没有学生',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加学生',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    WidgetRef ref,
    Student student,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            student.name.isNotEmpty ? student.name[0] : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(student.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('学号：${student.studentId}'),
            if (student.callCount > 0)
              Text(
                '被点名 ${student.callCount} 次 | 平均分 ${student.avgScore.toStringAsFixed(1)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('编辑'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditStudentDialog(context, ref, student);
                break;
              case 'delete':
                _showDeleteConfirmDialog(context, ref, student);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(
        onSave: (name, studentId) {
          ref.read(studentProvider.notifier).addStudent(
                Student(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  studentId: studentId,
                  classId: classGroup.id,
                ),
              );
        },
      ),
    );
  }

  void _showEditStudentDialog(
    BuildContext context,
    WidgetRef ref,
    Student student,
  ) {
    showDialog(
      context: context,
      builder: (context) => StudentFormDialog(
        initialName: student.name,
        initialStudentId: student.studentId,
        isEdit: true,
        onSave: (name, studentId) {
          ref.read(studentProvider.notifier).updateStudent(
                student.copyWith(
                  name: name,
                  studentId: studentId,
                ),
              );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    Student student,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除学生"${student.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(studentProvider.notifier).deleteStudent(student.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除学生"${student.name}"')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

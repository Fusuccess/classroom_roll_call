import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/class_group.dart';
import '../../core/providers/class_provider.dart';
import '../../core/providers/student_provider.dart';
import 'widgets/class_form_dialog.dart';
import 'student_management_screen.dart';

class ClassListScreen extends ConsumerWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classProvider);
    final students = ref.watch(studentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('班级管理'),
      ),
      body: classes.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classGroup = classes[index];
                final studentCount = students
                    .where((s) => s.classId == classGroup.id)
                    .length;
                return _buildClassCard(
                  context,
                  ref,
                  classGroup,
                  studentCount,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClassDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '还没有班级',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加第一个班级',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    WidgetRef ref,
    classGroup,
    int studentCount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.class_,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(classGroup.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (classGroup.description.isNotEmpty)
              Text(classGroup.description),
            Text('$studentCount 名学生'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'students',
              child: Row(
                children: [
                  Icon(Icons.people),
                  SizedBox(width: 8),
                  Text('管理学生'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('编辑班级'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除班级', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'students':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentManagementScreen(classGroup: classGroup),
                  ),
                );
                break;
              case 'edit':
                _showEditClassDialog(context, ref, classGroup);
                break;
              case 'delete':
                _showDeleteConfirmDialog(context, ref, classGroup);
                break;
            }
          },
        ),
      ),
    );
  }

  void _showAddClassDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ClassFormDialog(
        onSave: (name, description) {
          ref.read(classProvider.notifier).addClass(
                ClassGroup(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  description: description,
                  createdAt: DateTime.now(),
                ),
              );
        },
      ),
    );
  }

  void _showEditClassDialog(
    BuildContext context,
    WidgetRef ref,
    classGroup,
  ) {
    showDialog(
      context: context,
      builder: (context) => ClassFormDialog(
        initialName: classGroup.name,
        initialDescription: classGroup.description,
        isEdit: true,
        onSave: (name, description) {
          ref.read(classProvider.notifier).updateClass(
                ClassGroup(
                  id: classGroup.id,
                  name: name,
                  description: description,
                  createdAt: classGroup.createdAt,
                ),
              );
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    classGroup,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除班级"${classGroup.name}"吗？\n班级中的学生也会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 删除班级中的所有学生
              final students = ref.read(studentProvider);
              for (final student in students) {
                if (student.classId == classGroup.id) {
                  ref.read(studentProvider.notifier).deleteStudent(student.id);
                }
              }
              // 删除班级
              ref.read(classProvider.notifier).deleteClass(classGroup.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除班级"${classGroup.name}"')),
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

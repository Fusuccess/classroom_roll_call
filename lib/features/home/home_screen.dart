import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/class_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课堂点名'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildMenuCard(
            context,
            icon: Icons.people,
            title: '班级管理',
            color: Colors.blue,
            onTap: () => context.push('/classes'),
          ),
          _buildMenuCard(
            context,
            icon: Icons.touch_app,
            title: '开始点名',
            color: Colors.green,
            onTap: () => _showClassSelector(context, ref),
          ),
          _buildMenuCard(
            context,
            icon: Icons.bar_chart,
            title: '统计分析',
            color: Colors.orange,
            onTap: () => context.push('/statistics'),
          ),
          _buildMenuCard(
            context,
            icon: Icons.settings,
            title: '设置',
            color: Colors.grey,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _showClassSelector(BuildContext context, WidgetRef ref) {
    final classes = ref.read(classProvider);
    
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先在班级管理中创建班级')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择班级'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classGroup = classes[index];
              return ListTile(
                leading: const Icon(Icons.class_),
                title: Text(classGroup.name),
                subtitle: Text(classGroup.description),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/roll-call/${classGroup.id}');
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

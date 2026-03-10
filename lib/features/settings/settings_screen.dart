import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/student_provider.dart';
import '../../core/providers/class_provider.dart';
import '../../core/providers/call_record_provider.dart';
import '../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 watch 确保数据已加载
    final classes = ref.watch(classProvider);
    final students = ref.watch(studentProvider);
    final records = ref.watch(callRecordProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeModeLabel = ref.read(themeModeProvider.notifier).themeModeLabel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: '外观',
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('主题模式'),
                subtitle: Text(themeModeLabel),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, ref, themeMode),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '数据管理',
            children: [
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('清除点名记录'),
                subtitle: Text('保留班级和学生，仅清除点名历史（${records.length}条）'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showClearRecordsDialog(context, ref, records),
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('清除所有数据', style: TextStyle(color: Colors.red)),
                subtitle: Text('删除${classes.length}个班级、${students.length}名学生、${records.length}条记录'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showClearAllDialog(context, ref, classes, students, records),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '关于',
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('应用版本'),
                subtitle: const Text('1.0.1'),
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('使用说明'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showHelpDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('开源许可'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLicenseDialog(context),
              ),
            ],
          ),
          
          // 开发者信息
          const SizedBox(height: 24),
          _buildDeveloperInfo(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '开发者',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _openDeveloperWebsite(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.business,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '南漳云联软件技术工作室',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2026 All Rights Reserved',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('主题模式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('跟随系统'),
              subtitle: const Text('根据系统设置自动切换'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('主题已设置为跟随系统')),
                  );
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('浅色模式'),
              subtitle: const Text('始终使用浅色主题'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('主题已切换为浅色模式')),
                  );
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('深色模式'),
              subtitle: const Text('始终使用深色主题'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('主题已切换为深色模式')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearRecordsDialog(
    BuildContext context,
    WidgetRef ref,
    List records,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除点名记录'),
        content: Text('确定要清除所有点名记录吗？\n\n共 ${records.length} 条记录将被删除。\n班级和学生信息将保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 清除所有记录
              for (final record in records) {
                await ref.read(callRecordProvider.notifier).deleteRecord(record.id);
              }
              
              // 重置学生统计
              final students = ref.read(studentProvider);
              for (final student in students) {
                await ref.read(studentProvider.notifier).updateStudent(
                  student.copyWith(callCount: 0, avgScore: 0.0),
                );
              }
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('点名记录已清除')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(
    BuildContext context,
    WidgetRef ref,
    List classes,
    List students,
    List records,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ 危险操作'),
        content: Text(
          '确定要清除所有数据吗？\n\n'
          '将删除：\n'
          '• ${classes.length} 个班级\n'
          '• ${students.length} 名学生\n'
          '• ${records.length} 条点名记录\n\n'
          '此操作不可恢复！',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 清除所有记录
              for (final record in records) {
                await ref.read(callRecordProvider.notifier).deleteRecord(record.id);
              }
              
              // 清除所有学生
              for (final student in students) {
                await ref.read(studentProvider.notifier).deleteStudent(student.id);
              }
              
              // 清除所有班级
              for (final classGroup in classes) {
                await ref.read(classProvider.notifier).deleteClass(classGroup.id);
              }
              
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有数据已清除')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用说明'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '班级管理',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• 添加班级和学生信息\n• 编辑和删除班级\n• 导入 CSV 学生名单\n• 管理学生名单'),
              SizedBox(height: 16),
              Text(
                '随机点名',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• 选择班级开始点名\n• 随机选择学生\n• 评分记录（1-5分）\n• 避免重复点名'),
              SizedBox(height: 16),
              Text(
                '统计分析',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• 查看点名统计\n• 学生排名\n• 分数分布\n• 导出数据到 CSV\n• 按班级筛选'),
              SizedBox(height: 16),
              Text(
                '提示',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• 所有数据保存在本地\n• 支持多个班级管理\n• 可以不评分直接点名下一个\n• 导出文件保存在 Download 文件夹'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开源许可'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '课堂点名应用',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('版本：1.0.1'),
              SizedBox(height: 16),
              Text(
                '使用的开源库：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Flutter - Google\n'
                  '• Riverpod - Remi Rousselet\n'
                  '• Hive - Isar\n'
                  '• Go Router - Flutter Team\n'
                  '• Intl - Dart Team\n'
                  '• file_picker - Miguel Ruivo\n'
                  '• csv - Dart Team'),
              SizedBox(height: 16),
              Text(
                '本应用采用 MIT 许可证',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('© 2026 南漳云联软件技术工作室\nAll Rights Reserved'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _openDeveloperWebsite(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('访问开发者网站'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('南漳云联软件技术工作室'),
            SizedBox(height: 8),
            SelectableText(
              'https://fusuccess.top',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '提示：请在浏览器中打开此链接',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

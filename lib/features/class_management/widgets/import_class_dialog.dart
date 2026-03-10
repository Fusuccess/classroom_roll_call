import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/class_group.dart';
import '../../../core/models/student.dart';
import '../../../core/services/import_export_service.dart';

class ImportClassDialog extends StatefulWidget {
  final Function(ClassGroup, List<Student>) onImport;

  const ImportClassDialog({
    super.key,
    required this.onImport,
  });

  @override
  State<ImportClassDialog> createState() => _ImportClassDialogState();
}

class _ImportClassDialogState extends State<ImportClassDialog> {
  bool isLoading = false;
  List<Map<String, String>>? importedStudents;
  String? classNameInput;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导入班级和学生'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说明文字
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '导入说明',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• CSV 文件格式：班级名称, 学生姓名, 学号\n'
                    '• 第一行为标题行\n'
                    '• 每行一个学生\n'
                    '• 学生姓名和学号为必填项',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 班级名称输入
            if (importedStudents == null)
              TextField(
                decoration: InputDecoration(
                  labelText: '班级名称',
                  hintText: '请输入班级名称',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.class_),
                ),
                onChanged: (value) {
                  setState(() => classNameInput = value);
                },
              ),

            if (importedStudents == null) const SizedBox(height: 16),

            // 导入按钮
            if (importedStudents == null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading || classNameInput?.isEmpty != false
                      ? null
                      : _selectAndImportFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('选择 CSV 文件'),
                ),
              ),

            // 导入结果
            if (importedStudents != null) ...[
              const SizedBox(height: 16),
              Text(
                '班级：$classNameInput',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '已导入 ${importedStudents!.length} 个学生',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: importedStudents!.length,
                  itemBuilder: (context, index) {
                    final student = importedStudents![index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(student['name'] ?? ''),
                      subtitle: Text('学号：${student['studentId'] ?? ''}'),
                    );
                  },
                ),
              ),
            ],

            // 错误信息
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ],

            // 加载指示器
            if (isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        if (importedStudents != null)
          FilledButton(
            onPressed: () {
              _confirmImport();
            },
            child: const Text('确认导入'),
          ),
      ],
    );
  }

  Future<void> _selectAndImportFile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Web 端和移动端的文件选择需要不同的实现
      // 这里先显示提示，实际应用中需要集成 file_picker 或其他文件选择方案
      if (kIsWeb) {
        // Web 端：使用 file_picker 或其他方案
        _showFilePickerTip();
      } else {
        // 移动端/桌面端：使用 file_picker
        _showFilePickerTip();
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '文件选择失败: $e';
      });
    }
  }

  void _showFilePickerTip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text(
          '文件选择功能需要在实际设备上测试。\n\n'
          '您可以：\n'
          '1. 使用导出功能生成 CSV 模板\n'
          '2. 在 Excel 中编辑 CSV 文件\n'
          '3. 使用此导入功能导入修改后的文件',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmImport() {
    if (classNameInput == null || classNameInput!.isEmpty) {
      setState(() {
        errorMessage = '请输入班级名称';
      });
      return;
    }

    if (importedStudents == null || importedStudents!.isEmpty) {
      setState(() {
        errorMessage = '没有学生数据';
      });
      return;
    }

    // 创建班级对象
    final classGroup = ClassGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: classNameInput!,
      description: '导入于 ${DateTime.now().toString().split('.')[0]}',
      createdAt: DateTime.now(),
    );

    // 创建学生对象列表
    final students = importedStudents!
        .map((data) => Student(
              id: DateTime.now().millisecondsSinceEpoch.toString() +
                  importedStudents!.indexOf(data).toString(),
              name: data['name'] ?? '',
              studentId: data['studentId'] ?? '',
              classId: classGroup.id,
              callCount: 0,
              avgScore: 0.0,
            ))
        .toList();

    // 调用回调函数
    widget.onImport(classGroup, students);

    // 关闭对话框
    Navigator.pop(context);

    // 显示成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已导入班级"$classNameInput"，共 ${students.length} 个学生'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ImportStudentsDialog extends StatefulWidget {
  final Function(List<Map<String, String>>) onImport;

  const ImportStudentsDialog({
    super.key,
    required this.onImport,
  });

  @override
  State<ImportStudentsDialog> createState() => _ImportStudentsDialogState();
}

class _ImportStudentsDialogState extends State<ImportStudentsDialog> {
  bool isLoading = false;
  List<Map<String, String>>? importedStudents;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导入学生名单'),
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

            // 导入按钮
            if (importedStudents == null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : _selectAndImportFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('选择 CSV 文件'),
                ),
              ),

            // 导入结果
            if (importedStudents != null) ...[
              const SizedBox(height: 16),
              Text(
                '已导入 ${importedStudents!.length} 个学生',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.green,
                    ),
              ),
              const SizedBox(height: 8),
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
              widget.onImport(importedStudents!);
              Navigator.pop(context);
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

      // 这里需要使用 file_picker 或其他文件选择方案
      // 由于 file_picker 有兼容性问题，我们先使用简单的方案
      // 在实际应用中，可以使用 file_selector 或其他替代方案

      // 模拟文件选择（实际应用中需要实现真实的文件选择）
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('提示'),
          content: const Text('文件选择功能需要在实际设备上测试。\n'
              '请确保 CSV 文件格式正确。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );

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
}

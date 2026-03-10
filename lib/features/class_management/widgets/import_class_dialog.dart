import 'package:flutter/material.dart';
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
  List<Student>? importedStudents;
  String? classNameInput;
  String? errorMessage;
  String? selectedFilePath;
  TextEditingController? _classNameController;

  @override
  void initState() {
    super.initState();
    _classNameController = TextEditingController();
  }

  @override
  void dispose() {
    _classNameController?.dispose();
    super.dispose();
  }

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
                    '• CSV 文件必须包含"学生姓名"和"学号"列\n'
                    '• 第一行为标题行\n'
                    '• 每行一个学生\n'
                    '• 系统会自动匹配这两列',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 班级名称输入
            if (importedStudents == null)
              TextField(
                controller: _classNameController,
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

            // 选择文件显示
            if (importedStudents == null && selectedFilePath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '已选择文件',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            selectedFilePath!.split('/').last,
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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
                child: importedStudents!.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '没有学生数据',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: importedStudents!.length,
                        itemBuilder: (context, index) {
                          final student = importedStudents![index];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(student.name),
                            subtitle: Text('学号：${student.studentId}'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '导入失败',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
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
        if (importedStudents != null && !isLoading)
          TextButton(
            onPressed: () {
              setState(() {
                importedStudents = null;
                selectedFilePath = null;
                errorMessage = null;
              });
            },
            child: const Text('重新选择'),
          ),
        if (importedStudents != null && !isLoading)
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

      // 选择文件
      final filePath = await ImportExportService.pickCSVFile();
      if (filePath == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // 验证班级名称
      if (classNameInput == null || classNameInput!.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = '请输入班级名称';
        });
        return;
      }

      // 自动匹配列
      final (nameColumnIndex, idColumnIndex) =
          await ImportExportService.autoMatchColumns(filePath);

      // 创建班级 ID（在导入前生成）
      final classId = DateTime.now().millisecondsSinceEpoch.toString();

      // 导入班级和学生
      final (classGroup, students) =
          await ImportExportService.importClassAndStudentsFromCSV(
        filePath,
        classNameInput!,
        classId,
        nameColumnIndex: nameColumnIndex,
        studentIdColumnIndex: idColumnIndex,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
        selectedFilePath = filePath;
        importedStudents = students;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
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

    try {
      // 创建班级对象
      final classGroup = ClassGroup(
        id: importedStudents!.first.classId,
        name: classNameInput!,
        description: '导入于 ${DateTime.now().toString().split('.')[0]}',
        createdAt: DateTime.now(),
      );

      // 调用回调函数
      widget.onImport(classGroup, importedStudents!);

      // 关闭对话框
      Navigator.pop(context);

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已导入班级"$classNameInput"，共 ${importedStudents!.length} 个学生'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = '导入失败：$e';
      });
    }
  }
}

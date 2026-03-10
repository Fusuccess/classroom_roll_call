import 'package:flutter/material.dart';

class ClassFormDialog extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final bool isEdit;
  final Function(String name, String description) onSave;

  const ClassFormDialog({
    super.key,
    this.initialName,
    this.initialDescription,
    this.isEdit = false,
    required this.onSave,
  });

  @override
  State<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends State<ClassFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? '编辑班级' : '添加班级'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '班级名称',
                hintText: '例如：高一(1)班',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入班级名称';
                }
                return null;
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '班级描述（可选）',
                hintText: '例如：理科实验班',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        _descriptionController.text.trim(),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit ? '班级已更新' : '班级已添加'),
        ),
      );
    }
  }
}

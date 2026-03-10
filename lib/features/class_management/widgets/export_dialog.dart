import 'package:flutter/material.dart';
import '../../../core/models/student.dart';
import '../../../core/models/call_record.dart';
import '../../../core/services/import_export_service.dart';

class ExportDialog extends StatefulWidget {
  final String className;
  final List<Student> students;
  final List<CallRecord> records;

  const ExportDialog({
    super.key,
    required this.className,
    required this.students,
    required this.records,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool isExporting = false;
  String? exportMessage;
  bool isSuccess = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导出数据'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 导出选项
            _buildExportOption(
              '导出学生名单',
              '导出所有学生信息为 CSV 文件',
              Icons.people,
              () => _exportStudents(),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              '导出点名记录',
              '导出所有点名记录为 CSV 文件',
              Icons.history,
              () => _exportRecords(),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              '生成统计报告',
              '生成班级统计报告为 CSV 文件',
              Icons.assessment,
              () => _generateReport(),
            ),

            // 导出状态
            if (isExporting) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Text('正在导出...'),
            ],

            // 导出结果
            if (exportMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  exportMessage!,
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildExportOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      child: InkWell(
        onTap: isExporting ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportStudents() async {
    try {
      setState(() {
        isExporting = true;
        exportMessage = null;
      });

      final filePath = await ImportExportService.exportStudentsToCSV(
        widget.students,
        widget.className,
      );

      setState(() {
        isExporting = false;
        isSuccess = true;
        exportMessage = filePath.contains('Web')
            ? '✓ 学生名单已下载'
            : '学生名单已导出到：\n$filePath';
      });
    } catch (e) {
      setState(() {
        isExporting = false;
        isSuccess = false;
        exportMessage = '导出失败：$e';
      });
    }
  }

  Future<void> _exportRecords() async {
    try {
      setState(() {
        isExporting = true;
        exportMessage = null;
      });

      final filePath = await ImportExportService.exportRecordsToCSV(
        widget.records,
        widget.className,
      );

      setState(() {
        isExporting = false;
        isSuccess = true;
        exportMessage = filePath.contains('Web')
            ? '✓ 点名记录已下载'
            : '点名记录已导出到：\n$filePath';
      });
    } catch (e) {
      setState(() {
        isExporting = false;
        isSuccess = false;
        exportMessage = '导出失败：$e';
      });
    }
  }

  Future<void> _generateReport() async {
    try {
      setState(() {
        isExporting = true;
        exportMessage = null;
      });

      final filePath = await ImportExportService.generateStatisticsReport(
        widget.students,
        widget.records,
        widget.className,
      );

      setState(() {
        isExporting = false;
        isSuccess = true;
        exportMessage = filePath.contains('Web')
            ? '✓ 统计报告已下载'
            : '统计报告已生成到：\n$filePath';
      });
    } catch (e) {
      setState(() {
        isExporting = false;
        isSuccess = false;
        exportMessage = '生成失败：$e';
      });
    }
  }
}

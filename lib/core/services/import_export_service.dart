import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../models/student.dart';
import '../models/call_record.dart';
import '../models/class_group.dart';
import 'import_export_service_web.dart' if (dart.library.io) 'import_export_service_mobile.dart';

/// 导入导出服务
class ImportExportService {
  /// 获取 Download 文件夹路径
  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Android: /storage/emulated/0/Download
        final directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          return directory;
        }
        // 备选方案：使用外部存储目录
        return await getExternalStorageDirectory();
      } else if (Platform.isIOS) {
        // iOS: Documents 文件夹
        return await getApplicationDocumentsDirectory();
      } else {
        // 其他平台
        return await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      return await getExternalStorageDirectory();
    }
  }
  /// 导出学生名单为 CSV
  /// 返回文件路径
  static Future<String> exportStudentsToCSV(
    List<Student> students,
    String className,
  ) async {
    try {
      // 准备数据
      final List<List<dynamic>> rows = [
        ['班级名称', '学生姓名', '学号', '被点名次数', '平均分'],
      ];

      for (final student in students) {
        rows.add([
          className,
          student.name,
          student.studentId,
          student.callCount,
          student.avgScore.toStringAsFixed(2),
        ]);
      }

      // 转换为 CSV
      final csv = const ListToCsvConverter().convert(rows);

      // 根据平台选择不同的处理方式
      if (kIsWeb) {
        // Web 端：直接下载
        _downloadFileWeb(csv, 'students_$className.csv');
        return 'Web 端已下载文件';
      } else {
        // 移动端/桌面端：保存到 Download 文件夹
        final directory = await _getDownloadDirectory();
        if (directory == null) {
          throw Exception('无法访问下载文件夹');
        }
        final fileName =
            'students_${className}_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');

        // 写入文件
        await file.writeAsString(csv);

        return file.path;
      }
    } catch (e) {
      throw Exception('导出学生名单失败: $e');
    }
  }

  /// 导出点名记录为 CSV
  /// 返回文件路径
  static Future<String> exportRecordsToCSV(
    List<CallRecord> records,
    String className,
  ) async {
    try {
      // 准备数据
      final List<List<dynamic>> rows = [
        ['班级名称', '学生姓名', '学号', '点名时间', '评分', '备注'],
      ];

      for (final record in records) {
        final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
        rows.add([
          className,
          record.studentName,
          record.studentId,
          dateFormat.format(record.timestamp),
          record.score == 0 ? '未评分' : record.score,
          record.note,
        ]);
      }

      // 转换为 CSV
      final csv = const ListToCsvConverter().convert(rows);

      // 根据平台选择不同的处理方式
      if (kIsWeb) {
        // Web 端：直接下载
        _downloadFileWeb(csv, 'records_$className.csv');
        return 'Web 端已下载文件';
      } else {
        // 移动端/桌面端：保存到 Download 文件夹
        final directory = await _getDownloadDirectory();
        if (directory == null) {
          throw Exception('无法访问下载文件夹');
        }
        final fileName =
            'records_${className}_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');

        // 写入文件
        await file.writeAsString(csv);

        return file.path;
      }
    } catch (e) {
      throw Exception('导出点名记录失败: $e');
    }
  }

  /// 生成统计报告
  /// 返回文件路径
  static Future<String> generateStatisticsReport(
    List<Student> students,
    List<CallRecord> records,
    String className,
  ) async {
    try {
      // 计算统计数据
      final totalRecords = records.length;
      final scoredRecords = records.where((r) => r.score > 0).toList();
      final totalScore = scoredRecords.fold<int>(0, (sum, r) => sum + r.score);
      final avgScore =
          scoredRecords.isEmpty ? 0.0 : totalScore / scoredRecords.length;
      final participantCount = students.where((s) => s.callCount > 0).length;

      // 准备数据
      final List<List<dynamic>> rows = [
        ['班级统计报告'],
        [],
        ['班级名称', className],
        ['生成时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())],
        [],
        ['总体统计'],
        ['总学生数', students.length],
        ['参与点名学生数', participantCount],
        ['总点名次数', totalRecords],
        ['已评分次数', scoredRecords.length],
        ['平均分', avgScore.toStringAsFixed(2)],
        [],
        ['学生排名'],
        ['排名', '学生姓名', '学号', '被点名次数', '平均分'],
      ];

      // 按平均分排序
      final rankedStudents = students
          .where((s) => s.callCount > 0)
          .toList()
        ..sort((a, b) {
          final scoreCompare = b.avgScore.compareTo(a.avgScore);
          if (scoreCompare != 0) return scoreCompare;
          return b.callCount.compareTo(a.callCount);
        });

      for (int i = 0; i < rankedStudents.length; i++) {
        final student = rankedStudents[i];
        rows.add([
          i + 1,
          student.name,
          student.studentId,
          student.callCount,
          student.avgScore.toStringAsFixed(2),
        ]);
      }

      // 转换为 CSV
      final csv = const ListToCsvConverter().convert(rows);

      // 根据平台选择不同的处理方式
      if (kIsWeb) {
        // Web 端：直接下载
        _downloadFileWeb(csv, 'report_$className.csv');
        return 'Web 端已下载文件';
      } else {
        // 移动端/桌面端：保存到 Download 文件夹
        final directory = await _getDownloadDirectory();
        if (directory == null) {
          throw Exception('无法访问下载文件夹');
        }
        final fileName =
            'report_${className}_${DateTime.now().millisecondsSinceEpoch}.csv';
        final file = File('${directory.path}/$fileName');

        // 写入文件
        await file.writeAsString(csv);

        return file.path;
      }
    } catch (e) {
      throw Exception('生成统计报告失败: $e');
    }
  }

  /// Web 端文件下载辅助方法
  static void _downloadFileWeb(String content, String fileName) {
    if (kIsWeb) {
      downloadFileWeb(content, fileName);
    }
  }

  /// 从 CSV 文件导入班级和学生信息
  /// 返回 (班级对象, 学生列表)
  static Future<(ClassGroup, List<Student>)> importClassAndStudentsFromCSV(
    String filePath,
    String className,
    String classId, {
    int nameColumnIndex = 0,
    int studentIdColumnIndex = 1,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      final content = await file.readAsString();
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(content);

      if (rows.isEmpty) {
        throw Exception('CSV 文件为空');
      }

      // 跳过标题行
      final dataRows = rows.skip(1).toList();
      if (dataRows.isEmpty) {
        throw Exception('没有学生数据');
      }

      // 创建班级对象
      final classGroup = ClassGroup(
        id: classId,
        name: className,
        description: '导入于 ${DateTime.now().toString().split('.')[0]}',
        createdAt: DateTime.now(),
      );

      // 创建学生对象列表
      final students = <Student>[];
      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        
        // 检查列索引是否有效
        if (row.length <= nameColumnIndex || row.length <= studentIdColumnIndex) {
          continue;
        }

        final name = row[nameColumnIndex]?.toString().trim() ?? '';
        final studentId = row[studentIdColumnIndex]?.toString().trim() ?? '';

        if (name.isEmpty || studentId.isEmpty) continue;

        students.add(Student(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          name: name,
          studentId: studentId,
          classId: classId,
          callCount: 0,
          avgScore: 0.0,
        ));
      }

      if (students.isEmpty) {
        throw Exception('没有有效的学生数据');
      }

      return (classGroup, students);
    } catch (e) {
      throw Exception('导入班级和学生失败: $e');
    }
  }

  /// 自动匹配 CSV 文件中的学生姓名列和学号列
  /// 返回 (学生姓名列索引, 学号列索引)
  static Future<(int, int)> autoMatchColumns(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在');
      }

      final content = await file.readAsString();
      final List<List<dynamic>> rows =
          const CsvToListConverter().convert(content);

      if (rows.isEmpty) {
        throw Exception('CSV 文件为空');
      }

      // 获取第一行作为标题
      final headerRow = rows.first;
      int nameColumnIndex = -1;
      int idColumnIndex = -1;

      // 查找学生姓名列和学号列
      for (int i = 0; i < headerRow.length; i++) {
        final header = headerRow[i]?.toString().toLowerCase().trim() ?? '';
        
        // 匹配学生姓名列
        if (header.contains('姓名') || header.contains('name') || header.contains('学生')) {
          if (!header.contains('学号') && !header.contains('id')) {
            nameColumnIndex = i;
          }
        }
        
        // 匹配学号列
        if (header.contains('学号') || header.contains('id') || header.contains('号')) {
          idColumnIndex = i;
        }
      }

      // 如果没有找到，尝试使用前两列
      if (nameColumnIndex == -1 || idColumnIndex == -1) {
        if (headerRow.length >= 2) {
          nameColumnIndex = 0;
          idColumnIndex = 1;
        } else {
          throw Exception('CSV 文件必须包含"学生姓名"和"学号"列');
        }
      }

      return (nameColumnIndex, idColumnIndex);
    } catch (e) {
      throw Exception('自动匹配列失败: $e');
    }
  }

  /// 选择 CSV 文件
  static Future<String?> pickCSVFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      throw Exception('文件选择失败: $e');
    }
  }
}

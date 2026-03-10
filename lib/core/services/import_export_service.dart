import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/student.dart';
import '../models/call_record.dart';
import 'import_export_service_web.dart' if (dart.library.io) 'import_export_service_mobile.dart';

/// 导入导出服务
class ImportExportService {
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
        // 移动端/桌面端：保存到文件系统
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('无法访问外部存储');
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
        // 移动端/桌面端：保存到文件系统
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('无法访问外部存储');
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
        // 移动端/桌面端：保存到文件系统
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('无法访问外部存储');
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
}

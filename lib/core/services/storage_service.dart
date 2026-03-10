import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/student.dart';
import '../models/class_group.dart';
import '../models/call_record.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  static const String studentsBox = 'students';
  static const String classesBox = 'classes';
  static const String recordsBox = 'records';

  Future<Box<Map>> _getBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      return await Hive.openBox<Map>(name);
    }
    return Hive.box<Map>(name);
  }

  // 学生相关
  Future<List<Student>> getStudents() async {
    final box = await _getBox(studentsBox);
    return box.values
        .map((e) => Student.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveStudent(Student student) async {
    final box = await _getBox(studentsBox);
    await box.put(student.id, student.toJson());
  }

  Future<void> deleteStudent(String id) async {
    final box = await _getBox(studentsBox);
    await box.delete(id);
  }

  // 班级相关
  Future<List<ClassGroup>> getClasses() async {
    final box = await _getBox(classesBox);
    return box.values
        .map((e) => ClassGroup.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveClass(ClassGroup classGroup) async {
    final box = await _getBox(classesBox);
    await box.put(classGroup.id, classGroup.toJson());
  }

  Future<void> deleteClass(String id) async {
    final box = await _getBox(classesBox);
    await box.delete(id);
  }

  // 点名记录相关
  Future<List<CallRecord>> getRecords() async {
    final box = await _getBox(recordsBox);
    return box.values
        .map((e) => CallRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveRecord(CallRecord record) async {
    final box = await _getBox(recordsBox);
    await box.put(record.id, record.toJson());
  }

  Future<void> deleteRecord(String id) async {
    final box = await _getBox(recordsBox);
    await box.delete(id);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student.dart';
import '../services/storage_service.dart';

final studentProvider = StateNotifierProvider<StudentNotifier, List<Student>>((ref) {
  return StudentNotifier(ref.watch(storageServiceProvider));
});

class StudentNotifier extends StateNotifier<List<Student>> {
  final StorageService _storage;

  StudentNotifier(this._storage) : super([]) {
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    state = await _storage.getStudents();
  }

  Future<void> addStudent(Student student) async {
    await _storage.saveStudent(student);
    state = [...state, student];
  }

  Future<void> updateStudent(Student student) async {
    await _storage.saveStudent(student);
    state = [
      for (final s in state)
        if (s.id == student.id) student else s,
    ];
  }

  Future<void> deleteStudent(String id) async {
    await _storage.deleteStudent(id);
    state = state.where((s) => s.id != id).toList();
  }

  List<Student> getStudentsByClass(String classId) {
    return state.where((s) => s.classId == classId).toList();
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/class_group.dart';
import '../services/storage_service.dart';

final classProvider = StateNotifierProvider<ClassNotifier, List<ClassGroup>>((ref) {
  return ClassNotifier(ref.watch(storageServiceProvider));
});

class ClassNotifier extends StateNotifier<List<ClassGroup>> {
  final StorageService _storage;

  ClassNotifier(this._storage) : super([]) {
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    state = await _storage.getClasses();
  }

  Future<void> addClass(ClassGroup classGroup) async {
    await _storage.saveClass(classGroup);
    state = [...state, classGroup];
  }

  Future<void> updateClass(ClassGroup classGroup) async {
    await _storage.saveClass(classGroup);
    state = [
      for (final c in state)
        if (c.id == classGroup.id) classGroup else c,
    ];
  }

  Future<void> deleteClass(String id) async {
    await _storage.deleteClass(id);
    state = state.where((c) => c.id != id).toList();
  }
}

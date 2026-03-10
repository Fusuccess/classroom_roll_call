import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/call_record.dart';
import '../services/storage_service.dart';

final callRecordProvider = StateNotifierProvider<CallRecordNotifier, List<CallRecord>>((ref) {
  return CallRecordNotifier(ref.watch(storageServiceProvider));
});

class CallRecordNotifier extends StateNotifier<List<CallRecord>> {
  final StorageService _storage;

  CallRecordNotifier(this._storage) : super([]) {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    state = await _storage.getRecords();
  }

  Future<void> addRecord(CallRecord record) async {
    await _storage.saveRecord(record);
    state = [...state, record];
  }

  Future<void> updateRecord(CallRecord record) async {
    await _storage.saveRecord(record);
    state = [
      for (final r in state)
        if (r.id == record.id) record else r,
    ];
  }

  Future<void> deleteRecord(String id) async {
    await _storage.deleteRecord(id);
    state = state.where((r) => r.id != id).toList();
  }

  List<CallRecord> getRecordsByStudent(String studentId) {
    return state.where((r) => r.studentId == studentId).toList();
  }

  List<CallRecord> getRecentRecords({int limit = 10}) {
    final sorted = [...state]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }
}

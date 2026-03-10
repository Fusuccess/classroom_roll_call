import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/call_record_provider.dart';

class RollCallHistoryDialog extends ConsumerWidget {
  final String classId;

  const RollCallHistoryDialog({
    super.key,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRecords = ref.watch(callRecordProvider);
    final records = allRecords
        .where((r) => r.studentId.isNotEmpty)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '点名历史',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: records.isEmpty
                  ? const Center(
                      child: Text('还没有点名记录'),
                    )
                  : ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return _buildRecordItem(context, record);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, record) {
    final dateFormat = DateFormat('MM-dd HH:mm');
    final isScored = record.score > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isScored ? _getScoreColor(record.score) : Colors.grey,
          child: isScored
              ? Text(
                  record.score.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : const Icon(
                  Icons.question_mark,
                  color: Colors.white,
                ),
        ),
        title: Text(record.studentName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(record.timestamp)),
            if (!isScored)
              Text(
                '未评分',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: isScored ? _buildScoreStars(record.score) : null,
      ),
    );
  }

  Widget _buildScoreStars(int score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < score ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.orange,
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 4) return Colors.green;
    if (score >= 3) return Colors.orange;
    return Colors.red;
  }
}

class CallRecord {
  final String id;
  final String studentId;
  final String studentName;
  final DateTime timestamp;
  final int score;
  final String note;

  CallRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.timestamp,
    this.score = 0,
    this.note = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'timestamp': timestamp.toIso8601String(),
      'score': score,
      'note': note,
    };
  }

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    return CallRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      score: json['score'] as int? ?? 0,
      note: json['note'] as String? ?? '',
    );
  }
}

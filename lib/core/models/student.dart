class Student {
  final String id;
  final String name;
  final String studentId;
  final String classId;
  final int callCount;
  final double avgScore;

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.classId,
    this.callCount = 0,
    this.avgScore = 0.0,
  });

  Student copyWith({
    String? id,
    String? name,
    String? studentId,
    String? classId,
    int? callCount,
    double? avgScore,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      callCount: callCount ?? this.callCount,
      avgScore: avgScore ?? this.avgScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studentId': studentId,
      'classId': classId,
      'callCount': callCount,
      'avgScore': avgScore,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      callCount: json['callCount'] as int? ?? 0,
      avgScore: (json['avgScore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

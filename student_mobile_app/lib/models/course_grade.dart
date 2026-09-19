class CourseGrade {
  final String courseCode;
  final String courseName;
  final int creditHours;
  final String grade; // A+, A, B+, B, C+, C, D, F
  final double points; // 4.0, 3.5, 3.0, etc.
  final double? score; // 85%, 92%, etc.
  final String? status; // ناجح / رسوب

  CourseGrade({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
    required this.grade,
    required this.points,
    this.score,
    this.status,
  });

  factory CourseGrade.fromJson(Map<String, dynamic> json) {
    return CourseGrade(
      courseCode: json['course_code'] ?? json['code'] ?? '',
      courseName: json['course_name'] ?? json['name'] ?? '',
      creditHours: (json['credit_hours'] ?? json['hours'] ?? 3) as int,
      grade: json['grade'] ?? 'F',
      points: (json['points'] is num) ? (json['points'] as num).toDouble() : 0.0,
      score: (json['score'] is num) ? (json['score'] as num).toDouble() : null,
      status: json['status'] ?? (json['grade'] == 'F' ? 'راسب' : 'ناجح'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_code': courseCode,
      'course_name': courseName,
      'credit_hours': creditHours,
      'grade': grade,
      'points': points,
      'score': score,
      'status': status,
    };
  }
}

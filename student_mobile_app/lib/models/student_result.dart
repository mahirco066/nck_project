import 'course_grade.dart';

class StudentResult {
  final String id;
  final String studentId; // الرقم الجامعي
  final String studentName; // اسم الطالب
  final String departmentId; // كود التخصص
  final String departmentName; // اسم الكلية / التخصص
  final int semesterId; // رقم الفصل الدراسي
  final String semesterName; // اسم الفصل الدراسي
  final String academicYear; // العام الأكاديمي
  final double semesterGpa; // المعدل الفصلي (SGPA)
  final double cumulativeGpa; // المعدل التراكمي (CGPA)
  final int totalCreditHours; // مجموع الساعات المعتمدة
  final int passedCreditHours; // الساعات المجتازة بنجاح
  final String academicStatus; // الحالة الأكاديمية (ناجح، ممتاز، منقول بملاحق)
  final String? notes; // ملاحظات الشؤون العلمية
  final List<CourseGrade> courses; // قائمة المواد والدرجات
  final String? originalPdfUrl; // رابط ملف الـ PDF الأصلي المرفوع
  final String? individualPdfUrl; // رابط إشعار النتيجة الفردي المولد
  final DateTime? publishedAt; // تاريخ اعتماد ونشر النتيجة

  StudentResult({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.departmentId,
    required this.departmentName,
    required this.semesterId,
    required this.semesterName,
    required this.academicYear,
    required this.semesterGpa,
    required this.cumulativeGpa,
    required this.totalCreditHours,
    required this.passedCreditHours,
    required this.academicStatus,
    this.notes,
    required this.courses,
    this.originalPdfUrl,
    this.individualPdfUrl,
    this.publishedAt,
  });

  factory StudentResult.fromJson(Map<String, dynamic> json) {
    var rawCourses = json['courses'] as List? ?? [];
    List<CourseGrade> parsedCourses =
        rawCourses.map((c) => CourseGrade.fromJson(c)).toList();

    return StudentResult(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      studentName: json['student_name'] ?? 'طالب كلية شمال كردفان',
      departmentId: json['department_id'] ?? 'CS',
      departmentName: json['department_name'] ?? 'علوم الحاسوب',
      semesterId: json['semester_id'] is int
          ? json['semester_id']
          : int.tryParse(json['semester_id']?.toString() ?? '1') ?? 1,
      semesterName: json['semester_name'] ?? 'الفصل الدراسي الأول',
      academicYear: json['academic_year'] ?? '2025/2026',
      semesterGpa: (json['semester_gpa'] is num)
          ? (json['semester_gpa'] as num).toDouble()
          : 0.0,
      cumulativeGpa: (json['cumulative_gpa'] is num)
          ? (json['cumulative_gpa'] as num).toDouble()
          : 0.0,
      totalCreditHours: json['total_credit_hours'] ?? 0,
      passedCreditHours: json['passed_credit_hours'] ?? 0,
      academicStatus: json['academic_status'] ?? 'ناجح',
      notes: json['notes'],
      courses: parsedCourses,
      originalPdfUrl: json['original_pdf_url'],
      individualPdfUrl: json['individual_pdf_url'],
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_name': studentName,
      'department_id': departmentId,
      'department_name': departmentName,
      'semester_id': semesterId,
      'semester_name': semesterName,
      'academic_year': academicYear,
      'semester_gpa': semesterGpa,
      'cumulative_gpa': cumulativeGpa,
      'total_credit_hours': totalCreditHours,
      'passed_credit_hours': passedCreditHours,
      'academic_status': academicStatus,
      'notes': notes,
      'courses': courses.map((c) => c.toJson()).toList(),
      'original_pdf_url': originalPdfUrl,
      'individual_pdf_url': individualPdfUrl,
      'published_at': publishedAt?.toIso8601String(),
    };
  }
}

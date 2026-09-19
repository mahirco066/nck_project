import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/course_grade.dart';
import '../models/student_result.dart';

class ApiService {
  static const String _keyCustomBaseUrl = 'custom_base_url';

  // الحصول على رابط الـ API الحالي المخزن أو الافتراضي
  static Future<String> getBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyCustomBaseUrl) ?? AppConstants.defaultBaseUrl;
    } catch (_) {
      return AppConstants.defaultBaseUrl;
    }
  }

  // حفظ رابط سيرفر مخصص (في حال تغييره من الإعدادات)
  static Future<void> setBaseUrl(String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomBaseUrl, newUrl.trim());
  }

  // الاستعلام عن نتيجة طالب
  static Future<StudentResult> fetchStudentResult({
    required String studentId,
    required String departmentId,
    required int semesterId,
  }) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/results/search');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'student_id': studentId.trim(),
              'department_id': departmentId,
              'semester_id': semesterId,
            }),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['success'] == true && data['data'] != null) {
          return StudentResult.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'لم يتم العثور على النتيجة المطلوبة');
        }
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? 'فشل الاتصال بالخادم (${response.statusCode})');
      }
    } catch (e) {
      // إذا فشل الاتصال بالسيرفر، نتحقق مما إذا كان الرقم هو الرقم النموذجي للتجربة 2023001
      if (studentId.trim() == '2023001' || studentId.trim() == '2023002') {
        return _getMockResult(studentId.trim(), departmentId, semesterId);
      }
      throw Exception('تعذر الوصول لخادم النتائج: ${e.toString().replaceAll("Exception:", "")}');
    }
  }

  // بيانات افتراضية تجريبية للعمل دون انترنت عند الحاجة
  static StudentResult _getMockResult(String studentId, String deptId, int semId) {
    if (studentId == '2023002') {
      return StudentResult(
        id: 'mock-02',
        studentId: '2023002',
        studentName: 'سارة عبد الله محمد أحمد',
        departmentId: deptId,
        departmentName: 'العلوم الإدارية والمالية',
        semesterId: semId,
        semesterName: 'الفصل الدراسي الرابع',
        academicYear: AppConstants.academicYear,
        semesterGpa: 3.82,
        cumulativeGpa: 3.75,
        totalCreditHours: 18,
        passedCreditHours: 18,
        academicStatus: 'ناجح - مرتبة الشرف الأولى',
        notes: 'طالبة متفوقة على مستوى الدفعة',
        courses: [
          CourseGrade(courseCode: 'ACC201', courseName: 'المحاسبة المالية المتقدمة', creditHours: 3, grade: 'A', points: 4.0),
          CourseGrade(courseCode: 'MGT202', courseName: 'إدارة الأعمال الاستراتيجية', creditHours: 3, grade: 'A+', points: 4.0),
          CourseGrade(courseCode: 'ECO203', courseName: 'الاقتصاد الكلي والتحليلي', creditHours: 3, grade: 'A-', points: 3.7),
          CourseGrade(courseCode: 'STAT204', courseName: 'الإحصاء التطبيقي في الأعمال', creditHours: 3, grade: 'B+', points: 3.5),
          CourseGrade(courseCode: 'MIS205', courseName: 'نظم المعلومات الإدارية', creditHours: 3, grade: 'A', points: 4.0),
          CourseGrade(courseCode: 'ENG206', courseName: 'اللغة الإنجليزية للأعمال', creditHours: 3, grade: 'A', points: 4.0),
        ],
        publishedAt: DateTime.now(),
      );
    }

    return StudentResult(
      id: 'mock-01',
      studentId: '2023001',
      studentName: 'محمد أحمد إبراهيم عثمان',
      departmentId: deptId,
      departmentName: 'علوم الحاسوب وتكنولوجيا المعلومات',
      semesterId: semId,
      semesterName: 'الفصل الدراسي الرابع',
      academicYear: AppConstants.academicYear,
      semesterGpa: 3.65,
      cumulativeGpa: 3.58,
      totalCreditHours: 18,
      passedCreditHours: 18,
      academicStatus: 'ناجح بتقدير ممتاز',
      notes: 'تم اعتماد النتيجة رسمياً من أمانة الشؤون العلمية',
      courses: [
        CourseGrade(courseCode: 'CS201', courseName: 'تراكيب البيانات والخوارزميات', creditHours: 3, grade: 'A', points: 4.0, score: 91),
        CourseGrade(courseCode: 'CS202', courseName: 'هندسة البرمجيات وتصميم النظم', creditHours: 3, grade: 'A+', points: 4.0, score: 95),
        CourseGrade(courseCode: 'CS203', courseName: 'نظم إدارة قواعد البيانات (SQL)', creditHours: 3, grade: 'B+', points: 3.5, score: 84),
        CourseGrade(courseCode: 'IT204', courseName: 'شبكات الحاسوب والاتصالات', creditHours: 3, grade: 'A', points: 4.0, score: 88),
        CourseGrade(courseCode: 'MATH205', courseName: 'الرياضيات المتقطعة والإحصاء', creditHours: 3, grade: 'B', points: 3.0, score: 78),
        CourseGrade(courseCode: 'HUM206', courseName: 'مهارات الاتصال والأخلاقيات الأكاديمية', creditHours: 3, grade: 'A+', points: 4.0, score: 96),
      ],
      publishedAt: DateTime.now(),
    );
  }
}

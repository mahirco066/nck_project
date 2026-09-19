import 'package:flutter/material.dart';

class AppConstants {
  // اسم وهوية الكلية
  static const String appName = 'كلية شمال كردفان - النتائج';
  static const String collegeNameAr = 'كلية شمال كردفان';
  static const String collegeNameEn = 'North Kordofan College';
  static const String facultyTitle = 'أمانة الشؤون العلمية - إدارة الامتحانات والشهادات';
  static const String academicYear = '2025 / 2026م';

  // روابط الـ API
  // افتراضياً يتصل بالسيرفر المحلي مع إمكانية التبديل إلى IP الشبكة أو الخادم السحابي
  static const String defaultBaseUrl = 'http://10.0.2.2:5000/api'; // لمحاكي أندرويد
  static const String localWebBaseUrl = 'http://localhost:5000/api'; // لمتصفح الويب أو ويندوز
  static const String physicalDeviceBaseUrl = 'http://192.168.1.100:5000/api'; // للأجهزة الحقيقية عبر الواي فاي

  // ألوان هوية الكلية
  static const Color primaryGreen = Color(0xFF0F6838); // الأخضر الأكاديمي الرسمي
  static const Color primaryDarkGreen = Color(0xFF094424);
  static const Color accentGold = Color(0xFFD4AF37); // الذهبي الرسمي
  static const Color navyBlue = Color(0xFF1B365D); // الكحلي الملكي
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  // قائمة الكليات والتخصصات المعتمدة
  static const List<Map<String, String>> departments = [
    {
      'id': 'CS',
      'name': 'علوم الحاسوب وتكنولوجيا المعلومات',
      'code': 'CS-IT',
      'icon': 'computer'
    },
    {
      'id': 'BA',
      'name': 'العلوم الإدارية والمالية والمحاسبة',
      'code': 'BA-ACC',
      'icon': 'business'
    },
    {
      'id': 'NURSING',
      'name': 'التمريض والعلوم الصحية التطبيقية',
      'code': 'NURS',
      'icon': 'medical'
    },
    {
      'id': 'ENG',
      'name': 'الهندسة والتقانة (كهرباء ومدني)',
      'code': 'ENG-TECH',
      'icon': 'engineering'
    },
    {
      'id': 'EDU',
      'name': 'التربية واللغات والعلوم الإنسانية',
      'code': 'EDU-LANG',
      'icon': 'school'
    },
  ];

  // قائمة الفصول الدراسية
  static const List<Map<String, dynamic>> semesters = [
    {'id': 1, 'name': 'الفصل الدراسي الأول', 'short': 'ف 1'},
    {'id': 2, 'name': 'الفصل الدراسي الثاني', 'short': 'ف 2'},
    {'id': 3, 'name': 'الفصل الدراسي الثالث', 'short': 'ف 3'},
    {'id': 4, 'name': 'الفصل الدراسي الرابع', 'short': 'ف 4'},
    {'id': 5, 'name': 'الفصل الدراسي الخامس', 'short': 'ف 5'},
    {'id': 6, 'name': 'الفصل الدراسي السادس', 'short': 'ف 6'},
    {'id': 7, 'name': 'الفصل الدراسي السابع', 'short': 'ف 7'},
    {'id': 8, 'name': 'الفصل الدراسي الثامن', 'short': 'ف 8'},
  ];

  // مقياس التقديرات والنقاط
  static Color getGradeColor(String grade) {
    switch (grade.trim().toUpperCase()) {
      case 'A+':
      case 'A':
        return const Color(0xFF10B981); // أخضر زمردي ممتاز
      case 'B+':
      case 'B':
        return const Color(0xFF3B82F6); // أزرق جيد جداً
      case 'C+':
      case 'C':
        return const Color(0xFFF59E0B); // برتقالي جيد
      case 'D+':
      case 'D':
        return const Color(0xFFEAB308); // أصفر مقبول
      case 'F':
      default:
        return const Color(0xFFEF4444); // أحمر رسوب
    }
  }

  static String getGradeLabelAr(String grade) {
    switch (grade.trim().toUpperCase()) {
      case 'A+':
        return 'ممتاز مرتفع';
      case 'A':
        return 'ممتاز';
      case 'B+':
        return 'جيد جداً مرتفع';
      case 'B':
        return 'جيد جداً';
      case 'C+':
        return 'جيد مرتفع';
      case 'C':
        return 'جيد';
      case 'D+':
        return 'مقبول مرتفع';
      case 'D':
        return 'مقبول';
      case 'F':
        return 'رسوب';
      default:
        return grade;
    }
  }
}

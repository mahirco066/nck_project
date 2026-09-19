import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/student_result.dart';
import '../services/pdf_service.dart';
import '../widgets/course_card.dart';
import '../widgets/stat_card.dart';
import 'pdf_viewer_screen.dart';

class ResultScreen extends StatelessWidget {
  final StudentResult result;

  const ResultScreen({Key? key, required this.result}) : super(key: key);

  void _openPdfViewer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(result: result),
      ),
    );
  }

  void _printTranscript(BuildContext context) async {
    try {
      await PdfService.printResult(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال أمر الطباعة: $e')),
      );
    }
  }

  void _shareTranscript(BuildContext context) async {
    try {
      await PdfService.shareResultPdf(result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء المشاركة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كشف درجات الطالب'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            tooltip: 'طباعة الإشعار',
            onPressed: () => _printTranscript(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'مشاركة PDF',
            onPressed: () => _shareTranscript(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة بيانات الطالب الأساسية
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConstants.primaryGreen, AppConstants.primaryDarkGreen],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryGreen.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          result.studentName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.accentGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          result.academicStatus,
                          style: const TextStyle(
                            color: AppConstants.navyBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoItem('الرقم الجامعي', result.studentId, Icons.badge),
                      const SizedBox(width: 16),
                      _buildInfoItem('الفصل الدراسي', result.semesterName, Icons.calendar_today),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoItem('الكلية والتخصص', result.departmentName, Icons.school),
                      const SizedBox(width: 16),
                      _buildInfoItem('العام الأكاديمي', result.academicYear, Icons.date_range),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // شبكة بطاقات الإحصاء والمعدلات
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'المعدل الفصلي (SGPA)',
                    value: result.semesterGpa.toStringAsFixed(2),
                    subtitle: 'من أصل 4.00',
                    icon: Icons.analytics_outlined,
                    color: AppConstants.primaryGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'المعدل التراكمي (CGPA)',
                    value: result.cumulativeGpa.toStringAsFixed(2),
                    subtitle: 'من أصل 4.00',
                    icon: Icons.trending_up,
                    color: AppConstants.navyBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    title: 'الساعات المعتمدة',
                    value: '${result.totalCreditHours}',
                    subtitle: 'مجتازة بنجاح',
                    icon: Icons.timer_outlined,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // عنوان كشف المقررات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تفاصيل المواد والدرجات',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                  ),
                ),
                Text(
                  '${result.courses.length} مقرر دراسي',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // قائمة بطاقات المواد
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.courses.length,
              itemBuilder: (context, index) {
                return CourseCard(course: result.courses[index], index: index);
              },
            ),
            const SizedBox(height: 20),

            // أزرار العمليات (عرض الـ PDF، التحميل، والطباعة)
            ElevatedButton.icon(
              onPressed: () => _openPdfViewer(context),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
              label: const Text('عرض ومعاينة إشعار النتيجة PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _printTranscript(context),
                    icon: const Icon(Icons.print, size: 18),
                    label: const Text('طباعة فورية'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareTranscript(context),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('مشاركة النتيجة'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

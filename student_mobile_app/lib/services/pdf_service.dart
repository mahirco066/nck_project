import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../config/constants.dart';
import '../models/student_result.dart';

class PdfService {
  // تنزيل ملف PDF من رابط وحفظه محلياً في مجلد المستندات المؤقتة
  static Future<File> downloadPdf(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file;
  }

  // توليد ملف PDF إشعار درجات رسمي من بيانات الطالب وطباعته أو تنزيله
  static Future<Uint8List> generateResultPdfBytes(StudentResult result) async {
    final doc = pw.Document();

    // تحميل خط عربي يدعم ترميز الحروف المتصلة (Amiri أو Cairo من الأصول أو الخطوط المضمنة في الحزمة)
    final fontData = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    final primaryColor = PdfColor.fromHex('#0F6838');
    final goldColor = PdfColor.fromHex('#D4AF37');
    final navyColor = PdfColor.fromHex('#1B365D');
    final lightBg = PdfColor.fromHex('#F8FAFC');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: fontData, bold: fontBold),
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: primaryColor, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // ترويسة الكلية الرسمية
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'جمهورية السودان',
                          style: pw.TextStyle(fontSize: 12, font: fontBold),
                        ),
                        pw.Text(
                          'وزارة التعليم العالي والبحث العلمي',
                          style: pw.TextStyle(fontSize: 11, font: fontData),
                        ),
                        pw.Text(
                          AppConstants.collegeNameAr,
                          style: pw.TextStyle(fontSize: 15, font: fontBold, color: primaryColor),
                        ),
                        pw.Text(
                          'أمانة الشؤون العلمية - إدارة الامتحانات',
                          style: pw.TextStyle(fontSize: 11, font: fontData, color: navyColor),
                        ),
                      ],
                    ),
                    pw.Container(
                      width: 60,
                      height: 60,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        border: pw.Border.all(color: goldColor, width: 2),
                        color: lightBg,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'NKC',
                          style: pw.TextStyle(fontSize: 14, font: fontBold, color: primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Divider(color: primaryColor, thickness: 1.5, height: 16),

                // عنوان الشهادة
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    ),
                    child: pw.Text(
                      'إشعار نتيجة فصل دراسي - كشف درجات أكاديمي',
                      style: pw.TextStyle(fontSize: 13, font: fontBold, color: PdfColors.white),
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),

                // بيانات الطالب في شبكة منسقة
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('اسم الطالب: ${result.studentName}', style: pw.TextStyle(fontSize: 11, font: fontBold)),
                          pw.Text('الرقم الجامعي: ${result.studentId}', style: pw.TextStyle(fontSize: 11, font: fontBold, color: primaryColor)),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('الكلية / التخصص: ${result.departmentName}', style: pw.TextStyle(fontSize: 10, font: fontData)),
                          pw.Text('الفصل الدراسي: ${result.semesterName}', style: pw.TextStyle(fontSize: 10, font: fontData)),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('العام الأكاديمي: ${result.academicYear}', style: pw.TextStyle(fontSize: 10, font: fontData)),
                          pw.Text('الحالة الأكاديمية: ${result.academicStatus}', style: pw.TextStyle(fontSize: 10, font: fontBold, color: primaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),

                // جدول المواد والتقديرات
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1.2), // الرمز
                    1: const pw.FlexColumnWidth(3.5), // اسم المادة
                    2: const pw.FlexColumnWidth(1.2), // الساعات
                    3: const pw.FlexColumnWidth(1.2), // التقدير
                    4: const pw.FlexColumnWidth(1.2), // النقاط
                    5: const pw.FlexColumnWidth(1.5), // الحالة
                  },
                  children: [
                    // ترويسة الجدول
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: navyColor),
                      children: [
                        _buildTableHeader('رمز المقرر', fontBold),
                        _buildTableHeader('اسم المقرر الدراسي', fontBold),
                        _buildTableHeader('الساعات', fontBold),
                        _buildTableHeader('التقدير', fontBold),
                        _buildTableHeader('النقاط', fontBold),
                        _buildTableHeader('النتيجة', fontBold),
                      ],
                    ),
                    // صفوف المواد
                    ...result.courses.map((course) {
                      return pw.TableRow(
                        children: [
                          _buildTableCell(course.courseCode, fontData, align: pw.TextAlign.center),
                          _buildTableCell(course.courseName, fontData),
                          _buildTableCell('${course.creditHours}', fontData, align: pw.TextAlign.center),
                          _buildTableCell(course.grade, fontBold, align: pw.TextAlign.center, color: primaryColor),
                          _buildTableCell(course.points.toStringAsFixed(1), fontData, align: pw.TextAlign.center),
                          _buildTableCell(course.status ?? (course.grade == 'F' ? 'رسوب' : 'ناجح'), fontData, align: pw.TextAlign.center),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                pw.SizedBox(height: 14),

                // ملخص المعدلات
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: goldColor, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    color: PdfColor.fromHex('#FFFDF0'),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text('المعدل الفصلي (SGPA)', style: pw.TextStyle(fontSize: 10, font: fontData, color: navyColor)),
                          pw.Text('${result.semesterGpa.toStringAsFixed(2)} / 4.00', style: pw.TextStyle(fontSize: 13, font: fontBold, color: primaryColor)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text('المعدل التراكمي (CGPA)', style: pw.TextStyle(fontSize: 10, font: fontData, color: navyColor)),
                          pw.Text('${result.cumulativeGpa.toStringAsFixed(2)} / 4.00', style: pw.TextStyle(fontSize: 13, font: fontBold, color: primaryColor)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text('الساعات المعتمدة', style: pw.TextStyle(fontSize: 10, font: fontData, color: navyColor)),
                          pw.Text('${result.totalCreditHours} ساعة', style: pw.TextStyle(fontSize: 13, font: fontBold)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),

                // التوقيعات والأختام الرسمية
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('مسؤول الكنترول والامتحانات', style: pw.TextStyle(fontSize: 10, font: fontData)),
                        pw.SizedBox(height: 25),
                        pw.Text('................................', style: pw.TextStyle(fontSize: 10, font: fontData)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('ختم أمانة الشؤون العلمية', style: pw.TextStyle(fontSize: 10, font: fontData)),
                        pw.SizedBox(height: 10),
                        pw.Container(
                          width: 45,
                          height: 45,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(color: PdfColors.grey400, style: pw.BorderStyle.dashed),
                          ),
                          child: pw.Center(
                            child: pw.Text('الختم الرسمي', style: pw.TextStyle(fontSize: 7, font: fontData, color: PdfColors.grey600)),
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('عميد الكلية', style: pw.TextStyle(fontSize: 10, font: fontData)),
                        pw.SizedBox(height: 25),
                        pw.Text('................................', style: pw.TextStyle(fontSize: 10, font: fontData)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'ملاحظة: هذا المستند صادر إلكترونياً من بوابة نتائج كلية شمال كردفان الرسمية، وتعتبر السجلات المحفوظة بالكلية هي المرجع النهائي.',
                  style: pw.TextStyle(fontSize: 7, font: fontData, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );

    return doc.save();
  }

  // طباعة مباشرة
  static Future<void> printResult(StudentResult result) async {
    final pdfBytes = await generateResultPdfBytes(result);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'نتيجة_${result.studentId}_${result.studentName}.pdf',
    );
  }

  // مشاركة ملف PDF
  static Future<void> shareResultPdf(StudentResult result) async {
    final pdfBytes = await generateResultPdfBytes(result);
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/نتيجة_الطالب_${result.studentId}.pdf");
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'إشعار نتيجة الطالب ${result.studentName} - كلية شمال كردفان',
      subject: 'نتيجة ${result.studentId}',
    );
  }

  static pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: PdfColors.white, fontSize: 9, font: font),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.right,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          font: font,
          color: color ?? PdfColors.black,
        ),
        textAlign: align,
      ),
    );
  }
}

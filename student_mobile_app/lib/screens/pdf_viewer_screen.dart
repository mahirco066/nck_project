import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../config/constants.dart';
import '../models/student_result.dart';
import '../services/pdf_service.dart';

class PdfViewerScreen extends StatelessWidget {
  final StudentResult result;

  const PdfViewerScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إشعار نتيجة: ${result.studentId}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'مشاركة الملف',
            onPressed: () => PdfService.shareResultPdf(result),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateResultPdfBytes(result),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        pdfFileName: 'إشعار_نتيجة_${result.studentId}_${result.studentName}.pdf',
        loadingWidget: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(color: AppConstants.primaryGreen),
              SizedBox(height: 16),
              Text(
                'جاري إعداد وتوليد مستند الـ PDF الموثق...',
                style: TextStyle(fontSize: 13, color: AppConstants.textDark),
              ),
            ],
          ),
        ),
        actions: [
          PdfPrintAction(
            icon: const Icon(Icons.print, color: Colors.white),
            onPressed: (context, layout, format) async {
              await PdfService.printResult(result);
            },
          ),
        ],
      ),
    );
  }
}

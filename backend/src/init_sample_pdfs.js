const fs = require('fs');
const path = require('path');
const { generateStudentTranscriptPdf } = require('./pdf_generator');

const dbPath = path.join(__dirname, '..', 'database', 'results_db.json');
const uploadsDir = path.join(__dirname, '..', 'storage', 'uploads');

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const dbData = JSON.parse(fs.readFileSync(dbPath, 'utf8'));

// توليد ملفات الـ PDF للكشوفات التجريبية
dbData.results.forEach(res => {
  const pdfBuffer = generateStudentTranscriptPdf(res);
  const fileName = `Result_${res.student_id}.pdf`;
  fs.writeFileSync(path.join(uploadsDir, fileName), pdfBuffer);
  console.log(`Generated: ${fileName}`);
});

// توليد كشف الدفعة CS
const sampleCs = dbData.results[0];
fs.writeFileSync(path.join(uploadsDir, 'CS_Semester4_Final_2026.pdf'), generateStudentTranscriptPdf({
  ...sampleCs,
  student_name: 'BATCH RESULTS: COMPUTER SCIENCE - SEMESTER 4',
  student_id: 'ALL-CS-2026'
}));

// توليد كشف الدفعة BA
const sampleBa = dbData.results[1];
fs.writeFileSync(path.join(uploadsDir, 'BA_Semester4_Final_2026.pdf'), generateStudentTranscriptPdf({
  ...sampleBa,
  student_name: 'BATCH RESULTS: BUSINESS ADMINISTRATION - SEMESTER 4',
  student_id: 'ALL-BA-2026'
}));

// توليد كشف التمريض
const sampleNur = dbData.results[3];
fs.writeFileSync(path.join(uploadsDir, 'Nursing_Semester2_Final_2026.pdf'), generateStudentTranscriptPdf({
  ...sampleNur,
  student_name: 'BATCH RESULTS: NURSING APPLIED SCIENCES - SEMESTER 2',
  student_id: 'ALL-NUR-2026'
}));

console.log('All sample PDFs created successfully in storage/uploads!');

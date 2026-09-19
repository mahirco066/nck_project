// محرك توليد مستندات الـ PDF الأكاديمية الرسمية
// يتوافق مع معايير PDF 1.4 القياسية ليعمل في كافة قارئات الـ PDF والمتصفحات والموبايل
const fs = require('fs');
const path = require('path');

function generateStudentTranscriptPdf(result) {
  // حسابات التموضع في الصفحة A4 (595 x 842 pt)
  const studentName = result.student_name || 'طالب كلية شمال كردفان';
  const studentId = result.student_id || '---';
  const deptName = result.department_name || '---';
  const semesterName = result.semester_name || '---';
  const sgpa = (result.semester_gpa || 0).toFixed(2);
  const cgpa = (result.cumulative_gpa || 0).toFixed(2);
  const status = result.academic_status || 'ناجح';
  const academicYear = result.academic_year || '2025/2026';
  const courses = result.courses || [];

  // نصوص المقررات
  let tableRows = '';
  let yPos = 490;

  courses.forEach((c, i) => {
    const code = c.course_code || `C${i + 1}`;
    const name = c.course_name || `مقرر دراسي ${i + 1}`;
    const hours = c.credit_hours || 3;
    const grade = c.grade || 'A';
    const pts = (c.points || 4.0).toFixed(1);

    // خط أفقي
    tableRows += `
      0.8 w 0.85 0.88 0.92 RG
      50 ${yPos - 5} m 545 ${yPos - 5} l S
      0 0 0 rg
      BT /F1 9 Tf 55 ${yPos} Td (${code}) Tj ET
      BT /F1 9 Tf 130 ${yPos} Td (${escapePdfText(name)}) Tj ET
      BT /F1 9 Tf 360 ${yPos} Td (${hours}) Tj ET
      BT /F1 10 Tf 0.06 0.41 0.22 rg 420 ${yPos} Td (${grade}) Tj 0 0 0 rg ET
      BT /F1 9 Tf 480 ${yPos} Td (${pts}) Tj ET
    `;
    yPos -= 22;
  });

  const contentStream = `
    q
    % الإطار الخارجي والترويسة
    1.5 w 0.06 0.41 0.22 RG
    30 30 535 782 re S
    0.5 w 0.83 0.69 0.22 RG
    34 34 527 774 re S

    % خلفية الترويسة
    0.06 0.41 0.22 rg
    35 735 525 71 re f

    % نصوص الترويسة
    1 1 1 rg
    BT /F2 16 Tf 180 775 Td (NORTH KORDOFAN COLLEGE) Tj ET
    BT /F2 13 Tf 205 755 Td (ACADEMIC RESULTS PORTAL) Tj ET
    BT /F1 9 Tf 210 740 Td (Official Transcript of Academic Record) Tj ET

    % صندوق بيانات الطالب
    0.96 0.97 0.98 rg
    50 635 495 85 re f
    0.8 0.85 0.9 RG 0.8 w
    50 635 495 85 re S

    0.11 0.21 0.36 rg
    BT /F2 11 Tf 65 700 Td (Student Name: ) Tj ET
    0 0 0 rg
    BT /F1 11 Tf 160 700 Td (${escapePdfText(studentName)}) Tj ET

    0.11 0.21 0.36 rg
    BT /F2 11 Tf 360 700 Td (Student ID: ) Tj ET
    0.06 0.41 0.22 rg
    BT /F2 12 Tf 440 700 Td (${studentId}) Tj ET

    0.11 0.21 0.36 rg
    BT /F2 10 Tf 65 675 Td (Faculty / Major: ) Tj ET
    0 0 0 rg
    BT /F1 10 Tf 160 675 Td (${escapePdfText(deptName)}) Tj ET

    0.11 0.21 0.36 rg
    BT /F2 10 Tf 360 675 Td (Semester: ) Tj ET
    0 0 0 rg
    BT /F1 10 Tf 440 675 Td (${escapePdfText(semesterName)}) Tj ET

    0.11 0.21 0.36 rg
    BT /F2 10 Tf 65 650 Td (Academic Year: ) Tj ET
    0 0 0 rg
    BT /F1 10 Tf 160 650 Td (${escapePdfText(academicYear)}) Tj ET

    0.11 0.21 0.36 rg
    BT /F2 10 Tf 360 650 Td (Status: ) Tj ET
    0.06 0.41 0.22 rg
    BT /F2 10 Tf 440 650 Td (${escapePdfText(status)}) Tj ET

    % ترويسة جدول المواد
    0.11 0.21 0.36 rg
    50 515 495 24 re f
    1 1 1 rg
    BT /F2 9 Tf 55 522 Td (CODE) Tj ET
    BT /F2 9 Tf 130 522 Td (COURSE TITLE) Tj ET
    BT /F2 9 Tf 350 522 Td (HOURS) Tj ET
    BT /F2 9 Tf 415 522 Td (GRADE) Tj ET
    BT /F2 9 Tf 475 522 Td (POINTS) Tj ET

    % صفوف المواد
    ${tableRows}

    % صندوق ملخص المعدل
    0.99 0.98 0.92 rg
    50 170 495 50 re f
    0.83 0.69 0.22 RG 1 w
    50 170 495 50 re S

    0.11 0.21 0.36 rg
    BT /F2 10 Tf 70 198 Td (Semester GPA (SGPA):) Tj ET
    0.06 0.41 0.22 rg
    BT /F2 13 Tf 205 197 Td (${sgpa} / 4.00) Tj ET

    0.11 0.21 0.36 rg
    BT /F2 10 Tf 320 198 Td (Cumulative GPA (CGPA):) Tj ET
    0.06 0.41 0.22 rg
    BT /F2 13 Tf 465 197 Td (${cgpa} / 4.00) Tj ET

    % التوقيعات والأختام
    0.2 0.2 0.2 rg
    BT /F2 9 Tf 80 110 Td (Examinations Controller) Tj ET
    BT /F1 8 Tf 70 85 Td (...........................................) Tj ET

    BT /F2 9 Tf 245 110 Td (Official Scientific Affairs Seal) Tj ET
    0.83 0.69 0.22 RG 1 w
    285 75 25 0 360 arc S
    0.06 0.41 0.22 rg
    BT /F2 8 Tf 273 72 Td (SEAL) Tj ET

    0.2 0.2 0.2 rg
    BT /F2 9 Tf 430 110 Td (Dean of College) Tj ET
    BT /F1 8 Tf 415 85 Td (...........................................) Tj ET

    % الفوتر وتاريخ الاستخراج
    0.4 0.4 0.4 rg
    BT /F1 7 Tf 135 45 Td (Electronically Certified Result - North Kordofan College Academic System) Tj ET
    BT /F1 7 Tf 220 36 Td (Generated on: ${new Date().toISOString().split('T')[0]}) Tj ET
    Q
  `;

  return buildPdfDocument(contentStream);
}

function escapePdfText(text) {
  if (!text) return '';
  return text.replace(/\\/g, '\\\\').replace(/\(/g, '\\(').replace(/\)/g, '\\)');
}

function buildPdfDocument(contentStream) {
  const streamLength = Buffer.byteLength(contentStream, 'latin1');

  const pdfObjects = [
    // 1: Catalog
    `1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n`,
    // 2: Pages
    `2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n`,
    // 3: Page
    `3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595.28 841.89] /Contents 4 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>\nendobj\n`,
    // 4: Contents
    `4 0 obj\n<< /Length ${streamLength} >>\nstream\n${contentStream}\nendstream\nendobj\n`,
    // 5: Font F1 (Helvetica)
    `5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n`,
    // 6: Font F2 (Helvetica-Bold)
    `6 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n`
  ];

  let header = `%PDF-1.4\n%âãÏÓ\n`;
  let body = '';
  let xref = `xref\n0 7\n0000000000 65535 f \n`;
  let offset = Buffer.byteLength(header, 'latin1');

  pdfObjects.forEach(obj => {
    let paddedOffset = ('0000000000' + offset).slice(-10);
    xref += `${paddedOffset} 00000 n \n`;
    body += obj;
    offset += Buffer.byteLength(obj, 'latin1');
  });

  let trailer = `trailer\n<< /Size 7 /Root 1 0 R >>\nstartxref\n${offset}\n%%EOF\n`;

  return Buffer.from(header + body + xref + trailer, 'latin1');
}

module.exports = {
  generateStudentTranscriptPdf
};

// خادم نتائج كلية شمال كردفان (North Kordofan College Academic Results Server)
// يدعم REST API للتطبيق ولوحة تحكم الإدارة ومعالجة وتوليد ملفات الـ PDF
const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');
const { generateStudentTranscriptPdf } = require('./pdf_generator');

const PORT = process.env.PORT || 5000;
const DB_FILE = path.join(__dirname, '..', 'database', 'results_db.json');
const STORAGE_DIR = path.join(__dirname, '..', 'storage', 'uploads');
const PUBLIC_DIR = path.join(__dirname, '..', 'public');

// التأكد من وجود المجلدات الضرورية
if (!fs.existsSync(STORAGE_DIR)) fs.mkdirSync(STORAGE_DIR, { recursive: true });
if (!fs.existsSync(PUBLIC_DIR)) fs.mkdirSync(PUBLIC_DIR, { recursive: true });

// دوال قراءة وتحديث قاعدة البيانات
function loadDatabase() {
  try {
    const raw = fs.readFileSync(DB_FILE, 'utf8');
    return JSON.parse(raw);
  } catch (err) {
    console.error('Error reading database:', err);
    return { departments: [], semesters: [], results: [], uploaded_batches: [] };
  }
}

function saveDatabase(data) {
  try {
    fs.writeFileSync(DB_FILE, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    console.error('Error saving database:', err);
    return false;
  }
}

// مساعد إرجاع استجابات JSON
function sendJson(res, statusCode, payload) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(JSON.stringify(payload));
}

// قراءة محتوى جسم الطلب (Body Parser)
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
      // حماية الحجم الأقصى (20MB)
      if (body.length > 20 * 1024 * 1024) {
        req.destroy();
        reject(new Error('Payload Too Large'));
      }
    });
    req.on('end', () => {
      if (!body) return resolve({});
      try {
        const parsed = JSON.parse(body);
        resolve(parsed);
      } catch (e) {
        resolve({ raw: body });
      }
    });
    req.on('error', reject);
  });
}

// خادم الـ HTTP الرئيسي
const server = http.createServer(async (req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const method = req.method.toUpperCase();

  // معالجة طلبات الـ CORS Preflight
  if (method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Max-Age': '86400'
    });
    return res.end();
  }

  try {
    // -------------------------------------------------------------
    // 1. مسارات الـ API العامة (للطالب والتطبيق)
    // -------------------------------------------------------------

    // قائمة الكليات والأقسام
    if (method === 'GET' && pathname === '/api/departments') {
      const db = loadDatabase();
      return sendJson(res, 200, { success: true, data: db.departments });
    }

    // قائمة الفصول الدراسية
    if (method === 'GET' && pathname === '/api/semesters') {
      const db = loadDatabase();
      return sendJson(res, 200, { success: true, data: db.semesters });
    }

    // الاستعلام عن نتيجة طالب
    if (method === 'POST' && pathname === '/api/results/search') {
      const body = await parseBody(req);
      const studentId = (body.student_id || '').toString().trim();
      const departmentId = body.department_id;
      const semesterId = body.semester_id ? parseInt(body.semester_id) : null;

      if (!studentId) {
        return sendJson(res, 400, { success: false, message: 'يرجى إدخال الرقم الجامعي' });
      }

      const db = loadDatabase();
      // البحث بالرقم الجامعي مع مطابقة التخصص والفصل إذا حُددا
      let match = db.results.find(r => {
        const idMatch = r.student_id.toString().trim() === studentId;
        if (!idMatch) return false;
        if (departmentId && r.department_id !== departmentId) return false;
        if (semesterId && r.semester_id !== semesterId) return false;
        return true;
      });

      // إذا لم يطابق بالتخصص الدقيق، نبحث بالرقم الجامعي فقط ونعطيه النتيجة
      if (!match) {
        match = db.results.find(r => r.student_id.toString().trim() === studentId);
      }

      if (!match) {
        return sendJson(res, 404, {
          success: false,
          message: `عذراً، لم يتم العثور على نتيجة معتمدة للرقم الجامعي (${studentId}). يرجى التأكد من الرقم والتخصص أو مراجعة إدارة الامتحانات.`
        });
      }

      // تجهيز روابط الـ PDF
      const enrichedResult = {
        ...match,
        individual_pdf_url: `/api/results/${match.id}/pdf`,
        download_pdf_url: `/api/results/${match.id}/pdf?download=1`
      };

      return sendJson(res, 200, {
        success: true,
        message: 'تم استرجاع النتيجة بنجاح',
        data: enrichedResult
      });
    }

    // توليد وتنزيل ملف الـ PDF لإشعار نتيجة الطالب الفردية
    if (method === 'GET' && pathname.startsWith('/api/results/') && pathname.endsWith('/pdf')) {
      const parts = pathname.split('/');
      const resultId = parts[3]; // /api/results/:id/pdf
      const db = loadDatabase();
      const match = db.results.find(r => r.id === resultId || r.student_id === resultId);

      if (!match) {
        res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
        return res.end('لم يتم العثور على نتيجة الطالب');
      }

      const pdfBuffer = generateStudentTranscriptPdf(match);
      const isDownload = parsedUrl.query.download === '1';
      const disposition = isDownload
        ? `attachment; filename="Transcript_${match.student_id}.pdf"`
        : `inline; filename="Transcript_${match.student_id}.pdf"`;

      res.writeHead(200, {
        'Content-Type': 'application/pdf',
        'Content-Length': pdfBuffer.length,
        'Content-Disposition': disposition,
        'Access-Control-Allow-Origin': '*'
      });
      return res.end(pdfBuffer);
    }

    // -------------------------------------------------------------
    // 2. مسارات لوحة التحكم الإدارية (Admin API)
    // -------------------------------------------------------------

    // تسجيل دخول المسؤول
    if (method === 'POST' && pathname === '/api/admin/login') {
      const body = await parseBody(req);
      const { username, password } = body;
      // بيانات الدخول الافتراضية
      if ((username === 'admin' || username === 'nkc') && (password === 'admin123' || password === 'nkc@2026')) {
        return sendJson(res, 200, {
          success: true,
          token: 'nkc_admin_auth_token_secret_2026',
          user: {
            name: 'مسؤول الامتحانات والكنترول',
            role: 'SuperAdmin',
            college: 'كلية شمال كردفان'
          }
        });
      }
      return sendJson(res, 401, { success: false, message: 'اسم المستخدم أو كلمة المرور غير صحيحة' });
    }

    // إحصائيات لوحة التحكم
    if (method === 'GET' && pathname === '/api/admin/stats') {
      const db = loadDatabase();
      const totalStudents = db.results.length;
      const passedStudents = db.results.filter(r => !r.academic_status.includes('رسوب') && !r.academic_status.includes('ملاحق')).length;
      const passRate = totalStudents > 0 ? ((passedStudents / totalStudents) * 100).toFixed(1) : 0;
      const totalBatches = (db.uploaded_batches || []).length;
      const totalDepts = (db.departments || []).length;

      return sendJson(res, 200, {
        success: true,
        data: {
          totalStudents,
          passedStudents,
          passRate: `${passRate}%`,
          totalBatches,
          totalDepts,
          academicYear: (db.settings && db.settings.academicYear) || '2025/2026'
        }
      });
    }

    // جلب كافة النتائج مع التصفية والبحث
    if (method === 'GET' && pathname === '/api/admin/results') {
      const db = loadDatabase();
      let list = [...db.results];

      const { dept, semester, query } = parsedUrl.query;
      if (dept) list = list.filter(r => r.department_id === dept);
      if (semester) list = list.filter(r => r.semester_id === parseInt(semester));
      if (query) {
        const q = query.toLowerCase();
        list = list.filter(r =>
          r.student_id.toLowerCase().includes(q) ||
          r.student_name.toLowerCase().includes(q)
        );
      }

      return sendJson(res, 200, { success: true, count: list.length, data: list });
    }

    // إضافة نتيجة طالب فردي جديدة
    if (method === 'POST' && pathname === '/api/admin/results') {
      const body = await parseBody(req);
      if (!body.student_id || !body.student_name) {
        return sendJson(res, 400, { success: false, message: 'الرقم الجامعي واسم الطالب مطلوبان' });
      }

      const db = loadDatabase();
      const newId = 'res-' + Date.now();
      const newResult = {
        id: newId,
        student_id: body.student_id.trim(),
        student_name: body.student_name.trim(),
        department_id: body.department_id || 'CS',
        department_name: body.department_name || 'علوم الحاسوب وتكنولوجيا المعلومات',
        semester_id: body.semester_id ? parseInt(body.semester_id) : 1,
        semester_name: body.semester_name || 'الفصل الدراسي الأول',
        academic_year: body.academic_year || '2025/2026',
        semester_gpa: parseFloat(body.semester_gpa || 3.0),
        cumulative_gpa: parseFloat(body.cumulative_gpa || 3.0),
        total_credit_hours: parseInt(body.total_credit_hours || 18),
        passed_credit_hours: parseInt(body.passed_credit_hours || 18),
        academic_status: body.academic_status || 'ناجح',
        notes: body.notes || 'تمت الإضافة عبر لوحة التحكم',
        courses: body.courses || [],
        published_at: new Date().toISOString()
      };

      // حذف أي سجل قديم بنفس الرقم والفصل إن وجد وتحديثه
      db.results = db.results.filter(r => !(r.student_id === newResult.student_id && r.semester_id === newResult.semester_id));
      db.results.unshift(newResult);
      saveDatabase(db);

      return sendJson(res, 201, { success: true, message: 'تم حفظ نتيجة الطالب بنجاح', data: newResult });
    }

    // تعديل نتيجة طالب
    if (method === 'PUT' && pathname.startsWith('/api/admin/results/')) {
      const id = pathname.split('/')[4];
      const body = await parseBody(req);
      const db = loadDatabase();
      const index = db.results.findIndex(r => r.id === id);

      if (index === -1) {
        return sendJson(res, 404, { success: false, message: 'لم يتم العثور على السجل' });
      }

      db.results[index] = { ...db.results[index], ...body, id };
      saveDatabase(db);
      return sendJson(res, 200, { success: true, message: 'تم تحديث النتيجة بنجاح', data: db.results[index] });
    }

    // حذف نتيجة طالب
    if (method === 'DELETE' && pathname.startsWith('/api/admin/results/')) {
      const id = pathname.split('/')[4];
      const db = loadDatabase();
      const initialCount = db.results.length;
      db.results = db.results.filter(r => r.id !== id);

      if (db.results.length === initialCount) {
        return sendJson(res, 404, { success: false, message: 'لم يتم العثور على السجل' });
      }

      saveDatabase(db);
      return sendJson(res, 200, { success: true, message: 'تم حذف السجل بنجاح' });
    }

    // رفع كشف نتيجة PDF واستخراج بيانات الطلاب (PDF Upload & Auto-Extract)
    if (method === 'POST' && pathname === '/api/admin/upload-pdf') {
      const body = await parseBody(req);
      const {
        department_id,
        semester_id,
        academic_year,
        file_name,
        file_base64,
        students_data
      } = body;

      const db = loadDatabase();
      const dept = db.departments.find(d => d.id === department_id) || { name: 'الكلية' };
      const sem = db.semesters.find(s => s.id === parseInt(semester_id)) || { name: 'الفصل الدراسي' };

      const batchId = 'batch-' + Date.now();
      const savedFileName = file_name || `${department_id}_Sem${semester_id}_${Date.now()}.pdf`;
      const filePath = path.join(STORAGE_DIR, savedFileName);

      // إذا وُجد ملف بصيغة Base64 نقوم بحفظه في التخزين
      if (file_base64) {
        const buffer = Buffer.from(file_base64.replace(/^data:application\/pdf;base64,/, ''), 'base64');
        fs.writeFileSync(filePath, buffer);
      } else {
        // توليد ملف PDF رئيسي للكشف تلقائياً
        const samplePdf = generateStudentTranscriptPdf({
          student_name: `كشف نتائج: ${dept.name}`,
          student_id: `دفعة_${department_id}_${semester_id}`,
          department_name: dept.name,
          semester_name: sem.name,
          academic_year: academic_year || '2025/2026',
          courses: []
        });
        fs.writeFileSync(filePath, samplePdf);
      }

      // استخراج وإدراج درجات الطلاب (إذا تم تمرير قائمة الطلاب المستخرجة أو استخدام النموذج الذكي)
      let importedCount = 0;
      if (Array.isArray(students_data) && students_data.length > 0) {
        students_data.forEach(st => {
          const resId = 'res-' + Date.now() + '-' + Math.floor(Math.random() * 1000);
          const studentRecord = {
            id: resId,
            student_id: st.student_id.toString().trim(),
            student_name: st.student_name.trim(),
            department_id: department_id,
            department_name: dept.name,
            semester_id: parseInt(semester_id),
            semester_name: sem.name,
            academic_year: academic_year || '2025/2026',
            semester_gpa: parseFloat(st.semester_gpa || 3.2),
            cumulative_gpa: parseFloat(st.cumulative_gpa || 3.1),
            total_credit_hours: parseInt(st.total_credit_hours || 18),
            passed_credit_hours: parseInt(st.passed_credit_hours || 18),
            academic_status: st.academic_status || 'ناجح',
            courses: st.courses || [],
            original_pdf_url: `/storage/uploads/${savedFileName}`,
            published_at: new Date().toISOString()
          };

          db.results = db.results.filter(r => !(r.student_id === studentRecord.student_id && r.semester_id === studentRecord.semester_id));
          db.results.push(studentRecord);
          importedCount++;
        });
      }

      // إضافة الدفعة إلى سجل الملفات المرفوعة
      db.uploaded_batches.unshift({
        id: batchId,
        filename: savedFileName,
        department_id: department_id,
        department_name: dept.name,
        semester_id: parseInt(semester_id),
        semester_name: sem.name,
        academic_year: academic_year || '2025/2026',
        students_count: importedCount,
        uploaded_at: new Date().toISOString(),
        file_url: `/storage/uploads/${savedFileName}`
      });

      saveDatabase(db);

      return sendJson(res, 200, {
        success: true,
        message: `تم رفع ملف كشف الـ PDF بنجاح واستخراج ${importedCount} سجل طالب إلى قاعدة البيانات`,
        batch_id: batchId,
        file_url: `/storage/uploads/${savedFileName}`,
        imported_count: importedCount
      });
    }

    // سجل الملفات المرفوعة
    if (method === 'GET' && pathname === '/api/admin/batches') {
      const db = loadDatabase();
      return sendJson(res, 200, { success: true, data: db.uploaded_batches || [] });
    }

    // -------------------------------------------------------------
    // 3. خدمة الملفات الثابتة ولوحة التحكم والمحاكي
    // -------------------------------------------------------------

    // ملفات التخزين السحابية /storage/uploads/*
    if (pathname.startsWith('/storage/uploads/')) {
      const fileName = path.basename(pathname);
      const targetFile = path.join(STORAGE_DIR, fileName);
      if (fs.existsSync(targetFile)) {
        const stat = fs.statSync(targetFile);
        res.writeHead(200, {
          'Content-Type': 'application/pdf',
          'Content-Length': stat.size,
          'Access-Control-Allow-Origin': '*'
        });
        const readStream = fs.createReadStream(targetFile);
        return readStream.pipe(res);
      } else {
        res.writeHead(404);
        return res.end('File not found');
      }
    }

    // صفحة لوحة التحكم الإدارية /admin
    if (pathname === '/admin' || pathname === '/admin/' || pathname === '/') {
      const adminFile = path.join(PUBLIC_DIR, 'index.html');
      if (fs.existsSync(adminFile)) {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        return fs.createReadStream(adminFile).pipe(res);
      }
    }

    // محاكي تطبيق الموبايل التفاعلي /simulator
    if (pathname === '/simulator' || pathname === '/simulator/') {
      const simFile = path.join(PUBLIC_DIR, 'simulator.html');
      if (fs.existsSync(simFile)) {
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        return fs.createReadStream(simFile).pipe(res);
      }
    }

    // ملفات static في public/
    const staticPath = path.join(PUBLIC_DIR, pathname);
    if (fs.existsSync(staticPath) && fs.statSync(staticPath).isFile()) {
      let contentType = 'text/plain';
      if (pathname.endsWith('.html')) contentType = 'text/html; charset=utf-8';
      else if (pathname.endsWith('.js')) contentType = 'application/javascript; charset=utf-8';
      else if (pathname.endsWith('.css')) contentType = 'text/css; charset=utf-8';
      else if (pathname.endsWith('.png')) contentType = 'image/png';
      else if (pathname.endsWith('.svg')) contentType = 'image/svg+xml';
      else if (pathname.endsWith('.pdf')) contentType = 'application/pdf';

      res.writeHead(200, { 'Content-Type': contentType });
      return fs.createReadStream(staticPath).pipe(res);
    }

    // 404 لغير المعرف
    return sendJson(res, 404, { success: false, message: 'المسار المطلوب غير موجود' });

  } catch (error) {
    console.error('Server Internal Error:', error);
    return sendJson(res, 500, { success: false, message: 'خطأ داخلي في الخادم: ' + error.message });
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`=======================================================`);
  console.log(`NKC Results System Server is running!`);
  console.log(`Port: ${PORT}`);
  console.log(`Admin Dashboard: http://localhost:${PORT}/admin`);
  console.log(`Student App Simulator: http://localhost:${PORT}/simulator`);
  console.log(`REST API Health Check: http://localhost:${PORT}/api/departments`);
  console.log(`=======================================================`);
});

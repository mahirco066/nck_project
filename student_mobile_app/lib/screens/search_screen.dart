import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/student_result.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController =
      TextEditingController(text: '2023001');

  String _selectedDepartmentId = 'CS';
  int _selectedSemesterId = 4;
  bool _isLoading = false;

  void _performSearch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.fetchStudentResult(
        studentId: _studentIdController.text.trim(),
        departmentId: _selectedDepartmentId,
        semesterId: _selectedSemesterId,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('تنبيه الاستعلام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  void _showServerSettingsDialog() {
    final controller = TextEditingController();
    ApiService.getBaseUrl().then((url) => controller.text = url);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إعدادات خادم النتائج (API URL)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل عنوان السيرفر المحلي أو السحابي للاتصال بقاعدة بيانات النتائج:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'http://192.168.1.5:5000/api',
                prefixIcon: Icon(Icons.dns),
              ),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.setBaseUrl(controller.text.trim());
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديث رابط الخادم بنجاح')),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'إعدادات الخادم',
            onPressed: _showServerSettingsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // بطاقة الترحيب والإعلان الرسمي
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppConstants.navyBlue, Color(0xFF2C5282)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.navyBlue.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppConstants.accentGold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'بوابة الكنترول والنتائج المعتمدة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'يرجى إدخال الرقم الجامعي واختيار التخصص والفصل الدراسي للاطلاع على نتيجتك وسحب إشعار الدرجات.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // بطاقة النموذج الرئيسي
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // حقل الرقم الجامعي
                      const Text(
                        'الرقم الجامعي (University ID)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _studentIdController,
                        keyboardType: TextInputType.number,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'مثال: 2023001',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => _studentIdController.clear(),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'يرجى إدخال الرقم الجامعي';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // القائمة المنسدلة للكلية / التخصص
                      const Text(
                        'الكلية / التخصص الأكاديمي',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedDepartmentId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                        items: AppConstants.departments.map((dept) {
                          return DropdownMenuItem<String>(
                            value: dept['id'],
                            child: Text(
                              dept['name']!,
                              style: const TextStyle(fontSize: 12.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDepartmentId = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // القائمة المنسدلة للفصل الدراسي
                      const Text(
                        'الفصل الدراسي (Semester)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedSemesterId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.calendar_month_outlined),
                        ),
                        items: AppConstants.semesters.map((sem) {
                          return DropdownMenuItem<int>(
                            value: sem['id'] as int,
                            child: Text(
                              sem['name'] as String,
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSemesterId = val);
                        },
                      ),
                      const SizedBox(height: 24),

                      // زر الاستعلام
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _performSearch,
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('جاري جلب النتيجة...'),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.search_rounded, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'عرض النتيجة / استعلام',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // أرقام تجريبية سريعة للفحص المباشر
              const Text(
                'أرقام جامعية نموذجية للفحص السريع:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.textDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.person, size: 16, color: AppConstants.primaryGreen),
                    label: const Text('2023001 (علوم حاسوب)'),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppConstants.primaryGreen.withOpacity(0.4)),
                    onPressed: () {
                      setState(() {
                        _studentIdController.text = '2023001';
                        _selectedDepartmentId = 'CS';
                        _selectedSemesterId = 4;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.person, size: 16, color: AppConstants.navyBlue),
                    label: const Text('2023002 (إدارة أعمال)'),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: AppConstants.navyBlue.withOpacity(0.4)),
                    onPressed: () {
                      setState(() {
                        _studentIdController.text = '2023002';
                        _selectedDepartmentId = 'BA';
                        _selectedSemesterId = 4;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // تنويه أمانة الشؤون العلمية
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_rounded, color: Colors.amber.shade800, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'في حال عدم ظهور النتيجة أو وجود أي استفسار حول التقديرات، يرجى مراجعة إدارة شؤون الطلاب والامتحانات بالكلية مع إحضار البطاقة الجامعية.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.amber.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

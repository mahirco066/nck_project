import 'package:flutter/material.dart';
import '../config/constants.dart';
import 'search_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // الانتقال لشاشة البحث بعد ثانيتين ونصف
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.primaryGreen,
      body: Stack(
        children: [
          // خلفية زخرفية ناعمة
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // شعار الكلية
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(
                          color: AppConstants.accentGold,
                          width: 3.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.school_rounded,
                          size: 60,
                          color: AppConstants.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // اسم الكلية بالعربية
                    const Text(
                      AppConstants.collegeNameAr,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // اسم الكلية بالإنجليزية
                    const Text(
                      AppConstants.collegeNameEn,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.accentGold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // اسم التطبيق
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: const Text(
                        'بوابة استعلام النتائج والشهادات الأكاديمية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 45),

                    // مؤشر تحميل أنيق
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppConstants.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // فوتر الشاشة
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'العام الأكاديمي ${AppConstants.academicYear}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

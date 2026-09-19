import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/constants.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NKCResultApp());
}

class NKCResultApp extends StatelessWidget {
  const NKCResultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // تفعيل اللغة العربية والاتجاه من اليمين لليسار (RTL)
      locale: const Locale('ar', 'SD'),
      supportedLocales: const [
        Locale('ar', 'SD'),
        Locale('ar', 'SA'),
        Locale('ar', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const SplashScreen(),
    );
  }
}

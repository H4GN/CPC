import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/app_colors.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CPCApp());
}

class CPCApp extends StatelessWidget {
  const CPCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
          secondary: AppColors.sky,
        ),
        textTheme: GoogleFonts.notoSansSinhalaTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
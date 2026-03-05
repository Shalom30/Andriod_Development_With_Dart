// ============================================================
//  FILE: lib/main.dart
//
//  This is the entry point of the entire Flutter application.
//
//  CONCEPTS USED HERE:
//  ✅ Functions — main() is the top-level entry-point function.
//  ✅ OOP       — GradeVaultApp is a StatelessWidget class.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

/// main() is the FUNCTION that Dart calls first when the app starts.
void main() {
  // Ensure Flutter binding is ready before running on desktop.
  WidgetsFlutterBinding.ensureInitialized();

  // Run the root widget.
  runApp(const GradeVaultApp());
}

/// GradeVaultApp — the root widget of the application.
/// It configures the theme and sets the home screen.
class GradeVaultApp extends StatelessWidget {
  const GradeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Vault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
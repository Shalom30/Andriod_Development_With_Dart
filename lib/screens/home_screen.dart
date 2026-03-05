// ============================================================
//  FILE: lib/screens/home_screen.dart
//
//  CONCEPTS USED HERE:
//  ✅ OOP        — HomeScreen is a StatefulWidget (class).
//  ✅ Functions  — _pickFile(), _processFile() are named functions.
//  ✅ Safe code  — every async operation uses try/catch.
//  ✅ Delayed init (late) — _filePath is declared late and only
//                 assigned once the user picks a file.
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/student.dart';
import '../services/excel_service.dart';
import '../theme/app_theme.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ✅ DELAYED INIT — _filePath is declared but not given a value
  //    until the user actually picks a file.  We use a nullable
  //    String instead of `late` here so the UI can show an
  //    empty state safely.
  String? _filePath;
  bool _isLoading = false;
  String? _errorMessage;

  // ✅ FUNCTION — picks a file using the system dialog.
  Future<void> _pickFile() async {
    setState(() => _errorMessage = null);

    // FilePicker opens the OS file-chooser dialog.
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
      dialogTitle: 'Select Student Grade Excel File',
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _filePath = result.files.single.path!);
    }
  }

  // ✅ FUNCTION — reads the file and navigates to ResultsScreen.
  Future<void> _processFile() async {
    if (_filePath == null) {
      setState(() => _errorMessage = 'Please select an Excel file first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ✅ SAFE CODE — wrap in try/catch so errors are shown in UI.
    try {
      final List<Student> students =
          await ExcelService.readStudents(_filePath!);

      if (!mounted) return;

      // Navigate to results screen, passing the processed data.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(students: students),
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ───────────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Row(
        children: [
          // ── Left accent panel ───────────────────────────────
          _buildSidebar(),

          // ── Main content ────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildUploadCard(),
                  const SizedBox(height: 24),
                  if (_errorMessage != null) _buildError(),
                  const SizedBox(height: 40),
                  _buildInstructions(),
                  const SizedBox(height: 40),
                  _buildGradingTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sidebar ──────────────────────────────────────────────────
  Widget _buildSidebar() {
    return Container(
      width: 72,
      color: AppTheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF9D97FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 32),
          const Divider(color: AppTheme.divider, indent: 16, endIndent: 16),
          const SizedBox(height: 16),
          _sideIcon(Icons.home_rounded, true),
          _sideIcon(Icons.bar_chart_rounded, false),
          _sideIcon(Icons.settings_rounded, false),
        ],
      ),
    );
  }

  Widget _sideIcon(IconData icon, bool active) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Icon(
          icon,
          color: active ? AppTheme.accent : AppTheme.textSecond,
          size: 22,
        ),
      );

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GRADE VAULT',
          style: GoogleFonts.rajdhani(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: 4,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        const SizedBox(height: 8),
        Text(
          'Student grade processing & report generation',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.textSecond,
          ),
        ).animate(delay: 200.ms).fadeIn(),
        const SizedBox(height: 16),
        Container(
          height: 3,
          width: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accent, AppTheme.accentLight],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ).animate(delay: 300.ms).fadeIn().scaleX(alignment: Alignment.centerLeft),
      ],
    );
  }

  // ── Upload card ──────────────────────────────────────────────
  Widget _buildUploadCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _filePath != null
              ? AppTheme.accent.withOpacity(0.5)
              : AppTheme.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.upload_file_rounded,
                  color: AppTheme.accent, size: 22),
              const SizedBox(width: 10),
              Text(
                'Upload Excel File',
                style: GoogleFonts.rajdhani(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // File path display
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _filePath != null
                      ? AppTheme.accent
                      : AppTheme.divider,
                  style: _filePath == null
                      ? BorderStyle.solid
                      : BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _filePath != null
                        ? Icons.check_circle_rounded
                        : Icons.folder_open_rounded,
                    color: _filePath != null
                        ? AppTheme.success
                        : AppTheme.textSecond,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _filePath ??
                          'Click to browse for your Excel file (.xlsx)',
                      style: GoogleFonts.inter(
                        color: _filePath != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecond,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_filePath != null)
                    GestureDetector(
                      onTap: () => setState(() => _filePath = null),
                      child: const Icon(Icons.close,
                          color: AppTheme.textSecond, size: 16),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Browse'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentLight,
                  side: const BorderSide(color: AppTheme.accentLight),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _processFile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text(_isLoading ? 'Processing...' : 'Process Grades'),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1);
  }

  // ── Error banner ─────────────────────────────────────────────
  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.danger.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                color: AppTheme.danger,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake();
  }

  // ── Instructions ─────────────────────────────────────────────
  Widget _buildInstructions() {
    // ✅ LAMBDA — used inside .map() to build instruction items.
    final steps = [
      (
        '1',
        'Prepare your Excel file',
        'Column A: Student Name  |  Column B: CA Mark (/40)  |  Column C: Exam Mark (/100)',
        Icons.table_chart_rounded,
      ),
      (
        '2',
        'Upload & Process',
        'Click Browse to select your file, then click Process Grades.',
        Icons.upload_rounded,
      ),
      (
        '3',
        'Download Report',
        'Export results as a formatted Excel file or a styled PDF report.',
        Icons.download_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOW IT WORKS',
          style: GoogleFonts.rajdhani(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecond,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        ...steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    step.$1,
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.$2,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          )),
                      Text(step.$3,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecond,
                            fontSize: 12,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate(delay: 500.ms).fadeIn();
  }

  // ── Grading table ────────────────────────────────────────────
  Widget _buildGradingTable() {
    const bands = [
      ('A',  '4.0', '80 – 100', Color(0xFF2ECC71)),
      ('B+', '3.5', '70 – 79',  Color(0xFF27AE60)),
      ('B',  '3.0', '60 – 69',  Color(0xFF3498DB)),
      ('C+', '2.5', '55 – 59',  Color(0xFF2980B9)),
      ('C',  '2.0', '50 – 54',  Color(0xFFF39C12)),
      ('D+', '1.5', '45 – 49',  Color(0xFFE67E22)),
      ('D',  '1.0', '40 – 44',  Color(0xFFE74C3C)),
      ('F',  '0.0', '0 – 39',   Color(0xFF95A5A6)),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GRADING SCALE',
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecond,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bands.map((b) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: b.$4.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: b.$4.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Text(b.$1,
                        style: TextStyle(
                            color: b.$4,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text('GPA ${b.$2}',
                        style: TextStyle(color: b.$4, fontSize: 10)),
                    Text(b.$3,
                        style: const TextStyle(
                            color: AppTheme.textSecond, fontSize: 10)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn();
  }
}
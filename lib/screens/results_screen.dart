// ============================================================
//  FILE: lib/screens/results_screen.dart
//
//  CONCEPTS USED HERE:
//  ✅ OOP        — ResultsScreen is a StatefulWidget (class).
//  ✅ Functions  — _exportExcel(), _exportPdf() are named functions.
//  ✅ Lambdas    — used in .map(), .where(), .reduce() calls.
//  ✅ Safe code  — try/catch around every file operation.
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/student.dart';
import '../services/excel_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/grade_badge.dart';
import '../widgets/stat_card.dart';

class ResultsScreen extends StatefulWidget {
  final List<Student> students;

  const ResultsScreen({super.key, required this.students});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _sortField = 'name'; // current sort column
  bool _sortAsc     = true;
  String _searchQuery = '';
  bool _isExporting = false;

  // ✅ DELAYED INIT (late) — computed once when needed, then cached
  late final double _avgMark;
  late final double _avgGpa;
  late final int    _passed;
  late final int    _failed;

  @override
  void initState() {
    super.initState();
    // ✅ DELAYED INIT — assigned here, after the widget is inserted
    //    into the tree.  This is the Dart `late` pattern: declare at
    //    the top, assign before first use.
    _computeStats();
  }

  void _computeStats() {
    final students = widget.students;
    if (students.isEmpty) {
      _avgMark = 0;
      _avgGpa  = 0;
      _passed  = 0;
      _failed  = 0;
      return;
    }

    // ✅ LAMBDA — reduce() uses an anonymous function to sum marks.
    _avgMark = students
            .map((s) => s.finalMark)       // lambda: s => s.finalMark
            .reduce((a, b) => a + b)       // lambda: sum
        / students.length;

    _avgGpa = students
            .map((s) => s.gpa)
            .reduce((a, b) => a + b)
        / students.length;

    // ✅ LAMBDA — where() filters with a lambda predicate.
    _passed = students.where((s) => s.finalMark >= 40).length;
    _failed = students.length - _passed;
  }

  // ── Sorted + filtered list ──────────────────────────────────
  List<Student> get _filteredStudents {
    // ✅ LAMBDA — where() + contains() applied via lambdas.
    var list = widget.students
        .where((s) =>
            s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Sort using a lambda comparator.
    list.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case 'name':
          cmp = a.name.compareTo(b.name);
        case 'ca':
          cmp = a.caMark.compareTo(b.caMark);
        case 'exam':
          cmp = a.examMark.compareTo(b.examMark);
        case 'final':
          cmp = a.finalMark.compareTo(b.finalMark);
        case 'gpa':
          cmp = a.gpa.compareTo(b.gpa);
        default:
          cmp = 0;
      }
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  // ── Export helpers ──────────────────────────────────────────

  // ✅ FUNCTION — named async function for Excel export.
  Future<void> _exportExcel() async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Results as Excel',
      fileName: 'grade_results.xlsx',
      allowedExtensions: ['xlsx'],
      type: FileType.custom,
    );
    if (path == null) return;

    setState(() => _isExporting = true);
    try {
      await ExcelService.writeResults(widget.students, path);
      _showSuccess('Excel file saved successfully!');
    } catch (e) {
      _showError('Export failed: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  // ✅ FUNCTION — named async function for PDF export.
  Future<void> _exportPdf() async {
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Results as PDF',
      fileName: 'grade_results.pdf',
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );
    if (path == null) return;

    setState(() => _isExporting = true);
    try {
      await PdfService.generatePdf(widget.students, path);
      _showSuccess('PDF report saved successfully!');
    } catch (e) {
      _showError('Export failed: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(msg),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _setSort(String field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc = true;
      }
    });
  }

  // ───────────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(),
                  const SizedBox(height: 32),
                  _buildTableHeader(),
                  const SizedBox(height: 16),
                  _buildTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppTheme.textPrimary),
            tooltip: 'Back',
          ),
          const SizedBox(width: 12),
          Text(
            'RESULTS',
            style: GoogleFonts.rajdhani(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.students.length} students',
              style: const TextStyle(
                color: AppTheme.accentLight,
                fontSize: 12,
              ),
            ),
          ),
          const Spacer(),

          // ── Export buttons ────────────────────────────────
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppTheme.accent),
              ),
            ),

          OutlinedButton.icon(
            onPressed: _isExporting ? null : _exportExcel,
            icon: const Icon(Icons.table_chart_rounded, size: 18),
            label: const Text('Export Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.success,
              side: const BorderSide(color: AppTheme.success),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: _isExporting ? null : _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.danger,
              side: const BorderSide(color: AppTheme.danger),
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat cards ───────────────────────────────────────────────
  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        StatCard(
          label: 'Total Students',
          value: '${widget.students.length}',
          icon: Icons.people_rounded,
          color: AppTheme.accent,
        ),
        StatCard(
          label: 'Average Mark',
          value: '${_avgMark.toStringAsFixed(1)}%',
          icon: Icons.trending_up_rounded,
          color: AppTheme.accentLight,
        ),
        StatCard(
          label: 'Passed',
          value: '$_passed',
          icon: Icons.check_circle_rounded,
          color: AppTheme.success,
        ),
        StatCard(
          label: 'Failed',
          value: '$_failed',
          icon: Icons.cancel_rounded,
          color: AppTheme.danger,
        ),
      ],
    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1);
  }

  // ── Table header + search ─────────────────────────────────────
  Widget _buildTableHeader() {
    return Row(
      children: [
        Text(
          'STUDENT RECORDS',
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 280,
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by name…',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.textSecond, size: 18),
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 10, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ── Results table ────────────────────────────────────────────
  Widget _buildTable() {
    final students = _filteredStudents;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          _tableHeaderRow(),

          // Data rows
          if (students.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No students match your search.',
                style: const TextStyle(color: AppTheme.textSecond),
              ),
            )
          else
            ...students.asMap().entries.map((entry) {
              return _tableDataRow(entry.value, entry.key);
            }),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn();
  }

  Widget _tableHeaderRow() {
    // ✅ LAMBDA — columns defined as a list of records, mapped to widgets.
    final cols = [
      ('#',          '',        60.0),
      ('Name',       'name',   200.0),
      ('CA /40',     'ca',     100.0),
      ('Exam /100',  'exam',   110.0),
      ('Final /100', 'final',  120.0),
      ('Grade',      'grade',  100.0),
      ('GPA',        'gpa',     90.0),
    ];

    return Container(
      color: AppTheme.surfaceAlt,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: cols.map((c) {
          final isActive = _sortField == c.$2;
          return SizedBox(
            width: c.$3,
            child: GestureDetector(
              onTap: c.$2.isEmpty ? null : () => _setSort(c.$2),
              child: Row(
                children: [
                  Text(
                    c.$1,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppTheme.accent
                          : AppTheme.textSecond,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isActive)
                    Icon(
                      _sortAsc
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: AppTheme.accent,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _tableDataRow(Student s, int index) {
    final isEven = index.isEven;
    return Container(
      color: isEven ? Colors.transparent : AppTheme.surfaceAlt.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // index
          SizedBox(
            width: 60,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  color: AppTheme.textSecond, fontSize: 12),
            ),
          ),
          // name
          SizedBox(
            width: 200,
            child: Text(
              s.name,
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // CA
          SizedBox(
            width: 100,
            child: Text(
              s.caMark.toStringAsFixed(1),
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13),
            ),
          ),
          // Exam
          SizedBox(
            width: 110,
            child: Text(
              s.examMark.toStringAsFixed(1),
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13),
            ),
          ),
          // Final
          SizedBox(
            width: 120,
            child: Text(
              s.finalMark.toStringAsFixed(2),
              style: GoogleFonts.inter(
                color: AppTheme.accentLight,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          // Grade badge
          SizedBox(
            width: 100,
            child: GradeBadge(grade: s.grade),
          ),
          // GPA
          SizedBox(
            width: 90,
            child: Text(
              s.gpa.toStringAsFixed(1),
              style: TextStyle(
                color: AppTheme.gradeColor(s.grade),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
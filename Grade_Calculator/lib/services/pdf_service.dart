// ============================================================
//  FILE: lib/services/pdf_service.dart
//
//  CONCEPTS USED HERE:
//  ✅ Functions  — generatePdf() is a reusable async function.
//  ✅ OOP        — PdfService groups all PDF logic together.
//  ✅ Lambdas    — used in .map() and list comprehensions.
//  ✅ Safe code  — null safety throughout.
// ============================================================

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/student.dart';

class PdfService {
  /// Generates a styled PDF report from [students] and saves
  /// it at [outputPath].
  static Future<void> generatePdf(
    List<Student> students,
    String outputPath,
  ) async {
    final pdf = pw.Document();

    // ✅ LAMBDA — map() transforms each student into a table row.
    final dataRows = students.map((s) => [
      s.name,
      s.caMark.toStringAsFixed(1),
      s.examMark.toStringAsFixed(1),
      s.finalMark.toStringAsFixed(2),
      s.grade,
      s.gpa.toStringAsFixed(1),
    ]).toList();

    // Colour palette
    const headerBg  = PdfColor.fromInt(0xFF1a1a2e);
    const accentCol = PdfColor.fromInt(0xFF6c63ff);
    const oddRow    = PdfColor.fromInt(0xFFF0F0FA);
    const evenRow   = PdfColors.white;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // ── Title block ──────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: headerBg,
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GRADE VAULT',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Student Grade Report  •  Generated ${_today()}',
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey300,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Total students: ${students.length}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ── Summary statistics ───────────────────────────
          _buildSummary(students, accentCol),

          pw.SizedBox(height: 20),

          // ── Main data table ──────────────────────────────
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.8),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.2),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: accentCol),
                children: ['Name', 'CA /40', 'Exam /100',
                           'Final /100', 'Grade', 'GPA']
                    .map((h) => _headerCell(h))
                    .toList(),
              ),
              // Data rows
              ...dataRows.asMap().entries.map((entry) {
                final rowColor = entry.key.isEven ? evenRow : oddRow;
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: rowColor),
                  children: entry.value
                      .map((cell) => _dataCell(cell))
                      .toList(),
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          // ── Grading key ──────────────────────────────────
          _buildGradingKey(accentCol),
        ],
      ),
    );

    await File(outputPath).writeAsBytes(await pdf.save());
  }

  // ── Helpers ──────────────────────────────────────────────

  static pw.Widget _buildSummary(
    List<Student> students,
    PdfColor accent,
  ) {
    // ✅ LAMBDA — reduce/map to compute stats
    final avg = students.isEmpty
        ? 0.0
        : students.map((s) => s.finalMark).reduce((a, b) => a + b) /
          students.length;
    final passed = students.where((s) => s.finalMark >= 40).length;
    final failed = students.length - passed;

    return pw.Row(
      children: [
        _statBox('Average Mark', '${avg.toStringAsFixed(1)}%', accent),
        pw.SizedBox(width: 10),
        _statBox('Passed', '$passed', const PdfColor.fromInt(0xFF2ecc71)),
        pw.SizedBox(width: 10),
        _statBox('Failed', '$failed', const PdfColor.fromInt(0xFFe74c3c)),
      ],
    );
  }

  static pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
            pw.Text(value,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }

  static pw.Widget _headerCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );

  static pw.Widget _dataCell(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      );

  static pw.Widget _buildGradingKey(PdfColor accent) {
    // ✅ LAMBDA — map over grade bands to build the key rows
    const bands = [
      ('A',  '4.0', '80 – 100'),
      ('B+', '3.5', '70 – 79'),
      ('B',  '3.0', '60 – 69'),
      ('C+', '2.5', '55 – 59'),
      ('C',  '2.0', '50 – 54'),
      ('D+', '1.5', '45 – 49'),
      ('D',  '1.0', '40 – 44'),
      ('F',  '0.0', '0 – 39'),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Grading Key',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: accent,
              fontSize: 13,
            )),
        pw.SizedBox(height: 6),
        pw.Wrap(
          spacing: 8,
          runSpacing: 4,
          children: bands
              .map((b) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '${b.$1} (GPA ${b.$2}): ${b.$3}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  static String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}
// ============================================================
//  FILE: lib/services/excel_service.dart
//
//  CONCEPTS USED HERE:
//  ✅ Functions    — readStudents() and writeResults() are named,
//                   reusable async functions.
//  ✅ OOP          — ExcelService is a class that groups all
//                   Excel I/O logic together.
//  ✅ Safe code    — every operation is wrapped in try/catch
//                   and null-safety is respected throughout.
// ============================================================

import 'dart:io';
import 'package:excel/excel.dart';
import '../models/student.dart';

class ExcelService {
  // -------------------------------------------------------
  // READ — parse an input Excel file into a list of Students
  // -------------------------------------------------------
  /// Returns a list of [Student] objects read from [filePath].
  /// Throws a descriptive [Exception] if anything goes wrong.
  static Future<List<Student>> readStudents(String filePath) async {
    // ✅ SAFE CODE — we validate the file exists before touching it.
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    // Take the first sheet in the workbook.
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) {
      throw Exception('The Excel file has no sheets.');
    }

    final List<Student> students = [];

    // Row 0 is the header row — skip it (start at index 1).
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.row(i);

      // ✅ SAFE CODE — null-aware operators (??) provide defaults
      //    so a blank row never crashes the app.
      final name     = _cellString(row, 0);
      final caMark   = _cellDouble(row, 1);
      final examMark = _cellDouble(row, 2);

      // Skip completely empty rows.
      if (name.isEmpty) continue;

      // ✅ SAFE CODE — validate mark ranges.
      if (caMark < 0 || caMark > 40) {
        throw Exception(
          'CA mark for "$name" is $caMark — must be between 0 and 40.',
        );
      }
      if (examMark < 0 || examMark > 100) {
        throw Exception(
          'Exam mark for "$name" is $examMark — must be between 0 and 100.',
        );
      }

      students.add(Student(
        name: name,
        caMark: caMark,
        examMark: examMark,
      ));
    }

    if (students.isEmpty) {
      throw Exception(
        'No student data found. Make sure your Excel file has:\n'
        'Column A: Student Name\n'
        'Column B: CA Mark (out of 40)\n'
        'Column C: Exam Mark (out of 100)',
      );
    }

    return students;
  }

  // -------------------------------------------------------
  // WRITE — save processed results to a new Excel file
  // -------------------------------------------------------
  /// Writes [students] to an Excel file at [outputPath].
  static Future<void> writeResults(
    List<Student> students,
    String outputPath,
  ) async {
    final excel = Excel.createExcel();
    final sheet = excel['Results'];

    // --- Header row ---
    // ✅ LAMBDA — used inside map() to convert strings to cells.
    final headers = ['Student Name', 'CA Mark', 'Exam Mark',
                     'Final Mark', 'Grade', 'GPA'];

    for (int col = 0; col < headers.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[col]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1a1a2e'),
        fontColorHex: ExcelColor.fromHexString('#ffffff'),
      );
    }

    // --- Data rows ---
    for (int i = 0; i < students.length; i++) {
      final s = students[i];
      final rowIndex = i + 1;

      void setCell(int col, CellValue value) {
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: col,
              rowIndex: rowIndex,
            ))
            .value = value;
      }

      setCell(0, TextCellValue(s.name));
      setCell(1, DoubleCellValue(s.caMark));
      setCell(2, DoubleCellValue(s.examMark));
      setCell(3, DoubleCellValue(
        double.parse(s.finalMark.toStringAsFixed(2)),
      ));
      setCell(4, TextCellValue(s.grade));
      setCell(5, DoubleCellValue(s.gpa));
    }

    // Auto-size columns
    for (int col = 0; col < headers.length; col++) {
      sheet.setColumnWidth(col, 18);
    }

    // Save to disk.
    final outputBytes = excel.save();
    if (outputBytes == null) {
      throw Exception('Failed to encode Excel file.');
    }

    await File(outputPath).writeAsBytes(outputBytes);
  }

  // -------------------------------------------------------
  // Private helpers — ✅ SAFE CODE with null checks
  // -------------------------------------------------------
  static String _cellString(List<Data?> row, int col) {
    if (col >= row.length) return '';
    return row[col]?.value?.toString().trim() ?? '';
  }

  static double _cellDouble(List<Data?> row, int col) {
    if (col >= row.length) return 0.0;
    final val = row[col]?.value;
    if (val == null) return 0.0;
    if (val is IntCellValue) return val.value.toDouble();
    if (val is DoubleCellValue) return val.value;
    if (val is TextCellValue) return double.tryParse(val.value) ?? 0.0;
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
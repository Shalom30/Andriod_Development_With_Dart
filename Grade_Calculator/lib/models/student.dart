// ============================================================
//  FILE: lib/models/student.dart
// ============================================================

class Student {
  final String name;
  final double caMark;
  final double examMark;

  // ✅ DELAYED INIT — assigned inside _calculate()
  late final double finalMark;
  late final String grade;
  late final double gpa;

  Student({
    required this.name,
    required this.caMark,
    required this.examMark,
  }) {
    _calculate();
  }

  void _calculate() {
    final double caComponent   = caMark;
    final double examComponent = (examMark / 100) * 60;
    finalMark = caComponent + examComponent;

    final result = GradeCalculator.staticEvaluate(finalMark);
    grade = result.grade;
    gpa   = result.gpa;
  }

  @override
  String toString() =>
      'Student(name: $name, CA: $caMark, Exam: $examMark, '
      'Final: ${finalMark.toStringAsFixed(1)}, '
      'Grade: $grade, GPA: $gpa)';
}

// ── Value object ─────────────────────────────────────────────
class GradeResult {
  final String grade;
  final double gpa;
  const GradeResult(this.grade, this.gpa);
}

// ── Base class (Inheritance concept) ─────────────────────────
abstract class Calculator {
  GradeResult evaluate(double value);
}

// ── GradeCalculator extends Calculator ───────────────────────
// ✅ INHERITANCE — GradeCalculator IS-A Calculator
class GradeCalculator extends Calculator {
  static final GradeCalculator _instance = GradeCalculator._internal();
  factory GradeCalculator() => _instance;
  GradeCalculator._internal();

  // ✅ LAMBDA — firstWhere uses an anonymous function (b) => ...
  static const List<(double, String, double)> _bands = [
    (80, 'A',  4.0),
    (70, 'B+', 3.5),
    (60, 'B',  3.0),
    (55, 'C+', 2.5),
    (50, 'C',  2.0),
    (45, 'D+', 1.5),
    (40, 'D',  1.0),
    (0,  'F',  0.0),
  ];

  // FIX: renamed to staticEvaluate to avoid conflict with the
  // inherited instance method evaluate() from Calculator.
  static GradeResult staticEvaluate(double mark) {
    final band = _bands.firstWhere(
      (b) => mark >= b.$1,
      orElse: () => (0, 'F', 0.0),
    );
    return GradeResult(band.$2, band.$3);
  }

  // Implements the abstract method from Calculator (inheritance).
  @override
  GradeResult evaluate(double value) => GradeCalculator.staticEvaluate(value);
}
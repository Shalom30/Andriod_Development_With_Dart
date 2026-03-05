// ============================================================
//  FILE: lib/models/student.dart
//
//  CONCEPTS USED HERE:
//  ✅ Object-Oriented Programming (OOP) — Student is a class
//     with fields (properties) and methods (behaviour).
//  ✅ Delayed Initialization (late keyword) — some fields are
//     computed after the object is first created.
// ============================================================

/// Represents one row from the input Excel file.
/// Each student has a name, a CA mark (out of 40) and an exam
/// mark (out of 100).
class Student {
  // ---------- basic fields ----------
  final String name;
  final double caMark;   // raw CA mark  → out of 40
  final double examMark; // raw exam mark → out of 100

  // ---------- delayed-init fields ----------
  // These are marked `late` because we calculate them AFTER
  // the constructor runs.  Dart guarantees they will be set
  // before anyone reads them.
  late final double finalMark; // combined mark out of 100
  late final String grade;     // letter grade (A, B+, …, F)
  late final double gpa;       // GPA on a 4.0 scale

  // ---------- constructor ----------
  Student({
    required this.name,
    required this.caMark,
    required this.examMark,
  }) {
    // Trigger calculation immediately after construction.
    _calculate();
  }

  // ---------- private helper ----------
  void _calculate() {
    // CA is 40 % of the final mark.
    // The student's raw CA mark is already out of 40,
    // so it maps directly to 40 points.
    final double caComponent = caMark; // out of 40

    // The exam is 60 % of the final mark but the raw mark
    // is out of 100, so we convert it to be out of 60.
    final double examComponent = (examMark / 100) * 60; // out of 60

    // The two components add up to a mark out of 100.
    finalMark = caComponent + examComponent;

    // Use the grading function from GradeCalculator to assign
    // a grade and GPA (see grade_calculator.dart).
    final result = GradeCalculator.evaluate(finalMark);
    grade = result.grade;
    gpa   = result.gpa;
  }

  // ---------- convenience ----------
  @override
  String toString() =>
      'Student(name: $name, CA: $caMark, Exam: $examMark, '
      'Final: ${finalMark.toStringAsFixed(1)}, '
      'Grade: $grade, GPA: $gpa)';
}

// ============================================================
//  GradeResult — a tiny value object returned by GradeCalculator
// ============================================================
class GradeResult {
  final String grade;
  final double gpa;
  const GradeResult(this.grade, this.gpa);
}

// ============================================================
//  Calculator (base class)
//
//  CONCEPTS USED HERE:
//  ✅ Inheritance — GradeCalculator extends Calculator.
//     "A GradeCalculator IS A Calculator."
//     The base class defines the interface; the subclass
//     provides the specific implementation.
// ============================================================
abstract class Calculator {
  /// Every calculator must be able to evaluate a numeric value.
  GradeResult evaluate(double value);
}

// ============================================================
//  GradeCalculator — extends Calculator
//
//  CONCEPTS USED HERE:
//  ✅ Inheritance  — extends Calculator
//  ✅ Lambdas      — the grade boundaries are stored as a list
//                    of records evaluated with arrow syntax.
//  ✅ Static method — evaluate() is static so callers don't
//                    need to create an instance.
// ============================================================
class GradeCalculator extends Calculator {
  // --- Singleton so we can use it via inheritance if needed ---
  static final GradeCalculator _instance = GradeCalculator._internal();
  factory GradeCalculator() => _instance;
  GradeCalculator._internal();

  // ✅ LAMBDA / arrow syntax:
  // Each entry is a record (minMark, grade, gpa).
  // The list is searched top-to-bottom; the first matching
  // lambda `(mark) => mark >= minMark` wins.
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

  /// Static evaluate — uses a lambda to scan the bands list.
  static GradeResult evaluate(double mark) {
    // ✅ LAMBDA — firstWhere uses an anonymous function (lambda)
    //    to find the correct grading band.
    final band = _bands.firstWhere(
      (b) => mark >= b.$1,   // (b) => ... is a lambda
      orElse: () => (0, 'F', 0.0),
    );
    return GradeResult(band.$2, band.$3);
  }

  // Implementing the abstract method from Calculator (inheritance).
  @override
  GradeResult evaluate(double value) => GradeCalculator.evaluate(value);
}
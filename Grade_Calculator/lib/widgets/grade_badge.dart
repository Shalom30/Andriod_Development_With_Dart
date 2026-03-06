// ============================================================
//  FILE: lib/widgets/grade_badge.dart
//
//  CONCEPTS USED HERE:
//  ✅ OOP     — GradeBadge is a reusable Flutter widget (class).
//  ✅ Lambdas — colour lookup uses a switch expression (lambda-style).
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradeBadge extends StatelessWidget {
  final String grade;
  final double size;

  const GradeBadge({
    super.key,
    required this.grade,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.gradeColor(grade);
    return Container(
      width: size * 1.6,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.42,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
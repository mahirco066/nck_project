import 'package:flutter/material.dart';
import '../config/constants.dart';

class GradeBadge extends StatelessWidget {
  final String grade;
  final double size;

  const GradeBadge({
    Key? key,
    required this.grade,
    this.size = 38.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.getGradeColor(grade);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.8),
      ),
      child: Center(
        child: Text(
          grade.trim().toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.42,
          ),
        ),
      ),
    );
  }
}

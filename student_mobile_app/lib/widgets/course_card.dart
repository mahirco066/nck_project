import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/course_grade.dart';
import 'grade_badge.dart';

class CourseCard extends StatelessWidget {
  final CourseGrade course;
  final int index;

  const CourseCard({
    Key? key,
    required this.course,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppConstants.getGradeColor(course.grade);
    final gradeLabel = AppConstants.getGradeLabelAr(course.grade);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // شارة التقدير الحرفي
          GradeBadge(grade: course.grade, size: 44),
          const SizedBox(width: 12),

          // تفاصيل المقرر
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.courseCode,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${course.creditHours} ساعات معتمدة',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // التقدير العربي والنقاط
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                gradeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: gradeColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'النقاط: ${course.points.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

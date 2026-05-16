import 'package:flutter/material.dart';

class GradeUtils {
  static String calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  static Color getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.greenAccent;
      case 'B':
        return Colors.blueAccent;
      case 'C':
        return Colors.orangeAccent;
      case 'D':
        return Colors.deepOrangeAccent;
      case 'F':
      default:
        return Colors.redAccent;
    }
  }

  static double calculateGPA(List<double> marks) {
    if (marks.isEmpty) return 0.0;
    double sum = marks.reduce((a, b) => a + b);
    return sum / marks.length;
  }
}

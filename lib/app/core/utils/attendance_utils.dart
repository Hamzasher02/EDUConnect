import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AttendanceUtils {
  static String getAttendanceLabel(double percentage) {
    if (percentage >= 0.85) return 'Excellent';
    if (percentage >= 0.70) return 'Good';
    if (percentage >= 0.50) return 'Fair';
    return 'Poor';
  }

  static Color getStatusColor(double percentage) {
    if (percentage >= 0.85) return AppColors.accentLime;
    if (percentage >= 0.70) return Colors.blueAccent;
    if (percentage >= 0.50) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}

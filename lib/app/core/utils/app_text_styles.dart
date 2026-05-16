import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get h2 => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get h3 => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get bodyLarge =>
      GoogleFonts.inter(fontSize: 16, color: Colors.white);

  static TextStyle get bodyMedium =>
      GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.8));

  static TextStyle get bodySmall =>
      GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.6));

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
}

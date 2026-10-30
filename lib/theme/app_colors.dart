import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Color Palette & Theme Configuration for SSI Presensi Online Staff
class AppColors {
  // Brand SSI Palette (Peach / Coral Red Theme from Reference)
  static const Color primaryCoral = Color(0xFFFF5733);
  static const Color primaryDark = Color(0xFFD93815);
  static const Color primaryLight = Color(0xFFFF7D5E);
  static const Color peachBackground = Color(0xFFFDF2EE);
  static const Color peachSurface = Color(0xFFFFF6F4);
  static const Color peachAccent = Color(0xFFFFE6E0);
  
  // Legacy alias for compatibility
  static const Color primaryCobalt = primaryCoral;
  static const Color secondarySky = Color(0xFFFF7D5E);
  static const Color backgroundGray = peachBackground;

  // Text & Neutrals
  static const Color textPrimary = Color(0xFF1E242B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFF0DDD7);

  // Status Colors (from SSI Wireframes)
  static const Color success = Color(0xFF10B981); // Hadir / Hijau
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Izin / Kuning
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444); // Sakit / Alfa / Merah
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7); // Cuti

  // Elevation Shadows with warm peach undertones
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFFFF5733).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: const Color(0xFFD93815).withValues(alpha: 0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}

/// Global Application ThemeData using Plus Jakarta Sans
ThemeData getAppTheme() {
  final baseTextTheme = Typography.material2021().black;
  TextTheme textTheme;
  try {
    textTheme = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme);
  } catch (_) {
    textTheme = baseTextTheme;
  }

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.peachBackground,
    primaryColor: AppColors.primaryCoral,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryCoral,
      primary: AppColors.primaryCoral,
      secondary: AppColors.primaryLight,
      surface: AppColors.cardWhite,
      error: AppColors.danger,
    ),
    textTheme: textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
    ),
  );
}

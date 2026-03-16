import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ═══════════════════════════════════════════════════════════════════
/// APP THEME — Hệ thống thiết kế chuyên nghiệp (SaaS Education Style)
/// ═══════════════════════════════════════════════════════════════════

class AppColors {
  // ── Primary Palette (Modern & Soft) ──
  static const Color primary = Color(0xFF4E89FF); // Brighter, Modern Blue
  static const Color primaryLight = Color(0xFFE9F0FF);
  static const Color primaryDeep = Color(0xFF2D5BD0);
  
  static const Color secondary = Color(0xFF34C759); // Vibrant Green
  static const Color secondaryLight = Color(0xFFEBF9EE);
  
  // ── Semantic Colors ──
  static const Color success = Color(0xFF34C759);
  static const Color successLight = Color(0xFFEBF9EE);
  static const Color warning = Color(0xFFFF9500);
  static const Color warningLight = Color(0xFFFFF4E5);
  static const Color error = Color(0xFFFF3B30);
  static const Color errorLight = Color(0xFFFFEBEA);
  static const Color info = Color(0xFF007AFF);

  // ── Neutral Palette (Premium Slate) ──
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  
  // ── Text Palette ──
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textLight = Color(0xFF94A3B8); // Slate 400
  static const Color textHint = Color(0xFFCBD5E1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color navInactive = Color(0xFF94A3B8);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF70A1FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softBlueGradient = LinearGradient(
    colors: [Color(0xFFE9F0FF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Dark Mode Colors ──
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceVariant = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextLight = Color(0xFF94A3B8);
}

class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.primary.withAlpha(15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get cardHover => [
    BoxShadow(
      color: AppColors.primary.withAlpha(25),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: AppColors.primary.withAlpha(20),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get bottomNav => [
    BoxShadow(
      color: AppColors.primary.withAlpha(18),
      blurRadius: 30,
      offset: const Offset(0, -4),
    ),
  ];

  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withAlpha(8),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12; // Standard SaaS corner
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double full = 999;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.lexend(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get titleLarge => GoogleFonts.lexend(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.lexend(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static TextStyle get labelLarge => GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get sectionHeader => GoogleFonts.lexend(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );

  static TextStyle get caption => GoogleFonts.lexend(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );
}

class AppDecorations {
  static BoxDecoration get card => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get cardSubtle => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get cardClickable => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.md),
    border: Border.all(color: AppColors.border, width: 1),
  );

  static BoxDecoration get badgeGreen => BoxDecoration(
    color: AppColors.secondaryLight,
    borderRadius: BorderRadius.circular(AppRadius.xs),
  );

  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    elevation: 0,
  );

  static InputDecoration inputDecoration({
    required String label,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textLight, size: 20) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background, 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}


class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          side: const BorderSide(color: AppColors.border),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.border),
        ),
        color: AppColors.surface,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppDecorations.primaryButton,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        color: AppColors.darkSurface,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
      textTheme: TextTheme(
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.darkTextPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.darkTextPrimary),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.darkTextPrimary),
      ),
    );
  }
}


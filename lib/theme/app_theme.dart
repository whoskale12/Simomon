// THEME LOCK: light + dark — source: user explicit prompt
// Scaffold.backgroundColor = AppTheme.backgroundLight/Dark — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary palette
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFF9C6FFF);
  static const Color primaryDark = Color(0xFF5B2ECC);
  static const Color primaryContainer = Color(0xFFEDE7FF);

  // Accent colors
  static const Color coral = Color(0xFFFF6B6B);
  static const Color mint = Color(0xFF00D4AA);
  static const Color yellow = Color(0xFFFFD93D);
  static const Color indigo = Color(0xFF4361EE);

  // Semantic
  static const Color success = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFD93D);
  static const Color error = Color(0xFFFF6B6B);

  // Light surfaces
  static const Color backgroundLight = Color(0xFFF5F3FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEDE7FF);
  static const Color onSurfaceLight = Color(0xFF1A1035);
  static const Color onSurfaceMutedLight = Color(0xFF6B6B8A);

  // Dark surfaces
  static const Color backgroundDark = Color(0xFF0D0B1E);
  static const Color surfaceDark = Color(0xFF1A1035);
  static const Color surfaceVariantDark = Color(0xFF251A45);
  static const Color onSurfaceDark = Color(0xFFEEEAFF);
  static const Color onSurfaceMutedDark = Color(0xFF9E9BBF);

  // Category colors
  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catTransport = Color(0xFF4361EE);
  static const Color catCoffee = Color(0xFFB5835A);
  static const Color catShopping = Color(0xFFFF9F43);
  static const Color catBills = Color(0xFF6C63FF);
  static const Color catGaming = Color(0xFF00D4AA);
  static const Color catEducation = Color(0xFF4ECDC4);
  static const Color catEntertainment = Color(0xFFFF6B9D);
  static const Color catFreelance = Color(0xFF26D07C);
  static const Color catHealth = Color(0xFFFF4757);
  static const Color catOthers = Color(0xFF9E9BBF);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFF1A1035),
      secondary: coral,
      onSecondary: Colors.white,
      tertiary: mint,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      surfaceContainerHighest: surfaceVariantLight,
      onSurfaceVariant: onSurfaceMutedLight,
      error: error,
      onError: Colors.white,
      outline: Color(0xFFCCBFFF),
      outlineVariant: Color(0xFFEDE7FF),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: onSurfaceLight,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: onSurfaceLight,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurfaceLight,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurfaceLight,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: onSurfaceLight,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: onSurfaceLight,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurfaceLight,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: onSurfaceMutedLight,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onSurfaceLight,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: onSurfaceMutedLight,
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onSurfaceLight,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: primary,
          );
        }
        return GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onSurfaceMutedLight,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3D1F8A),
      onPrimaryContainer: Color(0xFFEDE7FF),
      secondary: coral,
      onSecondary: Colors.white,
      tertiary: mint,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      surfaceContainerHighest: surfaceVariantDark,
      onSurfaceVariant: onSurfaceMutedDark,
      error: error,
      onError: Colors.white,
      outline: Color(0xFF3D2E6B),
      outlineVariant: Color(0xFF251A45),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: onSurfaceDark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: onSurfaceDark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: onSurfaceDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurfaceDark,
      ),
      titleLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: onSurfaceDark,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: onSurfaceDark,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurfaceDark,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: onSurfaceMutedDark,
      ),
      labelLarge: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onSurfaceDark,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: onSurfaceMutedDark,
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onSurfaceDark,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.transparent,
      indicatorColor: const Color(0xFF3D1F8A),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.nunito(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: primaryLight,
          );
        }
        return GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onSurfaceMutedDark,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: surfaceVariantDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  // Helper: category color mapping
  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return catFood;
      case 'transport':
        return catTransport;
      case 'coffee':
        return catCoffee;
      case 'shopping':
        return catShopping;
      case 'bills':
        return catBills;
      case 'gaming':
        return catGaming;
      case 'education':
        return catEducation;
      case 'entertainment':
        return catEntertainment;
      case 'freelance':
        return catFreelance;
      case 'health':
        return catHealth;
      case 'gaji':
      case 'salary':
        return primary;
      case 'bonus':
        return yellow;
      default:
        return catOthers;
    }
  }

  // Helper: category icon mapping
  static IconData categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood_rounded;
      case 'transport':
        return Icons.directions_bike_rounded;
      case 'coffee':
        return Icons.local_cafe_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills':
        return Icons.receipt_long_rounded;
      case 'gaming':
        return Icons.sports_esports_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'freelance':
        return Icons.work_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'gaji':
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      case 'bonus':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

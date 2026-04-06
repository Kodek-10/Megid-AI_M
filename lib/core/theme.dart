// lib/core/theme.dart
import 'package:flutter/material.dart';

// ── Couleurs principales de Megidai ──────────────────────────────────
class MegidaiColors {
  // Couleurs de base
  static const Color primary = Color(0xFF00D4FF);      // Bleu cyan principal
  static const Color secondary = Color(0xFF00FF88);    // Vert menthe
  static const Color accent = Color(0xFFFF6B00);       // Orange accent

  // Thème sombre
  static const Color darkBackground = Color(0xFF0A0A0A); // Noir profond
  static const Color darkSurface = Color(0xFF1A1A1A);    // Gris très sombre
  static const Color darkCard = Color(0xFF2A2A2A);      // Gris sombre pour cartes

  // Texte
  static const Color textPrimary = Color(0xFFFFFFFF);    // Blanc
  static const Color textSecondary = Color(0xFFB0B0B0);  // Gris clair
  static const Color textGray = Color(0xFF808080);       // Gris moyen

  // États
  static const Color success = Color(0xFF00FF88);        // Vert succès
  static const Color warning = Color(0xFFFFD700);        // Jaune avertissement
  static const Color error = Color(0xFFFF4444);          // Rouge erreur
  static const Color info = Color(0xFF00D4FF);           // Bleu info

  // Sécurité
  static const Color secure = Color(0xFF00FF88);         // Vert sécurisé
  static const Color suspicious = Color(0xFFFFD700);     // Jaune suspect
  static const Color dangerous = Color(0xFFFF4444);      // Rouge dangereux
}

// ── Thème principal de l'application ────────────────────────────────
class MegidaiTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Couleurs principales
      primaryColor: MegidaiColors.primary,
      scaffoldBackgroundColor: MegidaiColors.darkBackground,
      cardColor: MegidaiColors.darkCard,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: MegidaiColors.darkSurface,
        foregroundColor: MegidaiColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MegidaiColors.primary,
          foregroundColor: MegidaiColors.textPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MegidaiColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // ── Style des cartes ──────────────────────────────────────
      cardTheme: CardThemeData(
        color: MegidaiColors.darkCard,
        elevation: 4,                // Légère ombre portée
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: MegidaiColors.accent,
            width: 0.5,              // Bordure turquoise fine
          ),
        ),
      ),

      // Champs de texte
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MegidaiColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MegidaiColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MegidaiColors.textGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MegidaiColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: MegidaiColors.textSecondary),
        hintStyle: const TextStyle(color: MegidaiColors.textGray),
      ),

      // Dialogues
      dialogTheme: DialogThemeData(
        backgroundColor: MegidaiColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Indicateurs de progression
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MegidaiColors.primary,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MegidaiColors.primary;
          }
          return MegidaiColors.textGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MegidaiColors.primary.withOpacity(0.3);
          }
          return MegidaiColors.textGray.withOpacity(0.3);
        }),
      ),

      // Texte
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: MegidaiColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: MegidaiColors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: MegidaiColors.textGray,
          fontSize: 12,
        ),
      ),
    );
  }

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Colors
      primaryColor: MegidaiColors.primary,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light background
      cardColor: Colors.white,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MegidaiColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MegidaiColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 0.5,
          ),
        ),
      ),

      // Text fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MegidaiColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MegidaiColors.primary,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MegidaiColors.primary;
          }
          return const Color(0xFF94A3B8);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return MegidaiColors.primary.withOpacity(0.3);
          }
          return const Color(0xFFCBD5E1);
        }),
      ),

      // Text
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 12,
        ),
      ),
    );
  }

  // Couleur sombre pour les textes sur fond clair
  static const Color dark = Color(0xFF000000);
}
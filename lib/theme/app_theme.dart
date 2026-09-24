import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// WARNA
// ─────────────────────────────────────────────
const Color kPrimary = Color(0xFF1B4D3E); // Hijau tua
const Color kPrimaryLight = Color(0xFF2D6B57);
const Color kAccent = Color(0xFFD97706); // Amber (ikon, badge)
const Color kAccentText = Color(0xFFB45309); // Amber lebih gelap untuk teks kecil
const Color kBackground = Color(0xFFF8F9FA);
const Color kCardBg = Colors.white;
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextMuted = Color(0xFF6B6B6B);
const Color kBorder = Color(0xFFE0E4E2);
const Color kError = Color(0xFFB3261E);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      primary: kPrimary,
      secondary: kAccent,
      surface: kBackground,
    ),
    scaffoldBackgroundColor: kBackground,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: kPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(color: kPrimary, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: Color(0xFF4A4A4A)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

/// Dekorasi seragam untuk semua field di halaman login & register.
InputDecoration fieldDecoration({
  required String label,
  required IconData icon,
  Widget? suffix,
  String? helper,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    helperText: helper,
    helperMaxLines: 2,
    prefixIcon: Icon(icon, size: 20),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(kBorder),
    enabledBorder: border(kBorder),
    focusedBorder: border(kPrimary, 1.8),
    errorBorder: border(kError),
    focusedErrorBorder: border(kError, 1.8),
  );
}

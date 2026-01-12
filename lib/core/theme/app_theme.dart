import 'package:flutter/material.dart';

/// Enhanced App Theme with Material Design 3 principles
/// 
/// Modern, clean, aesthetic design with:
/// - Dynamic color schemes
/// - Elevated surfaces with depth
/// - Refined typography
/// - Consistent spacing system
class AppTheme {
  // Private constructor
  AppTheme._();
  
  // ==================== COLOR SYSTEM ====================
  
  // Primary colors - Main brand color
  static const _primaryLight = Color(0xFF1976D2); // Deep Blue
  static const _primaryDark = Color(0xFF90CAF9); // Light Blue
  
  // Secondary colors - Accent color
  static const _secondaryLight = Color(0xFFF57C00); // Deep Orange
  static const _secondaryDark = Color(0xFFFFB74D); // Light Orange
  
  // Tertiary colors - Additional accent
  static const _tertiaryLight = Color(0xFF388E3C); // Deep Green
  static const _tertiaryDark = Color(0xFF81C784); // Light Green
  
  // Surface colors
  static const _surfaceLight = Color(0xFFFAFAFA);
  static const _surfaceDark = Color(0xFF121212);
  
  // Background colors
  static const _backgroundLight = Color(0xFFFFFFFF);
  static const _backgroundDark = Color(0xFF0A0A0A);
  
  // ==================== TYPOGRAPHY ====================
  
  static const String _fontFamily = 'Roboto';
  
  static const _textTheme = TextTheme(
    // Display - Largest text
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),
    
    // Headline - Titles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
    ),
    
    // Title - Section headers
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.50,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    
    // Body - Regular text
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.50,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),
    
    // Label - Buttons and labels
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );
  
  // ==================== SPACING SYSTEM ====================
  
  /// 8px grid system for consistent spacing
  static const double space1 = 4.0;   // 0.5x
  static const double space2 = 8.0;   // 1x
  static const double space3 = 12.0;  // 1.5x
  static const double space4 = 16.0;  // 2x
  static const double space5 = 20.0;  // 2.5x
  static const double space6 = 24.0;  // 3x
  static const double space8 = 32.0;  // 4x
  static const double space10 = 40.0; // 5x
  static const double space12 = 48.0; // 6x
  
  // ==================== BORDER RADIUS ====================
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  
  // ==================== ELEVATION ====================
  
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 4.0;
  static const double elevation3 = 8.0;
  static const double elevation4 = 12.0;
  
  // ==================== LIGHT THEME ====================
  
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _primaryLight,
      onPrimary: Colors.white,
      primaryContainer: _primaryLight.withValues(alpha: 0.1),
      onPrimaryContainer: _primaryLight,
      
      secondary: _secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: _secondaryLight.withValues(alpha: 0.1),
      onSecondaryContainer: _secondaryLight,
      
      tertiary: _tertiaryLight,
      onTertiary: Colors.white,
      tertiaryContainer: _tertiaryLight.withValues(alpha: 0.1),
      onTertiaryContainer: _tertiaryLight,
      
      error: const Color(0xFFD32F2F),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFCDD2),
      onErrorContainer: const Color(0xFFB71C1C),
      
      surface: _surfaceLight,
      onSurface: const Color(0xFF1C1B1F),
      surfaceContainerHighest: const Color(0xFFE7E0EC),
      
      outline: const Color(0xFF79747E),
      outlineVariant: const Color(0xFFCAC4D0),
      
      shadow: Colors.black,
      scrim: Colors.black,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      textTheme: _textTheme,
      
      // App Bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _backgroundLight,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Card
      cardTheme: CardThemeData(
        elevation: elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: space3,
        ),
      ),
      
      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: space2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        elevation: elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),
      
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        elevation: elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXLarge),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        actionTextColor: colorScheme.secondary,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: space3,
          vertical: space1,
        ),
      ),
    );
  }
  
  // ==================== DARK THEME ====================
  
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: const Color(0xFF0D47A1),
      primaryContainer: _primaryDark.withValues(alpha: 0.2),
      onPrimaryContainer: _primaryDark,
      
      secondary: _secondaryDark,
      onSecondary: const Color(0xFFE65100),
      secondaryContainer: _secondaryDark.withValues(alpha: 0.2),
      onSecondaryContainer: _secondaryDark,
      
      tertiary: _tertiaryDark,
      onTertiary: const Color(0xFF1B5E20),
      tertiaryContainer: _tertiaryDark.withValues(alpha: 0.2),
      onTertiaryContainer: _tertiaryDark,
      
      error: const Color(0xFFEF5350),
      onError: const Color(0xFFB71C1C),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFB4AB),
      
      surface: _surfaceDark,
      onSurface: const Color(0xFFE6E1E5),
      surfaceContainerHighest: const Color(0xFF36343B),
      
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
      
      shadow: Colors.black,
      scrim: Colors.black,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      textTheme: _textTheme,
      
      // App Bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: _backgroundDark,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      
      // Card
      cardTheme: CardThemeData(
        elevation: elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        surfaceTintColor: colorScheme.surfaceContainerHighest,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: space3,
        ),
      ),
      
      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space4,
          vertical: space2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        elevation: elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),
      
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        elevation: elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXLarge),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        actionTextColor: colorScheme.secondary,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: space3,
          vertical: space1,
        ),
      ),
    );
  }
}

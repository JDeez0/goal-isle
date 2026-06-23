/// Flutter theme built from Goal Isle design tokens.
///
/// This creates a ThemeData that applies the color palette, typography,
/// spacing, and motion defined in tokens.dart to the entire app.
library;

import 'package:flutter/material.dart';
import 'tokens.dart';

/// Creates the Goal Isle app theme with light mode.
ThemeData createAppTheme() {
  return ThemeData(
    // Use Material 3
    useMaterial3: true,

    // Brightness
    brightness: Brightness.light,

    // Scaffold background (calm slate water)
    scaffoldBackgroundColor: TokenColors.background,

    // Color scheme (used by Material widgets)
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: TokenColors.accent, // Blue for primary buttons
      onPrimary: TokenColors.textOnAccent, // White text on blue
      primaryContainer: TokenColors.accentSubtle, // Light blue background
      onPrimaryContainer: TokenColors.textPrimary,

      secondary: TokenColors.yellow, // Notebook yellow
      onSecondary: TokenColors.textPrimary,
      secondaryContainer: TokenColors.yellowSubtle,
      onSecondaryContainer: TokenColors.textPrimary,

      tertiary: TokenColors.textSecondary, // Gray for tertiary accents
      onTertiary: TokenColors.textOnAccent,
      tertiaryContainer: TokenColors.surfaceMuted,
      onTertiaryContainer: TokenColors.textPrimary,

      error: TokenColors.error,
      onError: TokenColors.textOnAccent,
      errorContainer: TokenColors.errorSubtle,
      onErrorContainer: TokenColors.textPrimary,

      outline: TokenColors.border, // Border color
      outlineVariant: TokenColors.divider,

      surface: TokenColors.surface, // White surfaces (isles)
      onSurface: TokenColors.textPrimary, // Dark text on white
      surfaceContainerHighest: TokenColors.surfaceMuted,

      surfaceTint: Colors.transparent,
    ),

    // Text theme
    textTheme: const TextTheme(
      // Display (very large text)
      displayLarge: TokenText.headline,
      displayMedium: TokenText.title,
      displaySmall: TokenText.subheading,

      // Headline (large headings)
      headlineLarge: TokenText.headline,
      headlineMedium: TokenText.title,
      headlineSmall: TokenText.subheading,

      // Title (medium headings)
      titleLarge: TokenText.title,
      titleMedium: TokenText.subheading,
      titleSmall: TokenText.bodyAccent,

      // Body (normal text)
      bodyLarge: TokenText.body,
      bodyMedium: TokenText.body,
      bodySmall: TokenText.bodySmall,

      // Label (small text)
      labelLarge: TokenText.bodySmall,
      labelMedium: TokenText.caption,
      labelSmall: TokenText.caption,
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: TokenColors.surface,
      foregroundColor: TokenColors.textPrimary,
      elevation: Elevation.none,
      centerTitle: false,
      titleTextStyle: TokenText.title,
      iconTheme: IconThemeData(color: TokenColors.textPrimary),
    ),

    // Card theme (for isle cards)
    cardTheme: CardThemeData(
      color: TokenColors.surface,
      elevation: Elevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: TokenRadius.mdBorder,
      ),
      margin: EdgeInsets.zero,
    ),

    // Elevated button theme (primary CTA, Spark button)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: TokenColors.accent,
        foregroundColor: TokenColors.textOnAccent,
        elevation: Elevation.md,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: TokenRadius.mdBorder,
        ),
        textStyle: const TextStyle(
          fontSize: TokenText.sizeBase,
          fontWeight: TokenText.medium,
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: TokenColors.accent,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xxs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: TokenRadius.smBorder,
        ),
        textStyle: const TextStyle(
          fontSize: TokenText.sizeSmall,
          fontWeight: TokenText.medium,
        ),
      ),
    ),

    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TokenColors.textPrimary,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: TokenColors.border, width: 1),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: TokenRadius.mdBorder,
        ),
        textStyle: const TextStyle(
          fontSize: TokenText.sizeBase,
          fontWeight: TokenText.medium,
        ),
      ),
    ),

    // Input decoration theme (text fields)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: TokenColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: TokenRadius.mdBorder,
        borderSide: const BorderSide(color: TokenColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: TokenRadius.mdBorder,
        borderSide: const BorderSide(color: TokenColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: TokenRadius.mdBorder,
        borderSide: const BorderSide(color: TokenColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: TokenRadius.mdBorder,
        borderSide: const BorderSide(color: TokenColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: TokenRadius.mdBorder,
        borderSide: const BorderSide(color: TokenColors.error, width: 2),
      ),
      hintStyle: const TextStyle(
        color: TokenColors.textTertiary,
        fontSize: TokenText.sizeBase,
      ),
      labelStyle: const TextStyle(
        color: TokenColors.textSecondary,
        fontSize: TokenText.sizeSmall,
        fontWeight: TokenText.medium,
      ),
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: TokenColors.accent,
      foregroundColor: TokenColors.textOnAccent,
      elevation: Elevation.lg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // Icon theme
    iconTheme: const IconThemeData(
      color: TokenColors.textSecondary,
      size: 24,
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: TokenColors.divider,
      thickness: 1,
      space: Spacing.md,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: TokenColors.surface,
      elevation: Elevation.lg,
      shape: RoundedRectangleBorder(
        borderRadius: TokenRadius.lgBorder,
      ),
      titleTextStyle: TokenText.title,
      contentTextStyle: TokenText.body,
    ),

    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: TokenColors.surface,
      elevation: Elevation.lg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
    ),

    // Snack bar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: TokenColors.surfaceDark,
      contentTextStyle: const TextStyle(color: TokenColors.textOnAccent),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: TokenRadius.mdBorder,
      ),
      elevation: Elevation.lg,
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: TokenColors.surfaceMuted,
      selectedColor: TokenColors.accentSubtle,
      deleteIconColor: TokenColors.textTertiary,
      disabledColor: TokenColors.surfaceMuted,
      labelStyle: const TextStyle(
        color: TokenColors.textPrimary,
        fontSize: TokenText.sizeSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: TokenRadius.fullBorder,
      ),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TokenColors.accent;
        }
        return TokenColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TokenColors.accentSubtle;
        }
        return TokenColors.border;
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TokenColors.accent;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(TokenColors.textOnAccent),
      side: const BorderSide(color: TokenColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: TokenRadius.smBorder,
      ),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TokenColors.accent;
        }
        return Colors.transparent;
      }),
    ),

    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: TokenColors.accent,
      linearTrackColor: TokenColors.surfaceMuted,
      circularTrackColor: TokenColors.surfaceMuted,
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: TokenColors.surfaceDark,
        borderRadius: TokenRadius.smBorder,
      ),
      textStyle: const TextStyle(
        color: TokenColors.textOnAccent,
        fontSize: TokenText.sizeSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.sm,
      ),
    ),
  );
}
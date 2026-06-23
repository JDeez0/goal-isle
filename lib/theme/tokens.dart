/// Design tokens for Goal Isle.
///
/// Light mode with white/light blue "slate water" backgrounds,
/// white surfaces, slight notebook yellow accents, and dark accents
/// for text and borders.
///
/// Usage: Import and use Token.color, Token.text, Token.spacing, etc.
library;

import 'package:flutter/material.dart';

/// Color tokens — light mode with slate water and notebook yellow accents.
class TokenColors {
  // Background
  static const Color background = Color(0xFFEEF2F5); // Calm slate water
  static const Color surface = Color(0xFFFFFFFF); // White (floating isles)
  static const Color surfaceMuted = Color(0xFFF8FAFB); // Very light surface
  static const Color surfaceDark = Color(0xFF1A2332); // Dark accent (reserved for specific use)

  // Text
  static const Color textPrimary = Color(0xFF1F2937); // Dark gray, almost black
  static const Color textSecondary = Color(0xFF64748B); // Medium gray
  static const Color textTertiary = Color(0xFF94A3B8); // Light gray
  static const Color textOnAccent = Color(0xFFFFFFFF); // White for text on blue buttons

  // UI elements
  static const Color border = Color(0xFFDDE3E8); // Light gray borders
  static const Color divider = Color(0xFFE5E7EB); // Slightly darker than border

  // Accent colors
  static const Color accent = Color(0xFF3B82F6); // Blue (primary CTA, Spark button)
  static const Color accentSubtle = Color(0xFFDBEAFE); // Light blue background
  static const Color accentHover = Color(0xFF2563EB); // Darker blue for hover

  // Notebook yellow — slight warm accent
  static const Color yellow = Color(0xFFFCD34D); // Notebook paper yellow
  static const Color yellowSubtle = Color(0xFFFEF3C7); // Light yellow background

  // Status colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color successSubtle = Color(0xFFD1FAE5); // Light green background
  static const Color warning = Color(0xFFF59E0B); // Amber (can use notebook yellow variation)
  static const Color warningSubtle = Color(0xFFFEF3C7); // Light amber background
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorSubtle = Color(0xFFFEE2E2); // Light red background
}

/// Text style tokens — system sans-serif with multiple weights and sizes.
class TokenText {
  // Font family
  static const String fontFamily = 'system-ui'; // Platform's system sans-serif

  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Font sizes (px) with line heights
  static const double sizeXLarge = 32.0; // Headlines
  static const double sizeLarge = 24.0; // Section titles
  static const double sizeMedium = 18.0; // Subheadings, large body
  static const double sizeBase = 16.0; // Body text
  static const double sizeSmall = 14.0; // Secondary text
  static const double sizeXSmall = 12.0; // Captions, labels

  // Line heights (unitless, relative to font size)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightLoose = 1.7;

  // Letter spacing (em units)
  static const double letterSpacingTight = -0.02;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.02;

  // Predefined text styles
  static const TextStyle headline = TextStyle(
    fontSize: sizeXLarge,
    fontWeight: bold,
    height: lineHeightTight,
    letterSpacing: letterSpacingTight,
    color: Color(0xFF1F2937),
  );

  static const TextStyle title = TextStyle(
    fontSize: sizeLarge,
    fontWeight: semibold,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: Color(0xFF1F2937),
  );

  static const TextStyle subheading = TextStyle(
    fontSize: sizeMedium,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingNormal,
    color: Color(0xFF1F2937),
  );

  static const TextStyle body = TextStyle(
    fontSize: sizeBase,
    fontWeight: regular,
    height: lineHeightLoose,
    letterSpacing: letterSpacingNormal,
    color: Color(0xFF1F2937),
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: sizeSmall,
    fontWeight: regular,
    height: lineHeightLoose,
    letterSpacing: letterSpacingNormal,
    color: Color(0xFF64748B),
  );

  static const TextStyle caption = TextStyle(
    fontSize: sizeXSmall,
    fontWeight: medium,
    height: lineHeightNormal,
    letterSpacing: letterSpacingWide,
    color: Color(0xFF94A3B8),
  );

  // Accented variants
  static const TextStyle bodyAccent = TextStyle(
    fontSize: sizeBase,
    fontWeight: medium,
    height: lineHeightLoose,
    letterSpacing: letterSpacingNormal,
    color: Color(0xFF3B82F6),
  );
}

/// Spacing tokens — 4px base unit.
class Spacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Gap spacing (for between items)
  static const double gapXxs = 4.0;
  static const double gapXs = 8.0;
  static const double gapSm = 12.0;
  static const double gapMd = 16.0;
  static const double gapLg = 24.0;
  static const double gapXl = 32.0;

  // Padding
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);

  // Screen padding (edges of the screen)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets screenPaddingLg = EdgeInsets.symmetric(horizontal: lg, vertical: md);
}

/// Border radius tokens — rounded corners.
class TokenRadius {
  static const double sm = 8.0; // Small elements, badges
  static const double md = 12.0; // Cards, buttons, inputs
  static const double lg = 16.0; // Large cards, modals
  static const double full = 9999.0; // Pills, tags, full rounds

  static final BorderRadius smBorder = BorderRadius.circular(sm);
  static final BorderRadius mdBorder = BorderRadius.circular(md);
  static final BorderRadius lgBorder = BorderRadius.circular(lg);
  static final BorderRadius fullBorder = BorderRadius.circular(full);
}

/// Motion tokens — durations and curves.
class Motion {
  // Durations (ms)
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration defaultDuration = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  // Curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOutBack = Curves.easeOutBack;
}

/// Shadow tokens — subtle depth for surfaces.
class Shadows {
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x1A3B82F6), // 10% blue
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}

/// Elevation tokens — z-index layering.
class Elevation {
  static const double none = 0.0;
  static const double sm = 1.0;
  static const double md = 2.0;
  static const double lg = 4.0;
  static const double xl = 8.0;
}

/// Z-index tokens — stacking context.
class ZIndex {
  static const int background = -1;
  static const int base = 0;
  static const int elevated = 10;
  static const int modal = 100;
  static const int toast = 1000;
  static const int overlay = 2000;
}

/// Breakpoint tokens — responsive design.
class Breakpoint {
  static const double xs = 0; // Mobile (portrait)
  static const double sm = 576; // Mobile (landscape)
  static const double md = 768; // Tablet
  static const double lg = 992; // Desktop (small)
  static const double xl = 1200; // Desktop (large)
}
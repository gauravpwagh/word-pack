import 'package:flutter/material.dart';

import 'wp_colors.dart';
import 'wp_text.dart';
import 'wp_tokens.dart';

/// Light and dark Material 3 themes built from `docs/UI_UX.md` §9.
abstract final class AppTheme {
  static ThemeData light() => _build(
    brightness: Brightness.light,
    wp: WpColors.light,
    surface: const Color(0xFFFFFDF8),
    surface3: const Color(0xFFE3DDD0),
    onSurface: const Color(0xFF1E1C18),
    onSurfaceVariant: const Color(0xFF57524A),
    primary: const Color(0xFF2F4A8A),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFE2E8F5),
    onPrimaryContainer: const Color(0xFF233A6E),
    outline: const Color(0xFF8F877A),
    outlineVariant: const Color(0xFFE0D9CB),
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    wp: WpColors.dark,
    surface: const Color(0xFF1E1C19),
    surface3: const Color(0xFF34312C),
    onSurface: const Color(0xFFEEE9DF),
    onSurfaceVariant: const Color(0xFFBDB6A9),
    primary: const Color(0xFFA8BDF4),
    onPrimary: const Color(0xFF13203F),
    primaryContainer: const Color(0xFF27314A),
    onPrimaryContainer: const Color(0xFFD0DBFA),
    outline: const Color(0xFF7A7468),
    outlineVariant: const Color(0xFF38352F),
  );

  static ThemeData _build({
    required Brightness brightness,
    required WpColors wp,
    required Color surface,
    required Color surface3,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color outline,
    required Color outlineVariant,
  }) {
    // Seed fills the slots the design does not name; the named ones override.
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: primaryContainer,
          onPrimaryContainer: onPrimaryContainer,
          secondaryContainer: primaryContainer,
          onSecondaryContainer: onPrimaryContainer,
          error: wp.negative,
          surface: surface,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          surfaceContainerLowest: surface,
          surfaceContainerLow: surface,
          surfaceContainer: wp.surfaceVariant,
          surfaceContainerHigh: wp.surfaceVariant,
          surfaceContainerHighest: surface3,
          outline: outline,
          outlineVariant: outlineVariant,
        );

    final textTheme = buildTextTheme().apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    RoundedRectangleBorder rounded(double r) =>
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
    const minButton = Size(WpSize.minTarget, WpSize.minTarget);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: wp.background,
      canvasColor: wp.background,
      textTheme: textTheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      iconTheme: IconThemeData(
        color: onSurfaceVariant,
        weight: 400,
        opticalSize: 24,
        grade: 0,
        fill: 0,
      ),
      extensions: [wp, WpText.standard],
      appBarTheme: AppBarTheme(
        backgroundColor: wp.background,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WpRadius.card),
          side: BorderSide(color: outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: minButton,
          shape: rounded(WpRadius.button),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minButton,
          shape: rounded(WpRadius.button),
          side: BorderSide(color: outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minButton,
          shape: rounded(WpRadius.button),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: rounded(WpRadius.chip),
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: outline),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WpRadius.field),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WpRadius.field),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(WpRadius.field),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: rounded(WpRadius.dialog),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(WpRadius.sheet),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: outlineVariant, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: wp.background,
        indicatorColor: primaryContainer,
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: onSurface,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: onSurfaceVariant,
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: wp.background),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Font families bundled in `assets/fonts/` (DECISIONS D-20).
abstract final class WpFonts {
  /// Reading serif for words and definitions.
  static const serif = 'Literata';

  /// UI sans.
  static const sans = 'AtkinsonHyperlegibleNext';

  static const serifFallback = ['Georgia', 'serif'];
  static const sansFallback = ['Segoe UI', 'Roboto', 'sans-serif'];
}

/// A text style in one of the bundled variable fonts. The weight is set both
/// as [FontWeight] (for fallbacks and semantics) and as the font's `wght` axis,
/// because a variable font does not pick its axis from [FontWeight] alone.
TextStyle wpStyle({
  required String family,
  required double size,
  required int weight,
  required double height,
  double? letterSpacing,
  FontStyle? fontStyle,
}) {
  return TextStyle(
    fontFamily: family,
    fontFamilyFallback: family == WpFonts.serif
        ? WpFonts.serifFallback
        : WpFonts.sansFallback,
    fontSize: size,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation.weight(weight.toDouble())],
    height: height,
    letterSpacing: letterSpacing,
    fontStyle: fontStyle,
  );
}

TextStyle _sans(double size, int weight, double height, {double? tracking}) =>
    wpStyle(
      family: WpFonts.sans,
      size: size,
      weight: weight,
      height: height,
      letterSpacing: tracking,
    );

TextStyle _serif(double size, int weight, double height, {double? tracking}) =>
    wpStyle(
      family: WpFonts.serif,
      size: size,
      weight: weight,
      height: height,
      letterSpacing: tracking,
    );

/// Material text roles mapped to the type scale in `docs/UI_UX.md` §9.
TextTheme buildTextTheme() {
  return TextTheme(
    displayLarge: _serif(44, 600, 1.15),
    displayMedium: _serif(34, 600, 1.15),
    displaySmall: _serif(28, 600, 1.15),
    headlineLarge: _sans(26, 700, 1.25),
    headlineMedium: _sans(24, 700, 1.25),
    headlineSmall: _sans(22, 700, 1.25),
    titleLarge: _sans(18, 700, 1.25),
    titleMedium: _sans(16, 700, 1.3),
    titleSmall: _sans(14, 700, 1.3),
    bodyLarge: _sans(16, 400, 1.5),
    bodyMedium: _sans(14, 400, 1.45),
    bodySmall: _sans(13, 400, 1.45),
    labelLarge: _sans(15, 600, 1.2),
    labelMedium: _sans(13, 600, 1.2),
    // Eyebrow: 12 / 1.3, +0.08em, uppercase (apply toUpperCase at the call site).
    labelSmall: _sans(12, 700, 1.3, tracking: 0.96),
  );
}

/// Study-card text styles that have no Material role.
@immutable
class WpText extends ThemeExtension<WpText> {
  const WpText({
    required this.cardWord,
    required this.cardWordWide,
    required this.cardAnswer,
    required this.cardPrompt,
    required this.cardPromptLong,
    required this.posChip,
  });

  final TextStyle cardWord;
  final TextStyle cardWordWide;
  final TextStyle cardAnswer;

  /// Definition shown as the prompt (Definition → Word).
  final TextStyle cardPrompt;

  /// [cardPrompt] for definitions longer than [longPromptChars].
  final TextStyle cardPromptLong;
  final TextStyle posChip;

  static const int longPromptChars = 140;

  static final standard = WpText(
    cardWord: _serif(34, 600, 1.15, tracking: -0.34),
    cardWordWide: _serif(44, 600, 1.15, tracking: -0.44),
    cardAnswer: _serif(20, 400, 1.45),
    cardPrompt: _serif(22, 400, 1.42),
    cardPromptLong: _serif(19, 400, 1.45),
    posChip: wpStyle(
      family: WpFonts.serif,
      size: 14,
      weight: 400,
      height: 1.0,
      fontStyle: FontStyle.italic,
    ),
  );

  static WpText of(BuildContext context) =>
      Theme.of(context).extension<WpText>()!;

  @override
  WpText copyWith({
    TextStyle? cardWord,
    TextStyle? cardWordWide,
    TextStyle? cardAnswer,
    TextStyle? cardPrompt,
    TextStyle? cardPromptLong,
    TextStyle? posChip,
  }) {
    return WpText(
      cardWord: cardWord ?? this.cardWord,
      cardWordWide: cardWordWide ?? this.cardWordWide,
      cardAnswer: cardAnswer ?? this.cardAnswer,
      cardPrompt: cardPrompt ?? this.cardPrompt,
      cardPromptLong: cardPromptLong ?? this.cardPromptLong,
      posChip: posChip ?? this.posChip,
    );
  }

  @override
  WpText lerp(WpText? other, double t) {
    if (other == null) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return WpText(
      cardWord: l(cardWord, other.cardWord),
      cardWordWide: l(cardWordWide, other.cardWordWide),
      cardAnswer: l(cardAnswer, other.cardAnswer),
      cardPrompt: l(cardPrompt, other.cardPrompt),
      cardPromptLong: l(cardPromptLong, other.cardPromptLong),
      posChip: l(posChip, other.posChip),
    );
  }
}

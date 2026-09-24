import 'package:flutter/material.dart';

/// App colours that Material's [ColorScheme] has no slot for: tone, trait and
/// pack-status colours plus a few surfaces. Values: `docs/UI_UX.md` §9.
///
/// Widgets read them with `Theme.of(context).extension<WpColors>()!` (or
/// [WpColors.of]); never hard-code these colours in a widget.
@immutable
class WpColors extends ThemeExtension<WpColors> {
  const WpColors({
    required this.background,
    required this.surfaceVariant,
    required this.textTertiary,
    required this.positive,
    required this.positiveTint,
    required this.negative,
    required this.negativeTint,
    required this.neutral,
    required this.counter,
    required this.counterBg,
    required this.counterOutline,
    required this.multi,
    required this.multiBg,
    required this.statusNew,
    required this.statusLearning,
    required this.statusLearningBg,
    required this.statusLearned,
    required this.statusLearnedBg,
  });

  final Color background;
  final Color surfaceVariant;
  final Color textTertiary;

  /// Tone edge and icon colours, and the card tints (neutral has no tint).
  final Color positive;
  final Color positiveTint;
  final Color negative;
  final Color negativeTint;
  final Color neutral;

  /// Counter-intuitive: badge icon, badge background, dashed outline.
  final Color counter;
  final Color counterBg;
  final Color counterOutline;

  /// Multiple meanings: badge icon, badge background.
  final Color multi;
  final Color multiBg;

  final Color statusNew;
  final Color statusLearning;
  final Color statusLearningBg;
  final Color statusLearned;
  final Color statusLearnedBg;

  static const light = WpColors(
    background: Color(0xFFF5F2EA),
    surfaceVariant: Color(0xFFEDE8DD),
    textTertiary: Color(0xFF6B655A),
    positive: Color(0xFF2B7A4B),
    positiveTint: Color(0xFFE9F3EB),
    negative: Color(0xFFB3372A),
    negativeTint: Color(0xFFFBEAE6),
    neutral: Color(0xFF6B655A),
    counter: Color(0xFF6240C0),
    counterBg: Color(0xFFEEE8FA),
    counterOutline: Color(0xFF7654CF),
    multi: Color(0xFF875500),
    multiBg: Color(0xFFF9EDD3),
    statusNew: Color(0xFF6B655A),
    statusLearning: Color(0xFF9E5200),
    statusLearningBg: Color(0xFFFAEEDF),
    statusLearned: Color(0xFF1F6B45),
    statusLearnedBg: Color(0xFFE5F0E8),
  );

  static const dark = WpColors(
    background: Color(0xFF141311),
    surfaceVariant: Color(0xFF292723),
    textTertiary: Color(0xFFA39C90),
    positive: Color(0xFF7CCB98),
    positiveTint: Color(0xFF1A2920),
    negative: Color(0xFFF29481),
    negativeTint: Color(0xFF36201C),
    neutral: Color(0xFFABA497),
    counter: Color(0xFFC5B2F8),
    counterBg: Color(0xFF2C2545),
    counterOutline: Color(0xFFA68DEC),
    multi: Color(0xFFEDC36D),
    multiBg: Color(0xFF382C13),
    statusNew: Color(0xFFABA497),
    statusLearning: Color(0xFFF2AE55),
    statusLearningBg: Color(0xFF35291A),
    statusLearned: Color(0xFF7CCB98),
    statusLearnedBg: Color(0xFF1C2A21),
  );

  static WpColors of(BuildContext context) =>
      Theme.of(context).extension<WpColors>()!;

  @override
  WpColors copyWith({
    Color? background,
    Color? surfaceVariant,
    Color? textTertiary,
    Color? positive,
    Color? positiveTint,
    Color? negative,
    Color? negativeTint,
    Color? neutral,
    Color? counter,
    Color? counterBg,
    Color? counterOutline,
    Color? multi,
    Color? multiBg,
    Color? statusNew,
    Color? statusLearning,
    Color? statusLearningBg,
    Color? statusLearned,
    Color? statusLearnedBg,
  }) {
    return WpColors(
      background: background ?? this.background,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textTertiary: textTertiary ?? this.textTertiary,
      positive: positive ?? this.positive,
      positiveTint: positiveTint ?? this.positiveTint,
      negative: negative ?? this.negative,
      negativeTint: negativeTint ?? this.negativeTint,
      neutral: neutral ?? this.neutral,
      counter: counter ?? this.counter,
      counterBg: counterBg ?? this.counterBg,
      counterOutline: counterOutline ?? this.counterOutline,
      multi: multi ?? this.multi,
      multiBg: multiBg ?? this.multiBg,
      statusNew: statusNew ?? this.statusNew,
      statusLearning: statusLearning ?? this.statusLearning,
      statusLearningBg: statusLearningBg ?? this.statusLearningBg,
      statusLearned: statusLearned ?? this.statusLearned,
      statusLearnedBg: statusLearnedBg ?? this.statusLearnedBg,
    );
  }

  @override
  WpColors lerp(WpColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return WpColors(
      background: l(background, other.background),
      surfaceVariant: l(surfaceVariant, other.surfaceVariant),
      textTertiary: l(textTertiary, other.textTertiary),
      positive: l(positive, other.positive),
      positiveTint: l(positiveTint, other.positiveTint),
      negative: l(negative, other.negative),
      negativeTint: l(negativeTint, other.negativeTint),
      neutral: l(neutral, other.neutral),
      counter: l(counter, other.counter),
      counterBg: l(counterBg, other.counterBg),
      counterOutline: l(counterOutline, other.counterOutline),
      multi: l(multi, other.multi),
      multiBg: l(multiBg, other.multiBg),
      statusNew: l(statusNew, other.statusNew),
      statusLearning: l(statusLearning, other.statusLearning),
      statusLearningBg: l(statusLearningBg, other.statusLearningBg),
      statusLearned: l(statusLearned, other.statusLearned),
      statusLearnedBg: l(statusLearnedBg, other.statusLearnedBg),
    );
  }
}

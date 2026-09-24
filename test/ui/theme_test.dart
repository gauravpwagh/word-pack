import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordpack/ui/theme/app_theme.dart';
import 'package:wordpack/ui/theme/wp_colors.dart';
import 'package:wordpack/ui/theme/wp_text.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    group('M0 $name theme (UI_UX §9)', () {
      final scheme = theme.colorScheme;
      final wp = theme.extension<WpColors>()!;

      test('has the WpColors and WpText extensions', () {
        expect(theme.extension<WpColors>(), isNotNull);
        expect(theme.extension<WpText>(), isNotNull);
        expect(theme.useMaterial3, isTrue);
      });

      test('uses the bundled fonts', () {
        expect(theme.textTheme.bodyLarge!.fontFamily, WpFonts.sans);
        expect(theme.textTheme.displaySmall!.fontFamily, WpFonts.serif);
        final text = theme.extension<WpText>()!;
        expect(text.cardWord.fontFamily, WpFonts.serif);
        expect(text.posChip.fontStyle, FontStyle.italic);
      });

      test('text pairs meet WCAG AA (4.5:1)', () {
        final pairs = <String, (Color, Color)>{
          'onSurface/surface': (scheme.onSurface, scheme.surface),
          'onSurfaceVariant/surface': (scheme.onSurfaceVariant, scheme.surface),
          'onSurface/background': (scheme.onSurface, wp.background),
          'textTertiary/surface': (wp.textTertiary, scheme.surface),
          'onPrimary/primary': (scheme.onPrimary, scheme.primary),
          'onPrimaryContainer/primaryContainer': (
            scheme.onPrimaryContainer,
            scheme.primaryContainer,
          ),
          'positive/positiveTint': (wp.positive, wp.positiveTint),
          'negative/negativeTint': (wp.negative, wp.negativeTint),
          'neutral/surface': (wp.neutral, scheme.surface),
          'counter/counterBg': (wp.counter, wp.counterBg),
          'multi/multiBg': (wp.multi, wp.multiBg),
          'statusLearning/bg': (wp.statusLearning, wp.statusLearningBg),
          'statusLearned/bg': (wp.statusLearned, wp.statusLearnedBg),
          'onSurface/positiveTint': (scheme.onSurface, wp.positiveTint),
          'onSurface/negativeTint': (scheme.onSurface, wp.negativeTint),
        };
        for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(4.5),
            reason: '$name $label',
          );
        }
      });

      test('control borders are at least 3:1 against the surface', () {
        expect(
          contrast(scheme.outline, scheme.surface),
          greaterThanOrEqualTo(3),
        );
      });
    });
  }
}

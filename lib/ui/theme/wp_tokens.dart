/// Spacing, radius and size tokens from `docs/UI_UX.md` §9.
abstract final class WpSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Side gutter on phones.
  static const double phoneGutter = 16;

  /// Content padding on wide layouts.
  static const double desktopPadding = 28;
}

abstract final class WpRadius {
  static const double card = 20;
  static const double button = 14;
  static const double buttonLarge = 16;
  static const double continueButton = 18;
  static const double field = 12;
  static const double chip = 8;
  static const double packTile = 14;
  static const double sheet = 28;
  static const double dialog = 24;
  static const double badge = 10;
}

abstract final class WpSize {
  static const double minTarget = 48;
  static const double studyAction = 56;
  static const double toneEdgeCard = 6;
  static const double toneEdgeRow = 4;
  static const double badge = 32;
  static const double badgeRow = 28;
  static const double badgeIcon = 20;
  static const double cardMinHeight = 240;
}

/// Window-width breakpoints (`docs/UI_UX.md` §1, DECISIONS D-22).
abstract final class WpBreakpoints {
  /// From here: navigation rail instead of the bottom bar.
  static const double medium = 600;

  /// From here: the tree panel is always visible.
  static const double expanded = 840;
}

/// The permanent tree panel on wide layouts.
abstract final class WpTreePanel {
  static const double defaultWidth = 280;
  static const double minWidth = 220;
  static const double maxWidth = 420;
}

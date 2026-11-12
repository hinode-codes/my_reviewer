/// Shared layout and motion tokens.
///
/// If the project already has equivalents, delete this file and point the
/// imports at the existing ones instead of keeping two sets.
library;

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 16;
}

abstract final class AppDurations {
  /// Small state changes on a single control (fade, border, highlight).
  static const Duration fast = Duration(milliseconds: 150);

  /// Movement between sibling pages.
  static const Duration medium = Duration(milliseconds: 250);
}

abstract final class AppSizes {
  static const double icon = 24;
}

abstract final class AppOpacity {
  static const double opaque = 1;

  /// A control that is visible but cannot be used.
  static const double disabledControl = 0.2;

  /// A surface laid over an image that must keep its text readable.
  static const double scrim = 0.87;
}

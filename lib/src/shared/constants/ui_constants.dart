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

abstract final class AppPadding {
  static const double sm = 4;
  static const double all = 8;
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

abstract final class SelectionConstants {
  static const double unselectedOpacity = 0.4;
  static const double selectedOpacity = 1.0;
  static const double selectedBorderWidth = 2.0;
  static const double unselectedBorderWidth = 1.0;
  static const double unselectedScrimOpacity = 0.27;
  static const double scrimIconSize = 16.0;
}

abstract final class AnimationConstants {
  static const Duration sm = Duration(milliseconds: 150);
  static const Duration md = Duration(milliseconds: 250);
}

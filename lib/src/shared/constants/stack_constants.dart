import 'dart:ui';

abstract final class StackConstants {
  /// More cards than this read as noise at thumbnail size.
  static const int maxVisibleCards = 3;

  /// Room kept around the cards so their tilt and spread are not clipped.
  static const double overflowMargin = 8;

  /// Spread grows with the card but is clamped so large tiles do not fan
  /// out further than small ones in absolute terms.
  static const double spreadXFactor = 0.08;
  static const double minSpreadX = 4;
  static const double maxSpreadX = 8;
  static const double spreadYFactor = 0.04;
  static const double minSpreadY = 2;
  static const double maxSpreadY = 6;

  /// Radians.
  static const double backCardAngle = -0.1;
  static const double middleCardAngle = 0.08;

  static const double cardRadius = 12;
  static const double imageRadius = 8;
  static const double cardBorderWidth = 2;
  static const double shadowBlur = 8;
  static const Offset shadowOffset = Offset(0, 4);
  static const double shadowOpacity = 0.15;

  static const double placeholderRadius = 10;
  static const double placeholderIconSize = 40;

  static const double cardShadowOpacity = 0.15;
  static const double cardShadowBlur = 8;
  static const Offset cardShadowOffset = Offset(0, 4);
}

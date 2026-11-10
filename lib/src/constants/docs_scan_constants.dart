import 'package:flutter/animation.dart';

abstract final class DocsScanConstants {
  /// Prefix of the group name given to a fresh scan session. The session's
  /// timestamp is appended to keep it unique.
  static const String defaultGroupNamePrefix = 'Scanned_Document_';

  /// Zoom range of a page in the preview. 1 means "fit to screen".
  static const double previewMinScale = 1;
  static const double previewMaxScale = 5;

  static const Curve pageTransitionCurve = Curves.easeInOut;

  /// Thumbnail in the group sheet, roughly the proportions of a paper sheet.
  static const double thumbnailWidth = 220;
  static const double thumbnailHeight = 280;
  static const double thumbnailBorderWidth = 2;
  static const double thumbnailSelectedBorderWidth = 4;
}

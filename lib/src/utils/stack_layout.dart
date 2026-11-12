import 'dart:math' as math;
import 'dart:ui';

import 'package:my_reviewer/src/constants/stack_constants.dart';

class CardPose {
  const CardPose({this.angle = 0, this.offset = Offset.zero});

  static const CardPose rest = CardPose();

  final double angle;
  final Offset offset;

  /// [t] = 0 is this pose, 1 is [other].
  CardPose lerpTo(CardPose other, double t) => CardPose(
    angle: lerpDouble(angle, other.angle, t)!,
    offset: Offset.lerp(offset, other.offset, t)!,
  );
}

class StackLayout {
  const StackLayout({required this.cardSize, required this.poses});

  final Size cardSize;

  /// One per visible card, back to front.
  final List<CardPose> poses;
}

StackLayout computeStackLayout({
  required Size available,
  required int count,
  required double cardAspectRatio,
}) {
  final safeWidth = math.max(
    0.0,
    available.width - StackConstants.overflowMargin,
  );
  final safeHeight = math.max(
    0.0,
    available.height - StackConstants.overflowMargin,
  );

  // Fill the height first; fall back to the width when that is too narrow.
  var cardHeight = safeHeight;
  var cardWidth = cardHeight * cardAspectRatio;

  if (cardWidth > safeWidth) {
    cardWidth = safeWidth;
    cardHeight = cardWidth / cardAspectRatio;
  }

  final spreadX = (cardWidth * StackConstants.spreadXFactor).clamp(
    StackConstants.minSpreadX,
    StackConstants.maxSpreadX,
  );
  final spreadY = (cardHeight * StackConstants.spreadYFactor).clamp(
    StackConstants.minSpreadY,
    StackConstants.maxSpreadY,
  );

  return StackLayout(
    cardSize: Size(cardWidth, cardHeight),
    poses: _posesFor(
      math.min(count, StackConstants.maxVisibleCards),
      spreadX,
      spreadY,
    ),
  );
}

List<CardPose> _posesFor(int count, double spreadX, double spreadY) {
  final back = CardPose(
    angle: StackConstants.backCardAngle,
    offset: Offset(-spreadX, spreadY),
  );
  final middle = CardPose(
    angle: StackConstants.middleCardAngle,
    offset: Offset(spreadX, spreadY),
  );

  return switch (count) {
    3 => [back, middle, CardPose.rest],
    2 => [back, CardPose.rest],
    _ => List.filled(count, CardPose.rest),
  };
}

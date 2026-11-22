import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_reviewer/src/constants/stack_constants.dart';
import 'package:my_reviewer/src/shared/utils/stack_layout.dart';

const _epsilon = 1e-9;
const _portrait = 0.5;

void _expectRest(CardPose pose) {
  expect(pose.angle, 0);
  expect(pose.offset, Offset.zero);
}

void main() {
  group('CardPose.lerpTo', () {
    const from = CardPose(angle: -0.2, offset: Offset(-10, 4));
    const to = CardPose(angle: 0.4, offset: Offset(20, -8));

    test('t = 0 is the starting pose', () {
      final pose = from.lerpTo(to, 0);

      expect(pose.angle, closeTo(from.angle, _epsilon));
      expect(pose.offset, from.offset);
    });

    test('t = 1 is the other pose', () {
      final pose = from.lerpTo(to, 1);

      expect(pose.angle, closeTo(to.angle, _epsilon));
      expect(pose.offset, to.offset);
    });

    test('t = 0.5 is halfway', () {
      final pose = from.lerpTo(to, 0.5);

      expect(pose.angle, closeTo(0.1, _epsilon));
      expect(pose.offset.dx, closeTo(5, _epsilon));
      expect(pose.offset.dy, closeTo(-2, _epsilon));
    });

    test('lerping towards rest untilts and recentres', () {
      _expectRest(from.lerpTo(CardPose.rest, 1));
    });
  });

  group('computeStackLayout card size', () {
    test('fills the height when the width allows it', () {
      final layout = computeStackLayout(
        available: const Size(1000, 200),
        count: 1,
        cardAspectRatio: _portrait,
      );
      final height = 200 - StackConstants.overflowMargin;

      expect(layout.cardSize.height, closeTo(height, _epsilon));
      expect(layout.cardSize.width, closeTo(height * _portrait, _epsilon));
    });

    test('falls back to the width when the height would be too wide', () {
      final layout = computeStackLayout(
        available: const Size(100, 1000),
        count: 1,
        cardAspectRatio: _portrait,
      );
      final width = 100 - StackConstants.overflowMargin;

      expect(layout.cardSize.width, closeTo(width, _epsilon));
      expect(layout.cardSize.height, closeTo(width / _portrait, _epsilon));
    });

    test('always fits inside the space left after the overflow margin, '
        'keeping the aspect ratio', () {
      const spaces = [
        Size(1000, 200),
        Size(100, 1000),
        Size(300, 300),
        Size(120, 240),
      ];

      for (final space in spaces) {
        final size = computeStackLayout(
          available: space,
          count: 3,
          cardAspectRatio: _portrait,
        ).cardSize;

        expect(
          size.width,
          lessThanOrEqualTo(
            space.width - StackConstants.overflowMargin + _epsilon,
          ),
          reason: 'width in $space',
        );
        expect(
          size.height,
          lessThanOrEqualTo(
            space.height - StackConstants.overflowMargin + _epsilon,
          ),
          reason: 'height in $space',
        );
        expect(
          size.width / size.height,
          closeTo(_portrait, _epsilon),
          reason: 'aspect ratio in $space',
        );
      }
    });

    test('is empty rather than negative when there is no space', () {
      final layout = computeStackLayout(
        available: Size.zero,
        count: 3,
        cardAspectRatio: _portrait,
      );

      expect(layout.cardSize, Size.zero);
    });
  });

  group('computeStackLayout poses', () {
    StackLayout layoutFor(int count, {Size available = const Size(300, 300)}) =>
        computeStackLayout(
          available: available,
          count: count,
          cardAspectRatio: _portrait,
        );

    test('no pages, no poses', () {
      expect(layoutFor(0).poses, isEmpty);
    });

    test('a single page lies flat', () {
      final poses = layoutFor(1).poses;

      expect(poses, hasLength(1));
      _expectRest(poses.single);
    });

    test('two pages: a tilted back card, then a flat front card', () {
      final poses = layoutFor(2).poses;

      expect(poses, hasLength(2));
      expect(poses.first.angle, StackConstants.backCardAngle);
      expect(poses.first.offset.dx, lessThan(0));
      _expectRest(poses.last);
    });

    test(
      'three pages: back and middle fan out to either side, front is flat',
      () {
        final poses = layoutFor(3).poses;
        final [back, middle, front] = poses;

        expect(back.angle, StackConstants.backCardAngle);
        expect(middle.angle, StackConstants.middleCardAngle);
        expect(back.offset.dx, lessThan(0));
        expect(middle.offset.dx, greaterThan(0));
        expect(back.offset.dx, -middle.offset.dx);
        expect(back.offset.dy, middle.offset.dy);
        _expectRest(front);
      },
    );

    test('the front card is flat for every count', () {
      for (var count = 1; count <= StackConstants.maxVisibleCards; count++) {
        _expectRest(layoutFor(count).poses.last);
      }
    });

    test('more pages than fit show only the visible maximum', () {
      final poses = layoutFor(StackConstants.maxVisibleCards + 5).poses;

      expect(
        poses,
        hasLength(
          math.min(
            StackConstants.maxVisibleCards + 5,
            StackConstants.maxVisibleCards,
          ),
        ),
      );
    });

    test('the spread stops growing on large cards', () {
      final back = layoutFor(
        3,
        available: const Size(100000, 100000),
      ).poses.first;

      expect(
        back.offset,
        Offset(-StackConstants.maxSpreadX, StackConstants.maxSpreadY),
      );
    });

    test('the spread keeps a minimum on tiny cards', () {
      final back = layoutFor(3, available: Size.zero).poses.first;

      expect(
        back.offset,
        Offset(-StackConstants.minSpreadX, StackConstants.minSpreadY),
      );
    });
  });
}

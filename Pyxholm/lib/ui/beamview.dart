import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assay/play.dart';
import '../assay/pyx.dart';
import 'palette.dart';

/// Where the beam and the coins are.
///
/// The painter and the finger both use this, which is the point of it: a coin
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    this.room = room;
    beam = math.min(room.height * 0.42, 260);

    final coins = play.pyx.coins;
    columns = coins <= 6 ? 3 : (coins <= 9 ? 3 : 4);
    rows = (coins + columns - 1) ~/ columns;

    final wide = room.width / columns;
    final tall = (room.height - beam) / rows;
    spot = math.min(wide, tall) * 0.32;
    across = wide;
    down = tall;
  }

  final Play play;
  late final Size room;

  /// How much room the beam takes above the coins.
  late final double beam;

  late final int columns;
  late final int rows;
  late final double spot;
  late final double across;
  late final double down;

  Offset middleOf(int coin) => Offset(
        (coin % columns + 0.5) * across,
        // A little above the middle of the row, so the words underneath the
        // bottom row are not cut off by whatever is below the map.
        beam + (coin ~/ columns + 0.42) * down,
      );

  /// Where the beam pivots.
  Offset get pivot => Offset(room.width / 2, beam * 0.34);

  double get arm => room.width * 0.33;

  /// Where each pan hangs, once the beam has tilted.
  (Offset, Offset) pansAt(Tip tip) {
    final lean = switch (tip) {
      Tip.left => 0.13,
      Tip.right => -0.13,
      Tip.level => 0.0,
    };
    return (
      pivot + Offset(-arm * math.cos(lean), -arm * math.sin(lean) + arm * 0.32),
      pivot + Offset(arm * math.cos(lean), arm * math.sin(lean) + arm * 0.32),
    );
  }

  /// The coin under a point, or -1.
  int coinAt(Offset touch) {
    if (touch.dy < beam) return -1;
    for (var coin = 0; coin < play.pyx.coins; coin++) {
      if ((middleOf(coin) - touch).distance < spot * 1.5) return coin;
    }
    return -1;
  }
}

/// The beam with whatever is on it, and the coins waiting underneath.
class BeamView extends CustomPainter {
  const BeamView({
    required this.play,
    required this.pointing,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// A weighing the game is pointing at, or null.
  final Weighing? pointing;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the beam.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final tip = play.told.isEmpty ? Tip.level : play.told.last.tip;

    _beam(canvas, metrics, tip);
    _coins(canvas, metrics);
  }

  void _beam(Canvas canvas, Metrics metrics, Tip tip) {
    final pivot = metrics.pivot;
    final (left, right) = metrics.pansAt(tip);

    // The stand.
    canvas.drawPath(
      Path()
        ..moveTo(pivot.dx - metrics.arm * 0.14, pivot.dy + metrics.arm * 0.5)
        ..lineTo(pivot.dx + metrics.arm * 0.14, pivot.dy + metrics.arm * 0.5)
        ..lineTo(pivot.dx, pivot.dy)
        ..close(),
      Paint()..color = Palette.verge,
    );

    final brass = Paint()
      ..color = Palette.beam
      ..strokeWidth = metrics.spot * 0.22
      ..strokeCap = StrokeCap.round;

    // The beam and the two cords the pans hang on.
    final ends = (
      Offset(left.dx, left.dy - metrics.arm * 0.32),
      Offset(right.dx, right.dy - metrics.arm * 0.32),
    );
    canvas.drawLine(ends.$1, ends.$2, brass);
    canvas.drawLine(ends.$1, left, brass..strokeWidth = metrics.spot * 0.1);
    canvas.drawLine(ends.$2, right, brass);
    canvas.drawCircle(pivot, metrics.spot * 0.3, Paint()..color = Palette.beam);

    for (final (where, coins, colour) in [
      (left, play.onLeft, Palette.onLeft),
      (right, play.onRight, Palette.onRight),
    ]) {
      final pan = Rect.fromCenter(
        center: where + Offset(0, metrics.spot * 0.4),
        width: metrics.arm * 0.8,
        height: metrics.spot * 0.8,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          pan,
          bottomLeft: Radius.circular(metrics.spot * 0.4),
          bottomRight: Radius.circular(metrics.spot * 0.4),
        ),
        Paint()..color = coins.isEmpty ? Palette.verge : colour,
      );
      if (!showWords) continue;
      _words(
        canvas,
        '${coins.length}',
        pan.center,
        labels.copyWith(
          color: coins.isEmpty ? Palette.inkDim : Palette.night,
          fontWeight: FontWeight.w700,
        ),
      );
    }
  }

  void _coins(Canvas canvas, Metrics metrics) {
    final pointedAt = <int>{
      ...?pointing?.left,
      ...?pointing?.right,
    };

    for (var coin = 0; coin < play.pyx.coins; coin++) {
      final middle = metrics.middleOf(coin);
      final cleared = play.isCleared(coin);
      final place = play.placeOf(coin);

      canvas.drawCircle(
        middle,
        metrics.spot,
        Paint()
          ..color = cleared
              ? Palette.cleared
              : place == 0
                  ? Palette.onLeft
                  : place == 1
                      ? Palette.onRight
                      : Palette.coin,
      );

      if (pointedAt.contains(coin)) {
        canvas.drawCircle(
          middle,
          metrics.spot * 1.28,
          Paint()
            ..color = pointing!.left.contains(coin)
                ? Palette.onLeft
                : Palette.onRight
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.spot * 0.14,
        );
      }

      if (!showWords) continue;

      _words(
        canvas,
        '${coin + 1}',
        middle,
        labels.copyWith(
          color: cleared ? Palette.inkDim : Palette.night,
          fontSize: metrics.spot * 0.78,
          fontWeight: FontWeight.w700,
        ),
      );

      // What is still known about it, under the coin.
      final says = cleared
          ? 'sound'
          : play.couldBeHeavy(coin) && play.couldBeLight(coin)
              ? 'either'
              : play.couldBeHeavy(coin)
                  ? 'heavy?'
                  : 'light?';
      _words(
        canvas,
        says,
        middle + Offset(0, metrics.spot * 1.42),
        labels.copyWith(
          color: cleared ? Palette.cleared : Palette.inkDim,
          fontSize: metrics.spot * 0.42,
        ),
      );
    }
  }

  void _words(Canvas canvas, String words, Offset middle, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      middle - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(BeamView old) =>
      old.play != play || old.pointing != pointing;
}

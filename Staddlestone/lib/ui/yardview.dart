import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mill/play.dart';
import 'palette.dart';

/// Where the staddles and every stone on them is.
///
/// The painter and the finger both use this, which is the point of it: a
/// stone is where it is drawn, and there is no second sum that could disagree
/// with the first.
class Metrics {
  Metrics(this.play, Size room) {
    this.room = room;
    ground = room.height * 0.82;
    third = room.width / 3;
    thick = math.min(room.height * 0.11, 56);
    widest = third * 0.94;
  }

  final Play play;
  late final Size room;

  /// Where the staddle caps sit.
  late final double ground;
  late final double third;

  /// How thick a stone is drawn.
  late final double thick;

  /// How wide the biggest stone is.
  late final double widest;

  double middleOf(int staddle) => third * (staddle + 0.5);

  /// How wide a stone is drawn: the smallest is stone 0.
  double widthOf(int stone) =>
      widest * (0.30 + 0.70 * (stone + 1) / play.yard.stones);

  /// Where a stone sits on its staddle: its place in the pile from the
  /// bottom.
  Rect stoneRect(int stone) {
    final staddle = play.standing.on[stone];
    var below = 0;
    for (var other = stone + 1; other < play.yard.stones; other++) {
      if (play.standing.on[other] == staddle) below++;
    }
    final lifted =
        play.lifted == staddle && play.topOf(staddle) == stone;
    final y = lifted
        ? room.height * 0.12
        : ground - thick * (below + 1);
    return Rect.fromCenter(
      center: Offset(middleOf(staddle), y + thick / 2),
      width: widthOf(stone),
      height: thick * 0.92,
    );
  }

  /// The staddle under a point, or -1.
  int staddleAt(Offset touch) {
    final staddle = touch.dx ~/ third;
    if (staddle < 0 || staddle > 2) return -1;
    return staddle;
  }
}

/// The yard: three staddles and the stones on them.
class YardView extends CustomPainter {
  const YardView({
    required this.play,
    required this.pointing,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// A staddle the game is pointing at, or -1.
  final int pointing;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the stones.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var staddle = 0; staddle < 3; staddle++) {
      final x = metrics.middleOf(staddle);

      // The staddle: a stem and its mushroom cap.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, metrics.ground + size.height * 0.05),
            width: metrics.widest * 0.16,
            height: size.height * 0.1,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = Palette.staddle,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, metrics.ground),
          width: metrics.widest * 0.5,
          height: metrics.thick * 0.5,
        ),
        Paint()..color = Palette.staddle,
      );

      if (staddle == pointing) {
        canvas.drawCircle(
          Offset(x, metrics.ground - size.height * 0.16),
          metrics.thick * 0.7,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }

      if (!showWords) continue;
      final name = TextPainter(
        text: TextSpan(
          text: staddle == 2 ? 'the far staddle' : '',
          style: labels.copyWith(color: Palette.inkDim, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      name.paint(
        canvas,
        Offset(x - name.width / 2, metrics.ground + size.height * 0.115),
      );
    }

    // The stones, biggest drawn first so the pile stacks properly.
    for (var stone = play.yard.stones - 1; stone >= 0; stone--) {
      final rect = metrics.stoneRect(stone);
      final lifted = play.lifted >= 0 &&
          play.topOf(play.lifted) == stone &&
          play.standing.on[stone] == play.lifted;

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(metrics.thick * 0.45)),
        Paint()..color = lifted ? Palette.liftedStone : Palette.stone,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(metrics.thick * 0.45)),
        Paint()
          ..color = lifted ? Palette.liftedStone : Palette.stoneEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      // The eye of the millstone.
      canvas.drawCircle(
        rect.center,
        metrics.thick * 0.14,
        Paint()..color = Palette.night,
      );
    }
  }

  @override
  bool shouldRepaint(YardView old) =>
      old.play != play || old.pointing != pointing;
}

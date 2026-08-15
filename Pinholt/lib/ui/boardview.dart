import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../board/play.dart';
import '../board/rules.dart';
import 'palette.dart';

/// Where the holes lie on the board, so the screen and the tests
/// can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    side = play.rules.side;
    pitch = math.min(room.width, room.height) * 0.86 / side;
    origin = Offset(
      (room.width - pitch * side) / 2,
      (room.height - pitch * side) / 2,
    );
  }

  final Play play;

  late final int side;
  late final double pitch;
  late final Offset origin;

  /// The middle of a hole; y counts up the board.
  Offset at(Hole hole) => Offset(
        origin.dx + (hole.$1 + 0.5) * pitch,
        origin.dy + (side - 1 - hole.$2 + 0.5) * pitch,
      );

  /// The hole under a touch, or null off the board.
  Hole? under(Offset touch) {
    final col = ((touch.dx - origin.dx) / pitch).floor();
    final row = ((touch.dy - origin.dy) / pitch).floor();
    if (col < 0 || col >= side || row < 0 || row >= side) return null;
    return (col, side - 1 - row);
  }
}

/// The board itself: holes, pins, the fence in gold, every frame
/// in green, and the rings of a refusal or a pointer.
class BoardView extends CustomPainter {
  BoardView({required this.play, this.pointing, required this.labels});

  final Play play;
  final (String, Hole)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;

    // The cork.
    final cork = Rect.fromLTWH(
      metrics.origin.dx,
      metrics.origin.dy,
      pitch * metrics.side,
      pitch * metrics.side,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cork.inflate(pitch * 0.12), Radius.circular(pitch * 0.2)),
      Paint()..color = Palette.cork,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cork.inflate(pitch * 0.12), Radius.circular(pitch * 0.2)),
      Paint()
        ..color = Palette.corkRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, pitch * 0.03),
    );

    // The holes.
    for (final hole in play.rules.holes) {
      canvas.drawCircle(metrics.at(hole), pitch * 0.09, Paint()..color = Palette.hole);
    }

    // The frames, each a green plot.
    for (final frame in play.frames) {
      final path = Path()..moveTo(metrics.at(frame[0]).dx, metrics.at(frame[0]).dy);
      for (final corner in frame.skip(1)) {
        path.lineTo(metrics.at(corner).dx, metrics.at(corner).dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Palette.frame.withValues(alpha: 0.12));
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.frame
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, pitch * 0.045)
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // The fence, in gold, once three or more pins stand.
    final fence = play.fence;
    if (fence.length >= 3) {
      final path = Path()..moveTo(metrics.at(fence[0]).dx, metrics.at(fence[0]).dy);
      for (final post in fence.skip(1)) {
        path.lineTo(metrics.at(post).dx, metrics.at(post).dy);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.fence
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, pitch * 0.025)
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // The pins.
    for (var order = 0; order < play.pins.length; order++) {
      final at = metrics.at(play.pins[order]);
      canvas.drawCircle(at, pitch * 0.24, Paint()..color = Palette.pinInk);
      canvas.drawCircle(at + Offset(0, -pitch * 0.02), pitch * 0.2, Paint()..color = Palette.pin);
      canvas.drawCircle(at + Offset(-pitch * 0.06, -pitch * 0.08), pitch * 0.05,
          Paint()..color = Colors.white.withValues(alpha: 0.5));
    }

    // A hole refused for lining up.
    final refused = play.refused;
    if (refused != null) {
      canvas.drawCircle(
        metrics.at(refused),
        pitch * 0.3,
        Paint()
          ..color = Palette.refused
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
      // The line it would have made.
      for (var i = 0; i < play.pins.length; i++) {
        for (var j = i + 1; j < play.pins.length; j++) {
          if (Rules.turn(play.pins[i], play.pins[j], refused) == 0) {
            final ends = [play.pins[i], play.pins[j], refused]
              ..sort((a, b) => a.$1 != b.$1 ? a.$1 - b.$1 : a.$2 - b.$2);
            canvas.drawLine(
              metrics.at(ends.first),
              metrics.at(ends.last),
              Paint()
                ..color = Palette.refused
                ..strokeWidth = math.max(1, pitch * 0.03),
            );
          }
        }
      }
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        metrics.at(aim.$2),
        pitch * 0.34,
        Paint()
          ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(BoardView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a plot as it stands.
String whyWords(Play play) {
  final plot = play.plot;
  final note = plot.note == null ? '' : ' ${plot.note}';
  if (!plot.winnable) {
    return 'Look at the fence, the gold line round the outside of '
        'the pins. It runs through five pins, or four, or three. '
        'Through five or four, and any four of them frame at once. '
        'Through three, and two pins stand inside; the line through '
        'those two leaves two of the fence pins on one side, and '
        'those two with the two inside frame. There is no fourth '
        'kind of fence. The sweep set all 25,052 placings and found '
        'no frameless five.$note';
  }
  return 'The placings are counted by the sweep, every way of setting '
      'the pins with no three in a line, every four of each read for a '
      'frame, and held to a second voice: the fence alone, with no '
      'fours read, gives four pins one frame or none and five pins '
      'five, three or one, and the two agree on every placing there '
      'is. ${plot.ways} placing${plot.ways == 1 ? '' : 's'} '
      'land${plot.ways == 1 ? 's' : ''} this plot.$note';
}

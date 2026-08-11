import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tower/play.dart';
import 'palette.dart';

/// Where every spindle and round stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final spindles = play.spindle.spindles;
    final rounds = play.spindle.rounds;
    lane = width / spindles;
    discHigh = math.min(height / (rounds + 4.5), 34.0);
    // Centered, with headroom above the posts for a lifted round.
    final posts = (rounds + 1.6) * discHigh;
    baseY = math.min(height * 0.5 + posts * 0.62, height * 0.86);
    postTop = baseY - posts;
  }

  final Play play;

  late final double width;
  late final double height;

  /// A spindle's share of the width, a round's height, the base line
  /// and where the posts top out.
  late final double lane;
  late final double discHigh;
  late final double baseY;
  late final double postTop;

  double spindleX(int spindle) => lane * (spindle + 0.5);

  /// A round's width by its size.
  double discWide(int round) =>
      lane * (0.34 + 0.56 * (round + 1) / play.spindle.rounds);

  /// Where the round at stack height `at` sits, nought at the base.
  double slotY(int at) => baseY - (at + 0.5) * discHigh;

  /// The spindle under a touch, or -1.
  int spindleAt(Offset touch) {
    final at = touch.dx ~/ lane;
    return at >= 0 && at < play.spindle.spindles ? at : -1;
  }
}

/// The bench, drawn.
class TowerView extends CustomPainter {
  TowerView({
    required this.play,
    required this.lifted,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The spindle whose top round is lifted, or -1.
  final int lifted;

  /// The move being pointed at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The base and the posts.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(metrics.lane * 0.12, metrics.baseY,
            metrics.width - metrics.lane * 0.24, metrics.discHigh * 0.6),
        Radius.circular(metrics.discHigh * 0.2),
      ),
      Paint()..color = Palette.base,
    );
    for (var spindle = 0; spindle < play.spindle.spindles; spindle++) {
      final x = metrics.spindleX(spindle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, (metrics.postTop + metrics.baseY) / 2),
            width: metrics.discHigh * 0.28,
            height: metrics.baseY - metrics.postTop,
          ),
          Radius.circular(metrics.discHigh * 0.14),
        ),
        Paint()..color = Palette.post,
      );
    }

    final pointed = pointing;
    if (pointed != null) _point(canvas, metrics, pointed);

    // The rounds, stacked; the lifted one floats above its post.
    for (var spindle = 0; spindle < play.spindle.spindles; spindle++) {
      final stack = <int>[];
      for (var round = play.spindle.rounds - 1; round >= 0; round--) {
        if (play.spindleOf(round) == spindle) stack.add(round);
      }
      for (var at = 0; at < stack.length; at++) {
        final round = stack[at];
        final isLifted =
            spindle == lifted && at == stack.length - 1;
        _round(
          canvas,
          metrics,
          round,
          metrics.spindleX(spindle),
          isLifted
              ? metrics.postTop - metrics.discHigh * 1.1
              : metrics.slotY(at),
          isLifted,
        );
      }
    }
  }

  void _round(Canvas canvas, Metrics metrics, int round, double x,
      double y, bool isLifted) {
    final rect = Rect.fromCenter(
      center: Offset(x, y),
      width: metrics.discWide(round),
      height: metrics.discHigh * 0.86,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect, Radius.circular(metrics.discHigh * 0.4)),
      Paint()
        ..color = Palette.rounds[round % Palette.rounds.length],
    );
    if (isLifted) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect, Radius.circular(metrics.discHigh * 0.4)),
        Paint()
          ..color = Palette.lifted
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
  }

  void _point(Canvas canvas, Metrics metrics, (int, int) move) {
    final (from, to) = move;
    final y = metrics.postTop - metrics.discHigh * 0.5;
    final fromX = metrics.spindleX(from);
    final toX = metrics.spindleX(to);
    final paint = Paint()
      ..color = Palette.shown
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(fromX, y), Offset(toX, y), paint);
    final step = toX > fromX ? 1.0 : -1.0;
    canvas.drawLine(Offset(toX, y),
        Offset(toX - step * metrics.discHigh * 0.5, y - metrics.discHigh * 0.35), paint);
    canvas.drawLine(Offset(toX, y),
        Offset(toX - step * metrics.discHigh * 0.5, y + metrics.discHigh * 0.35), paint);
  }

  @override
  bool shouldRepaint(TowerView old) =>
      old.play != play ||
      old.lifted != lifted ||
      old.pointing != pointing;
}

/// The words the why speaks, from the job at hand.
String whyWords(Play play) {
  final spindle = play.spindle;
  final note = spindle.note == null ? '' : ' ${spindle.note}';
  final wager = spindle.wager;
  if (wager != null) {
    return 'The walk stood on every board of this tower, all '
        '${play.rules.boards} of them, and wrote down the fewest from '
        'each. From the full stack it says ${spindle.fewest}, so a '
        'wager of $wager was lost before the first lift.$note';
  }
  if (spindle.spindles == 3) {
    return 'Three things that share nothing say the same number: the '
        'doubling rule, the old iteration played out move by move, '
        'and the walk of every board all name ${spindle.fewest}. The '
        'game plays from the walk, so Show me is never folklore.$note';
  }
  return 'Two reckonings that share nothing say the same number: the '
      'leapfrog reckoning and the walk of every board both name '
      '${spindle.fewest}. The game plays from the walk, so Show me '
      'is never folklore.$note';
}

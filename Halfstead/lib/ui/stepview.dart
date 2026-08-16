import 'dart:math';

import 'package:flutter/material.dart';

import '../step/frac.dart';
import '../step/play.dart';
import '../step/rules.dart';
import 'palette.dart';

/// Where the corridor lies in a board of a given size: the start on the
/// left, the wall on the right, the ground a whole length between.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare ? 0.0 : (roomy ? 30.0 : 0.0);
    left = bare ? size.width * 0.06 : 24;
    right = size.width - (bare ? size.width * 0.1 : 30);
    ground = (size.height - strip) * (bare ? 0.62 : 0.66);
    hopHeight = min((size.height - strip) * 0.4, (right - left) * 0.5);
  }

  final Play play;
  final Size size;
  late final double left, right, ground, hopHeight;

  double get length => right - left;

  /// Where a distance along the corridor falls, 0 the start, 1 the wall.
  double at(Frac distance) => left + length * distance.toDouble;

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The corridor, the ground covered, the hops that covered it, the
/// runner and the wall.
class StepView extends CustomPainter {
  const StepView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the corridor only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    // The ground, the covered part over it, and the wall.
    canvas.drawLine(Offset(m.left, m.ground), Offset(m.right, m.ground), Paint()..color = Palette.track..strokeWidth = bare ? 8 : 5..strokeCap = StrokeCap.round);
    final covered = play.covered;
    canvas.drawLine(Offset(m.left, m.ground), Offset(m.at(covered), m.ground), Paint()..color = Palette.covered..strokeWidth = bare ? 8 : 5..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(m.right, m.ground - (bare ? 60 : 40)), Offset(m.right, m.ground + (bare ? 14 : 10)), Paint()..color = Palette.wall..strokeWidth = bare ? 8 : 5..strokeCap = StrokeCap.square);
    // The hops, each an arc from where it started to where it landed.
    var from = Frac.zero;
    final hop = Paint()..color = Palette.hop..style = PaintingStyle.stroke..strokeWidth = bare ? 5 : 1.8;
    var k = 0;
    for (final step in play.lengths) {
      final to = from + step;
      final x0 = m.at(from), x1 = m.at(to);
      final w = x1 - x0;
      if (w >= 1) {
        final h = min(m.hopHeight, w * 0.7);
        final path = Path()..moveTo(x0, m.ground);
        path.quadraticBezierTo((x0 + x1) / 2, m.ground - 2 * h, x1, m.ground);
        canvas.drawPath(path, hop);
        if (!bare && k < 6 && w > 40) {
          _word(canvas, Rules.tell(step), Offset((x0 + x1) / 2, m.ground - h - 10), Palette.hop, size, 11);
        }
      }
      from = to;
      k++;
    }
    // The runner where the last hop landed, and the start.
    canvas.drawCircle(Offset(m.left, m.ground), bare ? 5 : 3.5, Paint()..color = Palette.inkDim);
    canvas.drawCircle(Offset(m.at(covered), m.ground), bare ? 9 : 6, Paint()..color = Palette.runner);
    if (bare) return;
    _word(canvas, 'start', Offset(m.left, m.ground + 16), Palette.inkDim, size, 11);
    _word(canvas, 'wall', Offset(m.right, m.ground + 16), Palette.inkDim, size, 11);
    if (!m.roomy) return;
    _word(canvas, '${Rules.tell(covered)} covered', Offset(size.width / 2, size.height - 26), Palette.covered, size, 12);
    _word(canvas, '${Rules.tell(play.left)} to go', Offset(size.width / 2, size.height - 10), Palette.toGo, size, 12);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize))),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(StepView old) => old.play != play || old.bare != bare;
}

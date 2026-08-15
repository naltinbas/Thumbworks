import 'dart:math';

import 'package:flutter/material.dart';

import '../rung/play.dart';
import '../rung/rules.dart';
import 'palette.dart';

/// Where the square, the rule and the ladder sit in a board of a given
/// size.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 26.0 : 0.0;
    // The square takes the left, the rule of ratios the right.
    final h = size.height - strip;
    // The square sits above, the rule of ratios runs across below it.
    squareSide = min(size.width * 0.62, h - 140).clamp(40.0, 400.0);
    squareTopLeft = Offset((size.width - squareSide) / 2 - size.width * 0.06, 28);
    ruleLeft = 24;
    ruleRight = size.width - 24;
    ruleY = squareTopLeft.dy + squareSide + 52;
  }

  final Play play;
  final Size size;
  late final double squareSide, ruleLeft, ruleRight, ruleY;
  late final Offset squareTopLeft;

  /// The rule runs from 1.3 to 1.5: where a ratio falls on it.
  double onRule(double ratio) => ruleLeft + (ruleRight - ruleLeft) * ((ratio - 1.3) / 0.2).clamp(0.0, 1.0);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The square with its diagonal, and the rule of ratios with the true
/// diagonal marked and the rungs of the ladder along it.
class RungView extends CustomPainter {
  const RungView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the square and the ladder only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    if (bare) {
      _square(canvas, Rect.fromLTWH(size.width * 0.1, size.height * 0.1, size.width * 0.8, size.height * 0.8), 6);
      return;
    }
    // The square and its diagonal, drawn to the side and diagonal set:
    // the diagonal runs corner to corner at the true length, and the
    // set diagonal is marked along it, short or long by its miss.
    final rect = Rect.fromLTWH(m.squareTopLeft.dx, m.squareTopLeft.dy, m.squareSide, m.squareSide);
    _square(canvas, rect, 2);
    final trueLength = m.squareSide * sqrt2;
    final setLength = m.squareSide * play.diagonal / play.side;
    final dir = Offset(1, -1) / sqrt2;
    final foot = rect.bottomLeft;
    final tip = foot + dir * min(setLength, trueLength * 1.25);
    canvas.drawLine(foot, tip, Paint()..color = Palette.diagonal..strokeWidth = 3);
    canvas.drawCircle(tip, 4, Paint()..color = Palette.diagonal);
    // The rule of ratios.
    canvas.drawLine(Offset(m.ruleLeft, m.ruleY), Offset(m.ruleRight, m.ruleY), Paint()..color = Palette.rule..strokeWidth = 2);
    for (final (r, tall) in [(1.3, true), (1.35, false), (1.4, true), (1.45, false), (1.5, true)]) {
      final x = m.onRule(r);
      canvas.drawLine(Offset(x, m.ruleY - (tall ? 8 : 4)), Offset(x, m.ruleY + (tall ? 8 : 4)), Paint()..color = Palette.rule..strokeWidth = 1.5);
    }
    for (final (s, d) in Rules.rungs) {
      final x = m.onRule(d / s);
      canvas.drawCircle(Offset(x, m.ruleY), 3, Paint()..color = Palette.rungDim);
    }
    final truth = m.onRule(sqrt2);
    canvas.drawLine(Offset(truth, m.ruleY - 16), Offset(truth, m.ruleY + 16), Paint()..color = Palette.truth..strokeWidth = 2);
    final mine = m.onRule(play.diagonal / play.side);
    canvas.drawCircle(Offset(mine, m.ruleY), 6, Paint()..color = play.onLadder ? Palette.rung : Palette.diagonal);
    if (!m.roomy) return;
    _word(canvas, 'side ${play.side}', rect.bottomCenter + const Offset(0, 12), Palette.chalk, size);
    _word(canvas, 'diagonal ${play.diagonal}', tip + const Offset(0, -12), Palette.diagonal, size);
    _word(canvas, 'root two', Offset(truth, m.ruleY - 26), Palette.truth, size);
    _word(canvas, '1.3', Offset(m.onRule(1.3), m.ruleY + 18), Palette.inkDim, size);
    _word(canvas, '1.5', Offset(m.onRule(1.5), m.ruleY + 18), Palette.inkDim, size);
    final ratio = (play.diagonal / play.side).toStringAsFixed(4);
    _word(canvas, ratio, Offset(mine, m.ruleY + 32), play.onLadder ? Palette.rung : Palette.diagonal, size);
    final miss = play.miss;
    final missTold = miss == 0 ? 'the true diagonal' : '${miss.abs()} ${miss > 0 ? 'over' : 'under'}';
    _word(canvas, '${play.diagonal} squared is ${Rules.commas(play.diagonal * play.diagonal)}, twice ${play.side} squared ${Rules.commas(2 * play.side * play.side)}: $missTold', Offset(size.width / 2, size.height - 12), Palette.inkDim, size);
  }

  void _square(Canvas canvas, Rect rect, double width) {
    canvas.drawRect(rect, Paint()..color = Palette.chalkFace);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Palette.chalk
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
    if (width > 2) {
      canvas.drawLine(rect.bottomLeft, rect.topRight, Paint()..color = Palette.diagonal..strokeWidth = width);
      // The ladder up the diagonal: rungs across it.
      for (var k = 1; k <= 5; k++) {
        final t = k / 6;
        final p = rect.bottomLeft + (rect.topRight - rect.bottomLeft) * t;
        canvas.drawLine(p + Offset(-rect.width * 0.08, -rect.width * 0.08), p + Offset(rect.width * 0.08, rect.width * 0.08), Paint()..color = Palette.rung..strokeWidth = width * 0.8);
      }
    }
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(RungView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

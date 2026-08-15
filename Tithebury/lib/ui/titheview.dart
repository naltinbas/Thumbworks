import 'dart:math';

import 'package:flutter/material.dart';

import '../tithe/play.dart';
import '../tithe/rules.dart';
import 'palette.dart';

/// Where the three bars sit in a board of a given size: the number, its
/// divisors laid end to end, and the divisors of their sum.
class Metrics {
  Metrics(this.play, this.size) {
    left = 16;
    right = size.width - 16;
    final h = size.height;
    barHeight = min(44.0, h / 7);
    gap = min(36.0, h / 7);
    top = (h - 3 * barHeight - 2 * gap) / 2;
    scale = (right - left) / max(1, [play.number, play.tithe, play.tithesTithe].reduce(max));
  }

  final Play play;
  final Size size;
  late final double left, right, barHeight, gap, top, scale;

  /// The rectangle of bar [i] (0 the number, 1 the divisors, 2 the
  /// tithe's tithe) of [length] units from the left.
  Rect bar(int i, num from, num length) => Rect.fromLTWH(left + from * scale, top + i * (barHeight + gap), length * scale, barHeight);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The number, its divisors laid end to end, and the tithe's tithe.
class TitheView extends CustomPainter {
  const TitheView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the bars only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.number, t = play.tithe, tt = play.tithesTithe;
    // The number.
    _bar(canvas, m.bar(0, 0, n), Palette.numberFace, Palette.number);
    // The divisors, end to end.
    var from = 0;
    final divisors = play.divisors;
    for (var i = 0; i < divisors.length; i++) {
      final d = divisors[i];
      _bar(canvas, m.bar(1, from, d), Palette.divisors[i % Palette.divisors.length].withValues(alpha: 0.35), Palette.divisors[i % Palette.divisors.length]);
      from += d;
    }
    // The tithe's tithe.
    if (tt > 0) _bar(canvas, m.bar(2, 0, tt), Palette.titheFace, Palette.tithe);
    // A rule down from the number's end, to read the sum against.
    final end = m.bar(0, 0, n).right;
    canvas.drawLine(Offset(end, m.top - 6), Offset(end, m.top + 3 * m.barHeight + 2 * m.gap + 6), Paint()..color = t == n ? Palette.good : Palette.rule..strokeWidth = bare ? 3 : 1.5);
    if (bare || !m.roomy) return;
    _word(canvas, 'the number, $n', m.bar(0, 0, n).topLeft + const Offset(0, -9), Palette.number, size, left: true);
    final told = divisors.isEmpty ? 'no divisors add up to 0' : divisors.length <= 9 ? 'its divisors ${Rules.told(divisors)} add up to $t' : 'its ${divisors.length} divisors add up to $t';
    final verdict = t == n ? 'perfect' : t > n ? '${t - n} over' : '${n - t} short';
    _word(canvas, '$told, $verdict', m.bar(1, 0, 0).topLeft + const Offset(0, -9), t == n ? Palette.good : t > n ? Palette.over : Palette.short, size, left: true);
    _word(canvas, tt > 0 ? 'the divisors of $t add up to $tt' : 'the divisors of $t add up to nothing', m.bar(2, 0, 0).topLeft + const Offset(0, -9), Palette.tithe, size, left: true);
  }

  void _bar(Canvas canvas, Rect rect, Color face, Color rim) {
    canvas.drawRect(rect, Paint()..color = face);
    canvas.drawRect(
      rect,
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 3 : 1.5,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, {bool left = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final ax = left ? at.dx : at.dx - text.width / 2;
    final x = ax.clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(TitheView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

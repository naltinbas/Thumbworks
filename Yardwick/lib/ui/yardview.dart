import 'dart:math';

import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import 'palette.dart';

/// Where the two hedges and the yardstick sit in a board of a given
/// size: two bars, one above the other, as long as the log of their
/// length, and the yardstick beneath.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    left = bare ? size.width * 0.06 : 16;
    width = size.width - 2 * left;
    final high = size.height - strip;
    barHeight = bare ? high * 0.18 : min(34.0, high * 0.16);
    firstY = bare ? high * 0.18 : high * 0.14;
    secondY = bare ? high * 0.46 : high * 0.42;
    stickY = bare ? high * 0.78 : high * 0.72;
  }

  final Play play;
  final Size size;
  late final double left, width, barHeight, firstY, secondY, stickY;

  /// A hedge's drawn length: the log of it, so that 1 is a stub and
  /// 832,040 the whole width.
  double lengthOf(BigInt n) => width * (log(n.toDouble()) + 1) / (log(832040) + 1);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The two hedges, their lengths, the yardstick and the counts' Euclid.
class YardView extends CustomPainter {
  const YardView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: ('m' or 'n', by).
  final (String, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the hedges and the yardstick only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final hedges = [(play.first, play.firstHedge, m.firstY), (play.second, play.secondHedge, m.secondY)];
    for (final (count, length, y) in hedges) {
      final w = m.lengthOf(length);
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(m.left, y, w, m.barHeight), Radius.circular(m.barHeight * 0.3));
      canvas.drawRRect(r, Paint()..color = Palette.hedge);
      canvas.drawRRect(r, Paint()..color = Palette.hedgeRim..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
      // Leaves along the top.
      final leaves = max(3, (w / (bare ? 26 : 14)).floor());
      for (var i = 0; i < leaves; i++) {
        final x = m.left + (i + 0.5) * w / leaves;
        canvas.drawCircle(Offset(x, y), bare ? 6 : 3.5, Paint()..color = Palette.hedgeRim);
      }
      final words = bare ? Rules.tell(length) : 'hedge $count: ${Rules.tell(length)}';
      _word(canvas, words, Offset(m.left + w / 2, y + m.barHeight / 2 + 1), Palette.chalk, size, bare ? m.barHeight * 0.55 : 13, bold: true, within: w);
    }
    // The yardstick.
    final stick = play.measure;
    final sw = m.lengthOf(stick);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(m.left, m.stickY, sw, bare ? m.barHeight * 0.55 : 12), const Radius.circular(3)), Paint()..color = Palette.gold);
    for (var i = 1; i < 6; i++) {
      final x = m.left + sw * i / 6;
      canvas.drawLine(Offset(x, m.stickY), Offset(x, m.stickY + (bare ? m.barHeight * 0.25 : 5)), Paint()..color = Palette.night..strokeWidth = 1.5);
    }
    if (bare) {
      _word(canvas, Rules.tell(stick), Offset(m.left + sw + m.barHeight * 0.9, m.stickY + m.barHeight * 0.27), Palette.gold, size, m.barHeight * 0.55, bold: true);
      return;
    }
    _word(canvas, 'yardstick ${Rules.tell(stick)}, the ${_nth(play.commonCount)} hedge', Offset(m.left + max(sw, 0) + 6 + 90, m.stickY + 6), Palette.gold, size, 12);
    if (!m.roomy) return;
    final steps = play.euclid.map((s) => '(${s.$1}, ${s.$2})').join(' to ');
    _word(canvas, 'Euclid on the counts: $steps, measure ${play.commonCount}', Offset(size.width / 2, size.height - 11), Palette.inkDim, size, 11);
  }

  static String _nth(int n) {
    const words = ['', 'first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth'];
    if (n < words.length) return words[n];
    return '${n}th';
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool bold = false, double? within}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize), fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    // A label wider than its bar sits just after the bar's start.
    if (within != null && text.width > within - 8) x = max(2.0, at.dx - within / 2 + 4);
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(YardView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

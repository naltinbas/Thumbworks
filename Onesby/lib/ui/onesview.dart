import 'dart:math';

import 'package:flutter/material.dart';

import '../ones/play.dart';
import '../ones/rules.dart';
import 'palette.dart';

/// Where the row of ones and the chain sit in a board of a given size.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final p = play.exponent;
    // The mark wraps the ones into a near square; the board runs them
    // in rows of sixteen at most.
    final columns = bare ? sqrt(p).ceil() : min(p, 16);
    rows = (p + columns - 1) ~/ columns;
    cell = bare ? min(size.width / (columns + 0.5), size.height / (rows + 0.5)) : min(30.0, max(8.0, (size.width - 24) / columns));
    this.columns = columns;
    top = bare ? (size.height - rows * cell) / 2 : 12;
    left = (size.width - columns * cell) / 2;
  }

  final Play play;
  final Size size;
  late final double cell, top, left;
  late final int rows, columns;

  /// The square of the i th one, hundreds place first.
  Rect oneAt(int i) => Rect.fromLTWH(left + (i % columns) * cell, top + (i ~/ columns) * cell, cell, cell);

  double get rowBottom => top + rows * cell;

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The row of ones, its number, and the Lucas-Lehmer chain under it.
class OnesView extends CustomPainter {
  const OnesView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the row of ones only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final prime = play.rowIsPrime;
    final colour = prime ? Palette.one : Palette.oneRust;
    for (var i = 0; i < play.exponent; i++) {
      final r = m.oneAt(i).deflate(bare ? 1.5 : 2);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), Paint()..color = Palette.cell);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)), Paint()..color = colour..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.4);
      _word(canvas, '1', r.center, colour, size, bare ? m.cell * 0.55 : min(16.0, m.cell * 0.6));
    }
    if (bare) return;
    // The number the ones make.
    final row = play.row;
    _word(canvas, '${play.exponent} ones: ${Rules.commas(row)}', Offset(size.width / 2, m.rowBottom + 16), Palette.number, size, 15);
    final verdict = prime
        ? 'prime, both ways'
        : '${Rules.commas(play.factor)} times ${Rules.commas(row ~/ play.factor)}${play.exponentIsPrime ? '' : ', the row of ${Rules.smallestExponentFactor(play.exponent)} ones dividing'}';
    _word(canvas, verdict, Offset(size.width / 2, m.rowBottom + 36), colour, size, 13);
    if (!m.roomy || play.exponent < 3) return;
    // The Lucas-Lehmer chain as bars, each the share of the row.
    final chain = Rules.chain(play.exponent);
    final chartTop = m.rowBottom + 56, chartBottom = size.height - 32;
    if (chartBottom - chartTop < 30) return;
    final w = (size.width - 40) / chain.length;
    canvas.drawLine(Offset(20, chartBottom), Offset(size.width - 20, chartBottom), Paint()..color = Palette.floor..strokeWidth = 1);
    for (var i = 0; i < chain.length; i++) {
      final share = chain[i].toDouble() / row.toDouble();
      final h = max(2.0, (chartBottom - chartTop) * share);
      final x = 20 + i * w;
      canvas.drawRect(Rect.fromLTWH(x + w * 0.15, chartBottom - h, w * 0.7, h), Paint()..color = i == chain.length - 1 && chain.last == BigInt.zero ? Palette.one : Palette.chain);
    }
    _word(
      canvas,
      'the Lucas-Lehmer chain, ${chain.length - 1} step${chain.length == 2 ? '' : 's'}, each bar its share of the row',
      Offset(size.width / 2, size.height - 20),
      Palette.inkDim,
      size,
      11,
    );
    _word(
      canvas,
      chain.last == BigInt.zero ? 'it ends at 0: prime' : 'it ends at ${Rules.commas(chain.last)}, not 0: composite',
      Offset(size.width / 2, size.height - 7),
      chain.last == BigInt.zero ? Palette.one : Palette.oneRust,
      size,
      11,
    );
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
  bool shouldRepaint(OnesView old) => old.play != play || old.bare != bare;
}

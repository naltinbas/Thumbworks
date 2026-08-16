import 'dart:math';

import 'package:flutter/material.dart';

import '../album/play.dart';
import '../album/rules.dart';
import 'palette.dart';

/// Where the album and the bar sit in a board of a given size.
class Metrics {
  Metrics(this.play, this.size) {
    final n = play.stickers;
    columns = n <= 4 ? n : n <= 8 ? 4 : 6;
    rows = (n + columns - 1) ~/ columns;
    cell = min((size.width - 40) / columns, 56.0);
    final gridHeight = rows * cell;
    top = 12;
    barTop = top + gridHeight + (roomy ? 44 : 20);
    barLeft = 24;
    barRight = size.width - 24;
    barHeight = 16;
  }

  final Play play;
  final Size size;
  late final int columns, rows;
  late final double cell, top, barTop, barLeft, barRight, barHeight;

  Rect slot(int i) {
    final w = columns * cell;
    final x0 = (size.width - w) / 2;
    return Rect.fromLTWH(x0 + (i % columns) * cell, top + (i ~/ columns) * cell, cell, cell);
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The album's slots, the chance bar and the average.
class AlbumView extends CustomPainter {
  const AlbumView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the album only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    // The page and its slots, each with its sticker.
    final page = Rect.fromLTRB(m.slot(0).left - 8, m.top - 8, m.slot(min(m.columns, play.stickers) - 1).right + 8, m.top + m.rows * m.cell + 8);
    canvas.drawRRect(RRect.fromRectAndRadius(page, const Radius.circular(8)), Paint()..color = Palette.page);
    for (var i = 0; i < play.stickers; i++) {
      final r = m.slot(i).deflate(bare ? 4 : 5);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(5));
      canvas.drawRRect(rr, Paint()..color = Palette.stickers[i % Palette.stickers.length]);
      canvas.drawRRect(rr, Paint()..color = Palette.slotRim..style = PaintingStyle.stroke..strokeWidth = 1);
      if (!bare && r.width >= 30) _word(canvas, '${i + 1}', r.center, Palette.night, size, 12);
    }
    if (bare) return;
    // The chance bar.
    final chance = play.chance.toDouble;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(m.barLeft, m.barTop, m.barRight, m.barTop + m.barHeight), const Radius.circular(8)), Paint()..color = Palette.barBack);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(m.barLeft, m.barTop, m.barLeft + (m.barRight - m.barLeft) * chance, m.barTop + m.barHeight), const Radius.circular(8)), Paint()..color = Palette.bar);
    // The half mark.
    final half = (m.barLeft + m.barRight) / 2;
    canvas.drawLine(Offset(half, m.barTop - 4), Offset(half, m.barTop + m.barHeight + 4), Paint()..color = Palette.ink..strokeWidth = 1.5);
    if (!m.roomy) return;
    _word(canvas, 'a set of ${play.stickers}: ${play.average} packets on average, ${Rules.decimal(play.average)}', Offset(size.width / 2, m.barTop - 22), Palette.ink, size, 12);
    _word(canvas, 'full after ${play.packets} packet${play.packets == 1 ? '' : 's'}: ${Rules.decimal(play.chance)}${play.chance == Frac.one ? ', certain' : ''}', Offset(size.width / 2, m.barTop + m.barHeight + 14), Palette.bar, size, 12);
    _word(canvas, 'half', Offset(half, m.barTop + m.barHeight + 30), Palette.inkDim, size, 10);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(AlbumView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

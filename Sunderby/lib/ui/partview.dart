import 'dart:math';

import 'package:flutter/material.dart';

import '../part/play.dart';
import 'palette.dart';

/// Where the shelf and the rows of dots sit in a board of a given size.
class Metrics {
  Metrics(this.play, this.size) {
    final n = play.level.number;
    columns = n <= 6 ? n : (n + 1) ~/ 2;
    shelfRows = (n + columns - 1) ~/ columns;
    cell = min((size.width - 16) / columns, 48.0);
    shelfTop = 6;
    rowsTop = shelfTop + shelfRows * cell + 18;
    dot = min(30.0, (size.width - 40) / (n + 2));
    rowHeight = min(dot * 1.4, (size.height - rowsTop - (roomy ? 26 : 6)) / max(1, play.parts.length + 1));
  }

  final Play play;
  final Size size;
  late final int columns, shelfRows;
  late final double cell, shelfTop, rowsTop, dot, rowHeight;

  /// The rectangle of shelf size [k], 1 to the number.
  Rect shelfRect(int k) {
    final w = columns * cell;
    final x0 = (size.width - w) / 2;
    final i = k - 1;
    return Rect.fromLTWH(x0 + (i % columns) * cell, shelfTop + (i ~/ columns) * cell, cell, cell);
  }

  /// The rectangle of the [i]th part's row.
  Rect rowRect(int i) => Rect.fromLTWH(20, rowsTop + i * rowHeight, size.width - 40, rowHeight);

  /// What is under a point: ('shelf', size) or ('row', i), or null.
  (String, int)? under(Offset p) {
    for (var k = 1; k <= play.level.number; k++) {
      if (shelfRect(k).contains(p)) return ('shelf', k);
    }
    for (var i = 0; i < play.parts.length; i++) {
      if (rowRect(i).contains(p)) return ('row', i);
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The shelf of sizes, the rows of dots and the sum.
class PartView extends CustomPainter {
  const PartView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the dots only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    if (bare) {
      // The rows of dots of the standing partition, big and centred:
      // one row a part, the largest on top.
      final rows = play.parts.length, columns = play.sorted.first;
      final u = min(size.width / (columns + 1), size.height / (rows + 1));
      final left = (size.width - columns * u) / 2, top = (size.height - rows * u) / 2;
      for (var i = 0; i < rows; i++) {
        final part = play.sorted[i];
        for (var k = 0; k < part; k++) {
          canvas.drawCircle(Offset(left + (k + 0.5) * u, top + (i + 0.5) * u), u * 0.39, Paint()..color = part.isOdd ? Palette.oddDot : Palette.evenDot);
        }
      }
      return;
    }
    final m = Metrics(play, size);
    for (var k = 1; k <= play.level.number; k++) {
      final r = m.shelfRect(k).deflate(2.5);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(5));
      final fits = play.sum + k <= play.level.number;
      canvas.drawRRect(rr, Paint()..color = fits ? Palette.shelf : Palette.rowBack);
      canvas.drawRRect(rr, Paint()..color = fits ? Palette.shelfRim : Palette.line..style = PaintingStyle.stroke..strokeWidth = 1);
      _word(canvas, '$k', r.center, fits ? Palette.chalk : Palette.inkDim, size, 13);
    }
    for (var i = 0; i < play.parts.length; i++) {
      final r = m.rowRect(i);
      final part = play.parts[i];
      for (var k = 0; k < part; k++) {
        canvas.drawCircle(Offset(r.left + m.dot * (k + 0.5), r.center.dy), m.dot * 0.4, Paint()..color = part.isOdd ? Palette.oddDot : Palette.evenDot);
      }
      _word(canvas, '$part', Offset(r.left + m.dot * (part + 1), r.center.dy), Palette.inkDim, size, 11);
    }
    final aim = pointing;
    if (aim != null) {
      final r = aim.$1 == Aim.add ? m.shelfRect(aim.$2).deflate(2.5) : m.rowRect(aim.$2);
      canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(2), const Radius.circular(6)), Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    if (!m.roomy) return;
    final n = play.level.number;
    _word(canvas, play.parts.isEmpty ? 'no parts laid: $n wanted' : '${play.sorted.join(' + ')} = ${play.sum}${play.isFull ? '' : ', ${n - play.sum} to go'}', Offset(size.width / 2, size.height - 11), play.isFull ? Palette.gold : Palette.inkDim, size, 12);
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
  bool shouldRepaint(PartView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

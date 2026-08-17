import 'dart:math';

import 'package:flutter/material.dart';

import '../shape/play.dart';
import 'palette.dart';

/// Where the staircase sits in a board of a given size: rows down the
/// board, boxes left aligned, and a strip under the last row where a
/// new row would start.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 26.0;
    final rows = play.rows.length + (bare ? 0 : 1);
    final wide = play.rows.first;
    pad = bare ? size.width * 0.06 : 16.0;
    final room = Size(size.width - pad * 2, size.height - words - pad);
    final fits = min(room.width / max(wide, 4), room.height / max(rows, 3));
    cell = min(fits, bare ? 64.0 : 46.0);
    left = (size.width - cell * wide) / 2;
    // The board leaves a row's worth of space under the staircase for
    // the strip that starts a new row; the mark has no strip to draw.
    top = (bare ? 0.0 : 6.0) +
        (size.height - words - cell * (play.rows.length + (bare ? 0 : 1))) / 2;
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double pad, cell, left, top;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 170 && size.width >= 240;

  Rect boxAt(int row, int column) =>
      Rect.fromLTWH(left + column * cell, top + row * cell, cell, cell);

  /// The strip where a new row would go.
  Rect get newRow =>
      Rect.fromLTWH(left, top + play.rows.length * cell, cell, cell);

  /// The row a tap means, counting a tap under the staircase as a new
  /// row; null when it lands nowhere.
  int? rowNear(Offset at) {
    if (at.dy < top) return null;
    final row = ((at.dy - top) / cell).floor();
    if (row < 0) return null;
    if (row < play.rows.length) return row;
    if (row == play.rows.length) return play.rows.length;
    return null;
  }
}

/// The staircase, the hook in every box, and the box in hand.
class ShapeView extends CustomPainter {
  const ShapeView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the staircase alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final hooks = play.hooks;
    final held = play.holding;
    var at = 0;
    for (var row = 0; row < play.rows.length; row++) {
      final corner = play.isCorner(row);
      final lit = pointing != null &&
          (held == null ? pointing!.$1 == row : pointing!.$2 == row);
      for (var column = 0; column < play.rows[row]; column++) {
        final box = m.boxAt(row, column);
        final last = column == play.rows[row] - 1;
        canvas.drawRect(
          box.deflate(1),
          Paint()
            ..color = corner && last && held == null
                ? Palette.corner
                : Palette.box,
        );
        canvas.drawRect(
          box.deflate(1),
          Paint()
            ..color = lit ? Palette.shown : Palette.night
            ..style = PaintingStyle.stroke
            ..strokeWidth = bare ? 3 : (lit ? 2.4 : 1.4),
        );
        if (!bare && m.cell > 16) {
          _word(canvas, '${hooks[at]}', box.center, Palette.night, size,
              m.cell * 0.42);
        }
        at++;
      }
    }
    if (bare) return;
    // The strip where a new row would go, and the box in hand over it.
    final strip = m.newRow;
    canvas.drawRect(
      strip.deflate(1),
      Paint()
        ..color = held != null && play.canDrop(play.rows.length)
            ? Palette.corner
            : Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    if (held != null) {
      final box = Rect.fromLTWH(
          m.left + play.rows[held] * m.cell, m.top + held * m.cell - m.cell * 0.5,
          m.cell, m.cell);
      canvas.drawRect(box.deflate(2), Paint()..color = Palette.held);
      canvas.drawRect(
        box.deflate(2),
        Paint()
          ..color = Palette.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (!m.roomy) return;
    _word(
        canvas,
        held == null
            ? 'the number in a box is its hook: itself, its row to the right, its column below'
            : 'tap a row to put the box on the end of it, or the strip to start a new row',
        Offset(size.width / 2, size.height - 8),
        Palette.inkDim,
        size,
        10);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(ShapeView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../odd/play.dart';
import 'palette.dart';

/// Where the square of dots sits in a board of a given size: the outer
/// square, the inner square in its bottom left corner, the run's odd
/// numbers as L-shaped bands round it.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare ? 0.0 : (roomy ? 30.0 : 0.0);
    final n = play.outer;
    final margin = bare ? size.width * 0.06 : 24.0;
    cell = min((size.width - 2 * margin) / n, (size.height - strip - 2 * margin) / n);
    left = (size.width - n * cell) / 2;
    bottom = margin + (size.height - strip - 2 * margin + n * cell) / 2;
  }

  final Play play;
  final Size size;
  late final double cell, left, bottom;

  /// The square of the dot in column [x], row [y] from the bottom left.
  Rect dotAt(int x, int y) => Rect.fromLTWH(left + x * cell, bottom - (y + 1) * cell, cell, cell);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The outer square of dots, the inner square dim, and the run's bands.
class OddView extends CustomPainter {
  const OddView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the square only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final n = play.outer, inner = play.inner;
    final asDots = m.cell >= 7;
    for (var x = 0; x < n; x++) {
      for (var y = 0; y < n; y++) {
        // The band of a dot is how far out it lies: the larger of x and y.
        final band = max(x, y);
        final Color colour;
        if (band < inner) {
          colour = Palette.innerDot;
        } else {
          colour = (band - inner).isEven ? Palette.bandA : Palette.bandB;
        }
        final r = m.dotAt(x, y);
        if (asDots) {
          canvas.drawCircle(r.center, r.width * (bare ? 0.36 : 0.32), Paint()..color = colour);
        } else {
          canvas.drawRect(r.deflate(m.cell > 2.5 ? 0.5 : 0), Paint()..color = colour);
        }
      }
    }
    // The inner square outlined, when it is there.
    if (inner > 0) {
      canvas.drawRect(Rect.fromLTRB(m.left, m.bottom - inner * m.cell, m.left + inner * m.cell, m.bottom), Paint()..color = Palette.outline..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
    }
    if (bare) return;
    // Each band's odd number at its corner, when there is room.
    if (m.cell >= 9) {
      for (var i = 0; i < play.count; i++) {
        final band = inner + i;
        final r = m.dotAt(band, band);
        _word(canvas, '${play.first + 2 * i}', r.center + Offset(m.cell * 0.55, -m.cell * 0.55), Palette.ink, size, min(12.0, m.cell * 0.9), backed: true);
      }
    }
    if (!m.roomy) return;
    final words = inner == 0
        ? '${play.count} odd number${play.count == 1 ? '' : 's'} from 1: ${play.count} squared, ${play.sum}'
        : '$n squared less $inner squared: ${n * n} less ${inner * inner}, ${play.sum}';
    _word(canvas, words, Offset(size.width / 2, size.height - 12), Palette.inkDim, size, 12);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool backed = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize))),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    if (backed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 2, y - 1, text.width + 4, text.height + 2), const Radius.circular(3)),
        Paint()..color = Palette.night,
      );
    }
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(OddView old) => old.play != play || old.bare != bare;
}

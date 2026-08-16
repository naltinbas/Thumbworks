import 'dart:math';

import 'package:flutter/material.dart';

import '../family/play.dart';
import '../family/rules.dart';
import 'palette.dart';

/// Where the grid of families sits in a board of a given size: the
/// elder child's kind down the side, the younger's along the top, boys
/// by tag first and girls by tag after.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare ? 0.0 : (roomy ? 30.0 : 0.0);
    final n = 2 * play.tags;
    final margin = bare ? 0.0 : 26.0;
    cell = min((size.width - 2 * margin) / n, (size.height - strip - 2 * margin) / n);
    left = (size.width - n * cell) / 2;
    top = margin + (size.height - strip - 2 * margin - n * cell) / 2;
  }

  final Play play;
  final Size size;
  late final double cell, left, top;

  int get kinds => 2 * play.tags;

  /// The square of the family with the elder of kind [e] and the younger
  /// of kind [y]: kinds 0 to k - 1 boys by tag, k to 2k - 1 girls.
  Rect cellAt(int e, int y) => Rect.fromLTWH(left + y * cell, top + e * cell, cell, cell);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The grid of families, the told ones lit, the two-boy ones gold.
class FamilyView extends CustomPainter {
  const FamilyView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the grid only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final k = play.tags, n = m.kinds;
    final gap = m.cell > 6 ? 1.0 : 0.0;
    for (var e = 0; e < n; e++) {
      for (var y = 0; y < n; y++) {
        final told = e == 0 || y == 0;
        final both = e < k && y < k;
        final colour = told ? (both ? Palette.bothBoys : Palette.told) : (both ? Palette.boysCell : Palette.cell);
        canvas.drawRect(m.cellAt(e, y).deflate(gap / 2), Paint()..color = colour);
      }
    }
    // The boys' and girls' halves marked along the edges.
    final boysEnd = m.left + k * m.cell, allEnd = m.left + n * m.cell;
    final rowBoysEnd = m.top + k * m.cell, rowAllEnd = m.top + n * m.cell;
    final stroke = Paint()..style = PaintingStyle.stroke..strokeWidth = bare ? 4 : 2;
    canvas.drawLine(Offset(m.left, m.top - 4), Offset(boysEnd - 1, m.top - 4), stroke..color = Palette.boys);
    canvas.drawLine(Offset(boysEnd + 1, m.top - 4), Offset(allEnd, m.top - 4), stroke..color = Palette.girls);
    canvas.drawLine(Offset(m.left - 4, m.top), Offset(m.left - 4, rowBoysEnd - 1), stroke..color = Palette.boys);
    canvas.drawLine(Offset(m.left - 4, rowBoysEnd + 1), Offset(m.left - 4, rowAllEnd), stroke..color = Palette.girls);
    if (bare) return;
    _word(canvas, 'younger: boys, then girls, by tag', Offset(size.width / 2, m.top - 14), Palette.inkDim, size, 10);
    canvas.save();
    canvas.translate(m.left - 14, (m.top + rowAllEnd) / 2);
    canvas.rotate(-pi / 2);
    _wordAt(canvas, 'elder', Offset.zero, Palette.inkDim, 10);
    canvas.restore();
    if (!m.roomy) return;
    _word(
      canvas,
      '${play.told} families hold a boy of the first tag, ${play.bothBoys} of them two boys: ${Rules.tell(play.chance)}',
      Offset(size.width / 2, size.height - 12),
      Palette.inkDim,
      size,
      12,
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

  void _wordAt(Canvas canvas, String words, Offset at, Color colour, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize))),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, at - Offset(text.width / 2, text.height / 2));
  }

  @override
  bool shouldRepaint(FamilyView old) => old.play != play || old.bare != bare;
}

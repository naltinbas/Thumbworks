import 'dart:math';

import 'package:flutter/material.dart';

import '../sight/play.dart';
import '../sight/rules.dart';
import 'palette.dart';

/// Where the orchard sits in a board of a given size: the gate at the
/// bottom left, files running right and rows running up, a tree at
/// every crossing from (1, 1) to (10, 10).
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    final room = min(size.width - (bare ? 0 : 24), size.height - strip - (bare ? 0 : 12));
    cell = room / (Rules.side + 1);
    final left = (size.width - room) / 2, top = (size.height - strip - room) / 2;
    gate = Offset(left + cell * 0.5, top + room - cell * 0.5);
  }

  final Play play;
  final Size size;
  late final double cell;

  /// Where the watcher stands, at (0, 0).
  late final Offset gate;

  /// Where tree [t] stands.
  Offset at((int, int) t) => gate + Offset(t.$1 * cell, -t.$2 * cell);

  /// The tree under a point, or null when none is near enough.
  (int, int)? under(Offset p) {
    final a = ((p.dx - gate.dx) / cell).round(), b = ((gate.dy - p.dy) / cell).round();
    if (!Rules.inOrchard((a, b))) return null;
    return (at((a, b)) - p).distance <= cell * 0.45 ? (a, b) : null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The orchard, the trees in sight and hidden, the line of sight to the
/// picked tree, and what stands in the way or behind.
class SightView extends CustomPainter {
  const SightView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: the tree to tap.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the orchard and the line only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final r = bare ? m.cell * 0.28 : max(3.0, m.cell * 0.22);
    // The grass.
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(m.gate.dx - m.cell * 0.5, m.at((1, Rules.side)).dy - m.cell * 0.5, m.at((Rules.side, 1)).dx + m.cell * 0.5, m.gate.dy + m.cell * 0.5), Radius.circular(m.cell * 0.3)), Paint()..color = Palette.grass);
    // The line of sight, from the gate through the picked tree.
    final picked = play.picked;
    if (picked != null) {
      final to = m.at(picked);
      final d = (to - m.gate) / (to - m.gate).distance;
      final front = play.front;
      if (front == null) {
        canvas.drawLine(m.gate, to + d * (m.cell * 0.4), Paint()..color = Palette.gold..strokeWidth = bare ? m.cell * 0.12 : 2.5);
      } else {
        // In sight as far as the tree in the way, then dashed to the pick.
        final at = m.at(front);
        canvas.drawLine(m.gate, at, Paint()..color = Palette.gold..strokeWidth = 2.5);
        _dashed(canvas, at, to, Paint()..color = Palette.bad..strokeWidth = 2);
      }
    }
    // The trees.
    final hidesSet = play.hides.toSet(), between = play.between.toSet();
    for (final t in Rules.trees) {
      final at = m.at(t);
      final seen = Rules.seenByFactor(t);
      canvas.drawLine(at, at + Offset(0, r * 0.9), Paint()..color = Palette.trunk..strokeWidth = max(1, r * 0.35));
      canvas.drawCircle(at - Offset(0, r * 0.2), r, Paint()..color = seen ? Palette.leaf : Palette.leafDim);
      if (!bare && hidesSet.contains(t)) {
        canvas.drawCircle(at - Offset(0, r * 0.2), r + 3, Paint()..color = Palette.gold..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
      if (!bare && between.contains(t)) {
        canvas.drawCircle(at - Offset(0, r * 0.2), r + 3, Paint()..color = Palette.bad..style = PaintingStyle.stroke..strokeWidth = 2);
      }
    }
    if (picked != null) {
      canvas.drawCircle(m.at(picked) - Offset(0, r * 0.2), r + (bare ? r * 0.6 : 5), Paint()..color = play.seen ? Palette.gold : Palette.bad..style = PaintingStyle.stroke..strokeWidth = bare ? m.cell * 0.08 : 2.5);
    }
    // The watcher at the gate.
    canvas.drawCircle(m.gate, bare ? m.cell * 0.22 : max(4.0, m.cell * 0.18), Paint()..color = Palette.gate);
    final aim = pointing;
    if (aim != null && !bare) {
      canvas.drawCircle(m.at(aim) - Offset(0, r * 0.2), r + 9, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    if (bare) return;
    // The file and row numbers along the edges.
    for (var k = 1; k <= Rules.side; k++) {
      _word(canvas, '$k', Offset(m.at((k, 1)).dx, m.gate.dy + 2), Palette.inkDim, size, 9);
      _word(canvas, '$k', Offset(m.gate.dx - 2, m.at((1, k)).dy), Palette.inkDim, size, 9);
    }
    if (!m.roomy) return;
    final String words;
    if (picked == null) {
      words = 'no tree picked: 63 in sight, 37 hidden';
    } else if (play.seen) {
      words = 'tree ${Rules.tell(picked)} in sight, hiding ${play.hides.isEmpty ? 'none' : play.hides.length == 1 ? Rules.tell(play.hides.single) : '${play.hides.length}'}';
    } else {
      words = 'tree ${Rules.tell(picked)} hidden behind ${Rules.tell(play.front!)}${play.between.length > 1 ? ', ${play.between.length - 1} more in the way' : ''}';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), picked != null && play.seen ? Palette.gold : Palette.inkDim, size, 12);
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final d = to - from;
    final length = d.distance;
    if (length == 0) return;
    final unit = d / length;
    var run = 0.0;
    while (run < length) {
      final end = min(run + 6, length);
      canvas.drawLine(from + unit * run, from + unit * end, paint);
      run += 11;
    }
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool bold = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize), fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(SightView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

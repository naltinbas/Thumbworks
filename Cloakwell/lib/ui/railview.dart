import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../rail/play.dart';
import 'palette.dart';

/// Where the hooks and the gaps between them lie on the board, so the
/// screen and the tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.row.length;
    gap = math.min(room.width * 0.84 / n, 110);
    left = (room.width - gap * (n - 1)) / 2;
    railY = room.height * 0.36;
    coatHeight = math.min(room.height * 0.42, gap * 1.9);
    coatWidth = gap * 0.6;
  }

  final Play play;

  late final double gap;
  late final double left;
  late final double railY;
  late final double coatHeight;
  late final double coatWidth;

  /// Hook [i]'s place on the rail.
  Offset hookAt(int i) => Offset(left + i * gap, railY);

  /// The middle of the gap between coats [i] and [i + 1], where a swap
  /// is tapped.
  Offset gapAt(int i) => Offset(left + (i + 0.5) * gap, railY + coatHeight * 0.55);

  /// The gap under a touch, or null off the coats.
  int? under(Offset touch) {
    if (touch.dy < railY - coatHeight * 0.3 || touch.dy > railY + coatHeight * 1.2) return null;
    final n = play.row.length;
    final k = ((touch.dx - left) / gap - 0.5).round();
    if (k < 0 || k + 1 >= n) return null;
    if ((touch.dx - gapAt(k).dx).abs() > gap * 0.5) return null;
    return k;
  }
}

/// The rail with its coats, the pairs out of order strung above, and
/// the gaps where a swap is made.
class RailView extends CustomPainter {
  RailView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.row.length;

    // The wall and the rail.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.wall);
    final railRect = Rect.fromLTWH(m.left - m.gap * 0.5, m.railY - 6, m.gap * (n - 1) + m.gap, 12);
    canvas.drawRRect(RRect.fromRectAndRadius(railRect, const Radius.circular(4)), Paint()..color = Palette.rail);
    canvas.drawRRect(RRect.fromRectAndRadius(railRect, const Radius.circular(4)), Paint()
      ..color = Palette.railEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // The pairs out of order, strung above the rail as arcs.
    var arcs = 0;
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        if (play.row[i] <= play.row[j]) continue;
        final a = m.hookAt(i), b = m.hookAt(j);
        final lift = m.railY * (0.25 + 0.12 * (j - i)) * 0.9;
        final path = Path()
          ..moveTo(a.dx, a.dy - 8)
          ..quadraticBezierTo((a.dx + b.dx) / 2, a.dy - lift, b.dx, b.dy - 8);
        canvas.drawPath(path, Paint()
          ..color = Palette.askew.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
        arcs++;
      }
    }
    _write(canvas, arcs == 0 ? 'no pair out of order' : '$arcs pair${arcs == 1 ? '' : 's'} out of order',
        Offset(size.width / 2, size.height * 0.05),
        labels.copyWith(color: arcs == 0 ? Palette.inOrder : Palette.askew, fontSize: 13, fontWeight: FontWeight.w700));

    // The hooks and the coats.
    for (var i = 0; i < n; i++) {
      final hook = m.hookAt(i);
      canvas.drawCircle(hook, 5, Paint()..color = Palette.brass);
      canvas.drawLine(hook, hook + Offset(0, m.coatHeight * 0.1), Paint()
        ..color = Palette.brass
        ..strokeWidth = 2);
      final coat = play.row[i];
      final top = hook.dy + m.coatHeight * 0.1;
      final body = Path()
        ..moveTo(hook.dx - m.coatWidth * 0.5, top + m.coatHeight * 0.18)
        ..lineTo(hook.dx - m.coatWidth * 0.42, top + m.coatHeight * 0.95)
        ..lineTo(hook.dx + m.coatWidth * 0.42, top + m.coatHeight * 0.95)
        ..lineTo(hook.dx + m.coatWidth * 0.5, top + m.coatHeight * 0.18)
        ..lineTo(hook.dx + m.coatWidth * 0.18, top)
        ..lineTo(hook.dx, top + m.coatHeight * 0.06)
        ..lineTo(hook.dx - m.coatWidth * 0.18, top)
        ..close();
      canvas.drawPath(body, Paint()..color = Palette.cloth[(coat - 1) % Palette.cloth.length]);
      canvas.drawPath(body, Paint()
        ..color = Palette.night.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      // The seam down the front, and the number.
      canvas.drawLine(Offset(hook.dx, top + m.coatHeight * 0.1), Offset(hook.dx, top + m.coatHeight * 0.9), Paint()
        ..color = Palette.night.withValues(alpha: 0.35)
        ..strokeWidth = 1);
      _write(canvas, '$coat', Offset(hook.dx, top + m.coatHeight * 0.5),
          labels.copyWith(color: Palette.ink, fontSize: m.coatWidth * 0.5, fontWeight: FontWeight.w800));
    }
    // The gaps, marked with a swap sign.
    for (var i = 0; i + 1 < n; i++) {
      final g = m.gapAt(i);
      canvas.drawCircle(g, m.gap * 0.14, Paint()..color = Palette.gap);
      _write(canvas, '<>', g, labels.copyWith(color: Palette.inkDim, fontSize: m.gap * 0.16, fontWeight: FontWeight.w800));
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.gapAt(aim.$2), m.gap * 0.22, Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(RailView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a rail as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'Count the pairs of coats out of order, a coat with a smaller one '
        'somewhere to its right. A swap of two neighbours changes that count by '
        'exactly one: it mends the pair they make or breaks it, and touches no '
        'other pair. So sorting a row takes at least as many swaps as it has '
        'pairs askew, and any number of swaps of the wrong parity leaves it '
        'unsorted. Every sequence of ${level.swaps} swaps was swept, '
        '${level.sequences} of them, and none sorts these four.$note';
  }
  return 'The sweep tries every sequence of ${level.swaps} swaps of neighbours, '
      '${level.sequences} of them, and counts those that sort the row; the '
      'fewest swaps for every row of up to six coats is found by search and is '
      'the count of pairs out of order every time, and the sign by cycles agrees '
      'with the parity of that count. Every swap that keeps within the count '
      'mends one pair, so the show-me points at a coat hung before a smaller '
      'neighbour. ${level.ways} of the ${level.sequences} land it.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fair/level.dart';
import '../fair/play.dart';
import 'palette.dart';

/// Where everything lies on the board, so the screen and the tests
/// can find every wrestler: the bouts table across the top, the
/// line-up in the middle, the bench along the bottom.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.level.wrestlers;
    tableCell = math.min(room.width * 0.86 / (n + 1), room.height * 0.46 / (n + 1));
    tableOrigin = Offset((room.width - tableCell * (n + 1)) / 2, room.height * 0.02);
    lineY = room.height * 0.68;
    benchY = room.height * 0.9;
    slotGap = room.width * 0.84 / n;
    slotLeft = (room.width - slotGap * (n - 1)) / 2;
    radius = math.min(slotGap * 0.36, room.height * 0.055);
  }

  final Play play;

  late final double tableCell;
  late final Offset tableOrigin;
  late final double lineY;
  late final double benchY;
  late final double slotGap;
  late final double slotLeft;
  late final double radius;

  /// The middle of table cell (row, column), row nought and column
  /// nought being the headers.
  Offset cellAt(int row, int col) => Offset(
        tableOrigin.dx + (col + 0.5) * tableCell,
        tableOrigin.dy + (row + 0.5) * tableCell,
      );

  /// Slot [i] of the line.
  Offset slotAt(int i) => Offset(slotLeft + i * slotGap, lineY);

  /// Wrestler [w]'s place on the bench.
  Offset benchAt(int w) => Offset(slotLeft + w * slotGap, benchY);

  /// The wrestler under a touch: the last in line, or one on the
  /// bench; null otherwise.
  int? under(Offset touch) {
    for (final w in play.bench) {
      if ((touch - benchAt(w)).distance <= radius * 1.4) return w;
    }
    for (var i = 0; i < play.line.length; i++) {
      if ((touch - slotAt(i)).distance <= radius * 1.4) return play.line[i];
    }
    return null;
  }
}

/// The yard: who threw whom in a chalked table, the line-up with its
/// links, and the bench.
class YardView extends CustomPainter {
  YardView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.level.wrestlers;
    final cell = m.tableCell;

    // The table, chalked on slate.
    final table = Rect.fromLTWH(m.tableOrigin.dx, m.tableOrigin.dy, cell * (n + 1), cell * (n + 1));
    canvas.drawRRect(RRect.fromRectAndRadius(table.inflate(cell * 0.12), Radius.circular(cell * 0.2)),
        Paint()..color = Palette.slate);
    final grid = Paint()
      ..color = Palette.chalkDim.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var k = 1; k <= n + 1; k++) {
      canvas.drawLine(Offset(table.left + k * cell, table.top), Offset(table.left + k * cell, table.bottom), grid);
      canvas.drawLine(Offset(table.left, table.top + k * cell), Offset(table.right, table.top + k * cell), grid);
    }
    _write(canvas, 'threw', m.cellAt(0, 0), labels.copyWith(color: Palette.chalkDim, fontSize: cell * 0.26));
    for (var w = 0; w < n; w++) {
      final tint = Palette.wrestlers[w];
      _write(canvas, Level.names[w], m.cellAt(w + 1, 0),
          labels.copyWith(color: tint, fontSize: cell * 0.3, fontWeight: FontWeight.w800));
      _write(canvas, Level.names[w][0], m.cellAt(0, w + 1),
          labels.copyWith(color: tint, fontSize: cell * 0.34, fontWeight: FontWeight.w800));
    }
    for (var a = 0; a < n; a++) {
      for (var b = 0; b < n; b++) {
        final at = m.cellAt(a + 1, b + 1);
        if (a == b) {
          canvas.drawRect(Rect.fromCenter(center: at, width: cell * 0.9, height: cell * 0.9),
              Paint()..color = Palette.night.withValues(alpha: 0.5));
        } else if (play.yard.beat(a, b)) {
          // A tick in chalk.
          final path = Path()
            ..moveTo(at.dx - cell * 0.22, at.dy + cell * 0.02)
            ..lineTo(at.dx - cell * 0.06, at.dy + cell * 0.2)
            ..lineTo(at.dx + cell * 0.24, at.dy - cell * 0.2);
          canvas.drawPath(path, Paint()
            ..color = Palette.chalk
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, cell * 0.09)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
        } else {
          canvas.drawCircle(at, cell * 0.05, Paint()..color = Palette.chalkDim.withValues(alpha: 0.5));
        }
      }
    }

    // The sawdust, the slots and the bench.
    final ring = Rect.fromLTRB(m.slotLeft - m.slotGap * 0.55, m.lineY - m.radius * 2.6,
        m.slotLeft + (n - 1) * m.slotGap + m.slotGap * 0.55, m.benchY + m.radius * 1.5);
    canvas.drawRRect(RRect.fromRectAndRadius(ring, Radius.circular(m.radius)), Paint()..color = Palette.sawdust);
    for (var i = 0; i < n; i++) {
      canvas.drawCircle(m.slotAt(i), m.radius * 1.08, Paint()
        ..color = Palette.slot
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
      _write(canvas, '${i + 1}', m.slotAt(i) + Offset(0, m.radius * 1.55),
          labels.copyWith(color: Palette.chalkDim, fontSize: m.radius * 0.5));
    }
    // The links between the lined wrestlers.
    for (var i = 0; i + 1 < play.line.length; i++) {
      final holds = play.linkHolds(i);
      _arrow(canvas, m.slotAt(i) + Offset(m.radius * 1.15, 0), m.slotAt(i + 1) - Offset(m.radius * 1.15, 0),
          holds ? Palette.held : Palette.broke, m.radius * 0.28);
    }
    // The ring's closing link, from the last slot back to the first.
    if (play.level.ring && play.full) {
      final from = m.slotAt(n - 1) + Offset(0, -m.radius * 1.15);
      final to = m.slotAt(0) + Offset(0, -m.radius * 1.15);
      final lift = m.radius * 1.3;
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo((from.dx + to.dx) / 2, from.dy - lift * 2, to.dx, to.dy);
      canvas.drawPath(path, Paint()
        ..color = play.ringCloses ? Palette.held : Palette.broke
        ..style = PaintingStyle.stroke
        ..strokeWidth = m.radius * 0.18
        ..strokeCap = StrokeCap.round);
      _head(canvas, Offset(to.dx + m.radius * 0.5, to.dy - lift * 0.55), to,
          play.ringCloses ? Palette.held : Palette.broke, m.radius * 0.28);
    }
    for (var i = 0; i < play.line.length; i++) {
      _wrestler(canvas, m.slotAt(i), play.line[i], m.radius, true);
    }
    for (var w = 0; w < n; w++) {
      final at = m.benchAt(w);
      if (play.line.contains(w)) {
        canvas.drawCircle(at, m.radius * 0.9, Paint()
          ..color = Palette.slot
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
      } else {
        _wrestler(canvas, at, w, m.radius * 0.9, false);
      }
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final at = aim.$1 == 'in' ? m.benchAt(aim.$2) : m.slotAt(play.line.indexOf(aim.$2));
      canvas.drawCircle(at, m.radius * 1.35, Paint()
        ..color = aim.$1 == 'in' ? Palette.shown : Palette.bad
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _wrestler(Canvas canvas, Offset at, int w, double r, bool lined) {
    canvas.drawCircle(at, r, Paint()..color = Palette.wrestlers[w]);
    canvas.drawCircle(at, r, Paint()
      ..color = Palette.night.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    _write(canvas, Level.names[w], at,
        labels.copyWith(color: Palette.ink, fontSize: r * 0.55, fontWeight: FontWeight.w800));
  }

  void _arrow(Canvas canvas, Offset from, Offset to, Color color, double head) {
    canvas.drawLine(from, to, Paint()
      ..color = color
      ..strokeWidth = head * 0.55
      ..strokeCap = StrokeCap.round);
    _head(canvas, from, to, color, head);
  }

  void _head(Canvas canvas, Offset from, Offset to, Color color, double head) {
    final d = to - from;
    final u = d / d.distance;
    final v = Offset(-u.dy, u.dx);
    final path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(to.dx - u.dx * head + v.dx * head * 0.6, to.dy - u.dy * head + v.dy * head * 0.6)
      ..lineTo(to.dx - u.dx * head - v.dx * head * 0.6, to.dy - u.dy * head - v.dy * head * 0.6)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(YardView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a yard as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final (chains, rings) = play.yard.count();
  if (!level.winnable) {
    return 'A ring needs someone before the champion who threw him, and nobody '
        'did: he threw all four. So the ring never closes, though the yard lines '
        'up $chains ways. Camion\'s rule says the same from the far side: a yard '
        'closes into a ring exactly when every wrestler can be reached from every '
        'other along the throws, and the walk of all 1,024 yards of five, and of '
        'all 32,768 of six, never found that rule wrong.$note';
  }
  if (level.ring) {
    return 'Every ordering of the yard is walked, and $rings of the ${level.orderings} '
        'close into a ring, $chains line up at all. Camion\'s rule reads the same '
        'yard with no walk: a ring closes exactly when every wrestler can be '
        'reached from every other along the throws, and here every one can.$note';
  }
  return 'Every ordering of the yard is walked, and $chains of the ${level.orderings} '
      'line up so each threw the next, an odd count, as Redei says it always is. '
      'His slotting finds a line with no search: take the wrestlers one at a time '
      'and put each in front of the first in the line he threw, or at the end; '
      'whoever stood before that place threw him.$note';
}

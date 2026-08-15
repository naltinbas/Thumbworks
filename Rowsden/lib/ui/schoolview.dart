import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../school/play.dart';
import '../school/rules.dart';
import 'palette.dart';

/// Where the week's slots, the pairs and the bench lie on the board, so
/// the screen and the tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    days = play.level.days;
    slate = Rect.fromLTRB(room.width * 0.04, room.height * 0.02, room.width * 0.96, room.height * 0.58);
    dayWidth = slate.width / days;
    slot = math.min(dayWidth / 3.6, slate.height / 4.2);
    pairs = Rect.fromLTRB(room.width * 0.55, room.height * 0.62, room.width * 0.96, room.height * 0.86);
    benchY = room.height * 0.94;
    benchGap = room.width * 0.86 / Rules.girls;
    benchLeft = (room.width - benchGap * (Rules.girls - 1)) / 2;
    benchRadius = math.min(benchGap * 0.4, room.height * 0.04);
  }

  final Play play;

  late final int days;
  late final Rect slate;
  late final double dayWidth;
  late final double slot;
  late final Rect pairs;
  late final double benchY;
  late final double benchGap;
  late final double benchLeft;
  late final double benchRadius;

  /// The middle of slot [k] of row [r] of day [d].
  Offset slotAt(int d, int r, int k) => Offset(
        slate.left + d * dayWidth + dayWidth / 2 + (k - 1) * slot * 1.15,
        slate.top + slate.height * 0.16 + (r + 0.5) * slot * 1.3,
      );

  Offset benchAt(int girl) => Offset(benchLeft + girl * benchGap, benchY);

  /// The girl under a touch on the bench, or null.
  int? under(Offset touch) {
    for (var g = 0; g < Rules.girls; g++) {
      if ((touch - benchAt(g)).distance <= benchRadius * 1.4) return g;
    }
    return null;
  }
}

/// The week on the slate, the pairs met, and the bench of girls.
class SchoolView extends CustomPainter {
  SchoolView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  static const names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final level = play.level;
    final givenCount = level.given.length;

    // The slate.
    canvas.drawRRect(RRect.fromRectAndRadius(m.slate, const Radius.circular(10)), Paint()..color = Palette.slate);
    for (var d = 1; d < m.days; d++) {
      final x = m.slate.left + d * m.dayWidth;
      canvas.drawLine(Offset(x, m.slate.top + 8), Offset(x, m.slate.bottom - 8), Paint()
        ..color = Palette.slateLine
        ..strokeWidth = 1);
    }
    // The days: given in chalk, built in gold, the day under way half
    // done, the rest empty slots.
    final placed = play.placed;
    for (var d = 0; d < m.days; d++) {
      _write(canvas, 'day ${d + 1}', Offset(m.slate.left + (d + 0.5) * m.dayWidth, m.slate.top + m.slate.height * 0.08),
          labels.copyWith(color: Palette.chalkDim, fontSize: 11));
      for (var r = 0; r < 3; r++) {
        for (var k = 0; k < 3; k++) {
          final at = m.slotAt(d, r, k);
          int? girl;
          var chalk = false;
          if (d < givenCount) {
            girl = level.given[d][r][k];
            chalk = true;
          } else {
            final i = (d - givenCount) * 9 + r * 3 + k;
            if (i < placed.length) girl = placed[i];
          }
          if (girl == null) {
            final isNext = (d - givenCount) * 9 + r * 3 + k == placed.length && !play.isOver;
            canvas.drawCircle(at, m.slot * 0.42, Paint()
              ..color = isNext ? Palette.gold : Palette.slateLine
              ..style = PaintingStyle.stroke
              ..strokeWidth = isNext ? 2 : 1);
          } else {
            canvas.drawCircle(at, m.slot * 0.46, Paint()..color = Palette.girls[girl]);
            canvas.drawCircle(at, m.slot * 0.46, Paint()
              ..color = chalk ? Palette.chalk : Palette.gold
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
            _write(canvas, names[girl], at,
                labels.copyWith(color: Palette.ink, fontSize: m.slot * 0.5, fontWeight: FontWeight.w800));
          }
        }
        // A row's pairs repeated: a rust bar under the row.
        if (d >= givenCount) {
          final i0 = (d - givenCount) * 9 + r * 3;
          if (i0 + 3 <= placed.length) {
            final row = placed.sublist(i0, i0 + 3);
            final before = _pairsBefore(d - givenCount, r);
            final clash = Rules.pairsOfRow(row).any(before.contains);
            if (clash) {
              canvas.drawLine(m.slotAt(d, r, 0) + Offset(-m.slot * 0.5, m.slot * 0.6),
                  m.slotAt(d, r, 2) + Offset(m.slot * 0.5, m.slot * 0.6), Paint()
                    ..color = Palette.twice
                    ..strokeWidth = 2.5);
            }
          }
        }
      }
    }

    // The pairs met: a triangle of 36 cells, A to H down and B to I
    // across.
    final met = play.pairsMet;
    final cell = math.min(m.pairs.width / 9, m.pairs.height / 9);
    final origin = Offset(m.pairs.left, m.pairs.top);
    _write(canvas, 'pairs met ${met.length} of 36', Offset(m.pairs.left - size.width * 0.28, m.pairs.top + m.pairs.height * 0.5),
        labels.copyWith(color: Palette.inkDim, fontSize: 12));
    for (var a = 0; a < 8; a++) {
      _write(canvas, names[a], origin + Offset(cell * 0.4, cell * (a + 1.5)),
          labels.copyWith(color: Palette.girls[a], fontSize: cell * 0.6, fontWeight: FontWeight.w800));
      for (var b = a + 1; b < 9; b++) {
        final at = origin + Offset(cell * (b + 0.5), cell * (a + 1.5));
        final done = met.contains(Rules.pairKey(a, b));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: at, width: cell * 0.82, height: cell * 0.82), const Radius.circular(2)),
            Paint()..color = done ? Palette.met : Palette.unmet);
      }
    }
    for (var b = 1; b < 9; b++) {
      _write(canvas, names[b], origin + Offset(cell * (b + 0.5), cell * 0.5),
          labels.copyWith(color: Palette.girls[b], fontSize: cell * 0.6, fontWeight: FontWeight.w800));
    }

    // The bench.
    final bench = Rect.fromLTRB(m.benchLeft - m.benchGap * 0.6, m.benchY - m.benchRadius * 1.6,
        m.benchLeft + (Rules.girls - 1) * m.benchGap + m.benchGap * 0.6, m.benchY + m.benchRadius * 1.6);
    canvas.drawRRect(RRect.fromRectAndRadius(bench, Radius.circular(m.benchRadius)), Paint()..color = Palette.bench);
    final today = play.today;
    for (var g = 0; g < Rules.girls; g++) {
      final at = m.benchAt(g);
      final out = today.contains(g);
      canvas.drawCircle(at, m.benchRadius, Paint()..color = out ? Palette.girls[g].withValues(alpha: 0.25) : Palette.girls[g]);
      _write(canvas, names[g], at,
          labels.copyWith(color: out ? Palette.inkDim : Palette.ink, fontSize: m.benchRadius * 0.9, fontWeight: FontWeight.w800));
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.benchAt(aim.$2), m.benchRadius * 1.35, Paint()
        ..color = aim.$1 == 'in' ? Palette.shown : Palette.bad
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  /// The pairs walked before row [r] of built day [d].
  Set<int> _pairsBefore(int d, int r) {
    final met = Rules.pairsMet(play.level.given);
    final placed = play.placed;
    for (var i = 0; i + 3 <= d * 9 + r * 3; i += 3) {
      met.addAll(Rules.pairsOfRow(placed.sublist(i, i + 3)));
    }
    return met;
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(SchoolView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a week as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'Every girl walks in a row of three, so she meets two others a day, '
        'and she has eight to meet: four days at the least, and three days meet '
        'no more than 27 of the 36 pairs. Every filling of the two more days, '
        '${level.fillings} of them, was walked to be sure, and none walks every '
        'pair.$note';
  }
  return 'Every filling of the days to fill is walked, one of the 280 ways of '
      'walking nine out in rows of three to each day, and every filling that '
      'repeats no pair is counted; Kirkman\'s own week, rows, columns and the '
      'two slants of a three-by-three, is worked out with no search and lands '
      'among them. ${level.ways} of the ${level.fillings} land it.$note';
}

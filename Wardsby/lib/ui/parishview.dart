import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../parish/play.dart';
import '../parish/rules.dart';
import 'palette.dart';

/// Where things lie on the board: the parish as a five-by-five of
/// households across the top, and the five wards' tallies below.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    // Once the ask is over the tallies go and the parish has the room;
    // so too when the board is too short to hold them.
    final whole = bare || play.isOver || room.height < 220;
    final side = math.min(room.width * (bare ? 0.9 : 0.86), room.height * (whole ? 0.92 : 0.66));
    cell = side / Rules.side;
    grid = Rect.fromLTWH((room.width - side) / 2, whole ? (room.height - side) / 2 : room.height * 0.03, side, side);
    tallyTop = grid.bottom + room.height * 0.05;
    tallies = !whole;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double cell;
  late final Rect grid;
  late final double tallyTop;

  /// Whether the tallies are drawn under the parish.
  late final bool tallies;

  /// The middle of household [c].
  Offset cellAt(int c) => Offset(grid.left + (c % Rules.side + 0.5) * cell, grid.top + (c ~/ Rules.side + 0.5) * cell);

  /// The household under a touch, or null.
  int? under(Offset touch) {
    if (!grid.contains(touch)) return null;
    final x = ((touch.dx - grid.left) / cell).floor().clamp(0, Rules.side - 1);
    final y = ((touch.dy - grid.top) / cell).floor().clamp(0, Rules.side - 1);
    return y * Rules.side + x;
  }
}

/// The parish: households as Blue and Red dots on ward washes, ward
/// lines drawn between wards, broken wards edged rust, and below the
/// tally of each ward.
class ParishView extends CustomPainter {
  ParishView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The (household, taps) the show-me points at, or null.
  final (int, int)? pointing;
  final TextStyle labels;

  /// Whether to draw the parish alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.parish);
    final sound = play.wardsSound;
    // Washes and dots.
    for (var c = 0; c < Rules.cells; c++) {
      final r = Rect.fromLTWH(m.grid.left + (c % Rules.side) * m.cell, m.grid.top + (c ~/ Rules.side) * m.cell, m.cell, m.cell);
      final w = play.wards[c];
      canvas.drawRect(r, Paint()..color = w == null ? Palette.bare : Palette.wards[w]);
      final dot = (m.cell * 0.22).clamp(3.0, 14.0);
      canvas.drawCircle(r.center, dot, Paint()..color = play.blue[c] ? Palette.blue : Palette.red);
      if (w != null && !bare && m.cell >= 24) {
        _write(canvas, '${w + 1}', Offset(r.left + m.cell * 0.18, r.top + m.cell * 0.18), labels.copyWith(color: Palette.wardsBright[w], fontSize: (m.cell * 0.22).clamp(8.0, 12.0), fontWeight: FontWeight.w800));
      }
    }
    // Ward lines: between neighbours of different wards, and round the
    // outside; a broken ward's cells edged rust.
    final line = Paint()
      ..color = Palette.border
      ..strokeWidth = (m.cell * 0.06).clamp(1.5, 4.0);
    final faint = Paint()
      ..color = Palette.line
      ..strokeWidth = 1;
    for (var c = 0; c < Rules.cells; c++) {
      final x = c % Rules.side, y = c ~/ Rules.side;
      final r = Rect.fromLTWH(m.grid.left + x * m.cell, m.grid.top + y * m.cell, m.cell, m.cell);
      if (x < Rules.side - 1) {
        canvas.drawLine(r.topRight, r.bottomRight, play.wards[c] != play.wards[c + 1] ? line : faint);
      }
      if (y < Rules.side - 1) {
        canvas.drawLine(r.bottomLeft, r.bottomRight, play.wards[c] != play.wards[c + Rules.side] ? line : faint);
      }
      final w = play.wards[c];
      if (w != null && !sound[w] && !bare) {
        canvas.drawRect(r.deflate(m.cell * 0.12), Paint()
          ..color = Palette.broken
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
      }
    }
    canvas.drawRect(m.grid, Paint()
      ..color = Palette.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = (m.cell * 0.06).clamp(1.5, 4.0));
    if (pointing != null) {
      final r = Rect.fromLTWH(m.grid.left + (pointing!.$1 % Rules.side) * m.cell, m.grid.top + (pointing!.$1 ~/ Rules.side) * m.cell, m.cell, m.cell);
      canvas.drawRect(r.deflate(2), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    if (bare || !m.tallies) return;
    // The tallies.
    final tally = play.tally;
    final sizes = List.generate(Rules.wards, (w) => play.wards.where((x) => x == w).length);
    final slotW = size.width / Rules.wards;
    for (var w = 0; w < Rules.wards; w++) {
      final cx = (w + 0.5) * slotW;
      final r = Rect.fromCenter(center: Offset(cx, m.tallyTop + 12), width: slotW * 0.8, height: 22);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(5)), Paint()..color = Palette.wards[w]);
      final blueVotes = tally[w], redVotes = sizes[w] - blueVotes;
      final words = sizes[w] == 0 ? 'ward ${w + 1}: bare' : '${w + 1}: $blueVotes Blue $redVotes Red';
      _write(canvas, words, r.center, labels.copyWith(color: Palette.ink, fontSize: 9));
      final verdict = !sound[w]
          ? (sizes[w] == 0 ? '' : sizes[w] != 5 ? '${sizes[w]} of 5' : 'in pieces')
          : blueVotes >= 3
              ? 'Blues'
              : 'Reds';
      _write(canvas, verdict, Offset(cx, m.tallyTop + 34), labels.copyWith(color: verdict == 'Blues' ? Palette.blue : verdict == 'Reds' ? Palette.red : Palette.broken, fontSize: 10, fontWeight: FontWeight.w800));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(ParishView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'Twenty-five households, each Blue or Red, drawn into five wards of '
      'five in one piece; a ward goes to the side with three or more of its five, '
      'and the vestry to the side with three or more of the five wards. Every '
      'drawing there is, 4,006 of them, is walked, the first bare household '
      'starting a new ward and every connected five holding it tried, and each '
      'drawing is told for the wards each side wins. Packing the other side into '
      'wards it wins by five to nought, and cracking your own across wards you win '
      'by three to two, is how a minority takes the vestry; and since a ward is won '
      'only with three votes in it, a side with fewer than nine votes never wins '
      'three wards, however the lines are drawn.';
  return '$law ${level.note}';
}

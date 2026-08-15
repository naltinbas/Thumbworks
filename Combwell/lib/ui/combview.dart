import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../comb/play.dart';
import '../comb/rules.dart';
import 'palette.dart';

/// Where the cells lie on the board, so the screen and the tests can
/// find every one: a comb of pointed hexagons, rows of three, four,
/// five, four and three, in the middle of the room.
class Metrics {
  Metrics(this.play, Size room) {
    radius = math.min(room.width * 0.92 / (5 * math.sqrt(3)), room.height * 0.92 / 8);
    centre = Offset(room.width / 2, room.height / 2);
  }

  final Play play;

  late final double radius;
  late final Offset centre;

  /// The middle of cell [c].
  Offset at(int c) {
    final (r, i) = Rules.placeOf(c);
    final length = Rules.rows[r].length;
    return centre + Offset((i - (length - 1) / 2) * math.sqrt(3) * radius, (r - 2) * 1.5 * radius);
  }

  /// The six corners of cell [c], pointed at the top.
  List<Offset> cornersOf(int c) => [
        for (var k = 0; k < 6; k++)
          at(c) + Offset(math.cos(math.pi / 6 + k * math.pi / 3), math.sin(math.pi / 6 + k * math.pi / 3)) * radius,
      ];

  /// The cell under a touch, or null.
  int? under(Offset touch) {
    for (var c = 0; c < Rules.cells; c++) {
      if ((touch - at(c)).distance <= radius * 0.9) return c;
    }
    return null;
  }
}

/// The comb: cells of wax, the given ones in stone and the filled ones
/// in honey, every complete line drawn through in green when it sums
/// right and rust when it is off, the picked cell ringed in chalk.
class CombView extends CustomPainter {
  CombView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.night);
    // The cells.
    for (var c = 0; c < Rules.cells; c++) {
      final path = _hex(m.cornersOf(c));
      final v = play.values[c];
      final colour = v == 0 ? Palette.wax : play.isGiven(c) ? Palette.stone : Palette.honey;
      canvas.drawPath(path, Paint()..color = colour);
      canvas.drawPath(path, Paint()
        ..color = play.held == c ? Palette.chalk : Palette.waxEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = play.held == c ? 3 : math.max(1, m.radius * 0.06));
    }
    // The lines complete, right in green and off in rust, under the numbers.
    for (final i in play.rightLines) {
      _line(canvas, m, i, Palette.good);
    }
    for (final i in play.wrongLines) {
      _line(canvas, m, i, Palette.clash);
    }
    // The numbers.
    for (var c = 0; c < Rules.cells; c++) {
      final v = play.values[c];
      if (v != 0) {
        _write(canvas, '$v', m.at(c), labels.copyWith(color: play.isGiven(c) ? Palette.ink : Palette.honeyDark, fontSize: m.radius * 0.8, fontWeight: FontWeight.w800));
      }
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawPath(_hex(m.cornersOf(aim.$2)), Paint()
        ..color = aim.$1 == 'set' ? Palette.shown : Palette.clash
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4);
    }
    if (!bare) {
      _write(canvas, 'every line ${play.rules.sum}', Offset(size.width * 0.5, size.height * 0.04), labels.copyWith(color: Palette.inkDim, fontSize: 12));
    }
  }

  void _line(Canvas canvas, Metrics m, int i, Color colour) {
    final cells = Rules.lines[i];
    canvas.drawLine(m.at(cells.first), m.at(cells.last), Paint()
      ..color = colour.withValues(alpha: 0.6)
      ..strokeWidth = math.max(2, m.radius * 0.09)
      ..strokeCap = StrokeCap.round);
  }

  Path _hex(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(CombView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a comb as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rows = 'The five rows of the comb take every number from 1 to 19 exactly once, '
      '190 between them, so if every line is to sum alike each row sums 38, five '
      'times 38 being 190, and no other sum can be.';
  if (!level.winnable) {
    return '$rows The walk fills the comb every way, forced cell by forced cell, and '
        'finds no filling for ${level.sum}, and none for 36, 39 or 40 either; for 38 '
        'it finds twelve, one comb turned and reflected.$note';
  }
  return 'The walk fills the empty cells every way, and whenever a line has one '
      'cell empty that cell is forced by the sum: ${level.ways} filling'
      '${level.ways == 1 ? '' : 's'} of this comb sum${level.ways == 1 ? 's' : ''} to '
      '${level.sum} on every line. $rows With nothing given the walk finds twelve '
      'fillings, and they are one comb in its six turnings and six reflections.$note';
}

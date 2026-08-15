import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../table/play.dart';
import 'palette.dart';

/// Where things lie on the board: the table drawn to its sides in the
/// middle of the room, a unit a fixed number of pixels for the sides
/// set, so the ball's path can be read.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    unit = math.min(room.width * (bare ? 0.86 : 0.84) / play.along, room.height * (bare ? 0.86 : 0.74) / play.up);
    final w = unit * play.along, h = unit * play.up;
    table = Rect.fromLTWH((room.width - w) / 2, (room.height - h) / 2 + (bare ? 0 : room.height * 0.02), w, h);
  }

  final Play play;

  late final double width;
  late final double height;

  /// One unit of the table, in pixels.
  late final double unit;

  /// The baize, as laid out.
  late final Rect table;

  /// Where table point (x, y) lies, y up.
  Offset at((int, int) point) => Offset(table.left + point.$1 * unit, table.bottom - point.$2 * unit);
}

/// The table: baize in a frame, the pockets at the corners, the ball's
/// path from the home corner in chalk with the bounces marked, and the
/// pocket found in gold.
class TableView extends CustomPainter {
  TableView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final String? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.room);
    final rim = (m.unit * 0.25).clamp(6.0, 18.0);
    canvas.drawRRect(RRect.fromRectAndRadius(m.table.inflate(rim), Radius.circular(rim)), Paint()..color = Palette.frame);
    canvas.drawRect(m.table, Paint()..color = Palette.baize);
    // The unit grid, faint.
    final grid = Paint()
      ..color = Palette.baizeLine
      ..strokeWidth = 1;
    for (var x = 0; x <= play.along; x++) {
      canvas.drawLine(m.at((x, 0)), m.at((x, play.up)), grid);
    }
    for (var y = 0; y <= play.up; y++) {
      canvas.drawLine(m.at((0, y)), m.at((play.along, y)), grid);
    }
    // The path.
    final corners = play.corners;
    final path = Path()..moveTo(m.at(corners.first).dx, m.at(corners.first).dy);
    for (final c in corners.skip(1)) {
      path.lineTo(m.at(c).dx, m.at(c).dy);
    }
    canvas.drawPath(path, Paint()
      ..color = Palette.path
      ..style = PaintingStyle.stroke
      ..strokeWidth = (m.unit * 0.08).clamp(1.5, 4.0)
      ..strokeJoin = StrokeJoin.round);
    // The bounces.
    for (final c in corners.sublist(1, corners.length - 1)) {
      canvas.drawCircle(m.at(c), (m.unit * 0.12).clamp(2.5, 6.0), Paint()..color = Palette.bounce);
    }
    // The pockets, the one found in gold, home in rust.
    final pocketR = (m.unit * 0.22).clamp(5.0, 14.0);
    for (final p in [(0, 0), (play.along, 0), (0, play.up), (play.along, play.up)]) {
      final found = p == play.pocket;
      canvas.drawCircle(m.at(p), pocketR, Paint()..color = found ? Palette.pocketFound : Palette.pocket);
      if (found) {
        canvas.drawCircle(m.at(p), pocketR + 4, Paint()
          ..color = Palette.pocketFound
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
    }
    // The ball at home.
    canvas.drawCircle(m.at((0, 0)) + Offset(m.unit * 0.3, -m.unit * 0.3), (m.unit * 0.14).clamp(3.0, 8.0), Paint()..color = Palette.ball);
    if (bare) return;
    // The words, when there is room above and below the frame.
    if (m.table.top - rim >= 24) {
      _write(canvas, '${play.along} along, ${play.up} up: ${play.bounces} bounce${play.bounces == 1 ? '' : 's'}, ${play.steps} steps, ${play.pocketName}', Offset(size.width / 2, m.table.top - rim - 14), labels.copyWith(color: Palette.ink, fontSize: 12, fontWeight: FontWeight.w800));
    }
    if (size.height - m.table.bottom - rim >= 24) {
      _write(canvas, 'home', m.at((0, 0)) + Offset(0, rim + 14), labels.copyWith(color: Palette.inkDim, fontSize: 10));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(TableView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'A ball shot from the home corner at forty-five degrees runs one unit '
      'along and one up each step and turns at a cushion. Unfold the table across '
      'every cushion it meets and the path is the straight diagonal, so the ball '
      'pockets at the first corner of the unfolded grid on that diagonal, after '
      'the least common multiple of the sides in steps, having crossed q/g tables '
      'along and p/g tables up, g the sides\' common factor. Which pocket is '
      'parity: an odd count along ends on the right and even on the left, an odd '
      'count up at the top and even at the bottom; the bounces are the two counts '
      'less two; and since the two counts are the sides with their common factor '
      'divided out, they share no factor and are never both even, so the ball '
      'never comes home. The ball is rolled step by step on every table to thirty '
      'a side, 841 tables, and the roll agrees with the rule on every one.';
  return '$law ${level.note}';
}

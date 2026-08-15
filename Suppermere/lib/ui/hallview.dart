import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hall/level.dart';
import '../hall/play.dart';
import '../hall/rules.dart';
import 'palette.dart';

/// Where the guests stand on the board, so the screen and the tests
/// can find every one: round a ring in the middle of the hall, the two
/// tables drawn at either side.
class Metrics {
  Metrics(this.play, Size room) {
    centre = Offset(room.width / 2, room.height * 0.5);
    ringRadius = math.min(room.width * 0.3, room.height * 0.34);
    guestRadius = math.min(room.width * 0.055, 26);
    leftBoard = Rect.fromLTWH(room.width * 0.03, room.height * 0.16, room.width * 0.09, room.height * 0.68);
    rightBoard = Rect.fromLTWH(room.width * 0.88, room.height * 0.16, room.width * 0.09, room.height * 0.68);
  }

  final Play play;

  late final Offset centre;
  late final double ringRadius;
  late final double guestRadius;
  late final Rect leftBoard;
  late final Rect rightBoard;

  /// Guest [g]'s place round the ring, the first at the top.
  Offset at(int g) {
    final n = play.level.guests;
    final a = -math.pi / 2 + g * 2 * math.pi / n;
    return centre + Offset(math.cos(a), math.sin(a)) * ringRadius;
  }

  /// The guest under a touch, or null.
  int? under(Offset touch) {
    for (var g = 0; g < play.level.guests; g++) {
      if ((touch - at(g)).distance <= guestRadius * 1.5) return g;
    }
    return null;
  }
}

/// The hall: two boards at the sides, the guests round the ring tinted
/// by table, and every quarrel strung between two guests, rust where
/// they share a table.
class HallView extends CustomPainter {
  HallView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.hall);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.86, size.width, size.height * 0.14), Paint()..color = Palette.floor);
    // The two boards, with a candle each.
    for (final (rect, colour, label) in [(m.leftBoard, Palette.leftTable, 'left'), (m.rightBoard, Palette.rightTable, 'right')]) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = Palette.boardWood);
      canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(3), const Radius.circular(4)), Paint()
        ..color = colour.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
      canvas.drawCircle(Offset(rect.center.dx, rect.top - 10), 4, Paint()..color = Palette.candle);
      canvas.drawRect(Rect.fromCenter(center: Offset(rect.center.dx, rect.top - 3), width: 3, height: 8), Paint()..color = Palette.ink);
      _write(canvas, label, Offset(rect.center.dx, rect.bottom + 12), labels.copyWith(color: colour, fontSize: 11));
    }
    // The quarrels.
    final clashes = play.clashes;
    for (final (a, b) in play.level.quarrels) {
      final ta = play.tables[a], tb = play.tables[b];
      final clash = clashes.contains((a, b));
      final parted = ta >= 0 && tb >= 0 && ta != tb;
      canvas.drawLine(m.at(a), m.at(b), Paint()
        ..color = clash ? Palette.clash : parted ? Palette.parted : Palette.quarrel.withValues(alpha: 0.6)
        ..strokeWidth = clash ? 4 : 2);
    }
    // The guests.
    for (var g = 0; g < play.level.guests; g++) {
      final at = m.at(g);
      final t = play.tables[g];
      final colour = t == Rules.left ? Palette.leftTable : t == Rules.right ? Palette.rightTable : Palette.standing;
      canvas.drawCircle(at, m.guestRadius, Paint()..color = colour);
      canvas.drawCircle(at, m.guestRadius, Paint()
        ..color = Palette.night.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      _write(canvas, Level.names[g], at, labels.copyWith(color: Palette.ink, fontSize: m.guestRadius * 0.9, fontWeight: FontWeight.w800));
      // A small mark of the table below the disc: L, R, or nothing.
      if (t >= 0) {
        _write(canvas, t == Rules.left ? 'left' : 'right', at + Offset(0, m.guestRadius * 1.55),
            labels.copyWith(color: colour, fontSize: 10));
      }
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.at(aim.$2), m.guestRadius * 1.5, Paint()
        ..color = aim.$1 == 'left' ? Palette.leftTable : Palette.rightTable
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(HallView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a supper as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final ring = level.rules.oddRing();
  if (!level.winnable) {
    final names = ring == null ? '' : ring.map((g) => Level.names[g]).join(', ');
    return 'Round a ring of quarrels the tables must alternate, left, right, left, '
        'right, and a ring with an odd count of guests cannot close: the last '
        'sits at the same table as the first. The walk finds such a ring here, '
        '$names, and every one of the ${level.seatings} seatings was swept to be '
        'sure. On every quarrel map of five guests, 1,024 maps, the sweep, the walk '
        'and the odd ring agree.$note';
  }
  return 'The sweep seats the guests every way, ${level.seatings} seatings, and '
      'keeps those with no quarrel at a table; the walk seats them with no sweep, '
      'the first guest of each party left and every quarreller of a seated guest '
      'across, and lands whenever no odd ring of quarrels runs through the hall, '
      'which is Konig\'s theorem; and the count landing is two to the power of the '
      'parties. ${level.ways} of the ${level.seatings} land it.$note';
}

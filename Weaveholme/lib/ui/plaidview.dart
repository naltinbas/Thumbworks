import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../plaid/play.dart';
import 'palette.dart';

/// Where the squares lie on the board, so the screen and the tests can
/// find every one: the plaid square in the middle of the room, a
/// margin at the right for the row marks.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.level.size;
    side = math.min(room.width * 0.84, room.height * 0.92);
    square = side / n;
    origin = Offset((room.width - side) / 2 - room.width * 0.04, (room.height - side) / 2);
  }

  final Play play;

  late final double side;
  late final double square;
  late final Offset origin;

  /// The middle of the square at row [r], column [c].
  Offset at(int r, int c) => origin + Offset((c + 0.5) * square, (r + 0.5) * square);

  Rect rectOf(int r, int c) => Rect.fromCenter(center: at(r, c), width: square, height: square);

  /// The row mark's place, right of the plaid.
  Offset markAt(int r) => origin + Offset(side + square * 0.55, (r + 0.5) * square);

  /// The square under a touch, or null.
  (int, int)? under(Offset touch) {
    final x = touch.dx - origin.dx, y = touch.dy - origin.dy;
    if (x < 0 || y < 0 || x >= side || y >= side) return null;
    return ((y / square).floor(), (x / square).floor());
  }
}

/// The loom: the plaid in cream and indigo, the rows given a shade
/// darker, and by every row a mark, green when it agrees in half with
/// every other row and rust when some pair is off.
class PlaidView extends CustomPainter {
  PlaidView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The square the show-me points at, or null.
  final (int, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.level.size;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.night);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(m.origin.dx, m.origin.dy, m.side, m.side).inflate(m.square * 0.15), Radius.circular(m.square * 0.12)),
        Paint()..color = Palette.loom);
    for (var r = 0; r < n; r++) {
      final given = play.isGiven(r);
      for (var c = 0; c < n; c++) {
        final rect = m.rectOf(r, c).deflate(math.max(0.8, m.square * 0.04));
        final dark = play.dark(r, c);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(m.square * 0.08)), Paint()
          ..color = dark ? (given ? Palette.darkGiven : Palette.darkSq) : (given ? Palette.lightGiven : Palette.light));
      }
    }
    // The row marks.
    final off = <int>{};
    for (final (i, j) in play.uneven) {
      off.add(i);
      off.add(j);
    }
    for (var r = 0; r < n; r++) {
      final at = m.markAt(r);
      canvas.drawCircle(at, m.square * 0.14, Paint()..color = off.contains(r) ? Palette.clash : Palette.good);
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(m.rectOf(aim.$1, aim.$2).deflate(m.square * 0.02), Radius.circular(m.square * 0.1)), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    if (!bare && play.level.given.isNotEmpty) {
      canvas.drawLine(
          Offset(m.origin.dx, m.origin.dy + play.level.given.length * m.square),
          Offset(m.origin.dx + m.side, m.origin.dy + play.level.given.length * m.square),
          Paint()
            ..color = Palette.gold
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(PlaidView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a plaid as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  if (!level.winnable) {
    return 'Six by six never weaves, because no three rows of six can agree pairwise '
        'in three squares: turn whole columns light for dark till the first row is '
        'all light, which changes no agreement between rows, and against it two '
        'other rows agree in an even count of squares, never three. Every triple of '
        'rows of six was swept, ${_commas(rules.triples().$2)} of them, and none agrees '
        'pairwise in three, though ${_commas(1280)} pairs of the 4,096 agree in three.$note';
  }
  final walked = level.size <= 4 ? 'The sweep holds up every filling of the plaid, ${_commas(level.fillings)} of them' : 'The walk weaves the free rows one by one, each held against every row above, over ${_commas(level.fillings)} fillings';
  return '$walked, and ${_commas(level.ways)} land, every two rows agreeing in exactly '
      '${level.size ~/ 2}. Sylvester\'s plaids of two, four and eight are held to land, '
      'the eight made of the four laid out four times with the last quarter turned '
      'light for dark; six never can, since no three rows of six agree pairwise in '
      'three.$note';
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}

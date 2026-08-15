import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../knights/play.dart';
import 'palette.dart';

/// Where the squares lie on the board, so the screen and the tests can
/// find every one: the board square in the middle of the room.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.rules.size;
    side = math.min(room.width, room.height) * 0.92;
    square = side / n;
    origin = Offset((room.width - side) / 2, (room.height - side) / 2);
  }

  final Play play;

  late final double side;
  late final double square;
  late final Offset origin;

  /// The middle of square [c].
  Offset at(int c) => origin + Offset((play.rules.file(c) + 0.5) * square, (play.rules.rank(c) + 0.5) * square);

  Rect rectOf(int c) => Rect.fromCenter(center: at(c), width: square, height: square);

  /// The square under a touch, or null.
  int? under(Offset touch) {
    final x = touch.dx - origin.dx, y = touch.dy - origin.dy;
    if (x < 0 || y < 0 || x >= side || y >= side) return null;
    return play.rules.at((y / square).floor(), (x / square).floor());
  }
}

/// The board: chequered squares, the knights in brass, the pairing
/// faint in chalk on the hopeless board, and every attacking pair
/// joined by a rust knight's move.
class BoardView extends CustomPainter {
  BoardView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final rules = play.rules;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.night);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(m.origin.dx, m.origin.dy, m.side, m.side).inflate(m.square * 0.12), Radius.circular(m.square * 0.1)),
        Paint()..color = Palette.frame);
    for (var c = 0; c < rules.squares; c++) {
      canvas.drawRect(m.rectOf(c), Paint()..color = (rules.rank(c) + rules.file(c)).isEven ? Palette.light : Palette.dark);
    }
    // The pairing, faint, on the hopeless board.
    if (!play.level.winnable) {
      for (final (a, b) in rules.pairing) {
        canvas.drawLine(m.at(a), m.at(b), Paint()
          ..color = Palette.chalk.withValues(alpha: 0.35)
          ..strokeWidth = math.max(2, m.square * 0.05));
      }
    }
    // The clashes: a knight's move drawn as its L, two along then one across.
    for (final (a, b) in play.clashes) {
      final dr = rules.rank(b) - rules.rank(a), df = rules.file(b) - rules.file(a);
      final elbow = dr.abs() == 2 ? m.at(a) + Offset(0, dr * m.square) : m.at(a) + Offset(df * m.square, 0);
      final paint = Paint()
        ..color = Palette.clash
        ..strokeWidth = math.max(3, m.square * 0.08)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(m.at(a), elbow, paint);
      canvas.drawLine(elbow, m.at(b), paint);
    }
    // The knights.
    final clashing = <int>{for (final (a, b) in play.clashes) ...[a, b]};
    for (final c in play.knights) {
      _knight(canvas, m.rectOf(c).deflate(m.square * 0.1), clashing.contains(c));
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawRect(m.rectOf(aim.$2).deflate(m.square * 0.06), Paint()
        ..color = aim.$1 == 'set' ? Palette.shown : Palette.clash
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  /// A knight, a horse's head in brass, in [box].
  void _knight(Canvas canvas, Rect box, bool clashing) {
    Offset p(double x, double y) => Offset(box.left + x * box.width, box.top + y * box.height);
    final path = Path()
      ..moveTo(p(0.2, 0.92).dx, p(0.2, 0.92).dy)
      ..lineTo(p(0.8, 0.92).dx, p(0.8, 0.92).dy)
      ..lineTo(p(0.8, 0.84).dx, p(0.8, 0.84).dy)
      ..lineTo(p(0.66, 0.76).dx, p(0.66, 0.76).dy)
      ..lineTo(p(0.66, 0.5).dx, p(0.66, 0.5).dy)
      ..lineTo(p(0.74, 0.4).dx, p(0.74, 0.4).dy)
      ..lineTo(p(0.7, 0.24).dx, p(0.7, 0.24).dy)
      ..lineTo(p(0.6, 0.3).dx, p(0.6, 0.3).dy)
      ..lineTo(p(0.54, 0.14).dx, p(0.54, 0.14).dy)
      ..lineTo(p(0.44, 0.3).dx, p(0.44, 0.3).dy)
      ..lineTo(p(0.28, 0.4).dx, p(0.28, 0.4).dy)
      ..lineTo(p(0.16, 0.54).dx, p(0.16, 0.54).dy)
      ..lineTo(p(0.24, 0.62).dx, p(0.24, 0.62).dy)
      ..lineTo(p(0.34, 0.6).dx, p(0.34, 0.6).dy)
      ..lineTo(p(0.4, 0.68).dx, p(0.4, 0.68).dy)
      ..lineTo(p(0.34, 0.8).dx, p(0.34, 0.8).dy)
      ..lineTo(p(0.2, 0.84).dx, p(0.2, 0.84).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = clashing ? Palette.clash : Palette.brass);
    canvas.drawPath(path, Paint()
      ..color = Palette.brassDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, box.width * 0.04)
      ..strokeJoin = StrokeJoin.round);
    canvas.drawCircle(p(0.52, 0.42), box.width * 0.045, Paint()..color = Palette.brassDark);
  }

  @override
  bool shouldRepaint(BoardView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a board as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  final pairs = rules.pairing.length;
  if (!level.winnable) {
    return 'The ${rules.squares} squares pair off as $pairs knight\'s moves, drawn faint '
        'on the board, and two knights on one pair attack each other, so at most '
        '$pairs stand: every one of the ${level.settings} settings of ${level.knights} '
        'was swept to be sure, and the pairing was found by the game itself. On '
        'every board from three to seven the most that stand is the squares less '
        'the pairs, half the board rounded up, and one colour of squares always '
        'seats that many, since a knight always lands on the other colour.$note';
  }
  final over = rules.squares - 2 * pairs;
  return 'The sweep sets the knights square by square, dropping every setting '
      'where two attack, and counts the settings of ${level.settings} that seat '
      '${level.knights}: ${level.ways}. The pairing bounds it with no sweep: the '
      'squares pair off as knight\'s moves, $pairs pairs'
      '${over > 0 ? ' and $over square left over' : ''}, and each pair holds one '
      'knight at most, so ${rules.bound} is the most; and one colour of squares '
      'seats ${rules.bound}, since a knight always changes colour. On every board '
      'from three to seven the three agree.$note';
}

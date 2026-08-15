import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../kings/play.dart';
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

/// The board: chequered squares, the kings in brass, the blocks faint
/// in chalk on the hopeless board, and every attacking pair joined by
/// a rust line.
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
    // The blocks, faint, on the hopeless board.
    if (!play.level.winnable) {
      for (final block in rules.blocks) {
        var box = m.rectOf(block.first);
        for (final c in block) {
          box = box.expandToInclude(m.rectOf(c));
        }
        canvas.drawRect(box.deflate(m.square * 0.08), Paint()
          ..color = Palette.chalk.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, m.square * 0.05));
      }
    }
    // The clashes: a line between two kings that touch.
    for (final (a, b) in play.clashes) {
      canvas.drawLine(m.at(a), m.at(b), Paint()
        ..color = Palette.clash
        ..strokeWidth = math.max(3, m.square * 0.08)
        ..strokeCap = StrokeCap.round);
    }
    // The kings.
    final clashing = <int>{for (final (a, b) in play.clashes) ...[a, b]};
    for (final c in play.kings) {
      _king(canvas, m.rectOf(c).deflate(m.square * 0.14), clashing.contains(c));
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

  /// A king, a crown in brass, in [box].
  void _king(Canvas canvas, Rect box, bool clashing) {
    Offset p(double x, double y) => Offset(box.left + x * box.width, box.top + y * box.height);
    final crown = Path()
      ..moveTo(p(0.12, 0.92).dx, p(0.12, 0.92).dy)
      ..lineTo(p(0.88, 0.92).dx, p(0.88, 0.92).dy)
      ..lineTo(p(0.88, 0.72).dx, p(0.88, 0.72).dy)
      ..lineTo(p(0.94, 0.28).dx, p(0.94, 0.28).dy)
      ..lineTo(p(0.7, 0.5).dx, p(0.7, 0.5).dy)
      ..lineTo(p(0.5, 0.14).dx, p(0.5, 0.14).dy)
      ..lineTo(p(0.3, 0.5).dx, p(0.3, 0.5).dy)
      ..lineTo(p(0.06, 0.28).dx, p(0.06, 0.28).dy)
      ..lineTo(p(0.12, 0.72).dx, p(0.12, 0.72).dy)
      ..close();
    canvas.drawPath(crown, Paint()..color = clashing ? Palette.clash : Palette.brass);
    canvas.drawPath(crown, Paint()
      ..color = Palette.brassDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, box.width * 0.05)
      ..strokeJoin = StrokeJoin.round);
    canvas.drawLine(p(0.16, 0.74), p(0.84, 0.74), Paint()
      ..color = Palette.brassDark
      ..strokeWidth = math.max(1, box.width * 0.04));
    for (final x in [0.5, 0.06, 0.94]) {
      final y = x == 0.5 ? 0.14 : 0.28;
      canvas.drawCircle(p(x, y), box.width * 0.055, Paint()..color = Palette.brassDark);
    }
  }

  @override
  bool shouldRepaint(BoardView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a board as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  final blocks = rules.blocks.length;
  if (!level.winnable) {
    return 'The ${rules.squares} squares cut into $blocks blocks of two by two, drawn '
        'faint on the board, and two kings in one block touch, so at most $blocks '
        'stand: every one of the ${level.settings} settings of ${level.kings} was '
        'swept to be sure. On every board from two to seven the most that stand is '
        'the count of the blocks, half the side rounded up and squared, and the '
        'even squares, every other rank and every other file, always seat that '
        'many.$note';
  }
  return 'The sweep sets the kings square by square, dropping every setting where '
      'two touch, and counts the settings of ${level.settings} that seat '
      '${level.kings}: ${level.ways}. The blocks bound it with no sweep: the board '
      'cuts into $blocks blocks of two by two, and two kings in one block touch, so '
      '${rules.bound} is the most; and the even squares seat ${rules.bound}, every '
      'other rank and every other file. On every board from two to seven the three '
      'agree.$note';
}

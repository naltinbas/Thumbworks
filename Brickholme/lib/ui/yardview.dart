import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import 'palette.dart';

/// Where the flags lie on the board, so the screen and the tests can
/// find every one: the yard square in the middle of the room.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.rules.side;
    side = math.min(room.width, room.height) * 0.92;
    square = side / n;
    origin = Offset((room.width - side) / 2, (room.height - side) / 2);
  }

  final Play play;

  late final double side;
  late final double square;
  late final Offset origin;

  /// The middle of flag [c].
  Offset at(int c) => origin + Offset((play.rules.colOf(c) + 0.5) * square, (play.rules.rowOf(c) + 0.5) * square);

  Rect rectOf(int c) => Rect.fromCenter(center: at(c), width: square, height: square);

  /// The rectangle a brick covers.
  Rect brickRect(Brick brick) {
    final flags = play.rules.flagsOf(brick)!;
    return rectOf(flags.first).expandToInclude(rectOf(flags.last));
  }

  /// The flag under a touch, or null.
  int? under(Offset touch) {
    final x = touch.dx - origin.dx, y = touch.dy - origin.dy;
    if (x < 0 || y < 0 || x >= side || y >= side) return null;
    return play.rules.at((y / square).floor(), (x / square).floor());
  }
}

/// The yard: flags in grey stone with grout between, the drain in iron,
/// the bricks laid in terracotta, and on the hopeless yard the three
/// colours of the slant worn faint by the flags.
class YardView extends CustomPainter {
  YardView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Brick)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final rules = play.rules;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.night);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(m.origin.dx, m.origin.dy, m.side, m.side).inflate(m.square * 0.1), Radius.circular(m.square * 0.12)),
        Paint()..color = Palette.yardEdge);
    canvas.drawRect(Rect.fromLTWH(m.origin.dx, m.origin.dy, m.side, m.side), Paint()..color = Palette.grout);
    for (var c = 0; c < rules.flags; c++) {
      final rect = m.rectOf(c).deflate(math.max(0.8, m.square * 0.04));
      if (c == rules.drain) {
        canvas.drawRect(rect, Paint()..color = Palette.drain);
        for (var i = 1; i <= 3; i++) {
          final y = rect.top + rect.height * i / 4;
          canvas.drawLine(Offset(rect.left + rect.width * 0.15, y), Offset(rect.right - rect.width * 0.15, y), Paint()
            ..color = Palette.iron
            ..strokeWidth = math.max(1, m.square * 0.06));
        }
        continue;
      }
      canvas.drawRect(rect, Paint()..color = Palette.flag);
      if (!play.level.winnable) {
        canvas.drawRect(rect, Paint()..color = Palette.slant[rules.colour(c, sum: true)].withValues(alpha: 0.35));
      }
    }
    // The bricks.
    for (final brick in play.bricks) {
      final rect = m.brickRect(brick).deflate(m.square * 0.08);
      canvas.drawRRect(RRect.fromRectAndRadius(rect.translate(m.square * 0.04, m.square * 0.05), Radius.circular(m.square * 0.14)), Paint()..color = Palette.brickDark);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(m.square * 0.14)), Paint()..color = Palette.brick);
      canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(m.square * 0.05), Radius.circular(m.square * 0.1)), Paint()
        ..color = Palette.brickLight.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, m.square * 0.05));
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final (what, brick) = aim;
      final rect = m.brickRect(brick).deflate(m.square * 0.06);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(m.square * 0.14)), Paint()
        ..color = what == 'lay' ? Palette.shown : Palette.bad
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
      if (what == 'lay') {
        canvas.drawCircle(m.at(brick.$1), m.square * 0.3, Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
  }

  @override
  bool shouldRepaint(YardView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a yard as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  final sums = rules.counts(sum: true), diffs = rules.counts(sum: false);
  final odd = rules.oddColour(sum: true), oddOther = rules.oddColour(sum: false);
  final wears = rules.colour(level.drain, sum: true), wearsOther = rules.colour(level.drain, sum: false);
  final counting = 'Colour the flags along one slant in three colours, ${sums[0]}, ${sums[1]} and '
      '${sums[2]} of them, and along the other slant, ${diffs[0]}, ${diffs[1]} and ${diffs[2]}: '
      'every brick three flags long covers one flag of each colour either way, so '
      'the drain must wear the odd colour of both slants, colour ${odd! + 1} and colour '
      '${oddOther! + 1}, and this drain wears colour ${wears + 1} and colour ${wearsOther + 1}.';
  if (!level.winnable) {
    return '$counting So no paving is possible, and the walk row by row counts none: '
        'on every yard from four to eleven with the drain on every flag, 375 yards, '
        'the walk finds a paving exactly when the colouring allows one.$note';
  }
  return 'The walk counts the pavings row by row, each column carrying how far the '
      'brick standing in it reaches down: ${level.ways} pavings of ${level.bricks} '
      'bricks. $counting On every yard from four to eleven with the drain on every '
      'flag, 375 yards, the walk finds a paving exactly when the colouring allows '
      'one.$note';
}

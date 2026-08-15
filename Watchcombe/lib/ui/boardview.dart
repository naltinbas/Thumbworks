import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../yard/play.dart';
import 'palette.dart';

/// Where the flags lie on the board, so the screen and the tests can
/// find every one: the yard square in the middle of the room.
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

  /// The middle of flag [c].
  Offset at(int c) => origin + Offset((play.rules.colOf(c) + 0.5) * square, (play.rules.rowOf(c) + 0.5) * square);

  Rect rectOf(int c) => Rect.fromCenter(center: at(c), width: square, height: square);

  /// The flag under a touch, or null.
  int? under(Offset touch) {
    final x = touch.dx - origin.dx, y = touch.dy - origin.dy;
    if (x < 0 || y < 0 || x >= side || y >= side) return null;
    return play.rules.at((y / square).floor(), (x / square).floor());
  }
}

/// The yard: flags in grey stone, lit amber where a watchman sees them
/// and left dark where none does, the watchmen with their lanterns, and
/// on the hopeless yard the far flags chalked.
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
        Paint()..color = Palette.wall);
    final watched = rules.watched(play.watchmen);
    for (var c = 0; c < rules.flags; c++) {
      final rect = m.rectOf(c).deflate(math.max(0.8, m.square * 0.03));
      final lit = watched.contains(c);
      canvas.drawRect(rect, Paint()..color = lit ? Palette.lit : Palette.dark);
      if (lit) {
        canvas.drawRect(rect.deflate(m.square * 0.12), Paint()..color = Palette.litBright.withValues(alpha: 0.35));
      }
    }
    // The far flags, chalked, on the hopeless yard.
    if (!play.level.winnable) {
      for (final f in rules.far) {
        final at = m.at(f);
        final r = m.square * 0.18;
        canvas.drawLine(at + Offset(-r, -r), at + Offset(r, r), Paint()
          ..color = Palette.chalk.withValues(alpha: 0.6)
          ..strokeWidth = 2);
        canvas.drawLine(at + Offset(-r, r), at + Offset(r, -r), Paint()
          ..color = Palette.chalk.withValues(alpha: 0.6)
          ..strokeWidth = 2);
      }
    }
    // The watchmen.
    for (final c in play.watchmen) {
      _watchman(canvas, m.rectOf(c).deflate(m.square * 0.14));
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

  /// A watchman: a dark coat and a lantern held high.
  void _watchman(Canvas canvas, Rect box) {
    Offset p(double x, double y) => Offset(box.left + x * box.width, box.top + y * box.height);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: p(0.42, 0.66), width: box.width * 0.36, height: box.height * 0.5), Radius.circular(box.width * 0.1)), Paint()..color = Palette.coat);
    canvas.drawCircle(p(0.42, 0.3), box.width * 0.13, Paint()..color = Palette.chalk.withValues(alpha: 0.85));
    canvas.drawLine(p(0.55, 0.5), p(0.78, 0.36), Paint()
      ..color = Palette.coat
      ..strokeWidth = math.max(1.5, box.width * 0.07));
    canvas.drawCircle(p(0.8, 0.28), box.width * 0.2, Paint()..color = Palette.lantern.withValues(alpha: 0.35));
    canvas.drawCircle(p(0.8, 0.28), box.width * 0.11, Paint()..color = Palette.lantern);
  }

  @override
  bool shouldRepaint(BoardView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a yard as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  final far = rules.far.length;
  if (!level.winnable) {
    return 'The flags in the rows and columns that are multiples of three, $far of them '
        'on this yard and chalked on the board, lie beyond one another\'s watch, so '
        'each wants a watchman of its own and fewer than $far never watch the yard: '
        'every one of the ${level.postings} postings of ${level.watchmen} was swept to '
        'be sure. On every yard from three to nine the fewest is that count, a third '
        'of the side rounded up and squared, and a watchman one in from each far flag '
        'watches the yard with exactly that many.$note';
  }
  return 'The walk posts a watchman on some flag that watches the first unwatched '
      'flag, again and again, and counts the postings of ${level.watchmen} that watch '
      'the whole yard: ${level.ways} of the ${level.postings}. The far flags bound it '
      'with no walk: the flags in the rows and columns that are multiples of three, '
      '$far of them, lie beyond one another\'s watch, so $far watchmen at least; and one '
      'in from each far flag watches the yard with $far. On every yard from three to '
      'nine the three agree.$note';
}

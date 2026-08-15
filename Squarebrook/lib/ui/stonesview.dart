import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../stones/play.dart';
import '../stones/rules.dart';
import 'palette.dart';

/// Where the stones lie on the board, so the screen and the tests can
/// find every one: the stones picked stand on the ground across the
/// middle, each a square as big as its number, and the rack of stones
/// to pick from runs along the bottom.
class Metrics {
  Metrics(this.play, Size room) {
    final stones = play.stones;
    final maxSide = math.sqrt(stones.last.toDouble());
    unit = math.min(room.width * 0.9 / (play.level.count * maxSide + (play.level.count - 1) * 0.6), room.height * 0.42 / maxSide);
    groundAt = room.height * 0.6;
    rackTop = room.height * 0.7;
    rackHeight = room.height * 0.3;
    slotWidth = room.width / stones.length;
    rackBase = math.min(slotWidth * 0.85, rackHeight * 0.62);
    width = room.width;
    height = room.height;
  }

  final Play play;

  late final double unit;
  late final double groundAt;
  late final double rackTop;
  late final double rackHeight;
  late final double slotWidth;
  late final double rackBase;
  late final double width;
  late final double height;

  /// The square the [i]th picked stone makes on the board.
  Rect pickedRect(int i) {
    final sides = [for (final s in play.picked) math.sqrt(s.toDouble()) * unit];
    var total = 0.0;
    for (final s in sides) {
      total += s;
    }
    total += (sides.length - 1) * unit * 0.6;
    var left = (width - total) / 2;
    for (var j = 0; j < i; j++) {
      left += sides[j] + unit * 0.6;
    }
    return Rect.fromLTWH(left, groundAt - sides[i], sides[i], sides[i]);
  }

  /// The square stone [s] makes on the rack.
  Rect rackRect(int s) {
    final stones = play.stones;
    final i = stones.indexOf(s);
    final side = rackBase * (0.42 + 0.58 * math.sqrt(s.toDouble()) / math.sqrt(stones.last.toDouble()));
    return Rect.fromCenter(center: Offset(slotWidth * (i + 0.5), rackTop + rackHeight * 0.5), width: side, height: side);
  }

  /// The middle of stone [s] on the rack.
  Offset rackAt(int s) => rackRect(s).center;

  /// What is under a touch: ('pick', stone) on the rack, ('lift', place)
  /// on a picked stone, or null.
  (String, int)? under(Offset touch) {
    if (touch.dy >= rackTop) {
      final i = (touch.dx / slotWidth).floor();
      final stones = play.stones;
      return i < 0 || i >= stones.length ? null : ('pick', stones[i]);
    }
    for (var i = 0; i < play.picked.length; i++) {
      if (pickedRect(i).inflate(6).contains(touch)) return ('lift', i);
    }
    return null;
  }
}

/// The yard: the stones picked standing on the ground, each a square
/// as big as its number, the sum they make, and the rack of stones to
/// pick from along the bottom.
class StonesView extends CustomPainter {
  StonesView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words and the rack off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.yard);
    canvas.drawRect(Rect.fromLTWH(0, m.groundAt, size.width, size.height * 0.1), Paint()..color = Palette.ground);
    // The stones picked.
    for (var i = 0; i < play.picked.length; i++) {
      final rect = m.pickedRect(i);
      _stone(canvas, rect, play.picked[i], sand: i.isOdd, m: m);
    }
    if (!bare) {
      final sum = play.sum;
      final words = play.isDone
          ? '${play.level.number} made'
          : play.picked.isEmpty
              ? 'pick ${play.level.count} stones'
              : '$sum of ${play.level.number}';
      _write(canvas, words, Offset(size.width / 2, size.height * 0.08),
          labels.copyWith(color: play.isDone ? Palette.good : play.full && sum != play.level.number ? Palette.clash : Palette.ink, fontSize: 16, fontWeight: FontWeight.w800));
      // The rack.
      canvas.drawRect(Rect.fromLTWH(0, m.rackTop, size.width, m.rackHeight), Paint()..color = Palette.rack);
      for (final s in play.stones) {
        _stone(canvas, m.rackRect(s), s, sand: false, m: m);
      }
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final rect = aim.$1 == 'pick' ? m.rackRect(aim.$2) : m.pickedRect(aim.$2);
      canvas.drawRect(rect.inflate(5), Paint()
        ..color = aim.$1 == 'pick' ? Palette.shown : Palette.clash
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _stone(Canvas canvas, Rect rect, int s, {required bool sand, required Metrics m}) {
    canvas.drawRect(rect.translate(3, 3), Paint()..color = Palette.night.withValues(alpha: 0.5));
    canvas.drawRect(rect, Paint()..color = sand ? Palette.sand : Palette.slate);
    canvas.drawRect(rect, Paint()
      ..color = sand ? Palette.sandDark : Palette.slateDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, rect.width * 0.05));
    if (rect.width >= 16) {
      _write(canvas, '$s', rect.center, labels.copyWith(color: sand ? Palette.night : Palette.ink, fontSize: math.max(9, math.min(rect.width * 0.4, 22)), fontWeight: FontWeight.w800));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(StonesView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a number as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final eight = 'A square leaves 0, 1 or 4 when divided by eight, so three squares '
      'leave ${(Rules.leavings(3).toList()..sort()).join(', ')} and never 7, and every '
      'number seven more than a multiple of eight, or four times one, is never three '
      'squares; every number to a thousand is four squares at most, as Lagrange '
      'proved, and three exactly when not of that form, as Legendre proved, both '
      'swept whole.';
  if (!level.winnable) {
    return '${level.number} leaves 7 by eight, so three squares never make it. $eight '
        'Every picking of three from the stones up to ${level.number}, ${level.pickings} '
        'of them, was swept as well.$note';
  }
  return 'The sweep picks ${level.count} stones every way from the ${play.stones.length} '
      'up to ${level.number}, repeats allowed, ${level.pickings} pickings, and '
      '${level.ways} make${level.ways == 1 ? 's' : ''} ${level.number}. $eight$note';
}

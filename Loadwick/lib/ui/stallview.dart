import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dice/play.dart';
import '../dice/rules.dart';
import 'palette.dart';

/// Where the dice lie on the board, so the screen and the tests can
/// find every one: the four dice in rows down the left, each a strip
/// of six faces, and the table of thirty-six rolls at the right once a
/// die is picked.
class Metrics {
  Metrics(this.play, Size room) {
    rowHeight = room.height * 0.16;
    faceSize = math.min(room.width * 0.4 / 6, rowHeight * 0.55);
    left = room.width * 0.05;
    tableLeft = room.width * 0.55;
    tableTop = room.height * 0.2;
    cell = math.min(room.width * 0.4 / 7, room.height * 0.62 / 7);
    width = room.width;
    height = room.height;
  }

  final Play play;

  late final double rowHeight;
  late final double faceSize;
  late final double left;
  late final double tableLeft;
  late final double tableTop;
  late final double cell;
  late final double width;
  late final double height;

  /// The strip of die [x], its six faces.
  Rect stripOf(int x) => Rect.fromLTWH(left, height * 0.14 + x * rowHeight, faceSize * 6.6, faceSize * 1.4);

  /// The middle of die [x]'s strip.
  Offset at(int x) => stripOf(x).center;

  /// The die under a touch, or null.
  int? under(Offset touch) {
    for (var x = 0; x < 4; x++) {
      if (stripOf(x).inflate(6).contains(touch)) return x;
    }
    return null;
  }

  /// The cell of the table for the pick's face [i] against the other's
  /// face [j], both nought to five.
  Rect cellOf(int i, int j) => Rect.fromLTWH(tableLeft + (j + 1) * cell, tableTop + (i + 1) * cell, cell, cell);
}

/// The stall: the four dice as strips of faces, the house's in madder
/// and the pick ringed, and the table of thirty-six rolls, won in green
/// and lost in rust.
class StallView extends CustomPainter {
  StallView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The die the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.stall);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.08, size.width, size.height * 0.92), Paint()..color = Palette.cloth);
    final house = play.level.house;
    for (var x = 0; x < 4; x++) {
      final strip = m.stripOf(x);
      final isHouse = x == house;
      final isPick = x == play.picked;
      final tried = play.tried.contains(x) && !isPick;
      if (!bare) {
        _write(canvas, isHouse ? 'the house rolls ${Rules.names[x]}' : 'die ${Rules.names[x]}', Offset(strip.left, strip.top - 9), labels.copyWith(color: isHouse ? Palette.madder : Palette.chalk, fontSize: 11, fontWeight: FontWeight.w700), left: true);
      }
      for (var f = 0; f < 6; f++) {
        final rect = Rect.fromLTWH(strip.left + f * m.faceSize * 1.1, strip.top + m.faceSize * 0.2, m.faceSize, m.faceSize);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(m.faceSize * 0.2)), Paint()..color = isHouse ? Palette.madder : Palette.bone);
        _write(canvas, '${Rules.dice[x][f]}', rect.center, labels.copyWith(color: isHouse ? Palette.bone : Palette.pip, fontSize: m.faceSize * 0.6, fontWeight: FontWeight.w800));
      }
      if (isPick || tried) {
        canvas.drawRRect(RRect.fromRectAndRadius(strip.inflate(3), Radius.circular(m.faceSize * 0.3)), Paint()
          ..color = isPick ? (play.isDone ? Palette.good : Palette.gold) : Palette.tie
          ..style = PaintingStyle.stroke
          ..strokeWidth = isPick ? 3 : 1.5);
      }
    }
    // The pointer.
    if (pointing != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(m.stripOf(pointing!).inflate(6), Radius.circular(m.faceSize * 0.35)), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    // The table of thirty-six.
    final p = play.picked, q = play.against;
    if (p != null && q != null) {
      final mine = Rules.dice[p], theirs = Rules.dice[q];
      for (var j = 0; j < 6; j++) {
        final r = m.cellOf(-1, j);
        _write(canvas, '${theirs[j]}', r.center, labels.copyWith(color: q == house ? Palette.madder : Palette.bone, fontSize: m.cell * 0.5, fontWeight: FontWeight.w800));
      }
      for (var i = 0; i < 6; i++) {
        final r = m.cellOf(i, -1);
        _write(canvas, '${mine[i]}', r.center, labels.copyWith(color: Palette.bone, fontSize: m.cell * 0.5, fontWeight: FontWeight.w800));
        for (var j = 0; j < 6; j++) {
          final rect = m.cellOf(i, j).deflate(1);
          final colour = mine[i] > theirs[j] ? Palette.won : mine[i] < theirs[j] ? Palette.lost : Palette.tie;
          canvas.drawRect(rect, Paint()..color = colour);
        }
      }
      if (!bare) {
        _write(canvas, '${Rules.names[p]} against ${Rules.names[q]}: wins ${play.winsNow} of 36', Offset(m.tableLeft + m.cell * 3.5, m.tableTop + m.cell * 7.6),
            labels.copyWith(color: play.winsNow > 18 ? Palette.good : Palette.clash, fontSize: 11, fontWeight: FontWeight.w700));
      }
    } else if (!bare) {
      _write(canvas, 'tap a die to roll it against the house', Offset(m.tableLeft + m.cell * 3.5, m.tableTop + m.cell * 3.5), labels.copyWith(color: Palette.chalk.withValues(alpha: 0.7), fontSize: 11));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style, {bool left = false}) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, left ? at - Offset(0, painter.height / 2) : at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(StallView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a stall as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final ring = 'Every roll of every pair is counted, thirty-six a pair, and the four run '
      'in a ring: A beats B, B beats C, C beats D and D beats A, 24 rolls of 36 each. '
      'Every die of six faces from nought to six was swept against the four as well, '
      '924 dice, and 96 beat all four, but none of Efron\'s own does.';
  if (!level.winnable) {
    return '$ring Each die loses to the one before it round the ring, so no die of the '
        'four beats every other: A loses to D, B to A, C to B and D to C.$note';
  }
  final beaters = Rules.beaters(level.house).map((x) => '${Rules.names[x]}, ${Rules.wins(Rules.dice[x], Rules.dice[level.house])} of 36').join('; ');
  return '$ring Against ${Rules.names[level.house]} the counts run: $beaters; the rest '
      'win half or fewer.$note';
}

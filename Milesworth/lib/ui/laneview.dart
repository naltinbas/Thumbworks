import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../lane/play.dart';
import '../lane/rules.dart';
import 'palette.dart';

/// Where the milestones lie on the board, so the screen and the tests
/// can find every one: rows of ten along the lane, and the run's coins
/// laid out below.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.level.count;
    perRow = n <= 16 ? 8 : 10;
    rows = (n + perRow - 1) ~/ perRow;
    pitch = math.min(room.width * 0.92 / perRow, room.height * 0.5 / rows);
    origin = Offset((room.width - pitch * perRow) / 2, room.height * 0.03);
    coins = Rect.fromLTRB(room.width * 0.05, origin.dy + rows * pitch + room.height * 0.05, room.width * 0.95, room.height * 0.98);
  }

  final Play play;

  late final int perRow;
  late final int rows;
  late final double pitch;
  late final Offset origin;
  late final Rect coins;

  /// Where milestone [stone] stands, one to the count.
  Offset at(int stone) {
    final i = stone - 1;
    return Offset(origin.dx + (i % perRow + 0.5) * pitch, origin.dy + (i ~/ perRow + 0.5) * pitch);
  }

  /// The milestone under a touch, or null off the lane.
  int? under(Offset touch) {
    final c = ((touch.dx - origin.dx) / pitch).floor();
    final r = ((touch.dy - origin.dy) / pitch).floor();
    if (c < 0 || c >= perRow || r < 0 || r >= rows) return null;
    final stone = r * perRow + c + 1;
    if (stone > play.level.count) return null;
    return stone;
  }
}

/// The lane: milestones in rows, the run marked, and its coins laid out
/// in a row for every stone of the run, so the sum can be seen.
class LaneView extends CustomPainter {
  LaneView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.level.count;
    final pitch = m.pitch;
    final run = play.run;
    final lands = play.isDone;

    // The grass and the lane's rows.
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(m.origin.dx - 6, m.origin.dy - 6, pitch * m.perRow + 12, pitch * m.rows + 12), const Radius.circular(10)),
        Paint()..color = Palette.grass);
    for (var r = 0; r < m.rows; r++) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(m.origin.dx, m.origin.dy + (r + 0.3) * pitch, pitch * m.perRow, pitch * 0.4), Radius.circular(pitch * 0.2)),
          Paint()..color = Palette.lane);
    }
    // The run's tint behind its stones.
    if (run != null) {
      for (var s = run.$1; s <= run.$2; s++) {
        canvas.drawCircle(m.at(s), pitch * 0.44, Paint()..color = (lands ? Palette.good : Palette.bad).withValues(alpha: 0.35));
      }
    }
    // The milestones.
    for (var s = 1; s <= n; s++) {
      final at = m.at(s);
      final marked = play.marks.contains(s);
      final stone = Path()
        ..moveTo(at.dx - pitch * 0.22, at.dy + pitch * 0.3)
        ..lineTo(at.dx + pitch * 0.22, at.dy + pitch * 0.3)
        ..lineTo(at.dx + pitch * 0.22, at.dy - pitch * 0.12)
        ..quadraticBezierTo(at.dx, at.dy - pitch * 0.42, at.dx - pitch * 0.22, at.dy - pitch * 0.12)
        ..close();
      canvas.drawPath(stone, Paint()..color = marked ? Palette.marked : Palette.stone);
      canvas.drawPath(stone, Paint()
        ..color = Palette.stoneInk.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
      _write(canvas, '$s', at + Offset(0, pitch * 0.02),
          labels.copyWith(color: Palette.stoneInk, fontSize: math.max(9, pitch * 0.32), fontWeight: FontWeight.w800));
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.at(aim.$2), pitch * 0.46, Paint()
        ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
    }

    // The coins: a row for each stone of the run, as many coins as its
    // number, so the sum can be counted by eye.
    final box = m.coins;
    if (run == null) {
      _write(canvas, play.marks.isEmpty ? 'Mark the two ends of a run and its coins are laid here.' : 'One end marked; mark the other.',
          box.center, labels.copyWith(color: Palette.inkDim, fontSize: 13));
      return;
    }
    final stones = Rules.length(run);
    final widest = run.$2;
    final coin = math.min(math.min(box.height / (stones + 0.5), box.width / (widest + 6)), 14.0);
    final top = box.top + (box.height - coin * stones) / 2;
    for (var i = 0; i < stones; i++) {
      final value = run.$1 + i;
      final y = top + (i + 0.5) * coin;
      _write(canvas, '$value', Offset(box.left + coin * 1.6, y),
          labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, coin * 0.85)));
      for (var k = 0; k < value; k++) {
        final x = box.left + coin * 3.5 + (k + 0.5) * coin;
        canvas.drawCircle(Offset(x, y), coin * 0.42, Paint()..color = Palette.coin);
        canvas.drawCircle(Offset(x, y), coin * 0.42, Paint()
          ..color = Palette.coinEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8);
      }
    }
    _write(canvas, '= ${play.sum}', Offset(box.right - coin * 2.5, top + coin * stones / 2),
        labels.copyWith(color: lands ? Palette.good : Palette.bad, fontSize: 14, fontWeight: FontWeight.w800));
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr, textAlign: TextAlign.center)
      ..layout(maxWidth: 260);
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(LaneView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a lane as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'A run of an odd number of stones adds to that number times its middle '
        'stone; a run of an even number adds to half that number times the sum of '
        'its two middle stones, and two neighbours add to an odd number. Either '
        'way some odd number past 1 divides the sum. ${level.count} has no odd '
        'divisor but 1, being a power of two, so no run adds to it; the sweep of '
        'all ${level.runs} runs on the lane finds none, and to two hundred the '
        'counts with no run are exactly the powers of two.$note';
  }
  return 'The sweep marks every run of two or more on the lane and adds it up; '
      'the odd divisors of the count read the same runs with no sweep, one run '
      'for each odd divisor past 1, centred on the count over the divisor, or '
      'folded back past the start when the centre stands too near it. On every '
      'lane to two hundred the two agree run for run. ${level.ways} of the '
      '${level.runs} land it.$note';
}

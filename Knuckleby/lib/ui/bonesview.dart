import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bones/play.dart';
import 'palette.dart';

/// Where every face and every bar lies, shared by the painter and
/// the hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final most =
        math.max(play.bench.facesOne, play.bench.facesTwo);
    tile = math.min(room.width * 0.9 / most, room.height * 0.16);
    left = (room.width - tile * play.bench.facesOne) / 2;
    leftTwo = (room.width - tile * play.bench.facesTwo) / 2;
    topOne = room.height * 0.06;
    topTwo = topOne + tile * 1.35;
    chartTop = topTwo + tile * 1.5;
    chartBottom = room.height * 0.94;
    chartLeft = room.width * 0.06;
    chartRight = room.width * 0.94;
  }

  final Play play;

  late final double tile;
  late final double left;
  late final double leftTwo;
  late final double topOne;
  late final double topTwo;
  late final double chartTop;
  late final double chartBottom;
  late final double chartLeft;
  late final double chartRight;

  /// The tile of one face.
  Rect faceRect(int die, int face) => Rect.fromLTWH(
        (die == 0 ? left : leftTwo) + face * tile,
        die == 0 ? topOne : topTwo,
        tile,
        tile,
      ).deflate(tile * 0.06);

  /// The face under a touch, or null.
  (int, int)? faceUnder(Offset touch) {
    for (var die = 0; die < 2; die++) {
      final faces =
          die == 0 ? play.bench.facesOne : play.bench.facesTwo;
      for (var face = 0; face < faces; face++) {
        if (faceRect(die, face).inflate(2).contains(touch)) {
          return (die, face);
        }
      }
    }
    return null;
  }
}

/// The bench, drawn.
class BonesView extends CustomPainter {
  BonesView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The face being pointed at, or null: (die, face).
  final (int, int)? pointing;

  final TextStyle labels;

  /// Where the pips sit on a face, for each count.
  static const layouts = <int, List<(double, double)>>{
    1: [(0.5, 0.5)],
    2: [(0.28, 0.72), (0.72, 0.28)],
    3: [(0.25, 0.75), (0.5, 0.5), (0.75, 0.25)],
    4: [(0.28, 0.28), (0.72, 0.28), (0.28, 0.72), (0.72, 0.72)],
    5: [
      (0.25, 0.25),
      (0.75, 0.25),
      (0.5, 0.5),
      (0.25, 0.75),
      (0.75, 0.75)
    ],
    6: [
      (0.28, 0.22),
      (0.72, 0.22),
      (0.28, 0.5),
      (0.72, 0.5),
      (0.28, 0.78),
      (0.72, 0.78)
    ],
    7: [
      (0.28, 0.22),
      (0.72, 0.22),
      (0.28, 0.5),
      (0.72, 0.5),
      (0.28, 0.78),
      (0.72, 0.78),
      (0.5, 0.36)
    ],
    8: [
      (0.28, 0.22),
      (0.72, 0.22),
      (0.28, 0.5),
      (0.72, 0.5),
      (0.28, 0.78),
      (0.72, 0.78),
      (0.5, 0.36),
      (0.5, 0.64)
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var die = 0; die < 2; die++) {
      final faces =
          die == 0 ? play.bench.facesOne : play.bench.facesTwo;
      final pips = die == 0 ? play.one : play.two;
      final locked = die == 0 && play.bench.lockedOne;

      for (var face = 0; face < faces; face++) {
        final tile = metrics.faceRect(die, face);
        final lit = pointing != null &&
            pointing!.$1 == die &&
            pointing!.$2 == face;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
              tile, Radius.circular(tile.width * 0.18)),
          Paint()..color = locked ? Palette.locked : Palette.bone,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              tile, Radius.circular(tile.width * 0.18)),
          Paint()
            ..color = lit ? Palette.shown : Palette.boneRim
            ..style = PaintingStyle.stroke
            ..strokeWidth = lit ? 2.8 : 1.4,
        );

        for (final (dx, dy) in layouts[pips[face]]!) {
          canvas.drawCircle(
            Offset(tile.left + tile.width * dx,
                tile.top + tile.height * dy),
            tile.width * 0.075,
            Paint()
              ..color = locked ? Palette.night : Palette.pip,
          );
        }
      }
    }

    _chart(canvas, metrics);
  }

  void _chart(Canvas canvas, Metrics metrics) {
    final wanted = play.wanted;
    final thrown = play.thrown;
    final totals = wanted.keys.toList()..sort();
    var mostThrows = 0;
    for (final total in totals) {
      mostThrows = math.max(mostThrows, wanted[total]!);
      mostThrows = math.max(mostThrows, thrown[total] ?? 0);
    }
    for (final total in thrown.keys) {
      if (!wanted.containsKey(total)) {
        totals.add(total);
        mostThrows = math.max(mostThrows, thrown[total]!);
      }
    }
    totals.sort();

    final span = metrics.chartRight - metrics.chartLeft;
    final lane = span / totals.length;
    final tall = metrics.chartBottom - metrics.chartTop -
        metrics.tile * 0.4;

    for (var at = 0; at < totals.length; at++) {
      final total = totals[at];
      final want = wanted[total] ?? 0;
      final got = thrown[total] ?? 0;
      final left = metrics.chartLeft + at * lane;

      // The asked-for count, hollow behind.
      if (want > 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            left + lane * 0.18,
            metrics.chartBottom - metrics.tile * 0.4 -
                tall * want / mostThrows,
            lane * 0.64,
            tall * want / mostThrows,
          ),
          Paint()
            ..color = Palette.barWant
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
      // The standing count, filled; green when it agrees.
      if (got > 0) {
        canvas.drawRect(
          Rect.fromLTWH(
            left + lane * 0.26,
            metrics.chartBottom - metrics.tile * 0.4 -
                tall * got / mostThrows,
            lane * 0.48,
            tall * got / mostThrows,
          ),
          Paint()
            ..color = got == want ? Palette.match : Palette.bar,
        );
      }

      final words = TextPainter(
        text: TextSpan(
          text: '$total',
          style: labels.copyWith(
            color: Palette.inkDim,
            fontSize: math.min(lane * 0.4, metrics.tile * 0.26),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        Offset(left + (lane - words.width) / 2,
            metrics.chartBottom - metrics.tile * 0.32),
      );
    }
  }

  @override
  bool shouldRepaint(BonesView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the bench at hand.
String whyWords(Play play) {
  final bench = play.bench;
  final note = bench.note == null ? '' : ' ${bench.note}';
  if (!bench.winnable) {
    return 'The standard table asks for a three, and three is odd: '
        'two even pips only ever land even. The sweep says the '
        'same the long way round, recutting every even-pipped '
        'pair, all 3,570 of them, and matching none.$note';
  }
  final trade = bench.facesOne == bench.facesTwo
      ? ' The factor-trade builds the same pairs without rolling '
          'once: a die is a polynomial, a term a face, and the '
          'standard product\'s factors deal out two fair-handed '
          'ways.'
      : '';
  return 'Two pairs of bones are the same trade when their tables '
      'agree to the last count, every throw of one falling as '
      'often as the other. The sweep recuts every pair there is '
      'and finds ${bench.ways} that fall alike on this '
      'bench.$trade$note';
}

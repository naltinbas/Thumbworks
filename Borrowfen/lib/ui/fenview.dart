import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../debt/play.dart';
import 'palette.dart';

/// Where every house stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    house = math.min(width, height) * 0.088;
    for (final (x, y) in play.village.spots) {
      centers.add(Offset(
        house * 1.6 + x * (width - house * 3.2),
        house * 1.6 + y * (height - house * 3.2),
      ));
    }
  }

  final Play play;

  late final double width;
  late final double height;
  late final double house;
  final List<Offset> centers = [];

  Offset houseAt(int at) => centers[at];

  /// The house under a touch, or -1.
  int houseUnder(Offset touch) {
    for (var at = 0; at < play.village.houses; at++) {
      if ((centers[at] - touch).distance <= house * 1.9) return at;
    }
    return -1;
  }
}

/// The village, drawn.
class FenView extends CustomPainter {
  FenView({
    required this.play,
    required this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The house the show-me points at, or -1.
  final int pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (final (a, b) in play.village.roads) {
      canvas.drawLine(
        metrics.houseAt(a),
        metrics.houseAt(b),
        Paint()
          ..color = Palette.road
          ..strokeWidth = math.max(metrics.house * 0.16, 2.4)
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var at = 0; at < play.village.houses; at++) {
      _house(canvas, metrics, at);
    }
  }

  void _house(Canvas canvas, Metrics metrics, int at) {
    final middle = metrics.houseAt(at);
    final side = metrics.house;
    final held = play.pounds[at];
    final owing = held < 0;

    // The wall and the roof.
    final wall = Rect.fromCenter(
      center: middle + Offset(0, side * 0.22),
      width: side * 1.5,
      height: side * 1.1,
    );
    canvas.drawRect(
        wall, Paint()..color = owing ? Palette.debt : Palette.wall);
    final roof = Path()
      ..moveTo(wall.left - side * 0.16, wall.top)
      ..lineTo(middle.dx, wall.top - side * 0.85)
      ..lineTo(wall.right + side * 0.16, wall.top)
      ..close();
    canvas.drawPath(roof, Paint()..color = Palette.roof);
    if (at == pointing) {
      canvas.drawRect(
        wall.inflate(side * 0.28),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }

    // The pounds: gold coins when holding, the count in rust when
    // owing.
    if (held > 0) {
      final coins = math.min(held, 4);
      for (var coin = 0; coin < coins; coin++) {
        canvas.drawCircle(
          middle +
              Offset((coin - (coins - 1) / 2) * side * 0.42,
                  -side * 1.05),
          side * 0.19,
          Paint()..color = Palette.coin,
        );
        canvas.drawCircle(
          middle +
              Offset((coin - (coins - 1) / 2) * side * 0.42,
                  -side * 1.05),
          side * 0.19,
          Paint()
            ..color = Palette.coinRim
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
    if (!showWords) return;

    final words = TextPainter(
      text: TextSpan(
        text: owing ? 'owes ${-held}' : '$held',
        style: labels.copyWith(
          color: owing ? Palette.debt : Palette.coin,
          fontSize: side * 0.52,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
        canvas,
        middle +
            Offset(-words.width / 2, side * 1.02));

    final name = TextPainter(
      text: TextSpan(
        text: play.village.houseNames[at],
        style: labels.copyWith(
          color: Palette.inkDim,
          fontSize: side * 0.38,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    name.paint(
        canvas,
        middle + Offset(-name.width / 2, side * 1.62));
  }

  @override
  bool shouldRepaint(FenView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the village at hand.
String whyWords(Play play) {
  final village = play.village;
  final rules = play.rules;
  final note = village.note == null ? '' : ' ${village.note}';
  final classes = rules.spanningTrees();
  if (!village.winnable) {
    return 'Lending and borrowing never move a spread out of its '
        'class, and this village holds $classes classes, counted '
        'twice: Dhar\'s burning finds $classes tidy spreads, and '
        'Kirchhoff\'s determinant finds $classes spanning trees. '
        'At ${village.total} pounds clear only '
        '${rules.winnableClasses(village.total)} of them settles, '
        'and this spread\'s burning leaves the bank in debt: no '
        'run of moves, however long, gets it out.$note';
  }
  return 'Whether a village settles is decided before a move is '
      'made: Dhar\'s burning tidies the spread and reads the '
      'verdict at the bank, the census counts $classes classes of '
      'spread against $classes spanning trees, and the search '
      'proves the fewest is ${village.fewest} '
      'move${village.fewest == 1 ? '' : 's'}, having walked every '
      'shorter run first. The genus here is ${rules.genus}, and '
      '${rules.winnableClasses(village.total)} of the $classes '
      'classes settle at ${village.total} clear.$note';
}

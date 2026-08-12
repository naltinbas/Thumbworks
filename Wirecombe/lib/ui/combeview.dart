import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wire/play.dart';
import 'palette.dart';

/// Where every cottage stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.5);
    ring = math.min(room.width, room.height) * 0.38;
  }

  final Play play;

  late final Offset middle;
  late final double ring;

  /// The point of a cottage, counted clockwise from the top.
  Offset cottageAt(int cottage) {
    final turn =
        -math.pi / 2 + 2 * math.pi * cottage / play.combe.cottages;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The cottage under a touch, or -1.
  int cottageUnder(Offset touch) {
    for (var at = 0; at < play.combe.cottages; at++) {
      if ((cottageAt(at) - touch).distance <= ring * 0.24) {
        return at;
      }
    }
    return -1;
  }
}

/// The combe, drawn.
class CombeView extends CustomPainter {
  CombeView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The line the show-me points at, or null.
  final ((int, int), bool)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The wires, rust when the wiring loops.
    for (final (a, b) in play.lines) {
      canvas.drawLine(
        metrics.cottageAt(a),
        metrics.cottageAt(b),
        Paint()
          ..color = play.looped ? Palette.loop : Palette.wire
          ..strokeWidth = math.max(metrics.ring * 0.035, 3.0)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointed line, dashed blue.
    final aim = pointing;
    if (aim != null) {
      final ((a, b), _) = aim;
      final from = metrics.cottageAt(a);
      final to = metrics.cottageAt(b);
      final way = (to - from) / (to - from).distance;
      var far = 0.0;
      final whole = (to - from).distance;
      while (far < whole) {
        final step = math.min(metrics.ring * 0.07, whole - far);
        canvas.drawLine(
          from + way * far,
          from + way * (far + step),
          Paint()
            ..color = Palette.shown
            ..strokeWidth = 2.8
            ..strokeCap = StrokeCap.round,
        );
        far += metrics.ring * 0.13;
      }
    }

    // The cottages, gables over the wires; a lane's end lights
    // its window.
    final ends = play.lanesEnds.toSet();
    for (var at = 0; at < play.combe.cottages; at++) {
      final middle = metrics.cottageAt(at);
      final side = metrics.ring * 0.13;
      final picked = play.picked == at;
      final wall = Rect.fromCenter(
        center: middle + Offset(0, side * 0.18),
        width: side * 1.5,
        height: side * 1.1,
      );
      canvas.drawRect(wall, Paint()..color = Palette.wall);
      final roof = Path()
        ..moveTo(wall.left - side * 0.16, wall.top)
        ..lineTo(middle.dx, wall.top - side * 0.8)
        ..lineTo(wall.right + side * 0.16, wall.top)
        ..close();
      canvas.drawPath(roof, Paint()..color = Palette.roof);
      if (ends.contains(at)) {
        canvas.drawRect(
          Rect.fromCenter(
            center: wall.center,
            width: side * 0.5,
            height: side * 0.55,
          ),
          Paint()..color = Palette.lanesEnd,
        );
      }
      if (picked) {
        canvas.drawRect(
          wall.inflate(side * 0.3),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: '${at + 1}',
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: metrics.ring * 0.1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(canvas,
            middle + Offset(-words.width / 2, side * 0.95));
      }
    }
  }

  @override
  bool shouldRepaint(CombeView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the combe at hand.
String whyWords(Play play) {
  final combe = play.combe;
  final rules = play.rules;
  final note = combe.note == null ? '' : ' ${combe.note}';
  if (!combe.winnable) {
    return 'The standing arithmetic bars this combe before the '
        'sweep is even asked: a run of ${combe.cottages} cottages '
        'holds ${combe.cottages - 1} lines with two ends apiece, '
        '${2 * (combe.cottages - 1)} to give, and every cottage '
        'on two lines at least would want '
        '${2 * combe.cottages}. The sweep swept regardless: of '
        'the ${rules.runs()} runs, none keeps fewer than two '
        'lane\'s ends.$note';
  }
  return 'The sweep wires every wiring and keeps the runs: '
      '${rules.runs()} of them on ${combe.cottages} cottages, '
      'exactly as Cayley\'s count says, and every one codes to '
      'its own Prufer word and decodes back. '
      '${combe.ways} run${combe.ways == 1 ? '' : 's'} '
      'land${combe.ways == 1 ? 's' : ''} this asking.$note';
}

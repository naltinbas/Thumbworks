import 'dart:math';

import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import 'palette.dart';

/// Where the three tracks sit in a board of a given size. The train
/// comes in from the right and leaves to the left; the siding is a stub
/// below the main line, and the wagon nearest the points is the one
/// nearest the junction.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 18.0;
    pad = bare ? size.width * 0.05 : 12.0;
    box = bare
        ? min(size.height / 5.4, (size.width - pad * 2) / (Rules.wagons + 0.4))
        : min(40.0, (size.width - pad * 2) / (Rules.wagons + 1.4));
    tall = box * (bare ? 0.86 : 0.72);
    final room = size.height - words;
    out = room * (bare ? 0.16 : 0.22);
    main = room * (bare ? 0.5 : 0.52);
    siding = room * (bare ? 0.84 : 0.82);
    points = pad + box * 1.2;
  }

  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double pad, box, tall, out, main, siding, points;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 150 && size.width >= 230;

  Rect outAt(int i) =>
      Rect.fromLTWH(pad + i * box, out - tall / 2, box - 3, tall);

  /// The wagons still on the line stand to the right, the head of them
  /// nearest the exit.
  Rect lineAt(int i, int howMany) => Rect.fromLTWH(
      size.width - pad - (howMany - i) * box, main - tall / 2, box - 3, tall);

  /// The siding fills away from the points, so the last one shunted is
  /// the one nearest them.
  Rect sidingAt(int fromPoints) => Rect.fromLTWH(
      points + fromPoints * box, siding - tall / 2, box - 3, tall);
}

/// The yard: the out-train, the main line and the siding.
class YardView extends CustomPainter {
  const YardView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final String? pointing;

  final TextStyle labels;

  /// Whether to draw the yard alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);
    final rail = Paint()
      ..color = Palette.rail
      ..strokeWidth = bare ? 3 : 2;
    canvas.drawLine(Offset(0, m.out + m.tall / 2 + 3),
        Offset(size.width, m.out + m.tall / 2 + 3), rail);
    canvas.drawLine(Offset(0, m.main + m.tall / 2 + 3),
        Offset(size.width, m.main + m.tall / 2 + 3), rail);
    // The stub, running back from the points under the main line.
    final stub = Path()
      ..moveTo(m.points - m.box * 0.7, m.main + m.tall / 2 + 3)
      ..lineTo(m.points, m.siding + m.tall / 2 + 3)
      ..lineTo(size.width, m.siding + m.tall / 2 + 3);
    canvas.drawPath(stub, Paint()
      ..color = Palette.rail
      ..style = PaintingStyle.stroke
      ..strokeWidth = bare ? 3 : 2);
    for (var i = 0; i < play.out.length; i++) {
      _wagon(canvas, m.outAt(i), play.out[i], Palette.sent, false, size, m);
    }
    for (var i = 0; i < play.line.length; i++) {
      _wagon(canvas, m.lineAt(i, play.line.length), play.line[i], Palette.wagon,
          i == 0, size, m);
    }
    for (var i = 0; i < play.siding.length; i++) {
      final wagon = play.siding[play.siding.length - 1 - i];
      _wagon(canvas, m.sidingAt(i), wagon, Palette.sided, i == 0, size, m);
    }
    if (bare || !m.roomy) return;
    _word(canvas, 'out', Offset(m.pad, m.out - m.tall / 2 - 8),
        Palette.inkDim, size, 10);
    _word(canvas, 'the line', Offset(m.pad, m.main - m.tall / 2 - 8),
        Palette.inkDim, size, 10);
    // The siding's name goes under its rail: the stub comes down across
    // the space above it.
    _word(canvas, 'the siding', Offset(m.pad, m.siding + m.tall / 2 + 12),
        Palette.inkDim, size, 10);
    _word(
        canvas,
        play.isClear
            ? 'the yard is clear'
            : 'the lit wagons are the ones that can move',
        Offset(size.width / 2, size.height - 8),
        Palette.inkDim,
        size,
        11,
        centred: true);
  }

  void _wagon(Canvas canvas, Rect box, int number, Color colour, bool lit,
      Size size, Metrics m) {
    final body = RRect.fromRectAndRadius(box, Radius.circular(box.height * 0.2));
    canvas.drawRRect(body, Paint()..color = lit ? Palette.lamp : colour);
    canvas.drawRRect(
      body,
      Paint()
        ..color = lit ? Palette.ink : Palette.night
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 2.5 : 1.4,
    );
    if (!bare) {
      _word(canvas, '$number', box.center, Palette.night, size,
          box.height * 0.62,
          centred: true);
    } else {
      // Two wheels, so the mark reads as wagons rather than boxes.
      for (final at in [0.28, 0.72]) {
        canvas.drawCircle(
            Offset(box.left + box.width * at, box.bottom + 2),
            box.height * 0.14,
            Paint()..color = Palette.rail);
      }
    }
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points,
      {bool centred = false}) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x0 = centred ? at.dx - text.width / 2 : at.dx;
    final x = x0.clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(YardView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}

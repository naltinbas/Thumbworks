import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../forme/play.dart';
import 'palette.dart';

/// Where the chase and every piece of type in it is.
///
/// The painter and the finger both use this, which is the point of it: a
/// letter is where it is drawn, and there is no second sum that could disagree
/// with the first.
class Metrics {
  Metrics(this.play, Size room) {
    final chase = play.chase;
    final wall = math.min(room.width, room.height) * 0.03;
    cell = math.min(
      (room.width - wall * 4) / chase.wide,
      (room.height - wall * 4) / chase.tall,
    );
    this.wall = wall;
    corner = Offset(
      (room.width - cell * chase.wide) / 2,
      (room.height - cell * chase.tall) / 2,
    );
  }

  final Play play;

  /// How big one cell of the chase is.
  late final double cell;

  /// How thick the chase wall is drawn.
  late final double wall;

  late final Offset corner;

  Rect cellRect(int cell) => Rect.fromLTWH(
        corner.dx + play.chase.columnOf(cell) * this.cell,
        corner.dy + play.chase.rowOf(cell) * this.cell,
        this.cell,
        this.cell,
      );

  Rect get frame => Rect.fromLTWH(
        corner.dx,
        corner.dy,
        cell * play.chase.wide,
        cell * play.chase.tall,
      );

  /// The cell under a point, or -1.
  int cellAt(Offset touch) {
    final column = ((touch.dx - corner.dx) / cell).floor();
    final row = ((touch.dy - corner.dy) / cell).floor();
    if (column < 0 || row < 0) return -1;
    if (column >= play.chase.wide || row >= play.chase.tall) return -1;
    return row * play.chase.wide + column;
  }
}

/// The chase with the type in it.
class FormeView extends CustomPainter {
  const FormeView({
    required this.play,
    required this.pointing,
    required this.labels,
  });

  final Play play;

  /// A cell the game is pointing at, or -1.
  final int pointing;

  /// The style the letters are set in. A painter has no theme to ask.
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final chase = play.chase;

    // The bench inside the chase, where the empty cell shows through.
    canvas.drawRect(
      metrics.frame.inflate(metrics.wall * 0.5),
      Paint()..color = Palette.bench,
    );

    for (var cell = 0; cell < chase.cells; cell++) {
      final sort = play.sortIn(cell);
      if (sort < 0) continue;
      final block = metrics.cellRect(cell).deflate(metrics.cell * 0.045);
      final round = Radius.circular(metrics.cell * 0.1);
      final home = chase.locked[cell] == sort;

      // The side of the block, so the type looks stood up rather than flat.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          block.translate(0, metrics.cell * 0.045),
          round,
        ),
        Paint()..color = Palette.night,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, round),
        Paint()..color = Palette.type,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          block.deflate(metrics.cell * 0.07),
          round,
        ),
        Paint()..color = home ? Palette.placed : Palette.face,
      );

      final letter = TextPainter(
        text: TextSpan(
          text: chase.letterOf(sort),
          style: labels.copyWith(
            color: Palette.type,
            fontSize: metrics.cell * 0.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      letter.paint(
        canvas,
        block.center - Offset(letter.width / 2, letter.height / 2),
      );

      if (cell == pointing) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(block.inflate(metrics.cell * 0.03), round),
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.cell * 0.05,
        );
      }
    }

    // The chase itself, drawn last so the brass sits over everything.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        metrics.frame.inflate(metrics.wall),
        Radius.circular(metrics.wall * 1.4),
      ),
      Paint()
        ..color = Palette.brass
        ..style = PaintingStyle.stroke
        ..strokeWidth = metrics.wall * 1.6,
    );
  }

  @override
  bool shouldRepaint(FormeView old) =>
      old.play != play || old.pointing != pointing;
}

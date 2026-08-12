import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../stack/play.dart';
import 'palette.dart';

/// Where every tile lies, shared by the painter and anything that
/// reads it.
class Metrics {
  Metrics(this.play, Size room) {
    tile = math.min(
      room.width * 0.66 / 4,
      room.height * 0.82 / play.set.count,
    );
    left = (room.width - tile * 4) / 2;
    top = (room.height - tile * play.set.count) / 2 + tile * 0.14;
  }

  final Play play;

  late final double tile;
  late final double left;
  late final double top;

  /// The rectangle of the tile at [wall] across and [box] down,
  /// the top box first.
  Rect tileAt(int wall, int box) => Rect.fromLTWH(
        left + wall * tile,
        top + box * tile,
        tile,
        tile,
      );
}

/// The stack's four walls, drawn as a grid of painted tiles.
class StackView extends CustomPainter {
  StackView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The box being pointed at, or null.
  final int? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final walls = play.walls;
    final clashes = play.clashes;

    if (showWords) {
      const names = ['front', 'right', 'back', 'left'];
      for (var wall = 0; wall < 4; wall++) {
        final words = TextPainter(
          text: TextSpan(
            text: names[wall],
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: metrics.tile * 0.22,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final spot = metrics.tileAt(wall, 0);
        words.paint(
          canvas,
          Offset(spot.center.dx - words.width / 2,
              spot.top - words.height - metrics.tile * 0.1),
        );
      }
    }

    for (var box = 0; box < play.set.count; box++) {
      final faces = [
        walls[box].$1,
        walls[box].$2,
        walls[box].$3,
        walls[box].$4,
      ];
      for (var wall = 0; wall < 4; wall++) {
        final spot = metrics.tileAt(wall, box).deflate(
              metrics.tile * 0.05,
            );
        final rounded = RRect.fromRectAndRadius(
          spot,
          Radius.circular(metrics.tile * 0.12),
        );
        canvas.drawRRect(
          rounded,
          Paint()..color = Palette.paints[faces[wall]]!,
        );
        if (clashes.contains((wall, box))) {
          canvas.drawRRect(
            rounded,
            Paint()
              ..color = Palette.clash
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3.2,
          );
        }
      }
      if (pointing == box) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              metrics.left - metrics.tile * 0.12,
              metrics.top + box * metrics.tile,
              metrics.tile * 4.24,
              metrics.tile,
            ).deflate(metrics.tile * 0.02),
            Radius.circular(metrics.tile * 0.14),
          ),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }
  }

  @override
  bool shouldRepaint(StackView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the stack at hand.
String whyWords(Play play) {
  final set = play.set;
  final note = set.note == null ? '' : ' ${set.note}';
  if (!set.winnable) {
    return 'The count dooms this stack before a box is turned: '
        'thirteen faces wear red, and a standing stack of four '
        'carries a colour on twelve faces at most, one on each of '
        'the four walls and eight hidden top and bottom. The '
        'factoring agrees, finding no fair picks to pair, and the '
        'sweep of every standing of every box found no settling '
        'either.$note';
  }
  return 'A settling is checked more ways than one: the wall '
      'check reads the standing stack, the sweep turns every box '
      'every way and counts ${set.ways} settlings, and on four '
      'boxes of four paints the pencil factoring pairs fair picks '
      'of sleeves, each touching every paint exactly twice.$note';
}

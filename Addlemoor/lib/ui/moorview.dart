import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../sum/play.dart';
import 'palette.dart';

/// Where every stone stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    perRow = play.moor.stones <= 8 ? play.moor.stones : 7;
    final rows = (play.moor.stones + perRow - 1) ~/ perRow;
    slot = math.min(
      room.width * 0.9 / perRow,
      room.height * 0.8 / (rows * 1.4),
    );
    left = (room.width - slot * perRow) / 2;
    top = (room.height - rows * slot * 1.4) / 2 + slot * 0.2;
  }

  final Play play;

  late final int perRow;
  late final double slot;
  late final double left;
  late final double top;

  /// The middle of a stone, stones numbered from one.
  Offset stoneAt(int stone) {
    final at = stone - 1;
    final row = at ~/ perRow;
    final place = at % perRow;
    return Offset(
      left + (place + 0.5) * slot,
      top + row * slot * 1.4 + slot * 0.55,
    );
  }

  /// The stone under a touch, or -1.
  int stoneUnder(Offset touch) {
    for (var stone = 1; stone <= play.moor.stones; stone++) {
      if ((stoneAt(stone) - touch).distance <= slot * 0.45) {
        return stone;
      }
    }
    return -1;
  }
}

/// The moor, drawn.
class MoorView extends CustomPainter {
  MoorView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The stone and paint the show-me points at, or null.
  final (int, int)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The stones of the first bad sum, ringed together.
    final ringed = <int>{};
    if (play.badSums.isNotEmpty) {
      final (x, y, z) = play.badSums.first;
      ringed.addAll([x, y, z]);
    }

    for (var stone = 1; stone <= play.moor.stones; stone++) {
      final middle = metrics.stoneAt(stone);
      final paint = play.painting[stone - 1];
      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: middle,
          width: metrics.slot * 0.72,
          height: metrics.slot * 0.9,
        ),
        Radius.circular(metrics.slot * 0.2),
      );
      canvas.drawRRect(
          body, Paint()..color = Palette.paints[paint]);
      canvas.drawRRect(
        body,
        Paint()
          ..color = ringed.contains(stone)
              ? Palette.badSum
              : pointing?.$1 == stone
                  ? Palette.shown
                  : Palette.night.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              ringed.contains(stone) || pointing?.$1 == stone
                  ? 3.0
                  : 1.4,
      );
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: '$stone',
            style: labels.copyWith(
              color: Palette.night,
              fontSize: metrics.slot * 0.3,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(canvas,
            middle - Offset(words.width / 2, words.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(MoorView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  if (count < 1000000) {
    return '${count ~/ 1000},'
        '${(count % 1000).toString().padLeft(3, '0')}';
  }
  return '${count ~/ 1000000},'
      '${((count % 1000000) ~/ 1000).toString().padLeft(3, '0')},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the moor at hand.
String whyWords(Play play) {
  final moor = play.moor;
  var everyPainting = 1;
  for (var stone = 0; stone < moor.stones; stone++) {
    everyPainting *= moor.paints;
  }
  final note = moor.note == null ? '' : ' ${moor.note}';
  if (!moor.winnable) {
    return 'Schur\'s theorem sets the wall: three paints cannot '
        'carry fourteen stones. The sweep walked the paintings '
        'with every bad sum pruned as it went, standing for all '
        '${withComma(everyPainting)} of them, and nothing '
        'survives; even the eighteen clean thirteens die in '
        'every paint at the fourteenth stone.$note';
  }
  return 'The census reads every bad sum off the row, x and y '
      'and their sum in one paint, and the sweep walks the '
      'paintings with the sums pruned, standing for all '
      '${withComma(everyPainting)}: ${withComma(moor.ways)} '
      'painting${moor.ways == 1 ? '' : 's'} '
      'land${moor.ways == 1 ? 's' : ''} this asking.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../row/play.dart';
import '../row/rules.dart';
import 'palette.dart';

/// Where every entry sits, shared by the painter and the
/// screen, so what is drawn is exactly what the winding says.
class Metrics {
  Metrics(this.play, Size room) {
    cell = math.min(
      room.width * 0.9 / (Rules.top + 1),
      room.height * 0.86 / (Rules.top + 1),
    );
    left = room.width / 2;
    top = (room.height - cell * (Rules.top + 1)) / 2;
  }

  final Play play;

  late final double cell;
  late final double left;
  late final double top;

  /// The middle of entry [k] of row [at].
  Offset entryAt(int at, int k) => Offset(
        left + (k - at / 2) * cell,
        top + (at + 0.5) * cell,
      );
}

/// The wall, drawn: sixteen rows of the triangle as dots, odds
/// lit, and the wound row large in gold.
class RowView extends CustomPainter {
  RowView({
    required this.play,
    required this.labels,
  });

  final Play play;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final cell = metrics.cell;

    for (var at = 0; at <= Rules.top; at++) {
      final wound = at == play.at;
      final odds = Rules.oddPlaces(at).toSet();
      for (var k = 0; k <= at; k++) {
        final here = metrics.entryAt(at, k);
        final isOdd = odds.contains(k);
        canvas.drawCircle(
          here,
          wound
              ? (isOdd ? cell * 0.34 : cell * 0.24)
              : (isOdd ? cell * 0.24 : cell * 0.14),
          Paint()
            ..color = wound
                ? (isOdd ? Palette.woundOdd : Palette.woundEven)
                : (isOdd ? Palette.odd : Palette.even),
        );
      }
      if (wound) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              metrics.left - (at / 2 + 0.7) * cell,
              metrics.top + at * cell,
              (at + 1.4) * cell,
              cell,
            ),
            Radius.circular(cell * 0.5),
          ),
          Paint()
            ..color = Palette.woundOdd
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
        final word = TextPainter(
          text: TextSpan(
            text: 'row $at',
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: cell * 0.5,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        word.paint(
          canvas,
          Offset(
            metrics.left - (at / 2 + 0.9) * cell - word.width,
            metrics.top + (at + 0.5) * cell - word.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(RowView old) => old.play != play;
}

/// The words the why speaks, from the asking at hand.
String whyWords(Play play) {
  final asking = play.asking;
  final note = asking.note == null ? '' : ' ${asking.note}';
  if (!asking.winnable) {
    return 'Read the count without an addition: an entry is odd '
        'exactly when its place\'s bits fit inside the row\'s '
        'bits, and each lit bit of the row offers a free choice, '
        'in or out. Choices double: one, two, four, eight, '
        'sixteen. Three is no power of two, and the wall\'s '
        'sixteen rows, each row read by the addition itself, '
        'tally 1, 4, 6, 4 and 1 across those five counts with '
        'nothing between.$note';
  }
  return 'The odds are counted three ways that share nothing: '
      'Pascal\'s addition builds every row and the odd entries '
      'are read straight off; Lucas\' bit rule lights a place '
      'exactly when its bits fit the row\'s; and the doubling '
      'multiplies two per lit bit. All three agree on every row '
      'of the wall. ${asking.ways} row${asking.ways == 1 ? '' : 's'} '
      'hold${asking.ways == 1 ? 's' : ''} this asking.$note';
}

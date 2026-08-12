import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mill/play.dart';
import 'palette.dart';

/// Where the mill stands, shared by the painter and anything
/// that reads it.
class Metrics {
  Metrics(Size room) {
    middle = Offset(room.width / 2, room.height * 0.34);
    wheel = math.min(room.width, room.height) * 0.21;
    noughtRow = room.height * 0.72;
  }

  late final Offset middle;
  late final double wheel;
  late final double noughtRow;
}

/// The mill, drawn: the winding on the wheel, the ledger beside,
/// the noughts strung along the row.
class MillView extends CustomPainter {
  MillView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The winding the show-me points at, or null.
  final int? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(size);

    // The wheel, spoked by the winding.
    canvas.drawCircle(
      metrics.middle,
      metrics.wheel,
      Paint()..color = Palette.mill,
    );
    canvas.drawCircle(
      metrics.middle,
      metrics.wheel,
      Paint()
        ..color = Palette.stone
        ..style = PaintingStyle.stroke
        ..strokeWidth = metrics.wheel * 0.16,
    );
    for (var spoke = 0; spoke < 8; spoke++) {
      final turn = 2 * math.pi * spoke / 8 +
          play.wound * 2 * math.pi / 25;
      canvas.drawLine(
        metrics.middle,
        metrics.middle +
            Offset(math.cos(turn), math.sin(turn)) *
                metrics.wheel * 0.92,
        Paint()
          ..color = Palette.stone
          ..strokeWidth = 3.0,
      );
    }
    // The winding on the face.
    final face = TextPainter(
      text: TextSpan(
        text: '${play.wound}',
        style: labels.copyWith(
          color: Palette.face,
          fontSize: metrics.wheel * 0.55,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.drawCircle(
      metrics.middle,
      metrics.wheel * 0.52,
      Paint()..color = Palette.night,
    );
    face.paint(canvas,
        metrics.middle - Offset(face.width / 2, face.height / 2));

    if (showWords) {
      // The ledger, term by term.
      final terms = play.ledger;
      final ledgerWords = terms.isEmpty
          ? 'no fives wound yet'
          : '${terms.join(' + ')} = ${play.noughts}';
      final ledger = TextPainter(
        text: TextSpan(
          text: ledgerWords,
          style: labels.copyWith(
            color: Palette.ledgerInk,
            fontSize: metrics.wheel * 0.24,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      ledger.paint(
        canvas,
        Offset(metrics.middle.dx - ledger.width / 2,
            metrics.middle.dy + metrics.wheel * 1.3),
      );
    }

    // The noughts, strung along rows that stay on the page.
    const perRow = 12;
    final step = math.min(size.width * 0.075, metrics.wheel * 0.42);
    final shown = math.min(play.noughts, perRow * 2);
    for (var at = 0; at < shown; at++) {
      final row = at ~/ perRow;
      final place = at % perRow;
      final inRow = math.min(shown - row * perRow, perRow);
      final middle = Offset(
        size.width / 2 + (place - (inRow - 1) / 2) * step,
        metrics.noughtRow + row * metrics.wheel * 0.48,
      );
      canvas.drawCircle(
        middle,
        step * 0.36,
        Paint()
          ..color = Palette.nought
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2,
      );
    }
    if (play.noughts > perRow * 2 && showWords) {
      final more = TextPainter(
        text: TextSpan(
          text: 'and ${play.noughts - perRow * 2} more',
          style: labels.copyWith(
            color: Palette.nought,
            fontSize: metrics.wheel * 0.22,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      more.paint(
        canvas,
        Offset(size.width / 2 - more.width / 2,
            metrics.noughtRow + metrics.wheel * 1.0),
      );
    }
  }

  @override
  bool shouldRepaint(MillView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the grind at hand.
String whyWords(Play play) {
  final grind = play.grind;
  final note = grind.note == null ? '' : ' ${grind.note}';
  if (!grind.winnable) {
    return 'Legendre\'s ledger counts the noughts without '
        'grinding: the fives wound past, plus the twenty-fives, '
        'plus the hundred-and-twenty-fives. At twenty-five the '
        'ledger jumps by two, so five noughts is never landed '
        'on. The suite ground every factorial to two hundred '
        'whole and the ledger never missed.$note';
  }
  return 'The count is kept two ways that share nothing: the '
      'mill grinds the factorial whole and trails its noughts, '
      'and Legendre\'s ledger sums the fives, the twenty-fives '
      'and up. They agree on every winding to two hundred, and '
      '${grind.ways} windings land this asking.$note';
}

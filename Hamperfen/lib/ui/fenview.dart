import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../basket/play.dart';
import '../basket/rules.dart';
import 'palette.dart';

/// Where every basket sits, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(Size room) {
    // Five shelves by herb count, widest shelf six baskets.
    slot = math.min(room.width * 0.94 / 6, room.height * 0.17);
    left = room.width / 2;
    top = (room.height - slot * 5.4) / 2;
  }

  late final double slot;
  late final double left;
  late final double top;

  static List<int> shelfOf(int held) => [
        for (var basket = 0; basket < 16; basket++)
          if (Rules.herbs(basket) == held) basket,
      ];

  /// The middle of a basket's seat: shelves stacked by herb
  /// count, full basket highest.
  Offset basketAt(int basket) {
    final held = Rules.herbs(basket);
    final shelf = shelfOf(held);
    final place = shelf.indexOf(basket);
    final width = shelf.length;
    return Offset(
      left + (place - (width - 1) / 2) * slot,
      top + (4 - held) * slot * 1.08 + slot * 0.5,
    );
  }

  /// The basket under a touch, or -1.
  int basketUnder(Offset touch) {
    for (var basket = 0; basket < 16; basket++) {
      if ((basketAt(basket) - touch).distance <= slot * 0.46) {
        return basket;
      }
    }
    return -1;
  }
}

/// The shelf of baskets, drawn.
class FenView extends CustomPainter {
  FenView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The basket the show-me points at, or null.
  final (int, bool)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(size);

    // A swallowing pair, joined rust.
    final swallowed = <int>{};
    for (final (small, big) in play.swallowings) {
      swallowed.addAll([small, big]);
      canvas.drawLine(
        metrics.basketAt(small),
        metrics.basketAt(big),
        Paint()
          ..color = Palette.swallow.withValues(alpha: 0.7)
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var basket = 0; basket < 16; basket++) {
      final middle = metrics.basketAt(basket);
      final held = play.taken.contains(basket);
      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: middle,
          width: metrics.slot * 0.82,
          height: metrics.slot * 0.62,
        ),
        Radius.circular(metrics.slot * 0.12),
      );
      canvas.drawRRect(
        body,
        Paint()
          ..color = held ? Palette.wicker : Palette.wickerDim,
      );
      canvas.drawRRect(
        body,
        Paint()
          ..color = swallowed.contains(basket)
              ? Palette.swallow
              : pointing?.$1 == basket
                  ? Palette.shown
                  : held
                      ? Palette.taken
                      : Palette.night.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = swallowed.contains(basket) ||
                  pointing?.$1 == basket ||
                  held
              ? 2.6
              : 1.2,
      );
      // The herbs as sprigs in the basket.
      var shown = 0;
      for (var herb = 0; herb < 4; herb++) {
        if ((basket >> herb) & 1 == 0) continue;
        final seat = middle +
            Offset(
              (shown - (Rules.herbs(basket) - 1) / 2) *
                  metrics.slot * 0.18,
              -metrics.slot * 0.05,
            );
        canvas.drawCircle(
          seat,
          metrics.slot * 0.075,
          Paint()..color = Palette.herbs[herb],
        );
        canvas.drawLine(
          seat,
          seat + Offset(0, metrics.slot * 0.16),
          Paint()
            ..color = Palette.herbs[herb]
            ..strokeWidth = 2.0,
        );
        shown++;
      }
      if (Rules.herbs(basket) == 0 && showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: 'bare',
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: metrics.slot * 0.18,
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
  bool shouldRepaint(FenView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the fen at hand.
String whyWords(Play play) {
  final fen = play.fen;
  final note = fen.note == null ? '' : ' ${fen.note}';
  if (!fen.winnable) {
    return 'Sperner\'s theorem holds the shelf: weigh each '
        'basket at twelve over its shelf\'s width and a free '
        'picking never weighs past twelve, since down any chain '
        'of swallowings the shelf takes only one basket. Seven '
        'baskets weigh fourteen twelfths at the least, and the '
        'sweep of all ${withComma(11440)} families of seven '
        'found none free.$note';
  }
  return 'The swallow census reads every taken pair, and the '
      'sweep tries every family of ${fen.take} on the shelf, '
      'finding ${withComma(fen.ways)} free and the weighing '
      'never past twelve twelfths: '
      '${fen.ways == 1 ? 'one family lands' : '${fen.ways} families land'} '
      'this asking.$note';
}

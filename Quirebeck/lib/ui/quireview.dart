import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../quire/play.dart';
import 'palette.dart';

/// Where every leaf lies, shared by the painter and the tests, so
/// what is drawn is exactly what the play holds.
class Metrics {
  Metrics(this.play, Size room) {
    final leaves = play.quire.leaves;
    leafHigh = math.min((room.height - 8) / leaves, room.height / 8);
    top = (room.height - leafHigh * leaves) * 0.4;
    left = room.width * 0.13;
    wide = room.width * 0.74;
  }

  final Play play;

  late final double leafHigh;
  late final double top;
  late final double left;
  late final double wide;

  /// The bar of the leaf sitting at [seat], counted from the top.
  Rect leafRect(int seat) => Rect.fromLTWH(
        left,
        top + seat * leafHigh,
        wide,
        leafHigh,
      );
}

/// The stack, drawn.
class QuireView extends CustomPainter {
  QuireView({required this.play, required this.labels});

  final Play play;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final quire = play.quire;

    for (var seat = 0; seat < quire.leaves; seat++) {
      final leaf = play.stack[seat];
      final bar = metrics.leafRect(seat).deflate(
          math.min(metrics.leafHigh * 0.08, 2.2));
      final isPlate = leaf == 0;
      final settled = quire.home && leaf == seat;

      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, Radius.circular(bar.height * 0.28)),
        Paint()..color = Palette.leaf,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, Radius.circular(bar.height * 0.28)),
        Paint()
          ..color = isPlate
              ? Palette.plate
              : settled
                  ? Palette.good
                  : Palette.leafRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = isPlate || settled ? 2.6 : 1.3,
      );

      final name = TextPainter(
        text: TextSpan(
          text: isPlate ? 'the plate' : 'leaf ${leaf + 1}',
          style: labels.copyWith(
            color: Palette.leafInk,
            fontSize: bar.height * 0.42,
            fontWeight: isPlate ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      name.paint(
        canvas,
        Offset(bar.left + bar.width * 0.06,
            bar.center.dy - name.height / 2),
      );

      if (isPlate) {
        // The engraving: a little diamond on the plate's right end.
        final middle = Offset(
            bar.right - bar.height * 0.7, bar.center.dy);
        final reach = bar.height * 0.18;
        final engraving = Path()
          ..moveTo(middle.dx, middle.dy - reach)
          ..lineTo(middle.dx + reach, middle.dy)
          ..lineTo(middle.dx, middle.dy + reach)
          ..lineTo(middle.dx - reach, middle.dy)
          ..close();
        canvas.drawPath(engraving, Paint()..color = Palette.plate);
      }

      // The seat numbers down the left margin.
      final number = TextPainter(
        text: TextSpan(
          text: '${seat + 1}',
          style: labels.copyWith(
            color: Palette.inkDim.withValues(alpha: 0.7),
            fontSize: bar.height * 0.34,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      number.paint(
        canvas,
        Offset(metrics.left - number.width - metrics.leafHigh * 0.35,
            bar.center.dy - number.height / 2),
      );
    }

    // The wanted seat, marked in the right margin.
    final wanted = quire.seat;
    if (wanted != null) {
      final bar = metrics.leafRect(wanted);
      final tip = Offset(bar.right + metrics.leafHigh * 0.28,
          bar.center.dy);
      final reach = metrics.leafHigh * 0.26;
      final mark = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx + reach, tip.dy - reach * 0.8)
        ..lineTo(tip.dx + reach, tip.dy + reach * 0.8)
        ..close();
      canvas.drawPath(mark, Paint()..color = Palette.seatMark);
      final word = TextPainter(
        text: TextSpan(
          text: 'seat ${wanted + 1}',
          style: labels.copyWith(
            color: Palette.seatMark,
            fontSize: metrics.leafHigh * 0.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      word.paint(canvas,
          Offset(tip.dx + reach * 1.3, tip.dy - word.height / 2));
    }
  }

  @override
  bool shouldRepaint(QuireView old) => old.play != play;
}

/// The words the why speaks, from the quire at hand.
String whyWords(Play play) {
  final quire = play.quire;
  final note = quire.note == null ? '' : ' ${quire.note}';
  if (!quire.winnable) {
    return 'A weave swaps leaves by an even count: the walk of every '
        'weaving on a quire of eight finds twenty-four stacks, every '
        'one an even count of swaps from bound order. This stack is '
        'one turned pair, an odd count, so no weaving from now to '
        'doomsday mends it.$note';
  }
  if (quire.home) {
    return 'The weaves reach twenty-four stacks of a quire of eight, '
        'and the walk of every weaving knows the shortest road home '
        'from each of them: from this tangle it is ${quire.weaves} '
        'weaves.$note';
  }
  final seat = quire.seat!;
  final word = [
    for (var bit = seat.bitLength - 1; bit >= 0; bit--)
      (seat >> bit) & 1 == 1 ? 'in' : 'out',
  ].join(', ');
  return 'Seat ${seat + 1} counts $seat seats below the top, and '
      '$seat in binary is ${seat.toRadixString(2)}: read it left to '
      'right, an in for a one and an out for a nought, and the word '
      'is $word. The walk of every weaving finds nothing shorter, '
      'here or on any seat of eight leaves or sixteen.$note';
}

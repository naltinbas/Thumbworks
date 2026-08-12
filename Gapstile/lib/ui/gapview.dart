import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../gap/play.dart';
import 'palette.dart';

/// Where the hoop lies, shared by the painter and anything that
/// writes over it.
class Metrics {
  Metrics(Size room) {
    middle = Offset(room.width / 2, room.height * 0.52);
    ring = math.min(room.width, room.height) * 0.38;
  }

  late final Offset middle;
  late final double ring;

  /// The point of a hole, holes counted clockwise from the top.
  Offset holeAt(int hole, int round, [double stretch = 1]) {
    final turn = -math.pi / 2 + 2 * math.pi * hole / round;
    return middle +
        Offset(math.cos(turn), math.sin(turn)) * ring * stretch;
  }
}

/// The hoop, drawn.
class GapView extends CustomPainter {
  GapView({
    required this.play,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  /// Each distinct gap length's colour, shortest first.
  static List<Color> coats(List<int> gaps) {
    final sizes = gaps.toSet().toList()..sort();
    const order = [Palette.gapOne, Palette.gapTwo, Palette.gapThree];
    return [
      for (final gap in gaps) order[sizes.indexOf(gap)],
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(size);
    final round = play.round;
    final spots = play.spots;
    final gaps = play.gapsNow;

    // The hoop itself.
    canvas.drawCircle(
      metrics.middle,
      metrics.ring,
      Paint()
        ..color = Palette.hoop
        ..style = PaintingStyle.stroke
        ..strokeWidth = metrics.ring * 0.085,
    );

    // The gaps, each arc coated by its length.
    final coat = coats(gaps);
    for (var at = 0; at < spots.length; at++) {
      final from = -math.pi / 2 + 2 * math.pi * spots[at] / round;
      final sweep = 2 * math.pi * gaps[at] / round;
      canvas.drawArc(
        Rect.fromCircle(center: metrics.middle, radius: metrics.ring),
        from,
        sweep,
        false,
        Paint()
          ..color = coat[at]
          ..style = PaintingStyle.stroke
          ..strokeWidth = metrics.ring * 0.085
          ..strokeCap = StrokeCap.butt,
      );
      if (showWords && spots.length > 1) {
        // The gap's length in holes, written just outside its middle.
        final middleTurn = from + sweep / 2;
        final spot = metrics.middle +
            Offset(math.cos(middleTurn), math.sin(middleTurn)) *
                metrics.ring *
                1.18;
        final words = TextPainter(
          text: TextSpan(
            text: '${gaps[at]}',
            style: labels.copyWith(
              color: coat[at],
              fontSize: metrics.ring * 0.13,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(
            canvas, spot - Offset(words.width / 2, words.height / 2));
      }
    }

    // Every hole of the round, so the stride has somewhere to land.
    for (var hole = 0; hole < round; hole++) {
      canvas.drawCircle(
        metrics.holeAt(hole, round),
        metrics.ring * 0.028,
        Paint()..color = Palette.hole,
      );
    }

    // The pegs, hammered at the stride's multiples.
    for (final spot in spots) {
      final middle = metrics.holeAt(spot, round);
      canvas.drawCircle(
          middle, metrics.ring * 0.062, Paint()..color = Palette.peg);
      canvas.drawCircle(
        middle,
        metrics.ring * 0.062,
        Paint()
          ..color = spot == 0 ? Palette.ink : Palette.pegRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = spot == 0 ? 2.6 : 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(GapView old) =>
      old.play != play || old.showWords != showWords;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the stile at hand.
String whyWords(Play play) {
  final stile = play.stile;
  final note = stile.note == null ? '' : ' ${stile.note}';
  if (!stile.winnable) {
    return 'The three-gap law: pegs at the multiples of any stride '
        'cut the hoop into gaps of at most three lengths, and when '
        'there are three, the longest is the other two put '
        'together. The sweep dials every stride of every round to '
        'twelfths and hammers every count of pegs to thirty, all '
        '${withComma(1980)} fences of them, and a fourth gap size '
        'has never once shown: this stile asks for one.$note';
  }
  return 'The gaps between pegs at a stride\'s multiples only ever '
      'take one, two, or three lengths, and the longest of three '
      'is the other two put together: swept over every stride of '
      'every round to twelfths and every count of pegs to thirty, '
      'all ${withComma(1980)} fences of them, without one break. '
      '${stile.ways} dial${stile.ways == 1 ? '' : 's'} of the '
      'sweep land this stile.$note';
}

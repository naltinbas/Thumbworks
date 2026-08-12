import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mark/play.dart';
import 'palette.dart';

/// Where every post stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    post = math.min(width, height) * 0.062;
    for (final (x, y) in play.low.spots) {
      centers.add(Offset(
        post * 2 + x * (width - post * 4),
        post * 2 + y * (height - post * 4),
      ));
    }
  }

  final Play play;

  late final double width;
  late final double height;
  late final double post;
  final List<Offset> centers = [];

  Offset postAt(int at) => centers[at];

  /// The post under a touch, or -1.
  int postUnder(Offset touch) {
    for (var at = 0; at < play.low.posts; at++) {
      if ((centers[at] - touch).distance <= post * 2.0) return at;
    }
    return -1;
  }
}

/// The low, drawn.
class LowView extends CustomPainter {
  LowView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The post and mark the show-me points at, or null.
  final (int, int)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final worn = play.gaps;
    final doubled = play.repeats.toSet();

    // The lines, each wearing its gap.
    for (var line = 0; line < play.low.lines.length; line++) {
      final (a, b) = play.low.lines[line];
      final from = metrics.postAt(a);
      final to = metrics.postAt(b);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = doubled.contains(line)
              ? Palette.clash
              : Palette.wire
          ..strokeWidth = math.max(metrics.post * 0.3, 3.0)
          ..strokeCap = StrokeCap.round,
      );
      if (showWords && worn[line] >= 0) {
        final middle = (from + to) / 2;
        final words = TextPainter(
          text: TextSpan(
            text: '${worn[line]}',
            style: labels.copyWith(
              color: doubled.contains(line)
                  ? Palette.clash
                  : Palette.gap,
              fontSize: metrics.post * 0.9,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        // Seat the gap's figure beside the line's middle.
        final along = (to - from) / (to - from).distance;
        final aside = Offset(-along.dy, along.dx);
        final seat = middle + aside * metrics.post * 1.1;
        words.paint(canvas,
            seat - Offset(words.width / 2, words.height / 2));
      }
    }

    // The posts, marked or bare, clashes ringed rust.
    final clashing = play.clashes.toSet();
    for (var at = 0; at < play.low.posts; at++) {
      final middle = metrics.postAt(at);
      final mark = play.numbering[at];
      canvas.drawCircle(
          middle, metrics.post, Paint()..color = Palette.post);
      canvas.drawCircle(
        middle,
        metrics.post,
        Paint()
          ..color = clashing.contains(at)
              ? Palette.clash
              : pointing?.$1 == at
                  ? Palette.shown
                  : Palette.postRim
          ..style = PaintingStyle.stroke
          ..strokeWidth =
              clashing.contains(at) || pointing?.$1 == at
                  ? 3.0
                  : 1.6,
      );
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: mark < 0 ? '?' : '$mark',
            style: labels.copyWith(
              color:
                  mark < 0 ? Palette.inkDim : Palette.night,
              fontSize: metrics.post * 1.0,
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
  bool shouldRepaint(LowView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the low at hand.
String whyWords(Play play) {
  final low = play.low;
  var everyNumbering = 1;
  for (var pick = 0; pick < low.posts; pick++) {
    everyNumbering *= low.lines.length + 1 - pick;
  }
  final note = low.note == null ? '' : ' ${low.note}';
  if (!low.winnable) {
    return 'Round a ring the gaps sum even: each gap shares its '
        'evenness with the sum of its two ends, and going round, '
        'every post is counted twice. Gaps of 1 to '
        '${low.lines.length} must sum to '
        '${low.lines.length * (low.lines.length + 1) ~/ 2}, '
        'which is odd, so no numbering graces this ring. The '
        'sweep walked all $everyNumbering and agreed.$note';
  }
  return 'The census reads every gap off the lines and cries '
      'the doubles, and the sweep walks all $everyNumbering '
      'numberings, finding ${low.ways} graceful and every '
      'complement of one graceful too. '
      '${low.ways} land${low.ways == 1 ? 's' : ''} this '
      'asking.$note';
}

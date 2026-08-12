import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fold/play.dart';
import 'palette.dart';

/// Where every post stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.5);
    ring = math.min(room.width, room.height) * 0.38;
  }

  final Play play;

  late final Offset middle;
  late final double ring;

  /// The point of a post, counted clockwise from the top.
  Offset postAt(int post) {
    final turn =
        -math.pi / 2 + 2 * math.pi * post / play.fold.posts;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The post under a touch, or -1.
  int postUnder(Offset touch) {
    for (var at = 0; at < play.fold.posts; at++) {
      if ((postAt(at) - touch).distance <= ring * 0.22) return at;
    }
    return -1;
  }
}

/// The paddock, drawn.
class FoldView extends CustomPainter {
  FoldView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The hurdle the show-me points at, or null.
  final ((int, int), bool)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The paddock grass.
    final rim = Path();
    for (var at = 0; at < play.fold.posts; at++) {
      final spot = metrics.postAt(at);
      if (at == 0) {
        rim.moveTo(spot.dx, spot.dy);
      } else {
        rim.lineTo(spot.dx, spot.dy);
      }
    }
    rim.close();
    canvas.drawPath(rim, Paint()..color = Palette.grass);

    // The rim rails.
    canvas.drawPath(
      rim,
      Paint()
        ..color = Palette.rail
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(metrics.ring * 0.045, 3.5),
    );

    // The crossings' rust, under the hurdles.
    final crossed = <(int, int)>{};
    for (final (one, two) in play.crossings) {
      crossed.addAll([one, two]);
    }

    // The hurdles.
    for (final hurdle in play.hurdles) {
      canvas.drawLine(
        metrics.postAt(hurdle.$1),
        metrics.postAt(hurdle.$2),
        Paint()
          ..color = crossed.contains(hurdle)
              ? Palette.crossing
              : Palette.hurdle
          ..strokeWidth = math.max(metrics.ring * 0.035, 3.0)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointed hurdle, dashed blue.
    final aim = pointing;
    if (aim != null) {
      final ((a, b), _) = aim;
      final from = metrics.postAt(a);
      final to = metrics.postAt(b);
      final way = (to - from) / (to - from).distance;
      var far = 0.0;
      final whole = (to - from).distance;
      while (far < whole) {
        final step = math.min(metrics.ring * 0.07, whole - far);
        canvas.drawLine(
          from + way * far,
          from + way * (far + step),
          Paint()
            ..color = Palette.shown
            ..strokeWidth = 2.8
            ..strokeCap = StrokeCap.round,
        );
        far += metrics.ring * 0.13;
      }
    }

    // The posts, ears lit gold once the paddock is fenced.
    final ears = play.ears.toSet();
    final crowned = play.crown;
    for (var at = 0; at < play.fold.posts; at++) {
      final middle = metrics.postAt(at);
      final lit = ears.contains(at);
      final picked = play.picked == at;
      if (lit) {
        canvas.drawCircle(
          middle,
          metrics.ring * 0.17,
          Paint()..color = Palette.ear.withValues(alpha: 0.22),
        );
      }
      canvas.drawCircle(
        middle,
        metrics.ring * 0.09,
        Paint()..color = lit ? Palette.ear : Palette.post,
      );
      canvas.drawCircle(
        middle,
        metrics.ring * 0.09,
        Paint()
          ..color = picked ? Palette.shown : Palette.postRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = picked ? 3.0 : 1.5,
      );
      if (showWords && play.fenced) {
        final words = TextPainter(
          text: TextSpan(
            text: '${crowned[at]}',
            style: labels.copyWith(
              color: lit ? Palette.ear : Palette.inkDim,
              fontSize: metrics.ring * 0.11,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final out = (middle - metrics.middle) /
            (middle - metrics.middle).distance;
        final seat = middle + out * metrics.ring * 0.19;
        words.paint(canvas,
            seat - Offset(words.width / 2, words.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(FoldView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the fold at hand.
String whyWords(Play play) {
  final fold = play.fold;
  final rules = play.rules;
  final note = fold.note == null ? '' : ' ${fold.note}';
  if (!fold.winnable) {
    return 'The two-ears theorem holds every paddock: a full '
        'fencing folds ${fold.posts} posts into '
        '${fold.posts - 2} pens, and at least two posts always '
        'corner exactly one. The sweep laid all '
        '${rules.foldings()} foldings and read every crown, and '
        'the ears never went below two.$note';
  }
  return 'The crowns are checked against the sweep: all '
      '${rules.foldings()} foldings laid, every crown summing '
      'to three pens a fold, no two foldings sharing one, and '
      '${fold.ways} folding${fold.ways == 1 ? '' : 's'} '
      'land${fold.ways == 1 ? 's' : ''} this asking.$note';
}

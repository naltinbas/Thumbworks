import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../down/play.dart';
import 'palette.dart';

/// Where every post stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.5);
    ring = math.min(room.width, room.height) * 0.4;
  }

  final Play play;

  late final Offset middle;
  late final double ring;

  /// The point of a post, counted clockwise from the top.
  Offset postAt(int post) {
    final turn =
        -math.pi / 2 + 2 * math.pi * post / play.down.posts;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The post under a touch, or -1.
  int postUnder(Offset touch) {
    for (var at = 0; at < play.down.posts; at++) {
      if ((postAt(at) - touch).distance <= ring * 0.22) return at;
    }
    return -1;
  }
}

/// The down, drawn.
class DownView extends CustomPainter {
  DownView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The rope the show-me points at, or null.
  final ((int, int), bool)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // Every knotted triangle, washed rust under the ropes.
    for (final (a, b, c) in play.knotted) {
      final path = Path()
        ..moveTo(metrics.postAt(a).dx, metrics.postAt(a).dy)
        ..lineTo(metrics.postAt(b).dx, metrics.postAt(b).dy)
        ..lineTo(metrics.postAt(c).dx, metrics.postAt(c).dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = Palette.knot.withValues(alpha: 0.22),
      );
    }

    // The ropes.
    for (final (a, b) in play.ropes) {
      final knottedRope = play.knotted.any((tri) =>
          [tri.$1, tri.$2, tri.$3].contains(a) &&
          [tri.$1, tri.$2, tri.$3].contains(b));
      canvas.drawLine(
        metrics.postAt(a),
        metrics.postAt(b),
        Paint()
          ..color = knottedRope ? Palette.knot : Palette.rope
          ..strokeWidth = math.max(metrics.ring * 0.035, 3.0)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointed rope, dashed blue between its posts.
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

    // The posts, over everything.
    for (var at = 0; at < play.down.posts; at++) {
      final middle = metrics.postAt(at);
      final picked = play.picked == at;
      canvas.drawCircle(
          middle, metrics.ring * 0.09, Paint()..color = Palette.post);
      canvas.drawCircle(
        middle,
        metrics.ring * 0.09,
        Paint()
          ..color = picked ? Palette.shown : Palette.postRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = picked ? 3.0 : 1.5,
      );
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: '${at + 1}',
            style: labels.copyWith(
              color: Palette.night,
              fontSize: metrics.ring * 0.09,
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
  bool shouldRepaint(DownView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the down at hand.
String whyWords(Play play) {
  final down = play.down;
  final rules = play.rules;
  final note = down.note == null ? '' : ' ${down.note}';
  if (!down.winnable) {
    return 'Mantel\'s law bars this down: split ${down.posts} '
        'posts into two pastures any way you like and the ropes '
        'between them number ${rules.pastureMost()} at best, '
        'which is the fence line, and every tethering past it '
        'knots. The sweep tied every tethering of ${down.asked} '
        'and found a triangle in each.$note';
  }
  return 'The census reads every triangle off the down, the '
      'pasture arithmetic sets the fence line at a quarter of '
      'the square of the posts, ${rules.fenceLine} here, and the '
      'sweep ties every tethering and counts ${down.ways} '
      'landing this asking, with every fullest tethering '
      'splitting into two pastures.$note';
}

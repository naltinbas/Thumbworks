import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../web/play.dart';
import 'palette.dart';

/// Where the posts and threads lie, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    round = math.min(width, height) * 0.38;
    middle = Offset(width / 2, height / 2);
    post = math.min(width, height) * 0.045;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double round;
  late final Offset middle;
  late final double post;

  Offset postAt(int at) {
    final turn = -math.pi / 2 + at * 2 * math.pi / play.web.dots;
    return middle + Offset(math.cos(turn), math.sin(turn)) * round;
  }

  /// The thread under a touch, or -1: nearest chord within reach.
  int threadAt(Offset touch) {
    var best = -1;
    var nearest = post * 2.4;
    for (var thread = 0; thread < play.rules.threads; thread++) {
      final (a, b) = play.rules.edges[thread];
      final from = postAt(a);
      final to = postAt(b);
      final way = to - from;
      final length = way.distance;
      final t = (((touch - from).dx * way.dx +
                  (touch - from).dy * way.dy) /
              (length * length))
          .clamp(0.0, 1.0);
      final on = from + way * t;
      final away = (touch - on).distance;
      if (away < nearest) {
        nearest = away;
        best = thread;
      }
    }
    return best;
  }
}

/// The web, drawn.
class WebView extends CustomPainter {
  WebView({
    required this.play,
    required this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The thread being pointed at, or -1.
  final int pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final closed = play.closedTriangle;
    final closedSet = closed == null
        ? const <int>{}
        : {closed.$1, closed.$2, closed.$3};

    // Free threads under, claimed over, the closing triangle last.
    for (var pass = 0; pass < 3; pass++) {
      for (var thread = 0; thread < play.rules.threads; thread++) {
        final isClosed = closedSet.contains(thread);
        final claimed = !play.isFree(thread);
        if (pass == 0 && claimed) continue;
        if (pass == 1 && (!claimed || isClosed)) continue;
        if (pass == 2 && !isClosed) continue;
        final (a, b) = play.rules.edges[thread];
        final colour = pass == 0
            ? Palette.free
            : isClosed
                ? Palette.closed
                : play.isMine(thread)
                    ? Palette.mineThread
                    : Palette.houseThread;
        canvas.drawLine(
          metrics.postAt(a),
          metrics.postAt(b),
          Paint()
            ..color = colour
            ..strokeWidth = pass == 0
                ? 1.6
                : isClosed
                    ? 5.0
                    : 3.2
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    if (pointing >= 0) {
      final (a, b) = play.rules.edges[pointing];
      canvas.drawLine(
        metrics.postAt(a),
        metrics.postAt(b),
        Paint()
          ..color = Palette.shown
          ..strokeWidth = 3.4
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var at = 0; at < play.web.dots; at++) {
      final middle = metrics.postAt(at);
      canvas.drawCircle(middle, metrics.post, Paint()..color = Palette.post);
      canvas.drawCircle(
        middle,
        metrics.post,
        Paint()
          ..color = Palette.postRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(WebView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the web at hand.
String whyWords(Play play) {
  final web = play.web;
  final note = web.note == null ? '' : ' ${web.note}';
  if (web.dots == 6) {
    return 'Six posts allow no finished web without a one-colour '
        'triangle: the sweep painted all 32,768 and found none, and '
        'the counting argument finds the triangle on any of them '
        'without looking twice. The search of every weave then says '
        'whose the win is.$note';
  }
  return 'Five posts allow exactly twelve finished webs with no '
      'one-colour triangle, every one a ring of each colour round '
      'all five posts: the sweep painted all 1,024 and counted. The '
      'search of every weave says best play from either chair ends '
      'in one.$note';
}

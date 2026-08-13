import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../round/play.dart';
import '../round/rules.dart';
import 'palette.dart';

/// Where every post stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height / 2);
    outer = math.min(room.width, room.height) * 0.42;
    inner = outer * 0.52;
    post = outer * 0.085;
  }

  final Play play;

  late final Offset middle;
  late final double outer;
  late final double inner;
  late final double post;

  /// The middle of a post: nought to four round the outer
  /// ring, five to nine round the inner star.
  Offset postAt(int at) {
    final ring = at < 5 ? outer : inner;
    final turn = -math.pi / 2 + 2 * math.pi * (at % 5) / 5;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The post under a touch, or -1 for the night.
  int postUnder(Offset touch) {
    for (var at = 0; at < 10; at++) {
      if ((postAt(at) - touch).distance <= post * 2.2) {
        return at;
      }
    }
    return -1;
  }
}

/// The star, drawn: fifteen lanes, the walk in gold, and the
/// posts on their two rings.
class RoundView extends CustomPainter {
  RoundView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The post the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final post = metrics.post;
    final walk = play.walk;

    // The walked lanes, closing lane included.
    final walked = <(int, int)>{};
    for (var at = 0; at + 1 < walk.length; at++) {
      walked.add(_sorted(walk[at], walk[at + 1]));
    }
    if (play.closed && walk.length > 1) {
      walked.add(_sorted(walk.last, walk.first));
    }

    // Every lane, the walked ones in gold.
    for (final (a, b) in Rules.lanes) {
      final isWalked = walked.contains((a, b));
      canvas.drawLine(
        metrics.postAt(a),
        metrics.postAt(b),
        Paint()
          ..color = isWalked ? Palette.walked : Palette.lane
          ..strokeWidth = isWalked
              ? math.max(post * 0.55, 3.4)
              : math.max(post * 0.25, 1.8)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The posts.
    for (var at = 0; at < 10; at++) {
      final here = metrics.postAt(at);
      final inWalk = walk.contains(at);
      final isHead =
          !play.closed && walk.isNotEmpty && walk.last == at;
      canvas.drawCircle(
        here,
        isHead ? post * 1.35 : post,
        Paint()
          ..color = isHead
              ? Palette.head
              : inWalk
                  ? Palette.walked
                  : Palette.post,
      );
      if (!play.closed &&
          walk.length == play.tour.posts &&
          at == walk.first &&
          play.takes(at)) {
        canvas.drawCircle(
          here,
          post * 1.9,
          Paint()
            ..color = Palette.walked
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
      if (pointing == at) {
        canvas.drawCircle(
          here,
          post * 2.2,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }
  }

  (int, int) _sorted(int a, int b) => a < b ? (a, b) : (b, a);

  @override
  bool shouldRepaint(RoundView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the tour at hand.
String whyWords(Play play) {
  final tour = play.tour;
  final note = tour.note == null ? '' : ' ${tour.note}';
  if (!tour.winnable) {
    return 'The sweep walked every closed round the star holds, '
        'at every length there is: twelve pentagons, ten '
        'hexagons, fifteen eights, twenty nines, and not one '
        'round of ten. Every nine-round leaves a single post '
        'out, and every post takes its turn, two tours apiece: '
        'the tenth post never joins.$note';
  }
  return 'A round is read two ways that share nothing: the walk '
      'itself, checked lane by lane as it closes, and the census, '
      'every closed round of the star swept at every length, '
      '5 through 10, and pinned: 12, 10, none of seven, 15, 20 '
      'and none of ten. ${tour.ways} '
      'round${tour.ways == 1 ? '' : 's'} '
      'stand${tour.ways == 1 ? 's' : ''} at this length.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ring/play.dart';
import 'palette.dart';

/// Where every lantern stands, shared by the painter and the
/// hit-testing, so where a lantern is drawn is exactly where a lantern
/// is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final places = play.watch.length;
    lantern = math.min(
      math.min(width, height) * 0.062,
      math.min(width, height) * math.pi / (places * 2.6),
    );
    round = math.min(width, height) / 2 - lantern * 2.2;
    middle = Offset(width / 2, height / 2);
  }

  final Play play;

  late final double width;
  late final double height;

  /// A lantern's radius, the ring's radius, and its middle.
  late final double lantern;
  late final double round;
  late final Offset middle;

  Offset lanternCenter(int place) {
    final turn = -math.pi / 2 + place * 2 * math.pi / play.watch.length;
    return middle + Offset(math.cos(turn), math.sin(turn)) * round;
  }

  /// The lantern under a touch, or -1.
  int lanternAt(Offset touch) {
    for (var place = 0; place < play.watch.length; place++) {
      if ((lanternCenter(place) - touch).distance <= lantern * 1.7) {
        return place;
      }
    }
    return -1;
  }
}

/// The ring, drawn.
class RingView extends CustomPainter {
  RingView({
    required this.play,
    required this.pointing,
    this.showClashes = false,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The lantern being pointed at, or -1.
  final int pointing;

  /// Whether to chord the clashing places red.
  final bool showClashes;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The road round the marsh.
    canvas.drawCircle(
      metrics.middle,
      metrics.round,
      Paint()
        ..color = Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(metrics.lantern * 0.16, 1.2),
    );

    if (showClashes) {
      for (final (one, other) in play.clashes) {
        canvas.drawLine(
          metrics.lanternCenter(one),
          metrics.lanternCenter(other),
          Paint()
            ..color = Palette.clash.withValues(alpha: 0.55)
            ..strokeWidth = math.max(metrics.lantern * 0.12, 1.4),
        );
      }
    }

    for (var place = 0; place < play.watch.length; place++) {
      _lantern(canvas, metrics, place);
    }
  }

  void _lantern(Canvas canvas, Metrics metrics, int place) {
    final middle = metrics.lanternCenter(place);
    final lantern = metrics.lantern;
    final isLit = play.lit(place);
    final locked = play.watch.isLocked(place);

    if (isLit) {
      canvas.drawCircle(
          middle, lantern * 2.1, Paint()..color = Palette.glow);
    }
    canvas.drawCircle(middle, lantern * 1.25,
        Paint()..color = isLit ? Palette.lamp : Palette.socket);
    if (isLit) {
      canvas.drawCircle(
        middle + Offset(-lantern * 0.35, -lantern * 0.4),
        lantern * 0.32,
        Paint()..color = Palette.lampLight,
      );
    }
    canvas.drawCircle(
      middle,
      lantern * 1.25,
      Paint()
        ..color = place == pointing
            ? Palette.shown
            : locked
                ? Palette.brass
                : Palette.socketRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = place == pointing || locked
            ? math.max(lantern * 0.22, 2.2)
            : math.max(lantern * 0.12, 1.4),
    );
    if (locked) {
      // A little hasp over a held lantern.
      canvas.drawCircle(
        middle + Offset(0, lantern * 1.55),
        lantern * 0.34,
        Paint()..color = Palette.brass,
      );
    }
  }

  @override
  bool shouldRepaint(RingView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showClashes != showClashes;
}

/// The words the why speaks, from the ring at hand.
String whyWords(Play play) {
  final watch = play.watch;
  final note = watch.note == null ? '' : ' ${watch.note}';
  if (!watch.winnable) {
    return 'Every place starts one watchword, so ${watch.length} '
        'places spell at most ${watch.length} words, and the watch '
        'asks ${watch.words}. The sweep of every ring there is agrees: '
        'none is full. The red chords are places spelling alike, and '
        'some always are.$note';
  }
  return 'The red chords are places spelling the same watchword; a '
      'full ring has none. Of the ${1 << watch.length} rings there '
      'are, the sweep counts ${watch.ways} full, and the shift-walk '
      'builds one from the words alone, never counting at all.$note';
}

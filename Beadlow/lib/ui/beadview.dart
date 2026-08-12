import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../bead/play.dart';
import 'palette.dart';

/// Where the ring and the shelf lie, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.27);
    round = math.min(room.width, room.height * 0.54) * 0.3;
    bead = math.min(round * 2 * math.pi / play.ring.beads * 0.34,
        round * 0.42);
    shelfTop = room.height * 0.56;
    shelfLeft = room.width * 0.06;
    shelfWide = room.width * 0.88;
  }

  final Play play;

  late final Offset middle;
  late final double round;
  late final double bead;
  late final double shelfTop;
  late final double shelfLeft;
  late final double shelfWide;

  /// Where a bead of the table's ring sits.
  Offset beadAt(int at) {
    final turn = -math.pi / 2 + at * 2 * math.pi / play.ring.beads;
    return middle + Offset(math.cos(turn), math.sin(turn)) * round;
  }

  /// The bead under a touch, or null.
  int? beadUnder(Offset touch) {
    for (var at = 0; at < play.ring.beads; at++) {
      if ((beadAt(at) - touch).distance <= bead * 1.4) return at;
    }
    return null;
  }

  /// Where a shelf necklace's centre sits: five to a row.
  Offset shelfAt(int at) {
    final lane = shelfWide / 5;
    return Offset(
      shelfLeft + lane * (at % 5 + 0.5),
      shelfTop + lane * 0.9 * (at ~/ 5 + 0.5),
    );
  }

  double get shelfRound => shelfWide / 5 * 0.3;
}

/// The stall, drawn.
class BeadView extends CustomPainter {
  BeadView({
    required this.play,
    this.ghost,
    this.named,
    required this.labels,
  });

  final Play play;

  /// A missing necklace shown inside the beads, or null.
  final List<int>? ghost;

  /// A shelf place being named as the repeat, or null.
  final int? named;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The cord of the table's ring.
    canvas.drawCircle(
      metrics.middle,
      metrics.round,
      Paint()
        ..color = Palette.cord
        ..style = PaintingStyle.stroke
        ..strokeWidth = metrics.bead * 0.22,
    );

    for (var at = 0; at < play.ring.beads; at++) {
      final spot = metrics.beadAt(at);
      canvas.drawCircle(spot, metrics.bead,
          Paint()..color = Palette.dyes[play.beads[at]]);
      canvas.drawCircle(
        spot,
        metrics.bead,
        Paint()
          ..color = Palette.beadRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      final want = ghost;
      if (want != null && want[at] != play.beads[at]) {
        canvas.drawCircle(
          spot,
          metrics.bead * 0.5,
          Paint()..color = Palette.dyes[want[at]],
        );
        canvas.drawCircle(
          spot,
          metrics.bead * 0.5,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
    }

    // The shelf: every necklace strung, in its smallest turning.
    for (var at = 0; at < play.strung.length; at++) {
      final middle = metrics.shelfAt(at);
      final round = metrics.shelfRound;
      canvas.drawCircle(
        middle,
        round,
        Paint()
          ..color = Palette.cord
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      final necklace = play.strung[at];
      for (var bead = 0; bead < necklace.length; bead++) {
        final turn =
            -math.pi / 2 + bead * 2 * math.pi / necklace.length;
        canvas.drawCircle(
          middle + Offset(math.cos(turn), math.sin(turn)) * round,
          round * 0.32,
          Paint()..color = Palette.dyes[necklace[bead]],
        );
      }
      if (at == named) {
        canvas.drawCircle(
          middle,
          round * 1.55,
          Paint()
            ..color = Palette.bad
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
    }

    // The empty places still to fill, when the asking fits the
    // shelf.
    final places = math.min(play.ring.asked, play.ring.holds);
    for (var at = play.strung.length; at < places; at++) {
      canvas.drawCircle(
        metrics.shelfAt(at),
        metrics.shelfRound,
        Paint()
          ..color = Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  @override
  bool shouldRepaint(BeadView old) =>
      old.play != play || old.ghost != ghost || old.named != named;
}

/// The words the why speaks, from the ring at hand.
String whyWords(Play play) {
  final ring = play.ring;
  final note = ring.note == null ? '' : ' ${ring.note}';
  final fixed = play.fixedByTurn.join(', ');
  final summed =
      play.fixedByTurn.reduce((held, next) => held + next);
  final base =
      'Two strings are one necklace when some turn of the ring '
      'maps one onto the other. Count what every turn fixes: a '
      'turn by r fixes dyes-to-the-gcd-of-r-and-${ring.beads} '
      'strings, which for this ring is $fixed. Their sum is '
      '$summed, and $summed over the ${ring.beads} turns is '
      '${ring.holds}: the shelf, folding every string by hand, '
      'says the same.';
  if (!ring.winnable) {
    return '$base The asking was ${ring.asked}, and the ring holds '
        'only ${ring.holds}.$note';
  }
  return base + note;
}

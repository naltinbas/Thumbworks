import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hedge/play.dart';
import '../hedge/rules.dart';
import 'palette.dart';

/// Where every withy stands, shared by the painter and the hit-testing,
/// so where a withy is drawn is exactly where a withy is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final stalks = play.hedge.stalks.length;
    lane = width / (stalks + 0.6);
    var tallest = 1;
    for (final (_, length) in play.hedge.stalks) {
      tallest = math.max(tallest, length);
    }
    withy = math.min(lane * 0.5, (height * 0.66) / tallest);
    groundY = height * 0.82;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double lane;
  late final double withy;
  late final double groundY;

  double stalkX(int stalk) => lane * (stalk + 0.5) + lane * 0.3;

  /// The withy so far up a stalk, whether standing or felled.
  Rect withyRect(int stalk, int at) => Rect.fromCenter(
        center: Offset(
          stalkX(stalk),
          groundY - (at + 0.5) * (withy * 1.06),
        ),
        width: withy * 0.44,
        height: withy,
      );

  /// The standing withy under a touch, or null.
  (int, int)? withyAt(Offset touch) {
    for (var stalk = 0; stalk < play.stalks.length; stalk++) {
      final (_, length) = play.stalks[stalk];
      for (var at = 0; at < length; at++) {
        if (withyRect(stalk, at).inflate(6).contains(touch)) {
          return (stalk, at);
        }
      }
    }
    return null;
  }
}

/// The hedge, drawn.
class HedgeView extends CustomPainter {
  HedgeView({
    required this.play,
    required this.pointing,
    required this.showWorth,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The withy being pointed at, or null.
  final (int, int)? pointing;

  /// Whether to write the worths on the stalks.
  final bool showWorth;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The ground.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          metrics.lane * 0.24,
          metrics.groundY,
          metrics.width - metrics.lane * 0.48,
          math.max(4.0, metrics.withy * 0.2),
        ),
        const Radius.circular(3),
      ),
      Paint()..color = Palette.ground,
    );

    for (var stalk = 0; stalk < play.stalks.length; stalk++) {
      final (bits, length) = play.stalks[stalk];
      for (var at = 0; at < length; at++) {
        _withy(canvas, metrics, stalk, at, (bits >> at) & 1 == 1);
      }
      if (showWorth && showWords) {
        _worth(canvas, metrics, stalk, length);
      }
    }
    if (pointing != null) _point(canvas, metrics);
  }

  void _withy(
      Canvas canvas, Metrics metrics, int stalk, int at, bool yours) {
    final rect = metrics.withyRect(stalk, at);
    final round = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.5),
    );
    canvas.drawRRect(
      round,
      Paint()..color = yours ? Palette.yours : Palette.theirs,
    );
    // A bud partway up, so a withy reads as a living shoot.
    canvas.drawCircle(
      rect.center + Offset(rect.width * 0.34, -rect.height * 0.18),
      rect.width * 0.16,
      Paint()..color = yours ? Palette.yoursDeep : Palette.theirsDeep,
    );
  }

  void _worth(Canvas canvas, Metrics metrics, int stalk, int length) {
    final worth = Rules.worthOf(play.stalks[stalk].$1, length);
    final words = TextPainter(
      text: TextSpan(
        text: worth.said,
        style: labels.copyWith(
          color: Palette.worth,
          fontSize: metrics.withy * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final top = length == 0
        ? metrics.groundY - metrics.withy * 0.6
        : metrics.withyRect(stalk, length - 1).top - words.height - 6;
    words.paint(
      canvas,
      Offset(metrics.stalkX(stalk) - words.width / 2, top),
    );
  }

  void _point(Canvas canvas, Metrics metrics) {
    final rect = metrics.withyRect(pointing!.$1, pointing!.$2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(4),
        Radius.circular(rect.width * 0.6),
      ),
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
  }

  @override
  bool shouldRepaint(HedgeView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showWorth != showWorth;
}

/// The words the why speaks, from the hedge at hand.
String whyWords(Play play) {
  final worths = [
    for (final (bits, length) in play.stalks)
      Rules.worthOf(bits, length).said,
  ].join(', ');
  final total = play.worth;
  final start = 'A stalk is worth whole ones while its colour holds from '
      'the ground, then each withy above the first change is worth half '
      'the one below, its own way. These stand at $worths, and the hedge '
      'sums to ${total.said}.';
  final verdict = total.isPositive
      ? ' Positive is yours whoever cuts: hold it positive and the '
          'hedger runs out first.'
      : total.isNought
          ? ' At exactly nought, whoever must cut first loses, and the '
              'first cut is yours.'
          : ' Negative is the hedger\'s whoever cuts.';
  final note = play.hedge.note;
  return '$start$verdict${note == null ? '' : ' $note'}';
}

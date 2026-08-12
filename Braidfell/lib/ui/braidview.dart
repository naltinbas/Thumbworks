import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../braid/play.dart';
import 'palette.dart';

/// Where every bundle lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final count = play.bundles.length;
    lane = width * 0.9 / math.max(count, 3);
    left = (width - lane * count) / 2;
    floorY = height * 0.62;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double lane;
  late final double left;
  late final double floorY;

  /// The heaviest weight the yard started with, for the scale.
  int get heaviest {
    var most = 1;
    for (final weight in play.yard.bundles) {
      most = math.max(most, weight);
    }
    // Braids can double the biggest bundle at most a few times;
    // scale by the whole yard instead so nothing outgrows the pen.
    var whole = 0;
    for (final weight in play.yard.bundles) {
      whole += weight;
    }
    return whole;
  }

  /// A bundle's centre and girth by its place.
  ({Offset middle, double girth}) bundleAt(int at) {
    final weight = play.bundles[at];
    final girth = lane * 0.34 +
        lane * 0.52 * math.sqrt(weight / heaviest);
    return (
      middle: Offset(left + lane * (at + 0.5), floorY - girth),
      girth: girth,
    );
  }

  /// The bundle under a touch, or null.
  int? bundleUnder(Offset touch) {
    for (var at = 0; at < play.bundles.length; at++) {
      final bundle = bundleAt(at);
      if ((bundle.middle - touch).distance <= bundle.girth * 1.25) {
        return at;
      }
    }
    return null;
  }
}

/// The yard, drawn.
class BraidView extends CustomPainter {
  BraidView({
    required this.play,
    required this.armed,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The bundle armed for a braid, or -1.
  final int armed;

  /// The two bundles being pointed at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The yard floor.
    canvas.drawLine(
      Offset(metrics.left * 0.5, metrics.floorY),
      Offset(size.width - metrics.left * 0.5, metrics.floorY),
      Paint()
        ..color = Palette.line
        ..strokeWidth = 2.4,
    );

    for (var at = 0; at < play.bundles.length; at++) {
      final bundle = metrics.bundleAt(at);
      final lit = at == armed ||
          (pointing != null &&
              (pointing!.$1 == at || pointing!.$2 == at));

      // A woolly bundle: a fat blob of overlapping rounds.
      for (final (dx, dy, part) in const [
        (-0.45, 0.1, 0.62),
        (0.45, 0.1, 0.62),
        (0.0, -0.42, 0.66),
        (0.0, 0.18, 0.78),
      ]) {
        canvas.drawCircle(
          bundle.middle +
              Offset(bundle.girth * dx, bundle.girth * dy),
          bundle.girth * part,
          Paint()..color = Palette.wool,
        );
      }
      canvas.drawCircle(
        bundle.middle + Offset(0, bundle.girth * 0.18),
        bundle.girth * 0.78,
        Paint()
          ..color = lit
              ? (at == armed ? Palette.armed : Palette.shown)
              : Palette.woolRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = lit ? 3.0 : 1.6,
      );

      final words = TextPainter(
        text: TextSpan(
          text: '${play.bundles[at]}',
          style: labels.copyWith(
            color: Palette.woolInk,
            fontSize: math.max(bundle.girth * 0.62, 13.0),
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        bundle.middle +
            Offset(-words.width / 2,
                bundle.girth * 0.18 - words.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(BraidView old) =>
      old.play != play ||
      old.armed != armed ||
      old.pointing != pointing;
}

/// The words the why speaks, from the yard at hand.
String whyWords(Play play) {
  final yard = play.yard;
  final note = yard.note == null ? '' : ' ${yard.note}';
  final orders = _ordersOf(yard.bundles.length);
  if (!yard.winnable) {
    return 'Every braid costs its two bundles put together, and '
        'the sweep has tried all $orders orders this yard allows: '
        'the cheapest finishes at ${yard.least}, and the asking '
        'was ${yard.asked}. Lightest-first lands the same '
        '${yard.least} without trying anything at all.$note';
  }
  return 'Every braid costs its two bundles put together. '
      'Lightest-first braids the two lightest every time, and the '
      'sweep of all $orders orders this yard allows finds nothing '
      'cheaper than its ${yard.least}: the rule and the sweep '
      'agree to the pound.$note';
}

int _ordersOf(int bundles) {
  var total = 1;
  for (var left = bundles; left > 1; left--) {
    total *= left * (left - 1) ~/ 2;
  }
  return total;
}

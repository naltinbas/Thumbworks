import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../peck/play.dart';
import 'palette.dart';

/// Where every chicken stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height / 2);
    ring = math.min(room.width, room.height) * 0.36;
    head = ring * 0.21;
  }

  final Play play;

  late final Offset middle;
  late final double ring;
  late final double head;

  /// The middle of a chicken's head, the first at the top.
  Offset chickenAt(int chicken) {
    final turn =
        -math.pi / 2 + 2 * math.pi * chicken / play.flock.chickens;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// Both ends of a pair's arrow, trimmed clear of the heads.
  (Offset, Offset) railOf(int pair) {
    final (a, b) = play.rules.pairs[pair];
    final from = chickenAt(a);
    final to = chickenAt(b);
    final way = (to - from) / (to - from).distance;
    return (from + way * head * 1.45, to - way * head * 1.45);
  }

  /// The pair whose arrow lies under a touch, or null.
  int? pairUnder(Offset touch) {
    int? found;
    var nearest = head * 1.2;
    for (var pair = 0; pair < play.rules.pairs.length; pair++) {
      final (from, to) = railOf(pair);
      final span = to - from;
      final length = span.distance;
      var along = ((touch - from).dx * span.dx +
              (touch - from).dy * span.dy) /
          (length * length);
      along = along.clamp(0.0, 1.0);
      final off = (from + span * along - touch).distance;
      if (off < nearest) {
        nearest = off;
        found = pair;
      }
    }
    return found;
  }

  /// Where a pair's arrowhead sits, staggered off the middle so
  /// crossing arrows stay readable.
  Offset headOf(int pair) {
    final (from, to) = railOf(pair);
    final at = 0.52 + (pair % 3) * 0.09;
    return from + (to - from) * at;
  }
}

/// The yard, drawn: chickens, arrows, crowns and the rosette.
class PeckView extends CustomPainter {
  PeckView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The pair the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final head = metrics.head;
    final table = play.rules.table(play.pecking);
    final kings = play.kings.toSet();
    final busiest = play.busiest.toSet();

    // The arrows, pecker to pecked.
    for (var pair = 0; pair < play.rules.pairs.length; pair++) {
      final (a, b) = play.rules.pairs[pair];
      final pecked = play.pecking[pair] ? a : b;
      final (from, to) = metrics.railOf(pair);
      final line = Paint()
        ..color = Palette.arrow
        ..strokeWidth = math.max(head * 0.14, 2.6)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(from, to, line);

      // The head of the arrow, along the rail, pointing at the
      // pecked chicken.
      final at = metrics.headOf(pair);
      final way = table[a][b]
          ? (to - from) / (to - from).distance
          : (from - to) / (from - to).distance;
      assert(table[a][b] == (pecked == b));
      final side = Offset(-way.dy, way.dx);
      final tip = at + way * head * 0.52;
      final wing = head * 0.34;
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx, tip.dy)
          ..lineTo(tip.dx - way.dx * wing * 1.6 + side.dx * wing,
              tip.dy - way.dy * wing * 1.6 + side.dy * wing)
          ..lineTo(tip.dx - way.dx * wing * 1.6 - side.dx * wing,
              tip.dy - way.dy * wing * 1.6 - side.dy * wing)
          ..close(),
        Paint()..color = Palette.arrow,
      );

      if (pointing == pair) {
        canvas.drawCircle(
          at,
          head * 0.85,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The chickens.
    for (var chicken = 0; chicken < play.flock.chickens; chicken++) {
      final at = metrics.chickenAt(chicken);

      if (busiest.contains(chicken)) {
        canvas.drawCircle(
          at,
          head * 1.32,
          Paint()
            ..color = Palette.rosette
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      }

      canvas.drawCircle(at, head, Paint()..color = Palette.chicken);
      // The comb.
      for (var bump = -1; bump <= 1; bump++) {
        canvas.drawCircle(
          at + Offset(bump * head * 0.38, -head * 0.92),
          head * 0.22,
          Paint()..color = Palette.comb,
        );
      }
      // The eye and the beak.
      canvas.drawCircle(
        at + Offset(head * 0.26, -head * 0.14),
        head * 0.1,
        Paint()..color = Palette.night,
      );
      final out = (at - metrics.middle) / (at - metrics.middle).distance;
      final beak = at + out * head * 0.98;
      final side = Offset(-out.dy, out.dx);
      canvas.drawPath(
        Path()
          ..moveTo(beak.dx + out.dx * head * 0.42,
              beak.dy + out.dy * head * 0.42)
          ..lineTo(beak.dx + side.dx * head * 0.22,
              beak.dy + side.dy * head * 0.22)
          ..lineTo(beak.dx - side.dx * head * 0.22,
              beak.dy - side.dy * head * 0.22)
          ..close(),
        Paint()..color = Palette.comb,
      );

      // The crown, on every king.
      if (kings.contains(chicken)) {
        final base = at + Offset(0, -head * 1.62);
        final wide = head * 0.62;
        final tall = head * 0.5;
        canvas.drawPath(
          Path()
            ..moveTo(base.dx - wide, base.dy)
            ..lineTo(base.dx - wide, base.dy - tall * 0.55)
            ..lineTo(base.dx - wide * 0.5, base.dy - tall * 0.2)
            ..lineTo(base.dx, base.dy - tall)
            ..lineTo(base.dx + wide * 0.5, base.dy - tall * 0.2)
            ..lineTo(base.dx + wide, base.dy - tall * 0.55)
            ..lineTo(base.dx + wide, base.dy)
            ..close(),
          Paint()..color = Palette.crown,
        );
      }

      // Each chicken's peck count, under the head.
      final count = TextPainter(
        text: TextSpan(
          text: '${play.outPecks[chicken]}',
          style: labels.copyWith(
            color: Palette.inkDim,
            fontSize: head * 0.7,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      count.paint(
        canvas,
        at + Offset(-count.width / 2, head * 1.18),
      );
    }
  }

  @override
  bool shouldRepaint(PeckView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the flock at hand.
String whyWords(Play play) {
  final flock = play.flock;
  final note = flock.note == null ? '' : ' ${flock.note}';
  final sweeps = {3: '8', 4: '64', 5: withComma(1024)};
  if (!flock.winnable) {
    return 'Two crowns cannot stand. A crowned pair holds no '
        'emperor, so somebody pecks the first king; the peckers of '
        'a king always keep a king of their own little flock, and '
        'he is a crown of the whole yard too, pecking the king and '
        'reaching the rest through him. That makes a third crown '
        'unless he is the second king; but then the second king\'s '
        'own peckers keep a king as well, a third crown for '
        'certain, and not the first, who is pecked by the second '
        'and so cannot peck him. The sweep settled all 64 peckings '
        'of four and found thirty-two lone crowns, thirty-two '
        'courts of three, and never a pair.$note';
  }
  return 'A crown is checked two ways that share nothing: chicken '
      'by chicken through every middleman, and by squaring the '
      'whole pecking table at once. The sweep settles every '
      'pecking of the yard, ${sweeps[flock.chickens]} of them, '
      'and the two counts agree on every one. ${flock.ways} '
      'peckings land this flock\'s asking.$note';
}

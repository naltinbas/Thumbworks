import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../daisy/play.dart';
import 'palette.dart';

/// Where every face lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height / 2);
    ring = math.min(room.width, room.height) * 0.36;
    face = ring * (play.circle.people > 5 ? 0.16 : 0.2);
  }

  final Play play;

  late final Offset middle;
  late final double ring;
  late final double face;

  /// The middle of a face, the first at the top.
  Offset faceAt(int person) {
    final turn =
        -math.pi / 2 + 2 * math.pi * person / play.circle.people;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// Both ends of a pair's wire, trimmed clear of the faces.
  (Offset, Offset) wireOf(int pair) {
    final (a, b) = play.rules.pairs[pair];
    final from = faceAt(a);
    final to = faceAt(b);
    final way = (to - from) / (to - from).distance;
    return (from + way * face * 1.35, to - way * face * 1.35);
  }

  /// Where a pair's ring and hit-centre sit, staggered along
  /// the wire so no two wires meet at anyone's centre.
  Offset midOf(int pair) {
    final (from, to) = wireOf(pair);
    return from + (to - from) * (0.34 + (pair % 4) * 0.11);
  }

  /// The pair whose wire lies under a touch, or null.
  int? pairUnder(Offset touch) {
    int? found;
    var nearest = face * 1.05;
    for (var pair = 0; pair < play.rules.pairs.length; pair++) {
      final (from, to) = wireOf(pair);
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
}

/// The circle, drawn: wires faint till wired, faces, and the
/// heart crowned in gold once the circle settles.
class DaisyView extends CustomPainter {
  DaisyView({
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
    final face = metrics.face;
    final table = play.rules.table(play.wired);

    // The petals, washed once the circle settles.
    if (play.isDone) {
      final degrees = [
        for (var v = 0; v < play.circle.people; v++)
          table[v].where((friend) => friend).length,
      ];
      final heart = degrees.indexOf(play.circle.people - 1);
      for (var a = 0; a < play.circle.people; a++) {
        for (var b = a + 1; b < play.circle.people; b++) {
          if (a == heart || b == heart) continue;
          if (!table[a][b]) continue;
          final wash = Path()
            ..addPolygon([
              metrics.faceAt(heart),
              metrics.faceAt(a),
              metrics.faceAt(b),
            ], true);
          canvas.drawPath(wash, Paint()..color = Palette.petalWash);
        }
      }
    }

    // Every wire, faint till wired, given wires steady.
    for (var pair = 0; pair < play.rules.pairs.length; pair++) {
      final (from, to) = metrics.wireOf(pair);
      final wiredUp = play.wired[pair];
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = wiredUp ? Palette.wire : Palette.line
          ..strokeWidth = wiredUp
              ? math.max(face * 0.16, 3.0)
              : math.max(face * 0.06, 1.4)
          ..strokeCap = StrokeCap.round,
      );
      if (pointing == pair) {
        canvas.drawCircle(
          metrics.midOf(pair),
          face * 0.62,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The faces, the heart crowned when the circle settles.
    final degrees = [
      for (var v = 0; v < play.circle.people; v++)
        table[v].where((friend) => friend).length,
    ];
    for (var person = 0; person < play.circle.people; person++) {
      final at = metrics.faceAt(person);
      final isHeart =
          play.isDone && degrees[person] == play.circle.people - 1;
      canvas.drawCircle(at, face, Paint()..color = Palette.face);
      canvas.drawCircle(
        at,
        face,
        Paint()
          ..color = isHeart ? Palette.heart : Palette.faceRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHeart ? 3.4 : 1.8,
      );
      // Two eyes and a smile.
      for (final side in [-1, 1]) {
        canvas.drawCircle(
          at + Offset(side * face * 0.32, -face * 0.18),
          face * 0.09,
          Paint()..color = Palette.night,
        );
      }
      canvas.drawArc(
        Rect.fromCenter(
            center: at + Offset(0, face * 0.12),
            width: face * 0.8,
            height: face * 0.62),
        math.pi * 0.15,
        math.pi * 0.7,
        false,
        Paint()
          ..color = Palette.night
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(face * 0.08, 1.6)
          ..strokeCap = StrokeCap.round,
      );
      if (isHeart) {
        final crownBase = at + Offset(0, -face * 1.4);
        final wide = face * 0.5;
        canvas.drawPath(
          Path()
            ..moveTo(crownBase.dx - wide, crownBase.dy + face * 0.24)
            ..lineTo(crownBase.dx - wide, crownBase.dy - face * 0.12)
            ..lineTo(crownBase.dx - wide * 0.33, crownBase.dy + face * 0.04)
            ..lineTo(crownBase.dx, crownBase.dy - face * 0.3)
            ..lineTo(crownBase.dx + wide * 0.33, crownBase.dy + face * 0.04)
            ..lineTo(crownBase.dx + wide, crownBase.dy - face * 0.12)
            ..lineTo(crownBase.dx + wide, crownBase.dy + face * 0.24)
            ..close(),
          Paint()..color = Palette.heart,
        );
      }

      // Each face's friend count, under the chin.
      final count = TextPainter(
        text: TextSpan(
          text: '${degrees[person]}',
          style: labels.copyWith(
            color: degrees[person].isOdd
                ? Palette.cross
                : Palette.inkDim,
            fontSize: face * 0.6,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      count.paint(
        canvas,
        at + Offset(-count.width / 2, face * 1.12),
      );
    }
  }

  @override
  bool shouldRepaint(DaisyView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  if (count < 1000000) {
    return '${count ~/ 1000},'
        '${(count % 1000).toString().padLeft(3, '0')}';
  }
  return '${count ~/ 1000000},'
      '${((count % 1000000) ~/ 1000).toString().padLeft(3, '0')},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the circle at hand.
String whyWords(Play play) {
  final circle = play.circle;
  final note = circle.note == null ? '' : ' ${circle.note}';
  final sweeps = {3: '8', 4: '64', 5: withComma(1024), 7: withComma(2097152)};
  if (!circle.winnable) {
    return 'Stand by anyone and look at their friends: each one '
        'pairs off with the single friend the two of you share, '
        'nobody pairing with themselves, so every friend count '
        'comes even. Four people cap the count at three, so '
        'even means exactly two, and everyone holding two '
        'friends makes a ring of four, where neighbours share '
        'no friend at all. The sweep wired all '
        '${sweeps[4]} circles of four and none lands.$note';
  }
  return 'The circle is read two ways that share nothing: the '
      'census counts every pair\'s common friends one by one, and '
      'the daisy count multiplies hearts by pairings with no '
      'searching in it. The sweep wires all '
      '${sweeps[circle.people]} circles and the two counts agree: '
      'every landing is a daisy with somebody at its heart. '
      '${circle.ways} wiring${circle.ways == 1 ? '' : 's'} '
      'land${circle.ways == 1 ? 's' : ''} this circle.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import 'palette.dart';

/// Where every bird and every arrow lies, shared by the painter and
/// the hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.46);
    round = math.min(room.width, room.height) * 0.36;
    chip = math.min(round * 0.32, 34.0);
  }

  final Play play;

  late final Offset middle;
  late final double round;
  late final double chip;

  /// Where a bird stands, first bird at the top.
  Offset birdAt(int bird) {
    final turn =
        -math.pi / 2 + bird * 2 * math.pi / play.yard.birds;
    return middle + Offset(math.cos(turn), math.sin(turn)) * round;
  }

  /// The bow of an arrow's arc, at its middle.
  Offset arcMid(int at) {
    final (one, two) = Rules.pairs(play.yard.birds)[at];
    final from = birdAt(one);
    final to = birdAt(two);
    final flat = Offset.lerp(from, to, 0.5)!;
    final way = to - from;
    final side = Offset(-way.dy, way.dx) / way.distance;
    return flat + side * chip * 0.9;
  }

  /// The arrow under a touch, or null: its pair index.
  int? arrowUnder(Offset touch) {
    final count = Rules.pairs(play.yard.birds).length;
    int? best;
    var bestFar = chip * 1.35;
    for (var at = 0; at < count; at++) {
      final far = (arcMid(at) - touch).distance;
      if (far < bestFar) {
        bestFar = far;
        best = at;
      }
    }
    return best;
  }
}

/// The yard, drawn.
class YardView extends CustomPainter {
  YardView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The arrow being pointed at, or null: its pair index.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pairs = Rules.pairs(play.yard.birds);
    final kings = play.kings;

    for (var at = 0; at < pairs.length; at++) {
      _arrow(canvas, metrics, at, lit: at == pointing);
    }

    for (var bird = 0; bird < play.yard.birds; bird++) {
      _hen(canvas, metrics, bird,
          crowned: kings.contains(bird),
          bantam: play.yard.wantOnly != null &&
              bird == play.yard.birds - 1);
    }
  }

  void _arrow(Canvas canvas, Metrics metrics, int at,
      {required bool lit}) {
    final (one, two) = Rules.pairs(play.yard.birds)[at];
    final pecksOneTwo = play.pecksOf(one, two);
    final from = metrics.birdAt(pecksOneTwo ? one : two);
    final to = metrics.birdAt(pecksOneTwo ? two : one);
    final mid = metrics.arcMid(at);

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(
          2 * mid.dx - (from.dx + to.dx) / 2,
          2 * mid.dy - (from.dy + to.dy) / 2,
          to.dx,
          to.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = lit ? Palette.shown : Palette.arrow
        ..style = PaintingStyle.stroke
        ..strokeWidth = lit ? 3.2 : 2.2,
    );

    // The head, part-way along, pointing at the pecked.
    final metric = path.computeMetrics().first;
    final headAt = metric.getTangentForOffset(metric.length * 0.68)!;
    final head = headAt.position;
    final way = headAt.vector;
    final side = Offset(-way.dy, way.dx);
    final tip = Path()
      ..moveTo(head.dx + way.dx * metrics.chip * 0.34,
          head.dy + way.dy * metrics.chip * 0.34)
      ..lineTo(head.dx + side.dx * metrics.chip * 0.16,
          head.dy + side.dy * metrics.chip * 0.16)
      ..lineTo(head.dx - side.dx * metrics.chip * 0.16,
          head.dy - side.dy * metrics.chip * 0.16)
      ..close();
    canvas.drawPath(
        tip, Paint()..color = lit ? Palette.shown : Palette.arrow);
  }

  void _hen(Canvas canvas, Metrics metrics, int bird,
      {required bool crowned, required bool bantam}) {
    final stand = metrics.birdAt(bird);
    final body = metrics.chip * (bantam ? 0.8 : 1.0);

    // The body, the head, the beak, the comb.
    canvas.drawOval(
      Rect.fromCenter(
          center: stand.translate(0, body * 0.12),
          width: body * 1.7,
          height: body * 1.35),
      Paint()..color = Palette.hen,
    );
    final headAt = stand.translate(body * 0.62, -body * 0.5);
    canvas.drawCircle(headAt, body * 0.42, Paint()..color = Palette.hen);
    final beak = Path()
      ..moveTo(headAt.dx + body * 0.36, headAt.dy - body * 0.1)
      ..lineTo(headAt.dx + body * 0.72, headAt.dy + body * 0.04)
      ..lineTo(headAt.dx + body * 0.34, headAt.dy + body * 0.18)
      ..close();
    canvas.drawPath(beak, Paint()..color = Palette.beak);
    for (final lean in const [-0.16, 0.04, 0.24]) {
      canvas.drawCircle(
        headAt.translate(body * lean, -body * 0.4),
        body * 0.11,
        Paint()..color = Palette.comb,
      );
    }
    canvas.drawCircle(
        headAt.translate(body * 0.1, -body * 0.06),
        body * 0.07,
        Paint()..color = Palette.henDark);

    // The tail.
    final tail = Path()
      ..moveTo(stand.dx - body * 0.72, stand.dy + body * 0.1)
      ..quadraticBezierTo(stand.dx - body * 1.15, stand.dy - body * 0.5,
          stand.dx - body * 0.6, stand.dy - body * 0.42)
      ..close();
    canvas.drawPath(tail, Paint()..color = Palette.henDark);

    if (crowned) {
      final browY = headAt.dy - body * 0.62;
      final crown = Path()..moveTo(headAt.dx - body * 0.34, browY);
      for (final (dx, rise) in const [
        (-0.34, 0.0),
        (-0.2, 0.42),
        (-0.06, 0.1),
        (0.08, 0.46),
        (0.22, 0.1),
        (0.34, 0.42),
        (0.42, 0.0),
      ]) {
        crown.lineTo(headAt.dx + body * dx, browY - body * rise);
      }
      crown.close();
      canvas.drawPath(crown, Paint()..color = Palette.crown);
    }

    final words = TextPainter(
      text: TextSpan(
        text: bantam ? 'bantam' : '${bird + 1}',
        style: labels.copyWith(
          color: Palette.inkDim,
          fontSize: metrics.chip * 0.42,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      stand.translate(-words.width / 2, body * 0.95),
    );
  }

  @override
  bool shouldRepaint(YardView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the yard at hand.
String whyWords(Play play) {
  final yard = play.yard;
  final note = yard.note == null ? '' : ' ${yard.note}';
  final yards = 1 << Rules.pairs(yard.birds).length;
  if (!yard.winnable) {
    return 'Every yard has a king, and a second crown always drags '
        'a third: any king\'s peckers hide another king among '
        'themselves. So no yard crowns exactly two, and the sweep '
        'of all $yards yards of ${yard.birds} birds finds none.'
        '$note';
  }
  return 'A king reaches every bird in a peck or a peck-of-a-peck, '
      'and every yard has one: the biggest winner is always a king, '
      'for whatever pecked it was pecked by something it pecked. '
      '${yard.task[0].toUpperCase()}${yard.task.substring(1)} takes '
      '${yard.par} flip${yard.par == 1 ? '' : 's'} at fewest, and '
      'the sweep of all $yards yards of ${yard.birds} birds stands '
      'behind the count.$note';
}

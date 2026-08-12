import 'package:flutter/material.dart';

import '../ford/play.dart';
import 'palette.dart';

/// Where the stream and its circles lie, shared by the painter and
/// the tests.
class Metrics {
  Metrics(this.play, Size room) {
    left = room.width * 0.06;
    right = room.width * 0.94;
    waterY = room.height * 0.66;
    reach = room.height * 0.3;
  }

  final Play play;

  late final double left;
  late final double right;
  late final double waterY;

  /// The radius a depth-one ford's circle would take.
  late final double reach;

  /// How far across the stream a ford sits.
  double across(int p, int q) => left + (right - left) * p / q;

  /// A ford's circle, resting on the water.
  ({Offset middle, double radius}) circleOf(int p, int q) {
    final radius = reach / (q * q);
    return (
      middle: Offset(across(p, q), waterY - radius),
      radius: radius,
    );
  }
}

/// The stream, drawn.
class FordView extends CustomPainter {
  FordView({required this.play, this.crossLit = false, required this.labels});

  final Play play;

  /// Whether the stone is being pointed at as the crossing.
  final bool crossLit;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The water.
    canvas.drawRect(
      Rect.fromLTRB(0, metrics.waterY, size.width, size.height),
      Paint()..color = Palette.water,
    );
    canvas.drawLine(
      Offset(0, metrics.waterY),
      Offset(size.width, metrics.waterY),
      Paint()
        ..color = Palette.waterLine
        ..strokeWidth = 2.0,
    );

    // The banks' circles, kissing while the crossing number holds.
    _ford(canvas, metrics, play.bankA.$1, play.bankA.$2,
        color: Palette.ring, label: true);
    _ford(canvas, metrics, play.bankC.$1, play.bankC.$2,
        color: Palette.ring, label: true);

    // The stone between them.
    final (sp, sq) = play.stone;
    _ford(canvas, metrics, sp, sq,
        color: crossLit ? Palette.shown : Palette.stone,
        label: true,
        stone: true);

    // The ford asked for, flagged on the far side of the water.
    final target = play.reach.target;
    if (target != null) {
      final at = metrics.across(target.$1, target.$2);
      canvas.drawLine(
        Offset(at, metrics.waterY + 8),
        Offset(at, metrics.waterY + 42),
        Paint()
          ..color = Palette.flag
          ..strokeWidth = 2.4,
      );
      final pennant = Path()
        ..moveTo(at, metrics.waterY + 8)
        ..lineTo(at + 26, metrics.waterY + 15)
        ..lineTo(at, metrics.waterY + 22)
        ..close();
      canvas.drawPath(pennant, Paint()..color = Palette.flag);
      _words(canvas, '${target.$1}/${target.$2}',
          Offset(at, metrics.waterY + 52), Palette.flag,
          metrics.reach * 0.085);
    }
  }

  void _ford(Canvas canvas, Metrics metrics, int p, int q,
      {required Color color, bool label = false, bool stone = false}) {
    final circle = metrics.circleOf(p, q);
    canvas.drawCircle(
      circle.middle,
      circle.radius,
      Paint()
        ..color = color.withValues(alpha: stone ? 0.28 : 0.14),
    );
    canvas.drawCircle(
      circle.middle,
      circle.radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stone ? 2.6 : 1.8,
    );
    if (stone) {
      // The stepping stone itself, on the water.
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(circle.middle.dx, metrics.waterY),
          width: metrics.reach * 0.22,
          height: metrics.reach * 0.09,
        ),
        Paint()..color = color,
      );
    }
    if (label) {
      // The stone's own label goes into the water beside it, clear
      // of the bank labels crowding the surface.
      final at = stone
          ? Offset(circle.middle.dx - metrics.reach * 0.2,
              metrics.waterY + metrics.reach * 0.07)
          : Offset(circle.middle.dx,
              metrics.waterY - circle.radius * 2 - metrics.reach * 0.16);
      _words(canvas, '$p/$q', at, stone ? color : Palette.inkDim,
          metrics.reach * 0.095);
    }
  }

  void _words(Canvas canvas, String words, Offset at, Color color,
      double size) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, 0));
  }

  @override
  bool shouldRepaint(FordView old) =>
      old.play != play || old.crossLit != crossLit;
}

/// The words the why speaks, from the reach at hand.
String whyWords(Play play) {
  final reach = play.reach;
  final note = reach.note == null ? '' : ' ${reach.note}';
  if (!reach.winnable) {
    return 'Take any ford strictly between two kissing banks and '
        'multiply the gaps out: its depth comes to at least the '
        'banks\' depths put together. Between the half and the two '
        'thirds that is five, so nothing shallower than fifths ever '
        'crosses; the sweep says the same on all 43 kissing pairs '
        'of the stream to depth eight, the one shallowest ford '
        'between each being the mediant itself.$note';
  }
  return 'The stone is always the banks\' mediant, and the crossing '
      'number bc - ad holds at one down every wade: one is exactly '
      'when two fords\' circles kiss, checked on all 253 pairs of '
      'the stream to depth eight, so the banks\' circles never '
      'part. Between kissing banks the one shallowest ford is the '
      'mediant, and the walk lands ${reach.target!.$1}/'
      '${reach.target!.$2} in ${reach.wades} '
      'wade${reach.wades == 1 ? '' : 's'}.$note';
}

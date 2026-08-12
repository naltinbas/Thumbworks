import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../beam/play.dart';
import '../beam/rules.dart';
import 'palette.dart';

/// Where every weight hangs, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(Size room) {
    slot = math.min(room.width * 0.92 / 6, room.height * 0.2);
    left = (room.width - slot * 6) / 2;
    rackTop = room.height * 0.08;
    beamMiddle = Offset(room.width / 2, room.height * 0.66);
    beamSpan = math.min(room.width * 0.4, slot * 2.6);
  }

  late final double slot;
  late final double left;
  late final double rackTop;
  late final Offset beamMiddle;
  late final double beamSpan;

  /// The middle of a weight's rack seat, two rows of six.
  Offset weightAt(int weight) {
    final at = Rules.rack.indexOf(weight);
    final row = at ~/ 6;
    final place = at % 6;
    return Offset(
      left + (place + 0.5) * slot,
      rackTop + slot * (0.5 + row * 1.1),
    );
  }

  /// The weight under a touch, or -1.
  int weightUnder(Offset touch) {
    for (final weight in Rules.rack) {
      if ((weightAt(weight) - touch).distance <= slot * 0.46) {
        return weight;
      }
    }
    return -1;
  }
}

/// The yard, drawn: the rack above, the balance beam below.
class BeamView extends CustomPainter {
  BeamView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The weight the show-me points at, or null.
  final (int, bool)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  void _weight(Canvas canvas, Offset middle, double slot, int worth,
      {required Color coat, required Color rim, double rimWidth = 1.6}) {
    final body = Path()
      ..moveTo(middle.dx - slot * 0.3, middle.dy + slot * 0.32)
      ..lineTo(middle.dx + slot * 0.3, middle.dy + slot * 0.32)
      ..lineTo(middle.dx + slot * 0.2, middle.dy - slot * 0.18)
      ..lineTo(middle.dx + slot * 0.07, middle.dy - slot * 0.18)
      ..arcTo(
          Rect.fromCircle(
              center: middle - Offset(0, slot * 0.22),
              radius: slot * 0.09),
          0.3,
          math.pi - 0.6,
          false)
      ..lineTo(middle.dx - slot * 0.2, middle.dy - slot * 0.18)
      ..close();
    canvas.drawPath(body, Paint()..color = coat);
    canvas.drawPath(
      body,
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimWidth,
    );
    if (showWords) {
      final words = TextPainter(
        text: TextSpan(
          text: '$worth',
          style: labels.copyWith(
            color: Palette.weightInk,
            fontSize: slot * 0.24,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(canvas,
          middle + Offset(-words.width / 2, slot * 0.0));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(size);

    // The rack.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          metrics.left - metrics.slot * 0.15,
          metrics.rackTop - metrics.slot * 0.15,
          metrics.slot * 6.3,
          metrics.slot * 2.35,
        ),
        Radius.circular(metrics.slot * 0.12),
      ),
      Paint()
        ..color = Palette.rackWood.withValues(alpha: 0.3),
    );

    for (final weight in Rules.rack) {
      final chosen = play.chosen.contains(weight);
      _weight(
        canvas,
        metrics.weightAt(weight),
        metrics.slot,
        weight,
        coat: chosen ? Palette.weightChosen : Palette.weight,
        rim: pointing?.$1 == weight
            ? Palette.shown
            : chosen
                ? Palette.ink
                : Palette.night.withValues(alpha: 0.5),
        rimWidth: pointing?.$1 == weight || chosen ? 2.6 : 1.2,
      );
    }

    // The beam, when a balance stands.
    final clash = play.balanced;
    if (clash != null) {
      final (leftSide, rightSide) = clash;
      final beam = Paint()
        ..color = Palette.beam
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
      // The post and the level beam: level is the accusation.
      canvas.drawLine(
        metrics.beamMiddle + Offset(0, metrics.slot * 0.9),
        metrics.beamMiddle,
        beam,
      );
      canvas.drawLine(
        metrics.beamMiddle - Offset(metrics.beamSpan, 0),
        metrics.beamMiddle + Offset(metrics.beamSpan, 0),
        beam,
      );
      for (final (side, parcel) in [
        (-1, leftSide),
        (1, rightSide),
      ]) {
        final hang = metrics.beamMiddle +
            Offset(side * metrics.beamSpan * 0.8, 0);
        canvas.drawLine(
          hang,
          hang + Offset(0, metrics.slot * 0.4),
          Paint()
            ..color = Palette.clash
            ..strokeWidth = 2.4,
        );
        var at = 0;
        for (final weight in parcel) {
          _weight(
            canvas,
            hang +
                Offset(
                  0,
                  metrics.slot * (0.75 + at * 0.62),
                ),
            metrics.slot * 0.8,
            weight,
            coat: Palette.weightChosen,
            rim: Palette.clash,
            rimWidth: 2.2,
          );
          at++;
        }
      }
    }
  }

  @override
  bool shouldRepaint(BeamView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the worth at hand.
String whyWords(Play play) {
  final worth = play.worth;
  final note = worth.note == null ? '' : ' ${worth.note}';
  if (!worth.winnable) {
    return 'Counting bars the seventh weight: seven weights '
        'make 127 parcels with something in them, no seven of '
        'this rack weigh past 125 pounds together, and 127 '
        'parcels cannot take 125 readings without two sharing. '
        'The sweep tried all 792 choices of seven and hung the '
        'beam level in every one.$note';
  }
  return 'The balance hunts every pair of parcels for a shared '
      'reading and strips the shared weights before it accuses, '
      'and the sweep tries every choice of ${worth.choose} from '
      'the rack: ${worth.ways} come clean.$note';
}

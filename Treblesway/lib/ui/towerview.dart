import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ring/play.dart';
import '../ring/tower.dart';
import 'palette.dart';

/// Where the bells and the trail of rows are.
///
/// The painter and the finger both use this, which is the point of it. The
/// changes themselves are buttons below the glass, so the painter's job is
/// the bells sounding now and the rows already rung.
class Metrics {
  Metrics(this.play, Size room) {
    this.room = room;
    bellY = room.height * 0.16;
    bell = math.min(room.width / (play.tower.bells * 2.4), 44);
    trailTop = room.height * 0.34;
    trailGap = math.min(room.height * 0.052, 30);
  }

  final Play play;
  late final Size room;

  late final double bellY;
  late final double bell;
  late final double trailTop;
  late final double trailGap;

  Offset bellAt(int place) => Offset(
        room.width * (place + 0.5) / play.tower.bells,
        bellY,
      );
}

/// The chamber: the bells in their present order, and the rows rung so far.
class TowerView extends CustomPainter {
  const TowerView({
    required this.play,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the bells.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final row = play.at;

    // The bells, in the order they sound now, heaviest drawn largest.
    for (var place = 0; place < play.tower.bells; place++) {
      final bell = row[place];
      final middle = metrics.bellAt(place);
      final size = metrics.bell * (0.72 + 0.28 * bell / (play.tower.bells - 1));

      // The bell: a shouldered dome with a lip.
      final path = Path()
        ..moveTo(middle.dx - size, middle.dy + size * 0.8)
        ..quadraticBezierTo(middle.dx - size * 0.9, middle.dy - size * 0.5,
            middle.dx - size * 0.35, middle.dy - size * 0.85)
        ..quadraticBezierTo(middle.dx, middle.dy - size * 1.05,
            middle.dx + size * 0.35, middle.dy - size * 0.85)
        ..quadraticBezierTo(middle.dx + size * 0.9, middle.dy - size * 0.5,
            middle.dx + size, middle.dy + size * 0.8)
        ..close();
      canvas.drawPath(path, Paint()..color = Palette.bell);
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.bronze
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );
      canvas.drawCircle(
        middle + Offset(0, size * 0.55),
        size * 0.16,
        Paint()..color = Palette.night,
      );

      if (!showWords) continue;
      final name = TextPainter(
        text: TextSpan(
          text: '${bell + 1}',
          style: labels.copyWith(
            color: Palette.ink,
            fontSize: size * 0.6,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      name.paint(
        canvas,
        middle - Offset(name.width / 2, size * 0.35),
      );
    }

    if (!showWords) return;

    // The trail: every row rung, latest at the top, fading down.
    final rows = <BellRow>[
      for (final pull in play.done.reversed) pull.row,
      play.tower.rounds,
    ];
    final fit = ((size.height - metrics.trailTop) / metrics.trailGap).floor();
    for (var at = 0; at < rows.length && at < fit; at++) {
      final spoken = Tower.spoken(rows[at]);
      final fade = at == 0 ? 1.0 : math.max(0.25, 1.0 - at * 0.09);
      final words = TextPainter(
        text: TextSpan(
          text: spoken,
          style: labels.copyWith(
            color: at == 0
                ? Palette.bronze
                : Palette.sounded.withValues(alpha: fade),
            fontSize: at == 0 ? 22 : 17,
            fontWeight: at == 0 ? FontWeight.w800 : FontWeight.w500,
            letterSpacing: 6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        Offset(
          (size.width - words.width) / 2,
          metrics.trailTop + at * metrics.trailGap,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(TowerView old) => old.play != play;
}

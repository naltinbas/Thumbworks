import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../clink/play.dart';
import 'palette.dart';

/// Where every guest sits, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height / 2);
    ring = math.min(room.width, room.height) * 0.36;
    face = ring * (play.feast.guests > 4 ? 0.19 : 0.22);
  }

  final Play play;

  late final Offset middle;
  late final double ring;
  late final double face;

  /// The middle of a face, the first at the top.
  Offset faceAt(int guest) {
    final turn =
        -math.pi / 2 + 2 * math.pi * guest / play.feast.guests;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// Both ends of a pair's wire, trimmed clear of the faces.
  (Offset, Offset) wireOf(int pair) {
    final (a, b) = play.rules.pairs[pair];
    final from = faceAt(a);
    final to = faceAt(b);
    final way = (to - from) / (to - from).distance;
    return (from + way * face * 1.4, to - way * face * 1.4);
  }

  /// A tap-worthy point of a pair's wire, staggered along it
  /// so crossing wires never share it.
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

/// The feast, drawn: wires faint till clinked, faces, and each
/// guest's count badge in its count's own tint.
class ClinkView extends CustomPainter {
  ClinkView({
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
    final counts = play.counts;

    // Every wire, faint till clinked.
    for (var pair = 0; pair < play.rules.pairs.length; pair++) {
      final (from, to) = metrics.wireOf(pair);
      final held = play.clinked[pair];
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = held ? Palette.wire : Palette.faint
          ..strokeWidth = held
              ? math.max(face * 0.18, 3.2)
              : math.max(face * 0.07, 1.6)
          ..strokeCap = StrokeCap.round,
      );
      if (pointing == pair) {
        canvas.drawCircle(
          metrics.midOf(pair),
          face * 0.6,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The faces and their badges.
    for (var guest = 0; guest < play.feast.guests; guest++) {
      final at = metrics.faceAt(guest);
      canvas.drawCircle(at, face, Paint()..color = Palette.face);
      canvas.drawCircle(
        at,
        face,
        Paint()
          ..color = Palette.faceRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      for (final side in [-1, 1]) {
        canvas.drawCircle(
          at + Offset(side * face * 0.3, -face * 0.16),
          face * 0.08,
          Paint()..color = Palette.night,
        );
      }
      canvas.drawArc(
        Rect.fromCenter(
            center: at + Offset(0, face * 0.14),
            width: face * 0.74,
            height: face * 0.56),
        math.pi * 0.15,
        math.pi * 0.7,
        false,
        Paint()
          ..color = Palette.night
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(face * 0.07, 1.4)
          ..strokeCap = StrokeCap.round,
      );

      // The count badge, tinted by the count itself.
      final count = counts[guest];
      final badgeAt = at + Offset(0, face * 1.42);
      canvas.drawCircle(
        badgeAt,
        face * 0.4,
        Paint()..color = Palette.tints[count % Palette.tints.length],
      );
      final wear = TextPainter(
        text: TextSpan(
          text: '$count',
          style: labels.copyWith(
            color: Palette.night,
            fontSize: face * 0.48,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      wear.paint(
          canvas, badgeAt - Offset(wear.width / 2, wear.height / 2));
    }
  }

  @override
  bool shouldRepaint(ClinkView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the feast at hand.
String whyWords(Play play) {
  final feast = play.feast;
  final note = feast.note == null ? '' : ' ${feast.note}';
  final sweep = feast.guests == 4 ? '64' : withComma(1024);
  if (!feast.winnable) {
    return 'Five different counts among nought to four must use '
        'every one of them: somebody clinked nobody, and somebody '
        'clinked all four others. But the toast of the table '
        'clinked the wallflower too, and the wallflower clinked '
        'nobody at all: the two cannot share a feast. The sweep '
        'raised all $sweep feasts of five and the counts never '
        'once all differed.$note';
  }
  return 'The counts are read two ways that share nothing: the '
      'census tallies each guest wire by wire, badges tinted so '
      'alike counts look alike, and the sweep raises all $sweep '
      'feasts of the table and holds the wallflower law on every '
      'one. ${withComma(feast.ways)} '
      'feast${feast.ways == 1 ? '' : 's'} '
      'land${feast.ways == 1 ? 's' : ''} this asking.$note';
}

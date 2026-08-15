import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mere/play.dart';
import '../mere/rules.dart';
import 'palette.dart';

/// Where the spots lie on the board, so the screen and the tests
/// can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    side = play.rules.side;
    pitch = math.min(room.width, room.height) * 0.86 / side;
    origin = Offset(
      (room.width - pitch * side) / 2,
      (room.height - pitch * side) / 2,
    );
  }

  final Play play;

  late final int side;
  late final double pitch;
  late final Offset origin;

  Offset at(Spot spot) => Offset(
        origin.dx + (spot.$1 + 0.5) * pitch,
        origin.dy + (spot.$2 + 0.5) * pitch,
      );

  /// The spot under a touch, or null off the mere.
  Spot? under(Offset touch) {
    final x = ((touch.dx - origin.dx) / pitch).floor();
    final y = ((touch.dy - origin.dy) / pitch).floor();
    if (x < 0 || x >= side || y < 0 || y >= side) return null;
    return (x, y);
  }
}

/// The mere itself: spots and lanterns, the next turn shown on top,
/// what will light ringed and what will go out crossed, each lit
/// lantern wearing its count of lit neighbours.
class MereView extends CustomPainter {
  MereView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Spot)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;
    final side = metrics.side;

    // The water.
    final water = Rect.fromLTWH(metrics.origin.dx, metrics.origin.dy, pitch * side, pitch * side);
    canvas.drawRRect(
      RRect.fromRectAndRadius(water.inflate(pitch * 0.12), Radius.circular(pitch * 0.2)),
      Paint()..color = Palette.water,
    );
    if (play.still && play.lit.isNotEmpty) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(water.inflate(pitch * 0.12), Radius.circular(pitch * 0.2)),
        Paint()
          ..color = Palette.still
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.04),
      );
    }

    final births = play.births;
    final deaths = play.deaths;
    for (final spot in play.rules.spots) {
      final at = metrics.at(spot);
      canvas.drawCircle(at, pitch * 0.4, Paint()..color = Palette.spot);
      canvas.drawCircle(
        at,
        pitch * 0.4,
        Paint()
          ..color = Palette.spotRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      if (play.lit.contains(spot)) {
        canvas.drawCircle(at, pitch * 0.42, Paint()..color = Palette.glow.withValues(alpha: 0.18));
        canvas.drawCircle(at, pitch * 0.3, Paint()..color = Palette.lit);
        _write(
          canvas,
          '${Rules.litRound(play.lit, spot)}',
          at,
          labels.copyWith(color: Palette.litInk, fontSize: pitch * 0.32, fontWeight: FontWeight.w800),
        );
        if (deaths.contains(spot)) {
          final cross = Paint()
            ..color = Palette.willGoOut
            ..strokeWidth = math.max(2, pitch * 0.06)
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(at + Offset(-pitch * 0.34, -pitch * 0.34), at + Offset(pitch * 0.34, pitch * 0.34), cross);
          canvas.drawLine(at + Offset(pitch * 0.34, -pitch * 0.34), at + Offset(-pitch * 0.34, pitch * 0.34), cross);
        }
      } else if (births.contains(spot)) {
        canvas.drawCircle(
          at,
          pitch * 0.3,
          Paint()
            ..color = Palette.willLight
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, pitch * 0.06),
        );
        _write(
          canvas,
          '3',
          at,
          labels.copyWith(color: Palette.willLight, fontSize: pitch * 0.28, fontWeight: FontWeight.w700),
        );
      }
    }
    // Births off the mere, shown as rings at the edge.
    for (final spot in births) {
      if (spot.$1 >= 0 && spot.$1 < side && spot.$2 >= 0 && spot.$2 < side) continue;
      final at = metrics.at(spot);
      canvas.drawCircle(
        at,
        pitch * 0.22,
        Paint()
          ..color = Palette.willLight
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, pitch * 0.04),
      );
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        metrics.at(aim.$2),
        pitch * 0.46,
        Paint()
          ..color = aim.$1 == 'douse' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(MereView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a lighting as it stands.
String whyWords(Play play) {
  final lighting = play.lighting;
  final note = lighting.note == null ? '' : ' ${lighting.note}';
  if (!lighting.winnable) {
    return 'A lit lantern stays lit only with two or three lit '
        'neighbours, and with three lanterns in all each has at most '
        'two others, so every one must touch both others: three lanterns '
        'in one corner of a two-by-two square. Then the fourth corner of '
        'that square touches all three, and an unlit spot with three lit '
        'neighbours lights. So something always changes. The sweep set '
        'every three lanterns on the mere and found no still '
        'picture.$note';
  }
  return 'The lightings are counted by the sweep, every way of lighting '
      'that many lanterns on the mere, the rule run on the whole plane so '
      'a light at the edge can wake a spot beyond it, and held to a second '
      'voice: the shapes, each lighting slid to the corner and counted '
      'once, so the block and the tub are seen to be the only fours and '
      'the boat the only five. ${lighting.ways} lightings lie still, '
      '${lighting.shapes} shape${lighting.shapes == 1 ? '' : 's'}.$note';
}

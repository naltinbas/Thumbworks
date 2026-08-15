import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../moor/play.dart';
import '../moor/rules.dart';
import 'palette.dart';

/// Where the holes lie on the board, so the screen and the tests can
/// find every one.
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

  Offset at(Peg peg) => Offset(
        origin.dx + (peg.$1 + 0.5) * pitch,
        origin.dy + (peg.$2 + 0.5) * pitch,
      );

  /// A doubled point's place.
  Offset atDoubled((int, int) d) => Offset(
        origin.dx + (d.$1 / 2 + 0.5) * pitch,
        origin.dy + (d.$2 / 2 + 0.5) * pitch,
      );

  /// The hole under a touch, or null off the moor.
  Peg? under(Offset touch) {
    final x = ((touch.dx - origin.dx) / pitch).floor();
    final y = ((touch.dy - origin.dy) / pitch).floor();
    if (x < 0 || x >= side || y < 0 || y >= side) return null;
    return (x, y);
  }
}

/// The moor itself: holes tinted by kind, pegs, a faint cord between
/// every two pegs, and the halfway post on each cord, green on a hole
/// and rust between holes.
class MoorView extends CustomPainter {
  MoorView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Peg)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;
    final side = metrics.side;

    // The moor and its holes, tinted by kind.
    final moor = Rect.fromLTWH(metrics.origin.dx, metrics.origin.dy, pitch * side, pitch * side);
    canvas.drawRRect(
      RRect.fromRectAndRadius(moor.inflate(pitch * 0.12), Radius.circular(pitch * 0.2)),
      Paint()..color = Palette.moor,
    );
    for (final hole in play.rules.holes) {
      final rect = Rect.fromCenter(center: metrics.at(hole), width: pitch, height: pitch).deflate(pitch * 0.06);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.14)),
        Paint()..color = Palette.kinds[Rules.kindOf(hole)],
      );
      canvas.drawCircle(metrics.at(hole), pitch * 0.08, Paint()..color = Palette.night);
    }

    // The cords, then every halfway post: green on a hole, rust
    // between holes. Two posts on one spot are drawn nested, so
    // there are as many rings as posts.
    final pegs = play.pegs;
    final posts = <(int, int), int>{};
    for (var i = 0; i < pegs.length; i++) {
      for (var j = i + 1; j < pegs.length; j++) {
        canvas.drawLine(metrics.at(pegs[i]), metrics.at(pegs[j]), Paint()
          ..color = Palette.cord.withValues(alpha: 0.35)
          ..strokeWidth = math.max(1, pitch * 0.02));
        final spot = Rules.postDoubled(pegs[i], pegs[j]);
        posts[spot] = (posts[spot] ?? 0) + 1;
      }
    }
    final stroke = math.max(1.5, pitch * 0.03);
    for (final spot in posts.keys) {
      final at = metrics.atDoubled(spot);
      final lands = spot.$1.isEven && spot.$2.isEven;
      final pegged = lands && pegs.contains((spot.$1 ~/ 2, spot.$2 ~/ 2));
      final count = posts[spot]!;
      if (lands) {
        final paint = Paint()
          ..color = Palette.landed
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke;
        if (!pegged) canvas.drawCircle(at, pitch * 0.17, Paint()..color = Palette.landed);
        if (!pegged) {
          for (var k = 0; k < count; k++) {
            canvas.drawCircle(at, pitch * (0.24 + 0.06 * k), paint);
          }
        }
      } else {
        for (var k = 0; k < count; k++) {
          final d = pitch * (0.11 + 0.06 * k);
          final path = Path()
            ..moveTo(at.dx, at.dy - d)
            ..lineTo(at.dx + d, at.dy)
            ..lineTo(at.dx, at.dy + d)
            ..lineTo(at.dx - d, at.dy)
            ..close();
          canvas.drawPath(path, Paint()
            ..color = Palette.between
            ..style = k == 0 ? PaintingStyle.fill : PaintingStyle.stroke
            ..strokeWidth = stroke);
        }
      }
    }

    // The pegs.
    for (var i = 0; i < pegs.length; i++) {
      final at = metrics.at(pegs[i]);
      canvas.drawCircle(at, pitch * 0.26, Paint()..color = Palette.peg);
      _write(canvas, '${i + 1}', at,
          labels.copyWith(color: Palette.pegInk, fontSize: pitch * 0.28, fontWeight: FontWeight.w800));
    }

    // Rings round pegged posts sit over the pegs.
    for (final spot in posts.keys) {
      if (!(spot.$1.isEven && spot.$2.isEven)) continue;
      if (!pegs.contains((spot.$1 ~/ 2, spot.$2 ~/ 2))) continue;
      final at = metrics.atDoubled(spot);
      for (var k = 0; k < posts[spot]!; k++) {
        canvas.drawCircle(at, pitch * (0.33 + 0.06 * k), Paint()
          ..color = Palette.landed
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke);
      }
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        metrics.at(aim.$2),
        pitch * 0.36,
        Paint()
          ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
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
  bool shouldRepaint(MoorView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a pegging as it stands.
String whyWords(Play play) {
  final pegging = play.pegging;
  final note = pegging.note == null ? '' : ' ${pegging.note}';
  if (!pegging.winnable) {
    return 'Halfway between two whole numbers is whole only when both are '
        'even or both are odd. A hole is even or odd across and even or '
        'odd down, four kinds, and the moor is tinted by them. Five pegs '
        'in four kinds: two share a kind, so their halfway post is whole '
        'across and whole down, and lands on a hole. The sweep set every '
        'five on the moor and never found all ten posts off.$note';
  }
  return 'The placings are counted by the sweep, every way of setting the '
      'pegs on the moor, and every halfway post is read two ways that must '
      'agree: whether it lands, both sums even, and the count by kinds, '
      'pegs of a kind pairing off two by two. ${pegging.ways} '
      'placing${pegging.ways == 1 ? '' : 's'} land${pegging.ways == 1 ? 's' : ''} '
      'this pegging.$note';
}

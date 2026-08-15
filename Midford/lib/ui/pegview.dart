import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../peg/play.dart';
import '../peg/rules.dart';
import 'palette.dart';

/// Where the peg holes lie on the board, so the screen and the tests
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

  Offset at(Peg peg) => Offset(
        origin.dx + (peg.$1 + 0.5) * pitch,
        origin.dy + (peg.$2 + 0.5) * pitch,
      );

  /// A doubled midpoint's place.
  Offset atDoubled((int, int) m) => Offset(
        origin.dx + (m.$1 / 2 + 0.5) * pitch,
        origin.dy + (m.$2 / 2 + 0.5) * pitch,
      );

  /// The hole under a touch, or null off the board.
  Peg? under(Offset touch) {
    final x = ((touch.dx - origin.dx) / pitch).floor();
    final y = ((touch.dy - origin.dy) / pitch).floor();
    if (x < 0 || x >= side || y < 0 || y >= side) return null;
    return (x, y);
  }
}

/// The board itself: holes, pegs in order, the cords round them, the
/// diagonals faint, and the midpoint figure in gold.
class PegView extends CustomPainter {
  PegView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Peg)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;
    final side = metrics.side;

    // The wood and the holes.
    final wood = Rect.fromLTWH(metrics.origin.dx, metrics.origin.dy, pitch * side, pitch * side);
    canvas.drawRRect(
      RRect.fromRectAndRadius(wood.inflate(pitch * 0.12), Radius.circular(pitch * 0.2)),
      Paint()..color = Palette.wood,
    );
    for (final peg in play.rules.pegs) {
      canvas.drawCircle(metrics.at(peg), pitch * 0.09, Paint()..color = Palette.hole);
    }

    final pegs = play.pegs;
    // The cords round the pegs.
    final cord = Paint()
      ..color = Palette.cord
      ..strokeWidth = math.max(1.5, pitch * 0.04)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i + 1 < pegs.length; i++) {
      canvas.drawLine(metrics.at(pegs[i]), metrics.at(pegs[i + 1]), cord);
    }
    if (pegs.length == 4) {
      canvas.drawLine(metrics.at(pegs[3]), metrics.at(pegs[0]), cord);
      // The diagonals, faint and dashed.
      final diag = Paint()
        ..color = Palette.diagonal.withValues(alpha: 0.7)
        ..strokeWidth = math.max(1, pitch * 0.025);
      _dashed(canvas, metrics.at(pegs[0]), metrics.at(pegs[2]), diag, pitch * 0.14);
      _dashed(canvas, metrics.at(pegs[1]), metrics.at(pegs[3]), diag, pitch * 0.14);
      // The midpoint figure.
      final m = Rules.midpointsDoubled(pegs);
      final path = Path()..moveTo(metrics.atDoubled(m[0]).dx, metrics.atDoubled(m[0]).dy);
      for (var i = 1; i < 4; i++) {
        path.lineTo(metrics.atDoubled(m[i]).dx, metrics.atDoubled(m[i]).dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Palette.figure.withValues(alpha: 0.18));
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.figure
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05)
          ..strokeJoin = StrokeJoin.round,
      );
      for (final mid in m) {
        canvas.drawCircle(metrics.atDoubled(mid), pitch * 0.09, Paint()..color = Palette.midpoint);
      }
    } else if (pegs.length >= 2) {
      // Midpoints of the cords so far.
      for (var i = 0; i + 1 < pegs.length; i++) {
        final mid = (pegs[i].$1 + pegs[i + 1].$1, pegs[i].$2 + pegs[i + 1].$2);
        canvas.drawCircle(metrics.atDoubled(mid), pitch * 0.09, Paint()..color = Palette.midpoint);
      }
    }

    // The pegs, numbered in order.
    for (var i = 0; i < pegs.length; i++) {
      final at = metrics.at(pegs[i]);
      final given = play.isGiven(pegs[i]);
      canvas.drawCircle(at, pitch * 0.24, Paint()..color = given ? Palette.pegGiven : Palette.peg);
      _write(
        canvas,
        '${i + 1}',
        at,
        labels.copyWith(color: Palette.pegInk, fontSize: pitch * 0.28, fontWeight: FontWeight.w800),
      );
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        metrics.at(aim.$2),
        pitch * 0.34,
        Paint()
          ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint, double dash) {
    final length = (b - a).distance;
    if (length == 0) return;
    final dir = (b - a) / length;
    var at = 0.0;
    while (at < length) {
      final end = math.min(at + dash, length);
      canvas.drawLine(a + dir * at, a + dir * end, paint);
      at += dash * 2;
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
  bool shouldRepaint(PegView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a cording as it stands.
String whyWords(Play play) {
  final cording = play.cording;
  final note = cording.note == null ? '' : ' ${cording.note}';
  if (!cording.winnable) {
    return 'Take the cord from the first peg to the second and the cord '
        'from the second to the third: the line joining their midpoints '
        'runs half way along each, so it is half the diagonal from the '
        'first peg to the third, and parallel to it. The same for the '
        'cords on the other side. Two sides of the midpoint figure equal '
        'and parallel make a parallelogram, whatever the pegs. The sweep '
        'set every ordered four on the board, 303,600 of them, and read '
        'the figure off its own corners: a parallelogram every '
        'time.$note';
  }
  return 'The fours are counted by the sweep, every ordered four of pegs on '
      'the board, and every figure is read two ways that must agree: off '
      'the midpoints themselves, corner by corner, and off the diagonals '
      'of the pegs, which cross square for a rectangle and run of a '
      'length for a rhombus, by Varignon\'s halves. '
      '${cording.ways} four${cording.ways == 1 ? '' : 's'} land${cording.ways == 1 ? 's' : ''} '
      'this cording.$note';
}

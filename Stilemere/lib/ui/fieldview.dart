import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../field/play.dart';
import '../field/rules.dart';
import 'palette.dart';

/// Where the junctions lie on the board, so the screen and the tests
/// can find every one: the gate bottom left, the mill top right.
class Metrics {
  Metrics(this.play, Size room) {
    final f = play.field;
    pitch = math.min(room.width * 0.8 / f.width, room.height * 0.76 / f.height);
    left = (room.width - pitch * f.width) / 2 + room.width * 0.02;
    bottom = (room.height + pitch * f.height) / 2 - room.height * 0.02;
  }

  final Play play;

  late final double pitch;
  late final double left;
  late final double bottom;

  Offset at(Junction j) => Offset(left + j.$1 * pitch, bottom - j.$2 * pitch);

  /// The junction under a touch, or null off the field.
  Junction? under(Offset touch) {
    final x = ((touch.dx - left) / pitch).round();
    final y = ((bottom - touch.dy) / pitch).round();
    final j = (x, y);
    if (!play.field.inside(j)) return null;
    if ((touch - at(j)).distance > pitch * 0.45) return null;
    return j;
  }
}

/// The field: plots and hedges, the counts at every junction, the
/// stiles and ponds, the gate and the mill, and the walk trodden
/// so far.
class FieldView extends CustomPainter {
  FieldView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Junction)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final f = play.field;
    final pitch = m.pitch;

    // The plots.
    for (var x = 0; x < f.width; x++) {
      for (var y = 0; y < f.height; y++) {
        final tl = m.at((x, y + 1));
        canvas.drawRect(Rect.fromLTWH(tl.dx, tl.dy, pitch, pitch),
            Paint()..color = (x + y).isEven ? Palette.plot : Palette.plotDim);
      }
    }
    // The hedges.
    final hedge = Paint()
      ..color = Palette.hedge
      ..strokeWidth = math.max(3, pitch * 0.11)
      ..strokeCap = StrokeCap.round;
    for (var x = 0; x <= f.width; x++) {
      canvas.drawLine(m.at((x, 0)), m.at((x, f.height)), hedge);
    }
    for (var y = 0; y <= f.height; y++) {
      canvas.drawLine(m.at((0, y)), m.at((f.width, y)), hedge);
    }
    // The coordinates along the edges.
    final small = labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, pitch * 0.16));
    for (var x = 0; x <= f.width; x++) {
      _write(canvas, '$x', m.at((x, 0)) + Offset(0, pitch * 0.32), small);
    }
    for (var y = 0; y <= f.height; y++) {
      _write(canvas, '$y', m.at((0, y)) - Offset(pitch * 0.32, 0), small);
    }

    // The walk trodden so far.
    final walk = play.walk;
    if (walk.length > 1) {
      final path = Path()..moveTo(m.at(walk.first).dx, m.at(walk.first).dy);
      for (final j in walk.skip(1)) {
        path.lineTo(m.at(j).dx, m.at(j).dy);
      }
      canvas.drawPath(path, Paint()
        ..color = Palette.walk
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(4, pitch * 0.16)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round);
    }

    // The ponds.
    for (final p in f.ponds) {
      final at = m.at(p);
      canvas.drawOval(Rect.fromCenter(center: at, width: pitch * 0.62, height: pitch * 0.46), Paint()..color = Palette.pondDeep);
      canvas.drawOval(Rect.fromCenter(center: at + Offset(0, -pitch * 0.03), width: pitch * 0.5, height: pitch * 0.34),
          Paint()..color = Palette.pond);
    }
    // The stiles: two bars over the hedge, gold, green once passed.
    for (final s in f.stiles) {
      final at = m.at(s);
      final passed = walk.contains(s);
      final paint = Paint()
        ..color = passed ? Palette.stilePassed : Palette.stile
        ..strokeWidth = math.max(3, pitch * 0.09)
        ..strokeCap = StrokeCap.round;
      final w = pitch * 0.26, h = pitch * 0.2;
      canvas.drawLine(at + Offset(-w, -h * 0.35), at + Offset(w, -h * 0.35), paint);
      canvas.drawLine(at + Offset(-w, h * 0.35), at + Offset(w, h * 0.35), paint);
      canvas.drawLine(at + Offset(-w * 0.7, -h), at + Offset(-w * 0.7, h), paint);
      canvas.drawLine(at + Offset(w * 0.7, -h), at + Offset(w * 0.7, h), paint);
    }
    // The gate.
    final gate = m.at(f.gate);
    final gatePaint = Paint()
      ..color = Palette.walk
      ..strokeWidth = math.max(3, pitch * 0.09)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(gate + Offset(-pitch * 0.22, pitch * 0.2), gate + Offset(-pitch * 0.22, -pitch * 0.2), gatePaint);
    canvas.drawLine(gate + Offset(pitch * 0.22, pitch * 0.2), gate + Offset(pitch * 0.22, -pitch * 0.2), gatePaint);
    canvas.drawLine(gate + Offset(-pitch * 0.22, -pitch * 0.05), gate + Offset(pitch * 0.22, -pitch * 0.05), gatePaint);
    // The mill: a tower and four sails.
    final mill = m.at(f.mill);
    final tower = Path()
      ..moveTo(mill.dx - pitch * 0.14, mill.dy + pitch * 0.32)
      ..lineTo(mill.dx + pitch * 0.14, mill.dy + pitch * 0.32)
      ..lineTo(mill.dx + pitch * 0.09, mill.dy - pitch * 0.05)
      ..lineTo(mill.dx - pitch * 0.09, mill.dy - pitch * 0.05)
      ..close();
    canvas.drawPath(tower, Paint()..color = Palette.mill);
    final sails = Paint()
      ..color = Palette.millDark
      ..strokeWidth = math.max(2.5, pitch * 0.07)
      ..strokeCap = StrokeCap.round;
    final hub = mill + Offset(0, -pitch * 0.08);
    for (var k = 0; k < 4; k++) {
      final a = math.pi / 4 + k * math.pi / 2;
      canvas.drawLine(hub, hub + Offset(math.cos(a), math.sin(a)) * pitch * 0.3, sails);
    }
    canvas.drawCircle(hub, math.max(2, pitch * 0.05), Paint()..color = Palette.mill);

    // The counts from the gate at every junction, round the ponds.
    final counts = f.routesFromGate();
    for (var x = 0; x <= f.width; x++) {
      for (var y = 0; y <= f.height; y++) {
        final j = (x, y);
        if (f.isPond(j) || j == f.mill || j == f.gate) continue;
        canvas.drawCircle(m.at(j), math.max(2.5, pitch * 0.07), Paint()..color = Palette.post);
        _count(canvas, '${counts[x][y]}', m.at(j) + Offset(pitch * 0.24, -pitch * 0.26), pitch);
      }
    }

    // The walker.
    final head = m.at(play.head);
    canvas.drawCircle(head, math.max(5, pitch * 0.15), Paint()..color = Palette.walker);
    canvas.drawCircle(head, math.max(5, pitch * 0.15), Paint()
      ..color = Palette.post
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.at(aim.$2), pitch * 0.3, Paint()
        ..color = aim.$1 == 'back' ? Palette.bad : Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, pitch * 0.05));
    }
  }

  void _count(Canvas canvas, String words, Offset at, double pitch) {
    final style = labels.copyWith(color: Palette.count, fontSize: math.max(9, pitch * 0.2), fontWeight: FontWeight.w800);
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    final rect = Rect.fromCenter(center: at, width: painter.width + 5, height: painter.height + 1);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), Paint()..color = Palette.halo.withValues(alpha: 0.7));
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(FieldView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a field as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'Every step is right or up, so the walk never returns to a lower '
        'row or a column further left. Two stiles can both be passed only when '
        'one lies right-and-up of the other; these two do not, and every one '
        'of the ${level.walks} routes was walked to be sure: none passes both. '
        'The multiplying rule says the same with no walk, since the leg from '
        'one stile to the other has a negative step in it and counts nought.$note';
  }
  return 'The routes are counted three ways that must agree: every route is '
      'walked; Pascal\'s rule adds, at every junction, the routes to the one '
      'left of it and the one below, ponds struck out, which is the number '
      'written on the field; and the binomial counts a leg with no ponds as '
      'so many steps, choose which go right, the legs over a stile multiplied. '
      '${level.ways} of the ${level.walks} routes land it.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import 'palette.dart';

/// Where the cells lie on the board, so the screen and the tests
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

  Rect rectOf(Cell cell) => Rect.fromLTWH(
        origin.dx + cell.$1 * pitch,
        origin.dy + cell.$2 * pitch,
        pitch,
        pitch,
      );

  Offset at(Cell cell) => rectOf(cell).center;

  /// The cell under a touch, or null off the yard.
  Cell? under(Offset touch) {
    final x = ((touch.dx - origin.dx) / pitch).floor();
    final y = ((touch.dy - origin.dy) / pitch).floor();
    if (x < 0 || x >= side || y < 0 || y >= side) return null;
    return (x, y);
  }
}

/// The yard itself: gravel cells, slabs, the kerb along every
/// exposed slab edge, the box in chalk, and the pointer.
class YardView extends CustomPainter {
  YardView({required this.play, this.pointing, required this.labels});

  final Play play;
  final (String, Cell)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;
    final side = metrics.side;

    // The gravel.
    final gravel = Rect.fromLTWH(
      metrics.origin.dx,
      metrics.origin.dy,
      pitch * side,
      pitch * side,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gravel.inflate(pitch * 0.12), Radius.circular(pitch * 0.15)),
      Paint()..color = Palette.gravel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(gravel.inflate(pitch * 0.12), Radius.circular(pitch * 0.15)),
      Paint()
        ..color = Palette.gravelRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, pitch * 0.02),
    );
    for (final cell in play.rules.cells) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            metrics.rectOf(cell).deflate(pitch * 0.06), Radius.circular(pitch * 0.06)),
        Paint()
          ..color = Palette.cellRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, pitch * 0.02),
      );
    }

    // The slabs, loose ones tinted rust when the yard is not
    // joined.
    final joined = play.joined || play.slabs.length <= 1;
    for (final slab in play.slabs) {
      final rect = metrics.rectOf(slab).deflate(pitch * 0.04);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.06)),
        Paint()..color = joined ? Palette.slab : Palette.loose.withValues(alpha: 0.7),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.06)),
        Paint()
          ..color = Palette.slabDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, pitch * 0.02),
      );
    }

    // The kerb: a brick line along every slab edge that meets bare
    // ground.
    final kerb = Paint()
      ..color = Palette.kerb
      ..strokeWidth = math.max(3, pitch * 0.09)
      ..strokeCap = StrokeCap.round;
    for (final slab in play.slabs) {
      final rect = metrics.rectOf(slab);
      final (x, y) = slab;
      if (!play.slabs.contains((x + 1, y))) canvas.drawLine(rect.topRight, rect.bottomRight, kerb);
      if (!play.slabs.contains((x - 1, y))) canvas.drawLine(rect.topLeft, rect.bottomLeft, kerb);
      if (!play.slabs.contains((x, y + 1))) canvas.drawLine(rect.bottomLeft, rect.bottomRight, kerb);
      if (!play.slabs.contains((x, y - 1))) canvas.drawLine(rect.topLeft, rect.topRight, kerb);
    }

    // The box, in chalk dashes, once two or more slabs stand.
    if (play.slabs.length >= 2) {
      var left = side, right = -1, top = side, bottom = -1;
      for (final (x, y) in play.slabs) {
        left = math.min(left, x);
        right = math.max(right, x);
        top = math.min(top, y);
        bottom = math.max(bottom, y);
      }
      final box = Rect.fromLTRB(
        metrics.rectOf((left, top)).left,
        metrics.rectOf((left, top)).top,
        metrics.rectOf((right, bottom)).right,
        metrics.rectOf((right, bottom)).bottom,
      ).inflate(pitch * 0.16);
      _dashed(canvas, box, Paint()
        ..color = Palette.box
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, pitch * 0.03), pitch * 0.18);
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(metrics.rectOf(aim.$2).deflate(pitch * 0.14), Radius.circular(pitch * 0.1)),
        Paint()
          ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }
  }

  void _dashed(Canvas canvas, Rect rect, Paint paint, double dash) {
    final path = Path()..addRect(rect);
    for (final metric in path.computeMetrics()) {
      var at = 0.0;
      while (at < metric.length) {
        final end = math.min(at + dash, metric.length);
        canvas.drawPath(metric.extractPath(at, end), paint);
        at += dash * 2;
      }
    }
  }

  @override
  bool shouldRepaint(YardView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a yard as it stands.
String whyWords(Play play) {
  final yard = play.yard;
  final note = yard.note == null ? '' : ' ${yard.note}';
  if (!yard.winnable) {
    return 'Look at the chalk box round the slabs: the kerb runs at '
        'least all the way round that box, twice its width plus its '
        'height, since every row and every column of the box that '
        'holds a slab is crossed twice. Five slabs need a box of two '
        'by three at the least, whose kerb is ten, so five slabs never '
        'wear eight. The sweep laid all 571 placings and measured '
        'them.$note';
  }
  return 'The placings are counted by the sweep, every joined placing '
      'of that many slabs on the yard, every kerb measured edge by '
      'edge, and held to a second voice: the shortest kerb for a '
      'count of slabs is twice the least whole number not below twice '
      'the square root of the count, Harary and Harborth\'s law, and '
      'the sweep\'s shortest agrees with it at every count from one to '
      'ten, while the box round any placing never wears more kerb than '
      'the slabs do. ${yard.ways} placing${yard.ways == 1 ? '' : 's'} '
      'land${yard.ways == 1 ? 's' : ''} this yard.$note';
}

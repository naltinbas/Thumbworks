import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tour/fewest.dart';
import '../tour/play.dart';
import 'palette.dart';

/// Where every paddock lies, shared by the painter and the hit-testing, so
/// where a paddock is drawn is exactly where a paddock is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final yard = play.yard;
    cell = math.min(room.width / yard.width, room.height / yard.height);
    final wide = cell * yard.width;
    final high = cell * yard.height;
    corner = Offset((room.width - wide) / 2, (room.height - high) / 2);
    board = Rect.fromLTWH(corner.dx, corner.dy, wide, high);
  }

  final Play play;

  late final double cell;
  late final Offset corner;
  late final Rect board;

  Rect paddockRect(int paddock) {
    final x = paddock % play.yard.width;
    final y = paddock ~/ play.yard.width;
    return Rect.fromLTWH(
      corner.dx + x * cell,
      corner.dy + y * cell,
      cell,
      cell,
    );
  }

  Offset middleOf(int paddock) => paddockRect(paddock).center;

  /// The paddock under a touch, or -1 off the yard.
  int paddockAt(Offset touch) {
    if (!board.contains(touch)) return -1;
    final x = ((touch.dx - corner.dx) / cell).floor();
    final y = ((touch.dy - corner.dy) / cell).floor();
    if (x < 0 || y < 0 || x >= play.yard.width || y >= play.yard.height) {
      return -1;
    }
    return y * play.yard.width + x;
  }
}

/// The yard, drawn.
class TourView extends CustomPainter {
  TourView({
    required this.play,
    required this.pointing,
    required this.showColours,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The paddock being pointed at, or -1.
  final int pointing;

  /// Whether to tally the two grasses: the colour argument, drawn.
  final bool showColours;

  /// Whether the tallies may write words. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var paddock = 0; paddock < play.yard.paddocks; paddock++) {
      _paddock(canvas, metrics, paddock);
    }
    _fence(canvas, metrics);
    _gate(canvas, metrics);
    if (play.path.length > 1) _trail(canvas, metrics);
    if (play.here != null && !play.isDone) _colt(canvas, metrics, play.here!);
    if (showColours && showWords) _tally(canvas, metrics);
    if (pointing >= 0) _point(canvas, metrics);
  }

  void _paddock(Canvas canvas, Metrics metrics, int paddock) {
    final rect = metrics.paddockRect(paddock);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Rounds.dark(play.yard, paddock) ? Palette.dark : Palette.light,
    );
    if (play.ridden(paddock) && paddock != play.here) {
      // Hoofprints where the colt has been.
      final hoof = Paint()..color = Palette.hoof;
      canvas.drawOval(
        Rect.fromCenter(
          center: rect.center + Offset(-rect.width * 0.13, rect.height * 0.08),
          width: rect.width * 0.11,
          height: rect.height * 0.16,
        ),
        hoof,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: rect.center + Offset(rect.width * 0.11, -rect.height * 0.1),
          width: rect.width * 0.11,
          height: rect.height * 0.16,
        ),
        hoof,
      );
    }
  }

  void _fence(Canvas canvas, Metrics metrics) {
    canvas.drawRect(
      metrics.board.deflate(0.8),
      Paint()
        ..color = Palette.fence
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
  }

  void _gate(Canvas canvas, Metrics metrics) {
    final at = play.yard.starts ?? (play.path.isEmpty ? -1 : play.path.first);
    if (at < 0) return;
    final rect = metrics.paddockRect(at);
    // Gate bars across the paddock's top edge.
    final bar = Paint()
      ..color = Palette.gate
      ..strokeWidth = math.max(1.6, metrics.cell * 0.05)
      ..strokeCap = StrokeCap.round;
    for (var rail = 0; rail < 3; rail++) {
      final y = rect.top + rect.height * (0.12 + 0.1 * rail);
      canvas.drawLine(
        Offset(rect.left + rect.width * 0.16, y),
        Offset(rect.right - rect.width * 0.16, y),
        bar,
      );
    }
  }

  void _trail(Canvas canvas, Metrics metrics) {
    final trail = Path()
      ..moveTo(metrics.middleOf(play.path.first).dx,
          metrics.middleOf(play.path.first).dy);
    for (var leg = 1; leg < play.path.length; leg++) {
      final to = metrics.middleOf(play.path[leg]);
      trail.lineTo(to.dx, to.dy);
    }
    canvas.drawPath(
      trail,
      Paint()
        ..color = Palette.path.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.8, metrics.cell * 0.06)
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _colt(Canvas canvas, Metrics metrics, int paddock) {
    final rect = metrics.paddockRect(paddock).deflate(metrics.cell * 0.18);
    final middle = rect.center;
    final wide = rect.width;
    final body = Paint()..color = Palette.colt;

    // Legs.
    final leg = Paint()
      ..color = Palette.colt
      ..strokeWidth = math.max(1.6, wide * 0.07)
      ..strokeCap = StrokeCap.round;
    for (final at in const [-0.2, -0.08, 0.1, 0.24]) {
      canvas.drawLine(
        middle + Offset(wide * at, wide * 0.08),
        middle + Offset(wide * at, wide * 0.34),
        leg,
      );
    }
    // Body, neck, head, ear, tail.
    canvas.drawOval(
      Rect.fromCenter(
        center: middle,
        width: wide * 0.62,
        height: wide * 0.34,
      ),
      body,
    );
    canvas.drawLine(
      middle + Offset(-wide * 0.24, -wide * 0.06),
      middle + Offset(-wide * 0.33, -wide * 0.22),
      Paint()
        ..color = Palette.colt
        ..strokeWidth = wide * 0.15
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: middle + Offset(-wide * 0.4, -wide * 0.25),
        width: wide * 0.26,
        height: wide * 0.16,
      ),
      body,
    );
    canvas.drawLine(
      middle + Offset(-wide * 0.34, -wide * 0.34),
      middle + Offset(-wide * 0.31, -wide * 0.24),
      Paint()
        ..color = Palette.colt
        ..strokeWidth = wide * 0.05
        ..strokeCap = StrokeCap.round,
    );
    final tail = Path()
      ..moveTo(middle.dx + wide * 0.3, middle.dy - wide * 0.02)
      ..quadraticBezierTo(
        middle.dx + wide * 0.44,
        middle.dy + wide * 0.1,
        middle.dx + wide * 0.4,
        middle.dy + wide * 0.28,
      );
    canvas.drawPath(
      tail,
      Paint()
        ..color = Palette.colt
        ..style = PaintingStyle.stroke
        ..strokeWidth = wide * 0.06
        ..strokeCap = StrokeCap.round,
    );
  }

  void _tally(Canvas canvas, Metrics metrics) {
    // The two grasses counted, chip and number, inside the yard's top edge.
    var dark = 0;
    for (var paddock = 0; paddock < play.yard.paddocks; paddock++) {
      if (Rounds.dark(play.yard, paddock)) dark++;
    }
    final light = play.yard.paddocks - dark;

    var across = metrics.board.left + 8;
    for (final (colour, count) in [
      (Palette.dark, dark),
      (Palette.light, light),
    ]) {
      final chip = Rect.fromLTWH(
        across,
        metrics.board.top - metrics.cell * 0.44 - 4,
        metrics.cell * 0.34,
        metrics.cell * 0.34,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(chip, Radius.circular(chip.width * 0.2)),
        Paint()..color = colour,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(chip, Radius.circular(chip.width * 0.2)),
        Paint()
          ..color = Palette.gate
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
      final words = TextPainter(
        text: TextSpan(
          text: '$count',
          style: labels.copyWith(
            color: Palette.ink,
            fontSize: chip.height * 0.9,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        Offset(chip.right + 5, chip.center.dy - words.height / 2),
      );
      across = chip.right + 5 + words.width + 14;
    }
  }

  void _point(Canvas canvas, Metrics metrics) {
    final rect = metrics.paddockRect(pointing);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(metrics.cell * 0.08),
        Radius.circular(metrics.cell * 0.16),
      ),
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(TourView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showColours != showColours;
}

/// The words the why speaks, from the yard at hand.
String whyWords(Play play) {
  final yard = play.yard;
  final start = 'Every jump lands on the other grass, dark to light, light '
      'to dark.';
  return '$start${yard.note == null ? '' : ' ${yard.note}'}';
}

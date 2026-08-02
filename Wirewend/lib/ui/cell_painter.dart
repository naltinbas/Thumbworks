import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../game/grid.dart';
import 'palette.dart';

/// Draws one cell: the wire as strokes that meet at the centre, plus the
/// glyph that says what the cell is for.
///
/// The wire reaches the full half-width of the cell, so a wire and its
/// neighbour draw one unbroken line across the gap between them. That is the
/// only cue the player needs for "these two are joined".
class CellPainter extends CustomPainter {
  const CellPainter({
    required this.cell,
    required this.lit,
    required this.spin,
  });

  final Cell cell;

  /// How lit the cell is, 0 to 1, animated rather than boolean so a lamp
  /// coming on reads as an event instead of a redraw.
  final double lit;

  /// How far through its quarter turn the cell is, 0 to 1. The board has
  /// already turned the cell by the time this painter sees it, so the wire is
  /// drawn wound back by whatever is left of the quarter: the picture catches
  /// up with the rule rather than leading it.
  final double spin;

  /// The glyphs are drawn upright whatever the wire is doing, because a lamp
  /// that spins looks like it is being replaced rather than turned.
  static const _quarter = math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final centre = Offset(size.width / 2, size.height / 2);

    _paintTile(canvas, size, side);
    if (cell.isEmpty) return;

    _paintWire(canvas, centre, side);
    switch (cell.kind) {
      case CellKind.source:
        _paintSource(canvas, centre, side);
      case CellKind.lamp:
        _paintLamp(canvas, centre, side);
      case CellKind.wire:
      case CellKind.empty:
        break;
    }
  }

  void _paintTile(Canvas canvas, Size size, double side) {
    final gap = side * 0.045;
    final face = RRect.fromRectAndRadius(
      Rect.fromLTWH(gap, gap, size.width - gap * 2, size.height - gap * 2),
      Radius.circular(side * 0.2),
    );
    final fill = cell.isEmpty
        ? Palette.hole
        : Color.lerp(Palette.tile, Palette.tileLive, lit)!;
    canvas.drawRRect(face, Paint()..color = fill);
  }

  void _paintWire(Canvas canvas, Offset centre, double side) {
    final reach = side / 2;
    final stroke = side * 0.155;

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(-_quarter * (1 - spin));

    // The glow goes down first and wider, so the live wire looks like it is
    // giving off light rather than being outlined.
    if (lit > 0.02) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 2.1
        ..strokeCap = StrokeCap.round
        ..color = Palette.wireLive.withValues(alpha: 0.22 * lit)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.09);
      _strokeEnds(canvas, reach, glow);
    }

    final wire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(Palette.wireIdle, Palette.wireLive, lit)!;
    _strokeEnds(canvas, reach, wire);

    canvas.restore();
  }

  void _strokeEnds(Canvas canvas, double reach, Paint paint) {
    for (final end in Ends.all) {
      if (!cell.ends.has(end)) continue;
      // The grid already knows which way an edge points; reusing it keeps the
      // picture and the rule from drifting apart.
      final delta = step(end);
      final to = Offset(delta.col * reach, delta.row * reach);
      canvas.drawLine(Offset.zero, to, paint);
    }
  }

  void _paintSource(Canvas canvas, Offset centre, double side) {
    final radius = side * 0.27;
    canvas.drawCircle(
      centre,
      radius * 1.4,
      Paint()
        ..color = Palette.wireLive.withValues(alpha: 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.1),
    );
    // A diamond, so the one cell current comes from is never mistaken for a
    // lamp at a glance. It is cut out of the wire first, because the live
    // stroke is nearly as wide as the glyph and would otherwise swallow it.
    canvas.drawPath(
      _diamond(centre, radius + side * 0.04),
      Paint()..color = Palette.tileLive,
    );
    canvas.drawPath(
      _diamond(centre, radius),
      Paint()..color = Palette.sourceBody,
    );
    canvas.drawPath(
      _diamond(centre, radius * 0.36),
      Paint()..color = Palette.sourceCore,
    );
  }

  Path _diamond(Offset centre, double radius) => Path()
    ..moveTo(centre.dx, centre.dy - radius)
    ..lineTo(centre.dx + radius, centre.dy)
    ..lineTo(centre.dx, centre.dy + radius)
    ..lineTo(centre.dx - radius, centre.dy)
    ..close();

  void _paintLamp(Canvas canvas, Offset centre, double side) {
    // The bulb swells as it comes on, which is what makes lighting the last
    // lamp feel like finishing rather than like one more move.
    final radius = side * 0.19 * (1 + 0.18 * lit);

    if (lit > 0.02) {
      canvas.drawCircle(
        centre,
        radius * 2.4,
        Paint()
          ..color = Palette.lampLit.withValues(alpha: 0.45 * lit)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, side * 0.13),
      );
    }

    canvas.drawCircle(
      centre,
      radius,
      Paint()..color = Color.lerp(Palette.lampIdle, Palette.lampLit, lit)!,
    );
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = side * 0.035
        ..color = Color.lerp(Palette.lampRimIdle, Palette.lampRimLit, lit)!,
    );
    canvas.drawCircle(
      centre.translate(-radius * 0.3, -radius * 0.3),
      radius * 0.3,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.15 + 0.5 * lit),
    );
  }

  @override
  bool shouldRepaint(CellPainter old) =>
      old.lit != lit ||
      old.spin != spin ||
      old.cell.ends != cell.ends ||
      old.cell.kind != cell.kind;
}

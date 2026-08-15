import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hex/play.dart';
import '../hex/rules.dart';
import 'palette.dart';

/// Where the triangles lie on the board, so the screen and the tests
/// can find every one: lattice cell (i, j) sits at i + j/2 across and
/// j times root three over two up.
class Metrics {
  Metrics(this.play, Size room) {
    final h = play.hexagon;
    // The hexagon's corners in lattice coordinates.
    final corners = [(0, 0), (h.a, 0), (h.a, h.b), (h.a - h.c, h.b + h.c), (-h.c, h.b + h.c), (-h.c, h.c)];
    var minX = double.infinity, maxX = -double.infinity, minY = double.infinity, maxY = -double.infinity;
    for (final (i, j) in corners) {
      final x = i + j / 2, y = j * _root3 / 2;
      minX = math.min(minX, x);
      maxX = math.max(maxX, x);
      minY = math.min(minY, y);
      maxY = math.max(maxY, y);
    }
    unit = math.min(room.width * 0.9 / (maxX - minX), room.height * 0.9 / (maxY - minY));
    origin = Offset(
      (room.width - (maxX - minX) * unit) / 2 - minX * unit,
      (room.height + (maxY - minY) * unit) / 2 + minY * unit,
    );
  }

  static const _root3 = 1.7320508075688772;

  final Play play;

  late final double unit;
  late final Offset origin;

  /// A lattice point on the screen.
  Offset point(int i, int j) => Offset(origin.dx + (i + j / 2) * unit, origin.dy - j * _root3 / 2 * unit);

  /// The three corners of a triangle.
  List<Offset> corners(Tri t) {
    final (up, i, j) = t;
    return up ? [point(i, j), point(i + 1, j), point(i, j + 1)] : [point(i + 1, j), point(i, j + 1), point(i + 1, j + 1)];
  }

  /// The middle of a triangle.
  Offset at(Tri t) {
    final c = corners(t);
    return Offset((c[0].dx + c[1].dx + c[2].dx) / 3, (c[0].dy + c[1].dy + c[2].dy) / 3);
  }

  /// The triangle under a touch, or null off the hexagon.
  Tri? under(Offset touch) {
    for (final t in play.hexagon.triangles) {
      if (_inside(touch, corners(t))) return t;
    }
    return null;
  }

  static bool _inside(Offset p, List<Offset> c) {
    double cross(Offset a, Offset b, Offset q) => (b.dx - a.dx) * (q.dy - a.dy) - (b.dy - a.dy) * (q.dx - a.dx);
    final d1 = cross(c[0], c[1], p), d2 = cross(c[1], c[2], p), d3 = cross(c[2], c[0], p);
    final neg = d1 < 0 || d2 < 0 || d3 < 0;
    final pos = d1 > 0 || d2 > 0 || d3 > 0;
    return !(neg && pos);
  }
}

/// The hexagon: its triangles, the lozenges laid as cube faces, the
/// held triangle, and the chips.
class HexView extends CustomPainter {
  HexView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Lozenge)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final h = play.hexagon;

    // The slate behind, and every triangle faintly.
    final all = [...h.triangles, ...h.chipped];
    for (final t in all) {
      final c = m.corners(t);
      final path = Path()
        ..moveTo(c[0].dx, c[0].dy)
        ..lineTo(c[1].dx, c[1].dy)
        ..lineTo(c[2].dx, c[2].dy)
        ..close();
      canvas.drawPath(path, Paint()..color = h.chipped.contains(t) ? Palette.chip : Palette.slate);
      canvas.drawPath(path, Paint()
        ..color = Palette.grid
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }
    // The lozenges, as faces of cubes.
    final seam = Paint()
      ..color = Palette.seam
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, m.unit * 0.05)
      ..strokeJoin = StrokeJoin.round;
    for (final l in play.laid) {
      final path = _lozengePath(m, l);
      final lean = Hexagon.lean(l);
      canvas.drawPath(path, Paint()..color = [Palette.top, Palette.left, Palette.right][lean]);
      canvas.drawPath(path, seam);
    }
    // The bare triangles when the hexagon is over and cannot be tiled.
    if (play.gaveUp) {
      for (final t in h.triangles) {
        if (play.covered(t)) continue;
        final c = m.corners(t);
        canvas.drawPath(
            Path()
              ..moveTo(c[0].dx, c[0].dy)
              ..lineTo(c[1].dx, c[1].dy)
              ..lineTo(c[2].dx, c[2].dy)
              ..close(),
            Paint()..color = Palette.bareTri.withValues(alpha: 0.6));
      }
    }
    // The held triangle.
    final held = play.held;
    if (held != null) {
      final c = m.corners(held);
      canvas.drawPath(
          Path()
            ..moveTo(c[0].dx, c[0].dy)
            ..lineTo(c[1].dx, c[1].dy)
            ..lineTo(c[2].dx, c[2].dy)
            ..close(),
          Paint()..color = Palette.held.withValues(alpha: 0.5));
    }
    // The rim.
    final rim = Path()..moveTo(m.point(0, 0).dx, m.point(0, 0).dy);
    for (final (i, j) in [(h.a, 0), (h.a, h.b), (h.a - h.c, h.b + h.c), (-h.c, h.b + h.c), (-h.c, h.c)]) {
      rim.lineTo(m.point(i, j).dx, m.point(i, j).dy);
    }
    rim.close();
    canvas.drawPath(rim, Paint()
      ..color = Palette.rim
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(2, m.unit * 0.06));

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawPath(_lozengePath(m, aim.$2), Paint()
        ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2.5, m.unit * 0.08));
    }
  }

  Path _lozengePath(Metrics m, Lozenge l) {
    // The four corners of the lozenge: the up triangle's corners with the
    // down triangle's far corner in the right place. Take the union: the
    // shared edge's two ends and the two far corners.
    final up = m.corners(l.$1), down = m.corners(l.$2);
    final shared = [for (final p in up) if (down.any((q) => (q - p).distance < 0.5)) p];
    final upFar = up.firstWhere((p) => !shared.any((s) => (s - p).distance < 0.5));
    final downFar = down.firstWhere((p) => !shared.any((s) => (s - p).distance < 0.5));
    return Path()
      ..moveTo(upFar.dx, upFar.dy)
      ..lineTo(shared[0].dx, shared[0].dy)
      ..lineTo(downFar.dx, downFar.dy)
      ..lineTo(shared[1].dx, shared[1].dy)
      ..close();
  }

  @override
  bool shouldRepaint(HexView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a hexagon as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final h = play.hexagon;
  if (!level.winnable) {
    return 'Every lozenge is one triangle pointing up glued to one pointing '
        'down along a shared edge, so a tiling covers as many of one as of the '
        'other. This hexagon holds ${h.ups.length} pointing up and '
        '${h.downs.length} pointing down; every laying that covers the ups was '
        'tried, 172 of them, and every one leaves two down triangles bare.$note';
  }
  return 'The sweep lays every tiling of the hexagon, each up triangle glued in '
      'turn to a free down triangle across one of its three edges, and counts '
      'them; MacMahon\'s product, (i + j + k - 1) over (i + j + k - 2) taken '
      'over the box, gives the same count with no sweep, and so does a third '
      'walk that counts stacks of cubes in the box the hexagon draws, since '
      'the three leans of a lozenge are the three faces of a cube. '
      '${level.ways} tilings.$note';
}

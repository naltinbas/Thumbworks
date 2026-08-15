import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wedge/play.dart';
import '../wedge/rules.dart';
import 'palette.dart';

/// Where things lie on the board, so the screen and the tests can find
/// them: the fan of faces round its point in the top part, and below it
/// two rows of numbers, the sides of a face and the faces meeting.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    dialTop = room.height * 0.72;
    rowHeight = room.height * 0.13;
    cellWidth = room.width * 0.11;
    cellLeft = room.width * 0.28;
    // Once the ask is over the dials are gone and the fan has the room.
    final whole = bare || play.isOver;
    centre = Offset(room.width / 2, room.height * (whole ? 0.5 : 0.37));
    fanRoom = math.min(room.width * (bare ? 0.5 : 0.46), room.height * (bare ? 0.5 : whole ? 0.44 : 0.33));
  }

  final Play play;

  late final double width;
  late final double height;
  late final double dialTop;
  late final double rowHeight;
  late final double cellWidth;
  late final double cellLeft;

  /// The point the faces meet at.
  late final Offset centre;

  /// How far from the point a face may reach.
  late final double fanRoom;

  /// The cell of dial [dial] (0 the sides, 1 the faces) at [value].
  Rect cell(int dial, int value) => Rect.fromLTWH(
        cellLeft + (value - 3) * cellWidth,
        dialTop + dial * rowHeight,
        cellWidth,
        rowHeight,
      ).deflate(3);

  /// The middle of that cell.
  Offset at(int dial, int value) => cell(dial, value).center;

  /// The dial and value under a touch, or null.
  (int, int)? under(Offset touch) {
    for (var dial = 0; dial < 2; dial++) {
      for (final value in Rules.sides) {
        if (cell(dial, value).contains(touch)) return (dial, value);
      }
    }
    return null;
  }

  /// A face's side, sized so the fan stays inside the room.
  double get side => fanRoom * math.sin(math.pi / play.sides);
}

/// The fan: the faces laid flat round their point, each a regular
/// polygon with a corner at the point, one after another round it; the
/// gap they leave in green, the overlap they make in rust; below, the
/// two dials.
class WedgeView extends CustomPainter {
  WedgeView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The (dial, value) the show-me points at, or null.
  final (int, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words and the dials off, for the mark.
  final bool bare;

  /// The corners of face [k] of [play], in the room, from the point round.
  static List<Offset> face(Play play, Metrics m, int k) {
    final p = play.sides;
    final a = math.pi * (p - 2) / p;
    final span = play.faces * a;
    final start = span <= 2 * math.pi + 1e-9 ? -math.pi / 2 - span / 2 : math.pi / 2;
    var heading = start + k * a;
    var at = m.centre;
    final corners = <Offset>[at];
    for (var j = 0; j < p - 1; j++) {
      at = at + Offset(math.cos(heading), -math.sin(heading)) * m.side;
      corners.add(at);
      heading += 2 * math.pi / p;
    }
    return corners;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.bench);
    final p = play.sides, q = play.faces;
    final a = math.pi * (p - 2) / p;
    final span = q * a;
    final full = 2 * math.pi;
    final start = span <= full + 1e-9 ? -math.pi / 2 - span / 2 : math.pi / 2;
    final stroke = (m.side * 0.03).clamp(1.0, 3.0);

    // The gap, when the faces come short of the turn.
    if (span < full - 1e-9) {
      final rect = Rect.fromCircle(center: m.centre, radius: m.side * 0.55);
      canvas.drawArc(rect, -(start + span), -(full - span), true, Paint()..color = Palette.gap.withValues(alpha: 0.35));
      canvas.drawArc(rect, -(start + span), -(full - span), true, Paint()
        ..color = Palette.gap
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke);
    }

    // The faces, from the point round.
    for (var k = 0; k < q; k++) {
      final corners = face(play, m, k);
      final path = Path()..addPolygon(corners, true);
      final colour = Palette.papers[k % Palette.papers.length];
      canvas.drawPath(path, Paint()..color = colour.withValues(alpha: span > full + 1e-9 ? 0.72 : 0.94));
      canvas.drawPath(path, Paint()
        ..color = Palette.fold
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round);
    }

    // The overlap, when the faces go past the turn.
    if (span > full + 1e-9) {
      final rect = Rect.fromCircle(center: m.centre, radius: m.side * 0.42);
      canvas.drawArc(rect, -start, -(span - full), true, Paint()..color = Palette.over.withValues(alpha: 0.55));
      canvas.drawArc(rect, -start, -(span - full), true, Paint()
        ..color = Palette.over
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke);
    }

    // The point.
    canvas.drawCircle(m.centre, stroke * 1.6, Paint()..color = Palette.fold);

    if (bare) return;

    // The gap or the overlap, told at the point's side.
    final gap = play.gap;
    final told = gap.$1 > 0
        ? '${Rules.degrees(gap)}° to spare'
        : gap.$1 == 0
            ? '360° exactly, flat'
            : '${Rules.degrees((-gap.$1, gap.$2))}° over';
    _write(canvas, told, Offset(size.width / 2, size.height * 0.03 + 8), labels.copyWith(color: gap.$1 > 0 ? Palette.gap : gap.$1 == 0 ? Palette.inkDim : Palette.over, fontSize: 13, fontWeight: FontWeight.w800));

    // The dials, while there is setting to do.
    if (play.isOver) return;
    for (var dial = 0; dial < 2; dial++) {
      _write(canvas, dial == 0 ? 'sides' : 'faces', Offset(m.cellLeft * 0.5, m.dialTop + dial * m.rowHeight + m.rowHeight / 2), labels.copyWith(color: Palette.inkDim, fontSize: 13));
      for (final value in Rules.sides) {
        final cell = m.cell(dial, value);
        final on = (dial == 0 ? play.sides : play.faces) == value;
        canvas.drawRRect(RRect.fromRectAndRadius(cell, const Radius.circular(8)), Paint()..color = on ? Palette.dialOn : Palette.dial);
        if (pointing != null && pointing!.$1 == dial && pointing!.$2 == value) {
          canvas.drawRRect(RRect.fromRectAndRadius(cell.inflate(2), const Radius.circular(9)), Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
        }
        _write(canvas, '$value', cell.center, labels.copyWith(color: on ? Palette.night : Palette.ink, fontSize: (m.rowHeight * 0.4).clamp(10.0, 18.0), fontWeight: FontWeight.w800));
      }
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(WedgeView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'A corner of a solid needs three faces at least, and their angles at it '
      'must come to less than a full turn, 360 degrees, or they lie flat or '
      'overlap. A regular face of p sides has corners of 180(p - 2)/p degrees: 60, '
      '90, 108, 120 and on. Three triangles, squares or pentagons come under, 180, '
      '270 and 324, and so do four and five triangles, 240 and 300; three hexagons '
      'make 360 exactly, six triangles and four squares too, and everything else '
      'goes over. So five corners close and no more, the tetrahedron, octahedron, '
      'icosahedron, cube and dodecahedron. Euler\'s count says the same another '
      'way: corners less edges plus faces come to two, and with p times the faces '
      'and q times the corners both twice the edges, the edges are 2pq over 4 - '
      '(p - 2)(q - 2), a whole positive number for exactly those five, 6, 12, 30, '
      '12 and 30. Every corner of three to eight faces of three to eight sides is '
      'swept, 36 settings, and the two readings agree on all of them.';
  return '$law ${level.note}';
}

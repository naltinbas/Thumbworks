import 'dart:math';

import 'package:flutter/material.dart';

import '../square/play.dart';
import '../square/rules.dart';
import 'palette.dart';

/// Where the pegboard sits in a board of a given size: pegs (0, 0) to
/// (4, 4) with room round them for the squares, (0, 0) at the bottom
/// left.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    final margin = bare ? 1.6 : 2.0;
    final room = min(size.width - (bare ? 0 : 16), size.height - strip - (bare ? 0 : 8));
    cell = room / (Rules.side - 1 + 2 * margin);
    final left = (size.width - room) / 2 + margin * cell, top = (size.height - strip - room) / 2 + margin * cell;
    origin = Offset(left, top + (Rules.side - 1) * cell);
  }

  final Play play;
  final Size size;
  late final double cell;

  /// Where peg (0, 0) falls; ranks run up from there.
  late final Offset origin;

  Offset at(double x, double y) => Offset(origin.dx + x * cell, origin.dy - y * cell);

  Offset pegAt(Peg p) => at(p.$1.toDouble(), p.$2.toDouble());

  /// A doubled point's place.
  Offset halfAt(Point2 p) => at(p.$1 / 2, p.$2 / 2);

  /// The peg under a point, or null when none is near enough.
  Peg? under(Offset p) {
    final x = ((p.dx - origin.dx) / cell).round(), y = ((origin.dy - p.dy) / cell).round();
    if (!Rules.onBoard((x, y))) return null;
    return (pegAt((x, y)) - p).distance <= cell * 0.45 ? (x, y) : null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The pegs, the four set with their cords, the squares on the sides,
/// their centres and the two joins.
class SquareView extends CustomPainter {
  const SquareView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (peg, lift).
  final (Peg, bool)? pointing;

  final TextStyle labels;

  /// Whether to draw the pegs set and their squares only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final thick = bare ? m.cell * 0.09 : 2.0;
    if (!bare) {
      for (final p in Rules.pegs) {
        canvas.drawCircle(m.pegAt(p), 2.5, Paint()..color = Palette.peg);
      }
    }
    final pegs = play.pegs;
    // The squares on the sides set, and the sides themselves.
    final sides = <(Peg, Peg)>[
      for (var i = 0; i + 1 < pegs.length; i++) (pegs[i], pegs[i + 1]),
      if (play.full) (pegs[3], pegs[0]),
    ];
    for (final (p, q) in sides) {
      final corners = Rules.square(p, q).map(m.halfAt).toList();
      final path = Path()..moveTo(corners[0].dx, corners[0].dy);
      for (final c in corners.skip(1)) {
        path.lineTo(c.dx, c.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Palette.copperFill);
      canvas.drawPath(path, Paint()..color = Palette.copper..style = PaintingStyle.stroke..strokeWidth = thick * 0.8..strokeJoin = StrokeJoin.round);
    }
    for (final (p, q) in sides) {
      canvas.drawLine(m.pegAt(p), m.pegAt(q), Paint()..color = Palette.chalk..strokeWidth = thick..strokeCap = StrokeCap.round);
    }
    // The centres, and the joins when the four is whole.
    final centres = play.centresSoFar;
    if (play.full) {
      final c = centres.map(m.halfAt).toList();
      canvas.drawLine(c[0], c[2], Paint()..color = Palette.gold..strokeWidth = thick * 1.2..strokeCap = StrokeCap.round);
      canvas.drawLine(c[1], c[3], Paint()..color = Palette.gold..strokeWidth = thick * 1.2..strokeCap = StrokeCap.round);
      final x = play.crossing;
      if (x != null) {
        canvas.drawCircle(m.at(x.$1.toDouble, x.$2.toDouble), bare ? m.cell * 0.12 : 4, Paint()..color = Palette.gold);
      }
    }
    const centreNames = ['P', 'Q', 'R', 'S'];
    for (var i = 0; i < centres.length; i++) {
      final at = m.halfAt(centres[i]);
      canvas.drawCircle(at, bare ? m.cell * 0.14 : 5, Paint()..color = Palette.gold);
      if (!bare) _word(canvas, centreNames[i], at + const Offset(0, -12), Palette.gold, size, 11, backed: true);
    }
    // The pegs set, named, and the pointer.
    for (var i = 0; i < pegs.length; i++) {
      final at = m.pegAt(pegs[i]);
      canvas.drawCircle(at, bare ? m.cell * 0.14 : 6, Paint()..color = Palette.held);
      if (!bare) _word(canvas, Play.names[i], at + const Offset(0, 13), Palette.held, size, 11, backed: true);
    }
    final aim = pointing;
    if (aim != null && !bare) {
      canvas.drawCircle(m.pegAt(aim.$1), 12, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    canvas.restore();
    if (bare || !m.roomy) return;
    final String words;
    if (play.full) {
      final (a, b) = play.lengthsSquared!;
      words = 'joins ${Rules.tellLength(a)} and ${Rules.tellLength(b)} long, ${play.atRightAngles ? 'at right angles' : 'askew'}';
    } else {
      words = 'pegs ${pegs.length} of 4';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), play.full ? Palette.gold : Palette.inkDim, size, 12, backed: true);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool backed = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize))),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    if (backed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 2, y - 1, text.width + 4, text.height + 2), const Radius.circular(3)),
        Paint()..color = Palette.night,
      );
    }
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(SquareView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

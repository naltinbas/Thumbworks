import 'dart:math';

import 'package:flutter/material.dart';

import '../chord/frac.dart';
import '../chord/play.dart';
import '../chord/rules.dart';
import 'palette.dart';

/// Where the wheel sits in a board of a given size: the middle in the
/// middle, five units to the rim, y up.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare ? 0.0 : (roomy ? 30.0 : 0.0);
    final side = min(size.width, size.height - strip);
    centre = Offset(size.width / 2, (size.height - strip) / 2);
    unit = (side / 2 - (bare ? 10 : 24)) / Rules.radius;
  }

  final Play play;
  final Size size;
  late final Offset centre;

  /// Pixels to a whole unit of the wheel.
  late final double unit;

  Offset at(double x, double y) => centre + Offset(x * unit, -y * unit);

  Offset pegAt(int i) => at(Rules.pegs[i].$1.toDouble(), Rules.pegs[i].$2.toDouble());

  Offset pointAt(Point p) => at(p.$1.toDouble, p.$2.toDouble);

  /// The peg under a point, or null.
  int? under(Offset p) {
    for (var i = 0; i < Rules.pegs.length; i++) {
      if ((pegAt(i) - p).distance <= max(14.0, unit * 0.55)) return i;
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The wheel, the pegs, the two chords and where they cross.
class WheelView extends CustomPainter {
  const WheelView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The peg the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the wheel and the chords only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawCircle(m.centre, Rules.radius * m.unit, Paint()..color = Palette.rim..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
    canvas.drawCircle(m.centre, bare ? 4 : 2.5, Paint()..color = Palette.middle);
    // The chords.
    final chosen = play.chosen;
    for (var k = 0; k + 1 < chosen.length; k += 2) {
      canvas.drawLine(
        m.pegAt(chosen[k]),
        m.pegAt(chosen[k + 1]),
        Paint()..color = k == 0 ? Palette.one : Palette.two..strokeWidth = bare ? 5 : 3..strokeCap = StrokeCap.round,
      );
    }
    // The pegs.
    for (var i = 0; i < Rules.pegs.length; i++) {
      final at = chosen.indexOf(i);
      final colour = at < 0 ? Palette.peg : at < 2 ? Palette.one : Palette.two;
      canvas.drawCircle(m.pegAt(i), bare ? 8 : 6, Paint()..color = colour);
      if (at >= 0) canvas.drawCircle(m.pegAt(i), bare ? 11 : 9, Paint()..color = colour..style = PaintingStyle.stroke..strokeWidth = 1.5);
      if (pointing == i && !bare) {
        canvas.drawCircle(m.pegAt(i), 13, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
      }
    }
    // The crossing and the pieces.
    final p = play.crossing;
    if (p != null) {
      final q = m.pointAt(p);
      canvas.drawCircle(q, bare ? 9 : 6, Paint()..color = Palette.crossing);
      if (!bare) {
        for (var k = 0; k < 4; k++) {
          final peg = Rules.pegs[chosen[k]];
          final end = m.pegAt(chosen[k]);
          final mid = Offset.lerp(q, end, 0.5)!;
          final away = _perp(end - q) * (k < 2 ? 13.0 : -13.0);
          _word(canvas, Rules.tellLength(Rules.piece2(p, peg)), mid + away, k < 2 ? Palette.one : Palette.two, size, 11, backed: true);
        }
      }
    }
    if (bare) return;
    if (!m.roomy) return;
    final products = play.products;
    final String words;
    if (products != null) {
      words = '${_told(p!, 0)} = ${products.$1}, ${_told(p, 2)} = ${products.$2}; 25 less ${Frac.of(25) - Rules.power(p)} is ${Rules.power(p)}';
    } else if (chosen.length == 4) {
      words = 'the chords do not cross inside the wheel';
    } else {
      words = 'pegs ${chosen.length} of 4';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 12), Palette.inkDim, size, 12);
  }

  /// The product of the pieces of the chord starting at [k], told.
  String _told(Point p, int k) =>
      '${Rules.tellLength(Rules.piece2(p, Rules.pegs[play.chosen[k]]))} times ${Rules.tellLength(Rules.piece2(p, Rules.pegs[play.chosen[k + 1]]))}';

  Offset _perp(Offset v) {
    final d = v.distance;
    if (d < 1e-9) return const Offset(0, -1);
    return Offset(-v.dy / d, v.dx / d);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool backed = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    if (backed) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 3, y - 1, text.width + 6, text.height + 2), const Radius.circular(4)),
        Paint()..color = Palette.night,
      );
    }
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(WheelView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../kiss/play.dart';
import '../kiss/rules.dart';
import 'palette.dart';

/// A bubble as drawn: its middle and its radius, in bubble units, a
/// unit bubble one across.
class Bubble {
  const Bubble(this.centre, this.radius);
  final Offset centre;
  final double radius;
}

/// Where the bubbles sit in a board of a given size, worked from the
/// three bends: the first two side by side, the third above, the one in
/// the gap and the outer one found by Descartes' rule for middles, and
/// the lot fitted to the board.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final k = play.bends;
    final r = [for (final b in k) 1 / b];
    // The three, kissing: the third above the first two.
    final d12 = r[0] + r[1], d13 = r[0] + r[2], d23 = r[1] + r[2];
    final x3 = (d13 * d13 - d23 * d23 + d12 * d12) / (2 * d12);
    final y3 = sqrt(max(0.0, d13 * d13 - x3 * x3));
    three = [Bubble(Offset.zero, r[0]), Bubble(Offset(d12, 0), r[1]), Bubble(Offset(x3, y3), r[2])];
    // The fourths, by the rule for middles: the bends times the middles
    // added, give or take twice a root of the pairwise products, over
    // the fourth bend; the sign is whichever kisses all three.
    final s = Rules.sum(k).toDouble(), q = Rules.pairs(k).toDouble();
    final innerBend = s + 2 * sqrt(q), outerBend = s - 2 * sqrt(q);
    inner = _fourth(innerBend);
    outer = outerBend.abs() < 1e-9 ? null : _fourth(outerBend);
    // The line the outer bubble flattens to, when it does: the common
    // tangent of the first two on the far side from the third.
    line = outer == null ? _flatLine() : null;
    // The fit: the three and the one in the gap, and the outer when it
    // is not too wide.
    var left = three.map((b) => b.centre.dx - b.radius).reduce(min);
    var right = three.map((b) => b.centre.dx + b.radius).reduce(max);
    var bottom = three.map((b) => b.centre.dy - b.radius).reduce(min);
    var top = three.map((b) => b.centre.dy + b.radius).reduce(max);
    final o = outer;
    if (o != null && o.radius <= 3 * (right - left)) {
      left = min(left, o.centre.dx - o.radius);
      right = max(right, o.centre.dx + o.radius);
      bottom = min(bottom, o.centre.dy - o.radius);
      top = max(top, o.centre.dy + o.radius);
    }
    if (line != null) bottom = min(bottom, three.map((b) => b.centre.dy - b.radius).reduce(min) - 0.15 * (right - left));
    final strip = bare || !roomy ? 0.0 : 26.0;
    final pad = bare ? 0.06 : 0.1;
    final w = (right - left) * (1 + 2 * pad), h = (top - bottom) * (1 + 2 * pad);
    scale = min((size.width - (bare ? 0 : 16)) / w, (size.height - strip - (bare ? 0 : 8)) / h);
    origin = Offset(size.width / 2 - scale * (left + right) / 2, (size.height - strip) / 2 + scale * (top + bottom) / 2);
  }

  final Play play;
  final Size size;
  late final List<Bubble> three;
  late final Bubble inner;
  late final Bubble? outer;

  /// The flat outer bubble as a line, two points of it, or null.
  late final (Offset, Offset)? line;
  late final double scale;
  late final Offset origin;

  /// A bubble unit point to the board.
  Offset at(Offset p) => Offset(origin.dx + p.dx * scale, origin.dy - p.dy * scale);

  Bubble _fourth(double bend) {
    final k = play.bends;
    final z = three.map((b) => b.centre).toList();
    // The bends times the middles added.
    var sx = 0.0, sy = 0.0;
    for (var i = 0; i < 3; i++) {
      sx += k[i] * z[i].dx;
      sy += k[i] * z[i].dy;
    }
    // The pairwise products of bend times middle, as complex numbers.
    Offset mul(Offset a, Offset b) => Offset(a.dx * b.dx - a.dy * b.dy, a.dx * b.dy + a.dy * b.dx);
    var px = 0.0, py = 0.0;
    for (var i = 0; i < 3; i++) {
      final j = (i + 1) % 3;
      final m = mul(z[i] * k[i].toDouble(), z[j] * k[j].toDouble());
      px += m.dx;
      py += m.dy;
    }
    // Its complex root.
    final mag = sqrt(sqrt(px * px + py * py));
    final ang = atan2(py, px) / 2;
    final root = Offset(mag * cos(ang), mag * sin(ang));
    final radius = 1 / bend.abs();
    Bubble? best;
    var bestMiss = double.infinity;
    for (final sign in [1.0, -1.0]) {
      final c = Offset((sx + 2 * sign * root.dx) / bend, (sy + 2 * sign * root.dy) / bend);
      // How far from kissing all three: outside kisses at r + ri, a wrap at r - ri.
      var miss = 0.0;
      for (final b in three) {
        final d = (c - b.centre).distance;
        miss += (bend > 0 ? (d - (radius + b.radius)).abs() : (d - (radius - b.radius)).abs());
      }
      if (miss < bestMiss) {
        bestMiss = miss;
        best = Bubble(c, radius);
      }
    }
    return best!;
  }

  (Offset, Offset) _flatLine() {
    // The lower common tangent of the first two bubbles, both resting on
    // it: it runs at the slope that touches both from below.
    final a = three[0], b = three[1];
    final d = b.centre.dx - a.centre.dx;
    final ang = asin((b.radius - a.radius) / d);
    // The line's normal points up into the bubbles.
    final n = Offset(-sin(ang), cos(ang));
    final p = a.centre - n * a.radius;
    final dir = Offset(cos(ang), sin(ang));
    return (p - dir * 4, p + dir * 4);
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The three bubbles, the one in the gap and the outer one, and their
/// bends written on them.
class KissView extends CustomPainter {
  const KissView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (place, by).
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the bubbles only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final thick = bare ? max(2.0, m.scale * 0.03) : 2.0;
    // The outer bubble, or its line.
    final o = m.outer;
    if (o != null) {
      canvas.drawCircle(m.at(o.centre), o.radius * m.scale, Paint()..color = Palette.copperFill);
      canvas.drawCircle(m.at(o.centre), o.radius * m.scale, Paint()..color = Palette.copper..style = PaintingStyle.stroke..strokeWidth = thick);
    }
    final l = m.line;
    if (l != null) {
      canvas.drawLine(m.at(l.$1), m.at(l.$2), Paint()..color = Palette.copper..strokeWidth = thick);
    }
    // The three.
    for (var i = 0; i < 3; i++) {
      final b = m.three[i];
      canvas.drawCircle(m.at(b.centre), b.radius * m.scale, Paint()..color = Palette.chalkFill);
      canvas.drawCircle(m.at(b.centre), b.radius * m.scale, Paint()..color = Palette.chalk..style = PaintingStyle.stroke..strokeWidth = thick);
    }
    // The one in the gap.
    canvas.drawCircle(m.at(m.inner.centre), m.inner.radius * m.scale, Paint()..color = Palette.goldFill);
    canvas.drawCircle(m.at(m.inner.centre), m.inner.radius * m.scale, Paint()..color = Palette.gold..style = PaintingStyle.stroke..strokeWidth = thick);
    // The bends written on the bubbles that have room.
    for (var i = 0; i < 3; i++) {
      final b = m.three[i];
      final room = b.radius * m.scale;
      if (room >= 9) _word(canvas, '${play.bends[i]}', m.at(b.centre), Palette.chalk, size, min(room * 0.7, bare ? 60 : 16), bold: true);
    }
    final innerRoom = m.inner.radius * m.scale;
    if (innerRoom >= 9 && play.whole) _word(canvas, '${play.fourths!.$1}', m.at(m.inner.centre), Palette.gold, size, min(innerRoom * 0.7, bare ? 60 : 16), bold: true);
    if (!bare && o != null && play.whole) {
      _word(canvas, '${play.fourths!.$2}', m.at(o.centre) + Offset(0, o.radius * m.scale - 12), Palette.copper, size, 12, bold: true);
    }
    canvas.restore();
    if (bare) return;
    // The pointer: a ring round the dial's bubble.
    final aim = pointing;
    if (aim != null) {
      final b = m.three[aim.$1];
      canvas.drawCircle(m.at(b.centre), b.radius * m.scale + 6, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    if (!m.roomy) return;
    final outerWords = m.outer == null ? 'a line' : play.outerSign < 0 ? 'round the outside' : 'in the far gap';
    _word(canvas, 'in the gap ${play.inner}, the outer ${play.outer}, $outerWords', Offset(size.width / 2, size.height - 11), play.whole ? Palette.gold : Palette.inkDim, size, 11);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool bold = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize), fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(KissView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

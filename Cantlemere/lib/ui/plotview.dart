import 'dart:math';

import 'package:flutter/material.dart';

import '../plot/play.dart';
import '../plot/rules.dart';
import 'palette.dart';

/// Where the field sits in a board of a given size. It is square and it
/// never moves; the pegs sit at its whole points, peg 0 at the bottom
/// left, and up on the screen is up in the field.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 38.0;
    final room = Size(size.width - 20, size.height - words - 20);
    step = min(room.width, room.height) / Rules.side;
    left = 10 + (room.width - step * Rules.side) / 2;
    bottom = 10 + words / 2 + (room.height + step * Rules.side) / 2;
    peg = min(step * 0.13, bare ? 22.0 : 11.0);
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double step, left, bottom, peg;

  /// Whether there is room for words under the field.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  Offset at(int x, int y) => Offset(left + x * step, bottom - y * step);

  Offset spot(int p) {
    final (x, y) = Rules.peg(p);
    return at(x, y);
  }

  /// The peg a tap means, or null when it lands nowhere near one.
  int? pegNear(Offset touch) {
    int? best;
    var away = peg * 2.1;
    for (var p = 0; p < Rules.pegs; p++) {
      final d = (spot(p) - touch).distance;
      if (d < away) {
        away = d;
        best = p;
      }
    }
    return best;
  }

  /// The laid plot a tap falls inside, or null. Used for lifting one off
  /// again, so it is only asked once no peg is near.
  int? plotUnder(Offset touch) {
    for (final p in play.laid) {
      final corners = Rules.plots[p];
      var sign = 0;
      var inside = true;
      for (var i = 0; i < 3; i++) {
        final a = spot(corners[i]), b = spot(corners[(i + 1) % 3]);
        final side = (b.dx - a.dx) * (touch.dy - a.dy) -
            (b.dy - a.dy) * (touch.dx - a.dx);
        final s = side > 0 ? 1 : (side < 0 ? -1 : 0);
        if (s == 0) continue;
        if (sign == 0) {
          sign = s;
        } else if (sign != s) {
          inside = false;
          break;
        }
      }
      if (inside) return p;
    }
    return null;
  }
}

/// The field, the plots laid on it, and the coloured pegs.
class PlotView extends CustomPainter {
  const PlotView({
    required this.play,
    this.pointing,
    this.showWhyNot = false,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The peg the show-me points at, or null.
  final int? pointing;

  /// Whether to pick out the motley plot and the plot that takes half
  /// the field, which are the two reasons the last ask cannot be done.
  final bool showWhyNot;

  final TextStyle labels;

  /// Whether to draw the field alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);

    // The field itself.
    final field = Rect.fromPoints(
        m.at(0, Rules.side), m.at(Rules.side, 0));
    canvas.drawRect(field, Paint()..color = Palette.ground);

    // The plots, each in turned earth, a shade apart from its neighbour
    // so the cut can be read.
    for (var k = 0; k < play.laid.length; k++) {
      final corners = Rules.plots[play.laid[k]];
      final path = Path()..moveTo(m.spot(corners[0]).dx, m.spot(corners[0]).dy);
      for (var i = 1; i < 3; i++) {
        path.lineTo(m.spot(corners[i]).dx, m.spot(corners[i]).dy);
      }
      path.close();
      final motley = Rules.motley(corners);
      final half = Rules.halves(corners) * 2 == Rules.field;
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.plot
              .withValues(alpha: 0.20 + 0.07 * (k % 3)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = showWhyNot && motley
              ? Palette.plotEdge
              : showWhyNot && half
                  ? Palette.blue
                  : Palette.plotEdge.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : (showWhyNot && (motley || half) ? 2.6 : 1.4),
      );
      if (!bare && m.roomy) {
        final middle = Offset(
          (m.spot(corners[0]).dx + m.spot(corners[1]).dx + m.spot(corners[2]).dx) / 3,
          (m.spot(corners[0]).dy + m.spot(corners[1]).dy + m.spot(corners[2]).dy) / 3,
        );
        // A dark backing, so a size that lands on a peg still reads.
        canvas.drawCircle(middle, m.peg * 0.95,
            Paint()..color = Palette.night.withValues(alpha: 0.72));
        _word(canvas, '${Rules.halves(corners)}', middle, Palette.ink, size,
            m.peg * 1.1);
      }
    }

    // The fence round the field.
    canvas.drawRect(
      field,
      Paint()
        ..color = Palette.fence
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 3 : 1.6,
    );

    // The pegs, painted by their own two numbers.
    for (var p = 0; p < Rules.pegs; p++) {
      final held = play.holding.contains(p);
      final colour = switch (Rules.colour(p)) {
        0 => Palette.red,
        1 => Palette.blue,
        _ => Palette.green,
      };
      canvas.drawCircle(m.spot(p), m.peg, Paint()..color = colour);
      if (!bare && (held || pointing == p)) {
        canvas.drawCircle(
          m.spot(p),
          m.peg * 1.9,
          Paint()
            ..color = held ? Palette.ink : Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    if (bare || !m.roomy) return;
    _word(
      canvas,
      play.holding.isEmpty
          ? 'the field is ${Rules.field} half acres; '
              '${play.taken} laid, ${play.left} left'
          : '${play.holding.length} of three pegs tapped',
      Offset(size.width / 2, size.height - 9),
      Palette.inkDim,
      size,
      10,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(PlotView old) =>
      old.play.laid.length != play.laid.length ||
      old.play.mark != play.mark ||
      old.play.holding.length != play.holding.length ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showWhyNot != showWhyNot ||
      old.bare != bare;
}

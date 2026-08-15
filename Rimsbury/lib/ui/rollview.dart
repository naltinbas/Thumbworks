import 'dart:math';

import 'package:flutter/material.dart';

import '../roll/play.dart';
import '../roll/rules.dart';
import 'palette.dart';

/// Where the hoop and the roller sit in a board of a given size: units
/// to pixels, the trip starting at the top and going anticlockwise.
class Metrics {
  Metrics(this.play, this.size) {
    // A roomy board keeps a strip at the bottom for the caption.
    final strip = roomy ? 26.0 : 0.0;
    centre = Offset(size.width / 2, (size.height - strip) / 2);
    // Inside, a roller too big for the hoop is drawn over it, so the
    // bigger of the two sets the size.
    final extent = play.inside ? max(play.hoop, play.coin) : play.hoop + 2 * play.coin;
    scale = (min(size.width, size.height - strip) / 2 - 12) / extent;
  }

  final Play play;
  final Size size;
  late final Offset centre;
  late final double scale;

  /// A point in units, the trip's start on the right, turned so the
  /// start is at the top of the board.
  Offset at(double x, double y) => centre + Offset(-y, -x) * scale;

  /// The roller's centre and its mark when it has gone [theta] round.
  (Offset, Offset) placed(double theta) {
    final (cx, cy, mx, my) = Rules.place(play.hoop, play.coin, play.inside, theta);
    return (at(cx, cy), at(mx, my));
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The hoop, the roller at its start and as ghosts round the trip, and
/// the mark's path.
class RollView extends CustomPainter {
  const RollView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the coins only, for the mark: no words, no ghosts.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final hoopR = play.hoop * m.scale, coinR = play.coin * m.scale;
    // The hoop.
    canvas.drawCircle(m.centre, hoopR, Paint()..color = Palette.hoopFace);
    canvas.drawCircle(
      m.centre,
      hoopR,
      Paint()
        ..color = Palette.hoop
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 4 : 2.5,
    );
    if (!play.fits) {
      // The roller does not fit: it lies over the hoop, crossed out.
      canvas.drawCircle(m.centre, coinR, Paint()..color = Palette.rollerFace.withValues(alpha: 0.8));
      canvas.drawCircle(
        m.centre,
        coinR,
        Paint()
          ..color = Palette.misfit
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      final cross = Paint()
        ..color = Palette.misfit
        ..strokeWidth = 3;
      final d = coinR * 0.5;
      canvas.drawLine(m.centre + Offset(-d, -d), m.centre + Offset(d, d), cross);
      canvas.drawLine(m.centre + Offset(-d, d), m.centre + Offset(d, -d), cross);
      if (m.roomy) _word(canvas, 'does not fit', m.centre + Offset(0, coinR + 14), Palette.misfit, size);
      return;
    }
    // The mark's path round one trip.
    final path = Path();
    for (var k = 0; k <= 720; k++) {
      final (_, mark) = m.placed(2 * pi * k / 720);
      if (k == 0) {
        path.moveTo(mark.dx, mark.dy);
      } else {
        path.lineTo(mark.dx, mark.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.path
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 3 : 1.5,
    );
    // The ghosts of the roller round the trip, mark spokes and all.
    if (!bare) {
      for (var k = 1; k < 8; k++) {
        final (c, mark) = m.placed(2 * pi * k / 8);
        canvas.drawCircle(
          c,
          coinR,
          Paint()
            ..color = Palette.ghost
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        canvas.drawLine(c, mark, Paint()..color = Palette.ghost..strokeWidth = 1.5);
        canvas.drawCircle(mark, 2.5, Paint()..color = Palette.mark.withValues(alpha: 0.55));
      }
    }
    // The roller at its start, its mark on the hoop.
    final (start, mark) = m.placed(0);
    canvas.drawCircle(start, coinR, Paint()..color = Palette.rollerFace);
    canvas.drawCircle(
      start,
      coinR,
      Paint()
        ..color = Palette.roller
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 4 : 2.5,
    );
    canvas.drawLine(start, mark, Paint()..color = Palette.mark..strokeWidth = bare ? 4 : 2.5);
    canvas.drawCircle(mark, bare ? 7 : 4.5, Paint()..color = Palette.mark);
    if (bare || !m.roomy) return;
    _word(canvas, 'start', start - (mark - start) * 0.5, Palette.roller, size);
    final turns = play.turns!;
    _word(canvas, '${Rules.fraction(turns)} turn${turns == (1, 1) ? '' : 's'} a trip, ${play.inside ? 'inside' : 'outside'}, anticlockwise', Offset(size.width / 2, size.height - 12), Palette.inkDim, size);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(RollView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

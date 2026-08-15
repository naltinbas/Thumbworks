import 'dart:math';

import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import 'palette.dart';

/// Where the yard sits in a board of a given size: berths to pixels.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 22.0 : 0.0;
    cell = min((size.width - 16) / 3, (size.height - strip - 16) / 3);
    origin = Offset(size.width / 2 - 1.5 * cell, (size.height - strip) / 2 - 1.5 * cell);
  }

  final Play play;
  final Size size;
  late final double cell;
  late final Offset origin;

  /// The rectangle of berth [i].
  Rect rect(int i) => Rect.fromLTWH(origin.dx + (i % 3) * cell, origin.dy + (i ~/ 3) * cell, cell, cell);

  /// The berth under a point, or null.
  int? under(Offset p) {
    final c = ((p.dx - origin.dx) / cell).floor(), r = ((p.dy - origin.dy) / cell).floor();
    if (c < 0 || c > 2 || r < 0 || r > 2) return null;
    return r * 3 + c;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The yard: berths, wagons and the gap, the pointer's ring.
class YardView extends CustomPainter {
  const YardView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The berth the show-me rings, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the yard only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    for (var i = 0; i < 9; i++) {
      final r = m.rect(i).deflate(2);
      canvas.drawRect(r, Paint()..color = play.yard[i] == 0 ? Palette.gap : Palette.berth);
      canvas.drawRect(
        r,
        Paint()
          ..color = Palette.berthRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      final wagon = play.yard[i];
      if (wagon == 0) continue;
      final home = Rules.home[i] == wagon;
      final w = r.deflate(m.cell * 0.09);
      final rr = RRect.fromRectAndRadius(w, Radius.circular(m.cell * 0.12));
      canvas.drawRRect(rr, Paint()..color = home ? Palette.wagonHome : Palette.wagon);
      canvas.drawRRect(
        rr,
        Paint()
          ..color = home ? Palette.wagonHomeRim : Palette.wagonRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 4 : 2,
      );
      // Wheels.
      final wheel = Paint()..color = Palette.night;
      canvas.drawCircle(Offset(w.left + w.width * 0.25, w.bottom - m.cell * 0.05), m.cell * 0.06, wheel);
      canvas.drawCircle(Offset(w.right - w.width * 0.25, w.bottom - m.cell * 0.05), m.cell * 0.06, wheel);
      _word(canvas, '$wagon', w.center, Palette.chalk, size, m.cell * (bare ? 0.42 : 0.34));
    }
    if (bare) return;
    final aim = pointing;
    if (aim != null) {
      canvas.drawRect(
        m.rect(aim).deflate(4),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (!m.roomy) return;
    final few = play.fewest;
    _word(canvas, few == null ? 'no way home: ${play.inversions} pair${play.inversions == 1 ? '' : 's'} out of order, odd' : few == 0 ? 'home: nought out of order' : 'fewest home from here $few; ${play.inversions} pairs out of order', Offset(size.width / 2, size.height - 11), Palette.inkDim, size, 11);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: fontSize, fontWeight: fontSize > 14 ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(YardView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

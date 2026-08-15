import 'dart:math';

import 'package:flutter/material.dart';

import '../kite/play.dart';
import 'palette.dart';

/// Where the kite sits in a board of a given size: cells to pixels.
class Metrics {
  Metrics(this.play, this.size) {
    final order = play.level.order;
    final strip = roomy ? 22.0 : 0.0;
    cell = min((size.width - 16) / (2 * order), (size.height - strip - 16) / (2 * order));
    origin = Offset(size.width / 2, (size.height - strip) / 2);
  }

  final Play play;
  final Size size;
  late final double cell;
  late final Offset origin;

  /// The rectangle of kite cell [i].
  Rect rect(int i) {
    final (x, y) = play.level.kite.cells[i];
    return Rect.fromLTWH(origin.dx + x * cell, origin.dy + y * cell, cell, cell);
  }

  /// The cell under a point, or null.
  int? under(Offset p) {
    final x = ((p.dx - origin.dx) / cell).floor(), y = ((p.dy - origin.dy) / cell).floor();
    return play.level.kite.index[(x, y)];
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The kite, its slates, the picked cell and the pointer's ring.
class KiteView extends CustomPainter {
  const KiteView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the kite only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final kite = play.level.kite;
    // Bare cells, outlined so they can be tapped.
    for (var i = 0; i < kite.count; i++) {
      final r = m.rect(i).deflate(1);
      canvas.drawRect(r, Paint()..color = Palette.bare);
      canvas.drawRect(
        r,
        Paint()
          ..color = Palette.bareRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    // The slates, coloured across or down and by the parity of their
    // low cell, the four kinds of the kite.
    for (final (a, b) in play.laid) {
      final r = m.rect(a).expandToInclude(m.rect(b)).deflate(bare ? 2 : 2.5);
      final (x, y) = kite.cells[a];
      final even = (x + y).isEven;
      final colour = kite.across(a, b) ? (even ? Palette.acrossEven : Palette.acrossOdd) : (even ? Palette.downEven : Palette.downOdd);
      final rr = RRect.fromRectAndRadius(r, Radius.circular(bare ? 6 : 4));
      canvas.drawRRect(rr, Paint()..color = colour);
      canvas.drawRRect(
        rr,
        Paint()
          ..color = Palette.slateRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : 1.5,
      );
    }
    if (bare) return;
    final picked = play.picked;
    if (picked != null) {
      canvas.drawRect(
        m.rect(picked).deflate(2),
        Paint()
          ..color = Palette.picked
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        m.rect(aim.$2).center,
        m.cell * 0.32,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (!m.roomy) return;
    _word(canvas, '${play.acrossCount} across, ${play.downCount} down, ${kite.count - 2 * play.laid.length} cells bare', Offset(size.width / 2, size.height - 11), Palette.inkDim, size);
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
  bool shouldRepaint(KiteView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

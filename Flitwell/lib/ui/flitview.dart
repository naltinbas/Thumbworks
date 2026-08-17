import 'dart:math';

import 'package:flutter/material.dart';

import '../flit/play.dart';
import '../flit/rules.dart';
import 'palette.dart';

/// Where the four cottages sit in a board of a given size.
///
/// They are a square of four, A and B along the top and C and D below,
/// and they never move. The tenants do.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 22.0;
    final room = Size(size.width - 16, size.height - words - 16);
    cellWidth = room.width / 2;
    cellHeight = min(room.height / 2, cellWidth * 1.05);
    left = 8;
    top = 8 + (room.height - cellHeight * 2) / 2;
    wide = min(cellWidth * 0.86, cellHeight * 0.82);
    tall = wide * 0.94;
    disc = wide * 0.21;
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double cellWidth, cellHeight, left, top, wide, tall, disc;

  /// Whether there is room for words under the board.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  /// The middle of a cottage, roof and all.
  Offset cottage(int c) => Offset(
        left + (c % 2 + 0.5) * cellWidth,
        top + (c ~/ 2 + 0.5) * cellHeight,
      );

  /// The walls of a cottage, which is the part a tenant is inside.
  Rect walls(int c) {
    final middle = cottage(c);
    return Rect.fromCenter(
      center: middle + Offset(0, tall * 0.12),
      width: wide,
      height: tall * 0.74,
    );
  }

  /// Where the tenant living in cottage [c] is drawn.
  Offset seat(int c) => walls(c).center - Offset(0, walls(c).height * 0.16);

  /// Where tenant [t] is drawn, which is inside whichever cottage they
  /// are in.
  Offset perch(int t) => seat(play.where[t]);

  /// The tenant a tap means, or null when it lands nowhere near one.
  int? tenantNear(Offset touch) {
    int? best;
    var away = wide * 0.42;
    for (var t = 0; t < Rules.cottages; t++) {
      final d = (perch(t) - touch).distance;
      if (d < away) {
        away = d;
        best = t;
      }
    }
    return best;
  }
}

/// The lane, its four cottages, and who is living in each.
class FlitView extends CustomPainter {
  const FlitView({
    required this.play,
    this.pointing,
    this.showWhyNot = false,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The two tenants the show-me wants swapped, or null.
  final (int, int)? pointing;

  /// Whether to pick out the tenants who already have the cottage they
  /// want most, which is the reason an ask cannot be landed.
  final bool showWhyNot;

  final TextStyle labels;

  /// Whether to draw the lane alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final living = play.living;
    final topped = play.topped;

    for (var c = 0; c < Rules.cottages; c++) {
      final walls = m.walls(c);
      final middle = m.cottage(c);
      final t = living[c];
      final rank = Rules.rank(play.orders, t, c);
      final shade = rank == 0
          ? Palette.best
          : rank == Rules.cottages - 1
              ? Palette.worst
              : Palette.inkDim;

      // The roof, then the walls.
      final roof = Path()
        ..moveTo(walls.left - m.wide * 0.06, walls.top)
        ..lineTo(middle.dx, walls.top - m.tall * 0.24)
        ..lineTo(walls.right + m.wide * 0.06, walls.top)
        ..close();
      canvas.drawPath(roof, Paint()..color = Palette.roof);
      canvas.drawRect(walls, Paint()..color = Palette.wall);
      canvas.drawRect(
        walls,
        Paint()
          ..color = shade
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 2.6 : 1.6,
      );
      if (!bare) {
        _word(canvas, Rules.letter(c), middle - Offset(0, m.tall * 0.36),
            Palette.inkDim, size, m.wide * 0.13);
      }

      // The tenant inside.
      final ringed = showWhyNot && topped.contains(t);
      canvas.drawCircle(m.seat(c), m.disc, Paint()..color = Palette.tenant);
      if (!bare) {
        _word(canvas, Rules.letter(t), m.seat(c), Palette.night, size,
            m.disc * 1.15);
      }
      if (!bare && (play.held == t || (pointing?.$1 == t) ||
          (pointing?.$2 == t) || ringed)) {
        canvas.drawCircle(
          m.seat(c),
          m.disc * 1.32,
          Paint()
            ..color = play.held == t
                ? Palette.ink
                : ringed
                    ? Palette.best
                    : Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }

      // What this tenant wants, best first, with the cottage they are
      // in picked out. This is the whole of what a player has to read.
      if (bare) continue;
      final order = play.orders[t];
      final step = m.wide * 0.19;
      for (var k = 0; k < order.length; k++) {
        final at = Offset(
          walls.center.dx + (k - (order.length - 1) / 2) * step,
          walls.bottom - m.tall * 0.14,
        );
        if (order[k] == c) {
          canvas.drawCircle(
            at,
            step * 0.42,
            Paint()
              ..color = shade
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.4,
          );
        }
        _word(canvas, Rules.letter(order[k]), at,
            order[k] == c ? shade : Palette.inkDim, size, m.wide * 0.12);
      }
    }

    if (bare || !m.roomy) return;
    final standings = play.standings;
    _word(
      canvas,
      'each tenant wants left to right; '
      '${standings.where((r) => r == 0).length} of 4 have their first choice',
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
  bool shouldRepaint(FlitView old) =>
      old.play.where.toString() != play.where.toString() ||
      old.play.held != play.held ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showWhyNot != showWhyNot ||
      old.bare != bare;
}

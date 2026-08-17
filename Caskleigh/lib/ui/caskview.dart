import 'dart:math';

import 'package:flutter/material.dart';

import '../cask/play.dart';
import '../cask/rules.dart';
import 'palette.dart';

/// Where the barrels sit in a board of a given size. Each row is one
/// barrel wide; the run is poured into them left to right, a slab per
/// cask, and it spills into the next row when a barrel fills.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final rows = max(1, play.total.toDouble.ceil());
    this.rows = rows;
    pad = bare ? size.width * 0.02 : (size.width < 200 ? 4.0 : 14.0);
    barrel = size.width - pad * 2;
    final strip = roomy ? 34.0 : 0.0;
    final words = roomy ? 34.0 : 0.0;
    final room = size.height - strip - words - 12;
    // The mark fills its square; a board on a phone keeps its rows to a
    // reading height and leaves the rest of the room alone.
    row = bare ? room / rows : max(6.0, min(40.0, room / rows));
    top = max(4.0, (size.height - words - strip - row * rows) / 2);
    twos =
        Rect.fromLTWH(pad, top + row * rows + 16, barrel, max(0.0, strip - 16));
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;
  late final int rows;
  late final double pad, barrel, row, top;
  late final Rect twos;

  /// Whether there is room for words and the twos strip.
  bool get roomy => !bare && size.height >= 190 && size.width >= 250;

  Rect rowRect(int i) => Rect.fromLTWH(pad, top + row * i, barrel, row);
}

/// The run of casks poured into barrels, and the twos under it.
class CaskView extends CustomPainter {
  const CaskView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the barrels only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final deepest = play.deepest.first;
    // The slabs, one per cask, laid end to end and spilling from barrel
    // to barrel.
    var at = 0.0;
    for (var k = play.first; k <= play.last; k++) {
      var left = 1 / k;
      final lit = k == deepest;
      while (left > 1e-12) {
        final row = at.floor();
        if (row >= m.rows) break;
        final x0 = at - row;
        final take = min(left, 1 - x0);
        final r = m.rowRect(row);
        final slab = Rect.fromLTRB(
          r.left + x0 * m.barrel,
          r.top + 2,
          r.left + (x0 + take) * m.barrel,
          r.bottom - 2,
        );
        canvas.drawRect(
          slab,
          Paint()
            ..color = lit
                ? Palette.deep
                : (k.isEven ? Palette.wine : Palette.wineLight),
        );
        if (slab.width > 3) {
          canvas.drawRect(
            slab,
            Paint()
              ..color = Palette.night
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
        if (!bare && slab.width > 17 && slab.height > 12) {
          _word(canvas, '$k', slab.center,
              lit ? Palette.night : Palette.ink, size, 10);
        }
        at += take;
        left -= take;
      }
    }
    // The barrels themselves, hooped, drawn over the slabs.
    for (var i = 0; i < m.rows; i++) {
      canvas.drawRect(
        m.rowRect(i).deflate(0.5),
        Paint()
          ..color = Palette.hoop
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : 1.6,
      );
    }
    if (bare || !m.roomy) return;
    // The twos: a tile per cask, as tall as the twos in its number, and
    // exactly one of them is tallest.
    final strip = m.twos;
    final casks = play.casks;
    final most = Rules.mostTwos(play.first, play.last);
    final wide = strip.width / casks;
    for (var i = 0; i < casks; i++) {
      final k = play.first + i;
      final has = Rules.twos(k);
      final tall = strip.height * (has + 0.5) / (most + 1);
      final tile = Rect.fromLTWH(
          strip.left + i * wide, strip.bottom - tall, max(1.0, wide - 1), tall);
      canvas.drawRect(
          tile, Paint()..color = k == deepest ? Palette.deep : Palette.line);
    }
    _word(canvas, 'twos in each cask', Offset(strip.left + 2, strip.top - 9),
        Palette.inkDim, size, 10,
        left: true);
    _word(
        canvas,
        'the ${Rules.ordinal(deepest)} has $most, and it is the only one',
        Offset(strip.right - 2, strip.top - 9),
        Palette.deep,
        size,
        10,
        right: true);
    // The second voice, under the barrels: the same run over a common
    // bottom, where the deepest cask is what leaves the top odd.
    final bottom = Rules.commonBottom(play.first, play.last);
    final digits = bottom.toString().length;
    _word(
        canvas,
        digits <= 12
            ? 'over a common bottom of $bottom the run comes to '
                '${Rules.commonTop(play.first, play.last)}, odd over even'
            : 'over a common bottom of $digits digits the run comes out odd '
                'over even',
        Offset(size.width / 2, strip.bottom + 15),
        Palette.inkDim,
        size,
        11);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points,
      {bool left = false, bool right = false}) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x0 = left
        ? at.dx
        : right
            ? at.dx - text.width
            : at.dx - text.width / 2;
    final x = x0.clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(CaskView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}

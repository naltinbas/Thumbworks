import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../loaf/fraction.dart';
import '../loaf/play.dart';
import 'palette.dart';

/// Where the loaf and the cut tiles lie on the board, so the
/// screen and the tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    cols = 6;
    final count = play.rules.cuts.length;
    rows = (count + cols - 1) ~/ cols;
    tile = math.min(room.width * 0.92 / cols, room.height * 0.5 / rows);
    tilesLeft = (room.width - tile * cols) / 2;
    tilesTop = room.height - tile * rows - room.height * 0.03;
    loaf = Rect.fromLTWH(
      room.width * 0.06,
      room.height * 0.12,
      room.width * 0.88,
      math.min(room.height * 0.16, tile * 1.2),
    );
  }

  final Play play;

  late final int cols;
  late final int rows;
  late final double tile;
  late final double tilesLeft;
  late final double tilesTop;

  /// The loaf, drawn as a bar one whole loaf long.
  late final Rect loaf;

  /// The middle of a cut's tile.
  Offset tileAt(int den) {
    final index = den - 2;
    return Offset(
      tilesLeft + (index % cols + 0.5) * tile,
      tilesTop + (index ~/ cols + 0.5) * tile,
    );
  }

  Rect tileRect(int den) =>
      Rect.fromCenter(center: tileAt(den), width: tile, height: tile).deflate(tile * 0.06);

  /// The cut under a touch, or null.
  int? under(Offset touch) {
    for (final den in play.rules.cuts) {
      if (tileRect(den).inflate(tile * 0.06).contains(touch)) return den;
    }
    return null;
  }

  /// The crumb inside the crust: what a whole loaf is measured on.
  Rect get crumb => loaf.deflate(loaf.height * 0.12);

  /// Where along the loaf a fraction of it ends.
  double along(Fraction f) => crumb.left + crumb.width * f.num / f.den;
}

/// The board itself: the loaf with the share marked and the cuts
/// laid along it, and the tiles of cuts to take.
class LoafView extends CustomPainter {
  LoafView({required this.play, this.pointing, required this.labels});

  final Play play;
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final loaf = metrics.loaf;
    final radius = Radius.circular(loaf.height * 0.4);

    // The whole loaf, crumb inside a crust.
    canvas.drawRRect(RRect.fromRectAndRadius(loaf, radius), Paint()..color = Palette.crust);
    final crumb = metrics.crumb;
    canvas.drawRRect(
      RRect.fromRectAndRadius(crumb, radius),
      Paint()..color = Palette.crumb,
    );

    // The cuts along it, tinted in turn, rust where they run past
    // the share.
    var at = crumb.left;
    for (var i = 0; i < play.cuts.length; i++) {
      final den = play.cuts[i];
      final width = crumb.width / den;
      final over = at + width > metrics.along(play.loaf.share) + 0.5;
      final rect = Rect.fromLTWH(at, loaf.top + loaf.height * 0.18, width, loaf.height * 0.64);
      canvas.drawRect(
        rect.deflate(1),
        Paint()..color = over ? Palette.over : Palette.cuts[i % Palette.cuts.length],
      );
      if (width > loaf.height * 0.5) {
        _write(
          canvas,
          '1/$den',
          rect.center,
          labels.copyWith(
            color: Palette.crumb,
            fontSize: math.min(loaf.height * 0.32, width * 0.4),
            fontWeight: FontWeight.w800,
          ),
        );
      }
      at += width;
    }

    // The share's mark: a gold line down the loaf where the share
    // ends, and the fraction above it.
    final markX = metrics.along(play.loaf.share);
    canvas.drawLine(
      Offset(markX, loaf.top - loaf.height * 0.25),
      Offset(markX, loaf.bottom + loaf.height * 0.25),
      Paint()
        ..color = Palette.shareMark
        ..strokeWidth = math.max(2, loaf.height * 0.06),
    );
    _write(
      canvas,
      '${play.loaf.share}',
      Offset(markX, loaf.top - loaf.height * 0.55),
      labels.copyWith(color: Palette.shareMark, fontSize: loaf.height * 0.36, fontWeight: FontWeight.w800),
    );
    _write(
      canvas,
      'one whole loaf',
      Offset(loaf.center.dx, loaf.bottom + loaf.height * 0.5),
      labels.copyWith(color: Palette.inkDim, fontSize: loaf.height * 0.28),
    );

    // The tiles.
    for (final den in play.rules.cuts) {
      final rect = metrics.tileRect(den);
      final taken = play.cuts.contains(den);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(metrics.tile * 0.12)),
        Paint()..color = taken ? Palette.tileTaken : Palette.tile,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(metrics.tile * 0.12)),
        Paint()
          ..color = Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      _write(
        canvas,
        '1/$den',
        rect.center,
        labels.copyWith(
          color: taken ? Palette.tileInk : Palette.inkDim,
          fontSize: metrics.tile * 0.34,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(metrics.tileRect(aim.$2).inflate(metrics.tile * 0.03),
            Radius.circular(metrics.tile * 0.14)),
        Paint()
          ..color = aim.$1 == 'back' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, metrics.tile * 0.06),
      );
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(LoafView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a share as it stands.
String whyWords(Play play) {
  final loaf = play.loaf;
  final note = loaf.note == null ? '' : ' ${loaf.note}';
  if (!loaf.winnable) {
    return 'Two cuts, no two alike. Either one of them is a half, and '
        'then the other must be three tenths, which is no unit cut on '
        'the board or off it; or neither is, and the two biggest cuts '
        'left are a third and a quarter, seven twelfths, short of four '
        'fifths. The sweep tried every pair on the board and found '
        'none.$note';
  }
  return 'The ways are counted by the sweep, every set of cuts on the '
      'board that adds up exactly, in whole fractions, and held to a '
      'second voice: Fibonacci\'s greedy cut, always the biggest unit '
      'fraction that fits, which ends on every share, since the top of '
      'what is left falls each time; where its cuts sit on the board '
      'the sweep finds them too. ${loaf.ways} set${loaf.ways == 1 ? '' : 's'} '
      'of cuts make${loaf.ways == 1 ? 's' : ''} this share.$note';
}

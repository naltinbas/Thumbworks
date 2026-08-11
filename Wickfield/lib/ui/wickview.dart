import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wick/play.dart';
import 'palette.dart';

/// Where every lamp stands, shared by the painter and the hit-testing,
/// so where a lamp is drawn is exactly where a lamp is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final rows = play.wick.rows;
    final cols = play.wick.cols;
    // Proportional everywhere: the gap is part of the cell, so a tiny
    // canvas shrinks the whole lot rather than going negative.
    cell = math.min(
      math.min(width / (cols + 0.7), height / (rows + 0.7)),
      104.0,
    );
    gap = cell * 0.12;
    left = (width - cols * cell) / 2;
    top = (height - rows * cell) / 2;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double cell;
  late final double gap;
  late final double left;
  late final double top;

  Rect cellRect(int cell_) {
    final row = cell_ ~/ play.wick.cols;
    final col = cell_ % play.wick.cols;
    return Rect.fromLTWH(
      left + col * cell + gap / 2,
      top + row * cell + gap / 2,
      cell - gap,
      cell - gap,
    );
  }

  /// The lamp under a touch, or -1 for nowhere.
  int cellAt(Offset touch) {
    for (var at = 0; at < play.rules.cells; at++) {
      if (cellRect(at).inflate(gap / 2).contains(touch)) return at;
    }
    return -1;
  }
}

/// The lamps, drawn.
class WickView extends CustomPainter {
  WickView({
    required this.play,
    required this.pointing,
    this.answer = 0,
    this.quietPattern = 0,
  });

  final Play play;

  /// The lamp being pointed at, or -1.
  final int pointing;

  /// The presses of a lightest answer, rimmed green. Nought for none.
  final int answer;

  /// A quiet pattern's lamps, rimmed violet. Nought for none.
  final int quietPattern;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // All the glows first, so no socket ever sits on a neighbour's light.
    for (var at = 0; at < play.rules.cells; at++) {
      if (!play.lit(at)) continue;
      canvas.drawCircle(
        metrics.cellRect(at).center,
        metrics.cellRect(at).width * 0.78,
        Paint()..color = Palette.glow,
      );
    }
    for (var at = 0; at < play.rules.cells; at++) {
      _lamp(canvas, metrics, at);
    }
  }

  void _lamp(Canvas canvas, Metrics metrics, int at) {
    final rect = metrics.cellRect(at);
    final round = Radius.circular(rect.width * 0.22);
    final isLit = play.lit(at);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, round),
      Paint()..color = isLit ? Palette.socket : Palette.socketDark,
    );

    // The pane: brass when lit, a cold socket when not.
    final pane = rect.deflate(rect.width * 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(pane, Radius.circular(pane.width * 0.3)),
      Paint()..color = isLit ? Palette.lamp : Palette.night,
    );
    if (isLit) {
      canvas.drawCircle(
        pane.center + Offset(-pane.width * 0.14, -pane.width * 0.16),
        pane.width * 0.13,
        Paint()..color = Palette.lampLight,
      );
    }

    final bit = 1 << at;
    final rim = at == pointing
        ? Palette.shown
        : answer & bit != 0
            ? Palette.answer
            : quietPattern & bit != 0
                ? Palette.quiet
                : null;
    if (rim == null) return;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, round),
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(rect.width * 0.05, 1.4),
    );
  }

  @override
  bool shouldRepaint(WickView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.answer != answer ||
      old.quietPattern != quietPattern;
}

/// The words the why speaks, from the board at hand.
String whyWords(Play play) {
  final wick = play.wick;
  final note = wick.note == null ? '' : ' ${wick.note}';
  if (!wick.winnable) {
    final pattern = play.oddAgainst!;
    final standing = play.rules.overlap(play.board, pattern);
    return 'The violet lamps are a quiet pattern: pressed all together '
        'they change nothing, and any press flips an even count of '
        'them. This board lights $standing of the pattern, an odd '
        'count, and odd it stays through every press there is. Dark '
        'needs nought.$note';
  }
  final ways = wick.ways == 1
      ? 'exactly one press-set darkens this board'
      : '${wick.ways} press-sets darken this board';
  return 'The green rims are a lightest answer worked out from the '
      'crosses: press them in any order and the board goes dark, and '
      'pressing one twice is pressing it never. Altogether $ways, '
      'every one executed by the suite before it shipped.$note';
}

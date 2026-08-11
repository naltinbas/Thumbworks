import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shunt/play.dart';
import 'palette.dart';

/// Where every tile stands, shared by the painter and the hit-testing,
/// so where a tile is drawn is exactly where a tile is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final rows = play.tray.rows;
    final cols = play.tray.cols;
    // Proportional everywhere: the gap between tiles is part of the
    // cell, so a tiny canvas shrinks the lot rather than going negative.
    cell = math.min(
      math.min(width / (cols + 0.9), height / (rows + 0.9)),
      116.0,
    );
    gap = cell * 0.08;
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

  Rect trayRect() => Rect.fromLTWH(
        left - cell * 0.12,
        top - cell * 0.12,
        play.tray.cols * cell + cell * 0.24,
        play.tray.rows * cell + cell * 0.24,
      );

  Rect cellRect(int at) {
    final row = at ~/ play.tray.cols;
    final col = at % play.tray.cols;
    return Rect.fromLTWH(
      left + col * cell + gap / 2,
      top + row * cell + gap / 2,
      cell - gap,
      cell - gap,
    );
  }

  /// The cell under a touch, or -1 for nowhere.
  int cellAt(Offset touch) {
    for (var at = 0; at < play.board.length; at++) {
      if (cellRect(at).inflate(gap / 2).contains(touch)) return at;
    }
    return -1;
  }
}

/// The tray, drawn.
class ShuntView extends CustomPainter {
  ShuntView({
    required this.play,
    required this.pointing,
    this.swindled = false,
    required this.labels,
  });

  final Play play;

  /// The cell being pointed at, or -1.
  final int pointing;

  /// Whether to rim the reversed pair red, for the swindle's why.
  final bool swindled;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    final tray = metrics.trayRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(tray, Radius.circular(metrics.cell * 0.16)),
      Paint()..color = Palette.panel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tray, Radius.circular(metrics.cell * 0.16)),
      Paint()
        ..color = Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(metrics.cell * 0.02, 1.0),
    );

    final redTiles = _swindledTiles();
    for (var at = 0; at < play.board.length; at++) {
      _cell(canvas, metrics, at, redTiles);
    }
  }

  /// The tiles of the reversed pairs, when asked for.
  Set<int> _swindledTiles() {
    if (!swindled) return const {};
    return {
      for (final (one, other) in play.rules.reversedPairs(play.board)) ...[
        one,
        other,
      ],
    };
  }

  void _cell(Canvas canvas, Metrics metrics, int at, Set<int> redTiles) {
    final rect = metrics.cellRect(at);
    final round = Radius.circular(rect.width * 0.16);
    final tile = play.tileAt(at);

    if (tile == 0) {
      // The gap: a recess in the tray.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect.deflate(rect.width * 0.03), round),
        Paint()..color = Palette.well,
      );
      return;
    }

    // The block, with a shadowed foot to sit it up off the tray.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.shift(Offset(0, rect.height * 0.045)), round),
      Paint()..color = Palette.tileEdge,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, round),
      Paint()..color = Palette.tile,
    );

    final rim = at == pointing
        ? Palette.shown
        : redTiles.contains(tile)
            ? Palette.swindled
            : null;
    if (rim != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, round),
        Paint()
          ..color = rim
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(rect.width * 0.055, 1.4),
      );
    }

    final words = TextPainter(
      text: TextSpan(
        text: '$tile',
        style: labels.copyWith(
          color: redTiles.contains(tile)
              ? Palette.swindled
              : Palette.tileInk,
          fontSize: rect.height * 0.46,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      rect.center - Offset(words.width / 2, words.height / 2),
    );
  }

  @override
  bool shouldRepaint(ShuntView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.swindled != swindled;
}

/// The words the why speaks, from the tray at hand.
String whyWords(Play play) {
  final tray = play.tray;
  final note = tray.note == null ? '' : ' ${tray.note}';
  if (!tray.winnable) {
    final pairs = play.rules.reversedPairs(play.board);
    return 'Read the tiles in order, gap left out, and count the pairs '
        'standing reversed: ${pairs.length}, an odd count. A sideways '
        'shunt leaves the reading untouched, and an up-or-down one '
        'slides a tile past two others, so no shunt ever turns odd to '
        'even. Home is even, and this tray is not.$note';
  }
  final fewest = play.fewestFromHere;
  final standing = fewest == null
      ? ''
      : ' As it stands, the board is $fewest shunt'
          '${fewest == 1 ? '' : 's'} out.';
  return 'The walk from home has been everywhere shunting can go, all '
      '${tray.cols == 3 && tray.rows == 3 ? '181,440' : '360'} boards, '
      'and wrote down the fewest for each before the game ever '
      'shipped.$standing$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../garden/play.dart';
import '../garden/rules.dart';
import 'palette.dart';

/// Where every bed and chip lies, shared by the painter and the
/// hit-testing, so where a thing is drawn is exactly where it is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final size = play.garth.size;
    bed = math.min((width - 16) / size, height * 0.62 / size);
    final across = bed * size;
    corner = Offset((width - across) / 2, height * 0.06);
    board = Rect.fromLTWH(corner.dx, corner.dy, across, across);
    chip = math.min((width - 24) / size - 8, 46.0);
    flowerRowY = board.bottom + chip * 0.9;
    colourRowY = flowerRowY + chip * 1.3;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double bed;
  late final Offset corner;
  late final Rect board;
  late final double chip;
  late final double flowerRowY;
  late final double colourRowY;

  Rect bedRect(int at) {
    final size = play.garth.size;
    return Rect.fromLTWH(
      corner.dx + (at % size) * bed,
      corner.dy + (at ~/ size) * bed,
      bed,
      bed,
    );
  }

  Rect flowerChip(int flower) => _chipRect(flower, flowerRowY);
  Rect colourChip(int colour) => _chipRect(colour, colourRowY);

  Rect _chipRect(int at, double y) {
    final size = play.garth.size;
    final acrossAll = size * (chip + 8) - 8;
    return Rect.fromLTWH(
      (width - acrossAll) / 2 + at * (chip + 8),
      y,
      chip,
      chip,
    );
  }

  /// What a touch lands on: a bed, a flower chip, or a colour chip.
  (String, int)? at(Offset touch) {
    if (board.contains(touch)) {
      final size = play.garth.size;
      final column = ((touch.dx - corner.dx) / bed).floor();
      final row = ((touch.dy - corner.dy) / bed).floor();
      if (column >= 0 && row >= 0 && column < size && row < size) {
        return ('bed', row * size + column);
      }
    }
    for (var at = 0; at < play.garth.size; at++) {
      if (flowerChip(at).inflate(6).contains(touch)) {
        return ('flower', at);
      }
      if (colourChip(at).inflate(6).contains(touch)) {
        return ('colour', at);
      }
    }
    return null;
  }
}

/// The garth, drawn.
class GarthView extends CustomPainter {
  GarthView({
    required this.play,
    required this.armedFlower,
    required this.armedColour,
    required this.pointing,
    required this.showPlanting,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The chips armed at the bench, or -1.
  final int armedFlower;
  final int armedColour;

  /// The bed being pointed at, or -1.
  final int pointing;

  /// Whether to lay the known planting as ghosts.
  final bool showPlanting;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final ghost = showPlanting ? Rules.planted(play.garth.size) : null;

    for (var at = 0; at < play.garth.beds; at++) {
      final rect = metrics.bedRect(at);
      canvas.drawRect(
        rect,
        Paint()
          ..color = ((at % play.garth.size) + (at ~/ play.garth.size))
                  .isEven
              ? Palette.soil
              : Palette.soilLight,
      );
      final (flower, colour) = play.beds[at];
      if (flower >= 0) {
        _posy(canvas, rect, flower, colour, ghostly: false);
      } else if (ghost != null) {
        _posy(canvas, rect, ghost[at].$1, ghost[at].$2, ghostly: true);
      }
      if (at == pointing) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.deflate(metrics.bed * 0.06),
            Radius.circular(metrics.bed * 0.12),
          ),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      }
    }
    canvas.drawRect(
      metrics.board.deflate(0.8),
      Paint()
        ..color = Palette.edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (!showWords) return;
    for (var at = 0; at < play.garth.size; at++) {
      _flowerChip(canvas, metrics, at);
      _colourChip(canvas, metrics, at);
    }
  }

  /// A posy: a rosette whose petal count is the flower, in the colour.
  void _posy(Canvas canvas, Rect rect, int flower, int colour,
      {required bool ghostly}) {
    final middle = rect.center;
    final reach = rect.width * 0.3;
    final petals = flower + 3;
    final paint = Paint()
      ..color = ghostly
          ? Palette.ghost.withValues(alpha: 0.45)
          : Palette.posies[colour % Palette.posies.length];
    for (var petal = 0; petal < petals; petal++) {
      final turn = -math.pi / 2 + petal * 2 * math.pi / petals;
      canvas.drawCircle(
        middle + Offset(math.cos(turn), math.sin(turn)) * reach * 0.62,
        reach * 0.4,
        paint,
      );
    }
    canvas.drawCircle(
      middle,
      reach * 0.34,
      Paint()
        ..color = ghostly
            ? Palette.ghost.withValues(alpha: 0.7)
            : Palette.dusk,
    );
  }

  void _flowerChip(Canvas canvas, Metrics metrics, int flower) {
    final rect = metrics.flowerChip(flower);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.18)),
      Paint()..color = Palette.bench,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.18)),
      Paint()
        ..color = armedFlower == flower ? Palette.armed : Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = armedFlower == flower ? 2.6 : 1.2,
    );
    _posy(canvas, rect.deflate(rect.width * 0.12), flower, 1,
        ghostly: false);
  }

  void _colourChip(Canvas canvas, Metrics metrics, int colour) {
    final rect = metrics.colourChip(colour);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.18)),
      Paint()..color = Palette.posies[colour % Palette.posies.length],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.18)),
      Paint()
        ..color = armedColour == colour ? Palette.armed : Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = armedColour == colour ? 2.6 : 1.2,
    );
  }

  @override
  bool shouldRepaint(GarthView old) =>
      old.play != play ||
      old.armedFlower != armedFlower ||
      old.armedColour != armedColour ||
      old.pointing != pointing ||
      old.showPlanting != showPlanting;
}

/// The words the why speaks, from the garth at hand.
String whyWords(Play play) {
  final garth = play.garth;
  if (!garth.possible) {
    return 'Try every way, there are few, and every one repeats a posy: '
        'no garth of ${garth.size} exists, swept whole in a blink.'
        '${garth.note == null ? '' : ' ${garth.note}'}';
  }
  final planted = garth.size.isOdd
      ? 'The gold ghosts are the two-line planting: bed r,c takes flower '
          'r plus c and colour r plus twice c, wrapped, and the check '
          'passes it row, column and pairing.'
      : 'The gold ghosts are the doubled square, the known planting for '
          'four, checked row, column and pairing.';
  return '$planted${garth.note == null ? '' : ' ${garth.note}'}';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tilth/play.dart';
import 'palette.dart';

/// Where every furrow lies, shared by the painter and the hit-testing,
/// so where a furrow is drawn is exactly where a furrow is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final furrows = math.max(play.tilth.board.length, 3);
    // The whole stack, in furrow heights: half a gap, the barn and its
    // half-gap after, the rows at 1.14 apiece, and a margin under the
    // last. Divided out so the bottom furrow always lands on the canvas.
    furrowHigh = math.min(height / (3.9 + 1.14 * (furrows - 1)), 64.0);
    // Short stacks sit a little above the middle rather than hugging
    // the top of the field.
    final stack = furrowHigh * (3.5 + 1.14 * (furrows - 1));
    final topPad = math.max(0.0, (height - stack) * 0.35);
    barnRect = Rect.fromLTWH(
      width * 0.06,
      topPad + furrowHigh * 0.5,
      width * 0.26,
      furrowHigh * 1.5,
    );
    troughLeft = width * 0.08;
    troughWide = width * 0.84;
    firstTroughTop = barnRect.bottom + furrowHigh * 0.5;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double furrowHigh;
  late final Rect barnRect;
  late final double troughLeft;
  late final double troughWide;
  late final double firstTroughTop;

  Rect furrowRect(int furrow) => Rect.fromLTWH(
        troughLeft,
        firstTroughTop + (furrow - 1) * furrowHigh * 1.14,
        troughWide,
        furrowHigh,
      );

  /// The furrow under a touch, or -1 for nowhere.
  int furrowAt(Offset touch) {
    for (var furrow = 1; furrow <= play.board.length; furrow++) {
      if (furrowRect(furrow).inflate(2).contains(touch)) return furrow;
    }
    return -1;
  }
}

/// The strip, drawn.
class TilthView extends CustomPainter {
  TilthView({
    required this.play,
    required this.pointing,
    required this.showSowable,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The furrow being pointed at, or -1.
  final int pointing;

  /// Whether to rim the sowable furrows.
  final bool showSowable;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    _barn(canvas, metrics);
    final trapped = play.trapped.toSet();
    for (var furrow = 1; furrow <= play.board.length; furrow++) {
      _furrow(canvas, metrics, furrow, trapped.contains(furrow));
    }
  }

  void _barn(Canvas canvas, Metrics metrics) {
    final rect = metrics.barnRect;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top + rect.height * 0.34, rect.width,
          rect.height * 0.66),
      Paint()..color = Palette.barn,
    );
    final roof = Path()
      ..moveTo(rect.left - rect.width * 0.08, rect.top + rect.height * 0.38)
      ..lineTo(rect.center.dx, rect.top)
      ..lineTo(
          rect.right + rect.width * 0.08, rect.top + rect.height * 0.38)
      ..close();
    canvas.drawPath(roof, Paint()..color = Palette.roof);

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '${play.barned}',
        style: labels.copyWith(
          color: Palette.ink,
          fontSize: rect.height * 0.4,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      Offset(rect.center.dx - words.width / 2,
          rect.top + rect.height * 0.5),
    );
  }

  void _furrow(
      Canvas canvas, Metrics metrics, int furrow, bool isTrapped) {
    final rect = metrics.furrowRect(furrow);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.4)),
      Paint()..color = Palette.trough,
    );
    final rim = furrow == pointing
        ? Palette.shown
        : isTrapped
            ? Palette.trapped
            : (showSowable && play.maySow(furrow))
                ? Palette.sowable
                : Palette.line;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.4)),
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            rim == Palette.line ? 1.4 : 2.6,
    );

    // The seeds, dotted along the trough.
    final seeds = play.seedsIn(furrow);
    final most = math.max(furrow, seeds);
    for (var seed = 0; seed < seeds; seed++) {
      final at = Offset(
        rect.left +
            rect.width * (0.12 + 0.76 * (most == 1 ? 0 : seed / (most - 1))),
        rect.center.dy,
      );
      canvas.drawCircle(
          at, rect.height * 0.22, Paint()..color = Palette.seed);
      canvas.drawCircle(
        at + Offset(-rect.height * 0.06, -rect.height * 0.07),
        rect.height * 0.09,
        Paint()..color = Palette.seedLight,
      );
    }

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '$furrow',
        style: labels.copyWith(
          color: isTrapped ? Palette.trapped : Palette.inkDim,
          fontSize: rect.height * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      Offset(rect.left - words.width - 7,
          rect.center.dy - words.height / 2),
    );
  }

  @override
  bool shouldRepaint(TilthView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showSowable != showSowable;
}

/// The words the why speaks, from the tilth at hand.
String whyWords(Play play) {
  final tilth = play.tilth;
  if (!tilth.winnable) {
    return 'A furrow may be sown only holding exactly its number, and '
        'every sowing of another furrow adds to the nearer ones: a '
        'furrow holding more than its number can never be sown again, '
        'and its seeds are trapped where you see them, red. '
        '${tilth.note ?? ''}';
  }
  return 'Every count of seeds has exactly one board that plays home, '
      'grown backwards from the barn by unsowing, and this is the one '
      'for ${tilth.seeds}. The green rims are the sowable furrows; a '
      'wrong choice leaves a board of the same size that is not the '
      'chosen one, and the red of a trapped furrow says so at once. '
      '${tilth.note ?? ''}';
}

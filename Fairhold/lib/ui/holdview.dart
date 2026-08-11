import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hold/play.dart';
import '../hold/rules.dart';
import 'palette.dart';

/// Where every chip lies, shared by the painter and the hit-testing, so
/// where a rope is drawn is exactly where a rope is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    chip = math.min((width - 40) / 4 * 0.8, height * 0.09);
    crateWide = (width - 24) / 4;
    chipsTop = height * 0.44;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double chip;
  late final double crateWide;
  late final double chipsTop;

  Rect chipRect(int crate, int pair) => Rect.fromCenter(
        center: Offset(
          12 + crateWide * (crate + 0.5),
          chipsTop + pair * chip * 1.5,
        ),
        width: crateWide * 0.74,
        height: chip,
      );

  /// The post for a paint, across the top.
  Offset postAt(int paint) => Offset(
        width * (0.17 + 0.22 * paint),
        height * 0.16,
      );

  /// The chip under a touch, as (crate, pair), or null.
  (int, int)? chipAt(Offset touch) {
    for (var crate = 0; crate < 4; crate++) {
      for (var pair = 0; pair < 3; pair++) {
        if (chipRect(crate, pair).inflate(5).contains(touch)) {
          return (crate, pair);
        }
      }
    }
    return null;
  }
}

/// The yard, drawn.
class HoldView extends CustomPainter {
  HoldView({
    required this.play,
    required this.pointing,
    required this.showRopes,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The chip being pointed at, as (crate, pair), or null.
  final (int, int)? pointing;

  /// Whether to string the chosen ropes between the paint posts.
  final bool showRopes;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    if (play.isStacked) {
      _stack(canvas, metrics);
      return;
    }

    if (showRopes) _ropes(canvas, metrics);

    for (var crate = 0; crate < 4; crate++) {
      for (var pair = 0; pair < 3; pair++) {
        _chip(canvas, metrics, crate, pair);
      }
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: 'crate ${crate + 1}',
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: metrics.chip * 0.42,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(
          canvas,
          Offset(
            12 + metrics.crateWide * (crate + 0.5) - words.width / 2,
            metrics.chipsTop - metrics.chip * 1.25,
          ),
        );
      }
    }
  }

  void _chip(Canvas canvas, Metrics metrics, int crate, int pair) {
    final rect = metrics.chipRect(crate, pair);
    final (a, b) = play.consignment.crates[crate][pair];
    final half = Rect.fromLTWH(
        rect.left, rect.top, rect.width / 2, rect.height);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        half,
        topLeft: Radius.circular(rect.height * 0.4),
        bottomLeft: Radius.circular(rect.height * 0.4),
      ),
      Paint()..color = Palette.paints[a],
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(rect.center.dx, rect.top, rect.width / 2,
            rect.height),
        topRight: Radius.circular(rect.height * 0.4),
        bottomRight: Radius.circular(rect.height * 0.4),
      ),
      Paint()..color = Palette.paints[b],
    );

    final serves = play.serves(crate, pair);
    final ringColour = serves == 'ns'
        ? Palette.northSouth
        : serves == 'ew'
            ? Palette.eastWest
            : Palette.wood;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.4)),
      Paint()
        ..color = pointing != null &&
                pointing!.$1 == crate &&
                pointing!.$2 == pair
            ? Palette.shown
            : ringColour
        ..style = PaintingStyle.stroke
        ..strokeWidth = serves == null && pointing == null ? 1.4 : 2.6,
    );

    if (!showWords || serves == null) return;
    final words = TextPainter(
      text: TextSpan(
        text: serves == 'ns' ? 'N-S' : 'E-W',
        style: labels.copyWith(
          color: ringColour,
          fontSize: rect.height * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      Offset(rect.right + 5, rect.center.dy - words.height / 2),
    );
  }

  void _ropes(Canvas canvas, Metrics metrics) {
    for (final ns in const [true, false]) {
      final rope = Paint()
        ..color = (ns ? Palette.northSouth : Palette.eastWest)
            .withValues(alpha: 0.75)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke;
      for (final (a, b) in play.lineRopes(ns)) {
        final from = metrics.postAt(a);
        final to = metrics.postAt(b);
        if (a == b) {
          canvas.drawCircle(
            from + Offset(0, ns ? -metrics.chip : metrics.chip),
            metrics.chip * 0.6,
            rope,
          );
          continue;
        }
        final lift = (ns ? -1 : 1) *
            (metrics.chip * 1.2 + (b - a).abs() * metrics.chip * 0.4);
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(
            (from.dx + to.dx) / 2,
            from.dy + lift,
            to.dx,
            to.dy,
          );
        canvas.drawPath(path, rope);
      }
    }
    for (var paint = 0; paint < 4; paint++) {
      final where = metrics.postAt(paint);
      canvas.drawCircle(
          where, metrics.chip * 0.5, Paint()..color = Palette.paints[paint]);
      if (!showWords) continue;
      final ns = play.endsOn(true)[paint];
      final ew = play.endsOn(false)[paint];
      final words = TextPainter(
        text: TextSpan(
          text: '$ns·$ew',
          style: labels.copyWith(
            color: Palette.inkDim,
            fontSize: metrics.chip * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        where + Offset(-words.width / 2, metrics.chip * 0.75),
      );
    }
  }

  void _stack(Canvas canvas, Metrics metrics) {
    // The stack, standing: each crate a band showing its north face on
    // the left and its east face on the right.
    final north = Rules.orient(play.lineRopes(true))!;
    final east = Rules.orient(play.lineRopes(false))!;
    final band = math.min(metrics.height * 0.16, metrics.width * 0.2);
    final wide = metrics.width * 0.5;
    final left = (metrics.width - wide) / 2;
    final bottom = metrics.height * 0.86;
    for (var crate = 0; crate < 4; crate++) {
      final top = bottom - (crate + 1) * band + 4;
      canvas.drawRect(
        Rect.fromLTWH(left, top, wide / 2, band - 6),
        Paint()..color = Palette.paints[north[crate].$1],
      );
      canvas.drawRect(
        Rect.fromLTWH(left + wide / 2, top, wide / 2, band - 6),
        Paint()..color = Palette.paints[east[crate].$1],
      );
      canvas.drawRect(
        Rect.fromLTWH(left, top, wide, band - 6),
        Paint()
          ..color = Palette.wood
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: 'north      east',
        style: labels.copyWith(
          color: Palette.inkDim,
          fontSize: band * 0.24,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      Offset(metrics.width / 2 - words.width / 2, bottom + 8),
    );
  }

  @override
  bool shouldRepaint(HoldView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showRopes != showRopes;
}

/// The words the why speaks, from the consignment at hand.
String whyWords(Play play) {
  final consignment = play.consignment;
  if (!consignment.possible) {
    final ends = Rules.endsInAll(consignment.crates);
    final short = ends.indexWhere((e) => e < 4);
    return 'Think of the paints as posts and each crate\'s opposite '
        'pairs as ropes between them. A fair stack needs every paint at '
        'two rope-ends on each line, four in all, and this consignment '
        'holds the short paint at only ${ends[short]}. Count the faces: '
        'that is the whole proof.'
        '${consignment.note == null ? '' : ' ${consignment.note}'}';
  }
  return 'Think of the paints as posts and each crate\'s opposite pairs '
      'as ropes between them. Give one rope of each crate to each line '
      'so every post holds exactly two ends per line, the counts by the '
      'posts, and the crates can always be turned so each paint shows '
      'once every way: the loops close, and walking them nose to tail '
      'is the turning.'
      '${consignment.note == null ? '' : ' ${consignment.note}'}';
}

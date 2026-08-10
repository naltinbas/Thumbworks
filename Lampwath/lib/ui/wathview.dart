import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wath/play.dart';
import 'palette.dart';

/// Where the banks, the bridge and every walker is.
///
/// The painter and the finger both use this, which is the point of it: a
/// walker is where they are drawn, and there is no second sum that could
/// disagree with the first.
class Metrics {
  Metrics(this.play, Size room) {
    this.room = room;
    bankTop = room.height * 0.10;
    bankBottom = room.height * 0.90;
    nearX = room.width * 0.20;
    farX = room.width * 0.80;
    spot = math.min(room.width, room.height) * 0.045;
  }

  final Play play;
  late final Size room;

  late final double bankTop;
  late final double bankBottom;
  late final double nearX;
  late final double farX;
  late final double spot;

  /// Where a walker stands: on their bank, spaced down it.
  Offset middleOf(int walker) {
    final far = play.onFar(walker);
    final x = far ? farX : nearX;
    final step = (bankBottom - bankTop) / (play.bridge.count + 1);
    return Offset(x, bankTop + step * (walker + 1));
  }

  /// The walker under a point, or -1.
  int walkerAt(Offset touch) {
    var nearest = -1;
    var best = spot * 2.2;
    for (var walker = 0; walker < play.bridge.count; walker++) {
      final away = (middleOf(walker) - touch).distance;
      if (away < best) {
        best = away;
        nearest = walker;
      }
    }
    return nearest;
  }
}

/// The wath: two banks, the bridge, the walkers and the lantern.
class WathView extends CustomPainter {
  const WathView({
    required this.play,
    required this.pointing,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// Walkers the game is pointing at, as bits.
  final int pointing;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the crossing.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The water between the banks.
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.32, 0, size.width * 0.68, size.height),
      Paint()..color = Palette.water,
    );

    // The bridge across the middle.
    final bridgeTop = size.height * 0.42;
    final bridgeBottom = size.height * 0.58;
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.28, bridgeTop, size.width * 0.72,
          bridgeBottom),
      Paint()..color = Palette.stone,
    );
    for (final y in [bridgeTop, bridgeBottom]) {
      canvas.drawLine(
        Offset(size.width * 0.28, y),
        Offset(size.width * 0.72, y),
        Paint()
          ..color = Palette.edge
          ..strokeWidth = 3,
      );
    }

    // The lantern, on whichever bank holds it.
    final lampX = play.lampFar ? metrics.farX : metrics.nearX;
    final lamp = Offset(lampX, size.height * 0.5);
    canvas.drawCircle(
      lamp,
      metrics.spot * 2.2,
      Paint()..color = Palette.lantern.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      lamp,
      metrics.spot * 0.55,
      Paint()..color = Palette.lantern,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: lamp - Offset(0, metrics.spot * 0.75),
        width: metrics.spot * 0.3,
        height: metrics.spot * 0.4,
      ),
      Paint()..color = Palette.stone,
    );

    // The walkers, named, with their minutes.
    for (var walker = 0; walker < play.bridge.count; walker++) {
      final middle = metrics.middleOf(walker);
      final picked = play.isChosen(walker);
      final pointed = (pointing & (1 << walker)) != 0;

      canvas.drawCircle(
        middle,
        metrics.spot,
        Paint()..color = picked ? Palette.chosen : Palette.walker,
      );
      // A little body under the head.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: middle + Offset(0, metrics.spot * 1.3),
            width: metrics.spot * 1.2,
            height: metrics.spot * 1.4,
          ),
          Radius.circular(metrics.spot * 0.5),
        ),
        Paint()..color = picked ? Palette.chosen : Palette.walker,
      );

      if (pointed) {
        canvas.drawCircle(
          middle + Offset(0, metrics.spot * 0.6),
          metrics.spot * 2,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }

      if (!showWords) continue;
      final onFar = play.onFar(walker);
      final name = TextPainter(
        text: TextSpan(
          text: '${play.bridge.walkers[walker].name} · '
              '${play.bridge.walkers[walker].minutes}',
          style: labels.copyWith(
            color: picked ? Palette.chosen : Palette.inkDim,
            fontSize: 11.5,
            fontWeight: picked ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final where = middle +
          Offset(
            onFar ? -metrics.spot * 1.6 - name.width : metrics.spot * 1.6,
            -name.height / 2,
          );
      name.paint(canvas, where);
    }
  }

  @override
  bool shouldRepaint(WathView old) =>
      old.play != play || old.pointing != pointing;
}

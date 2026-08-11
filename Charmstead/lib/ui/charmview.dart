import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../charm/play.dart';
import '../charm/rules.dart';
import 'palette.dart';

/// Where the bed, the coins and the tray lie, shared by the painter
/// and the hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    cell = math.min(width * 0.226, height * 0.15);
    bedLeft = (width - cell * 3) / 2;
    bedTop = height * 0.10;
    trayStep = width * 0.94 / 9;
    coin = math.min(trayStep * 0.42, cell * 0.4);
    trayY = bedTop + cell * 3 + cell * 1.3;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double cell;
  late final double bedLeft;
  late final double bedTop;
  late final double trayStep;
  late final double coin;
  late final double trayY;

  Rect cellRect(int at) => Rect.fromLTWH(
        bedLeft + (at % 3) * cell,
        bedTop + (at ~/ 3) * cell,
        cell,
        cell,
      );

  Offset trayCenter(int worth) => Offset(
        width * 0.03 + (worth - 0.5) * trayStep,
        trayY,
      );

  /// The cell under a touch, or -1.
  int cellAt(Offset touch) {
    for (var at = 0; at < 9; at++) {
      if (cellRect(at).contains(touch)) return at;
    }
    return -1;
  }

  /// The tray coin under a touch, or -1.
  int trayCoinAt(Offset touch) {
    for (var worth = 1; worth <= 9; worth++) {
      if ((trayCenter(worth) - touch).distance <= coin * 1.25) {
        return worth;
      }
    }
    return -1;
  }
}

/// The bed, drawn.
class CharmView extends CustomPainter {
  CharmView({
    required this.play,
    required this.armed,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The tray coin armed for laying, or -1.
  final int armed;

  /// The mend being pointed at: a cell, and the coin it wants or null
  /// to lift.
  final (int, int?)? pointing;

  /// Whether sums may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final broken = play.broken.toSet();

    // The bed and its cells.
    for (var at = 0; at < 9; at++) {
      final rect = metrics.cellRect(at);
      canvas.drawRect(rect, Paint()..color = Palette.bed);
      canvas.drawRect(
        rect,
        Paint()
          ..color = Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    final pointed = pointing;
    if (pointed != null) {
      canvas.drawRect(
        metrics.cellRect(pointed.$1).deflate(1.4),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    for (var at = 0; at < 9; at++) {
      final coin = play.laid[at];
      if (coin == null) continue;
      _coin(canvas, metrics, metrics.cellRect(at).center, coin,
          pinned: play.charm.isPinned(at));
    }

    // The tray, and the armed ring.
    for (final worth in play.tray) {
      final middle = metrics.trayCenter(worth);
      _coin(canvas, metrics, middle, worth);
      if (worth == armed ||
          (pointed != null && pointed.$2 == worth)) {
        canvas.drawCircle(
          middle,
          metrics.coin * 1.16,
          Paint()
            ..color =
                worth == armed ? Palette.armed : Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      }
    }

    if (!showWords) return;
    _sums(canvas, metrics, broken);
  }

  void _coin(Canvas canvas, Metrics metrics, Offset middle, int worth,
      {bool pinned = false}) {
    canvas.drawCircle(
        middle, metrics.coin, Paint()..color = Palette.coinEdge);
    canvas.drawCircle(middle, metrics.coin * 0.88,
        Paint()..color = Palette.coin);
    if (pinned) {
      canvas.drawCircle(
        middle + Offset(0, -metrics.coin * 0.62),
        metrics.coin * 0.16,
        Paint()..color = Palette.pinStud,
      );
    }
    final words = TextPainter(
      text: TextSpan(
        text: '$worth',
        style: labels.copyWith(
          color: Palette.coinInk,
          fontSize: metrics.coin * 1.05,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
        canvas, middle - Offset(words.width / 2, words.height / 2));
  }

  void _sums(Canvas canvas, Metrics metrics, Set<int> broken) {
    // Rows at the right, columns underneath, crossways at their far
    // corners.
    for (var line = 0; line < Rules.lines.length; line++) {
      final (count, full) = play.lineCount(line);
      final colour = !full
          ? Palette.inkDim
          : broken.contains(line)
              ? Palette.brokenLine
              : Palette.kept;
      final at = switch (line) {
        0 || 1 || 2 => Offset(
            metrics.bedLeft + metrics.cell * 3 + metrics.cell * 0.34,
            metrics.bedTop + (line + 0.5) * metrics.cell),
        3 || 4 || 5 => Offset(
            metrics.bedLeft + (line - 3 + 0.5) * metrics.cell,
            metrics.bedTop + metrics.cell * 3 + metrics.cell * 0.3),
        6 => Offset(
            metrics.bedLeft + metrics.cell * 3 + metrics.cell * 0.34,
            metrics.bedTop + metrics.cell * 3 + metrics.cell * 0.3),
        _ => Offset(metrics.bedLeft - metrics.cell * 0.34,
            metrics.bedTop + metrics.cell * 3 + metrics.cell * 0.3),
      };
      final words = TextPainter(
        text: TextSpan(
          text: '$count',
          style: labels.copyWith(
            color: colour,
            fontSize: metrics.cell * 0.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
          canvas, at - Offset(words.width / 2, words.height / 2));
    }
  }

  @override
  bool shouldRepaint(CharmView old) =>
      old.play != play ||
      old.armed != armed ||
      old.pointing != pointing;
}

/// The words the why speaks, from the charm at hand.
String whyWords(Play play) {
  final charm = play.charm;
  final note = charm.note == null ? '' : ' ${charm.note}';
  if (!charm.winnable) {
    return 'The sweep laid every filling of the bed against these '
        'pins, all of them, and none holds the eight fifteens.$note';
  }
  return 'The rows share the nine coins between them, and one to '
      'nine count forty five: each row must carry fifteen, and the '
      'columns and crossways the same. The sweep of every filling '
      'finds ${charm.ways} charm${charm.ways == 1 ? '' : 's'} '
      'honouring the pins.$note';
}

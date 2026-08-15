import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../count/play.dart';
import 'palette.dart';

/// Where the tray's slots lie on the board, so the screen and the
/// tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    cols = 6;
    rows = play.rules.capacity ~/ cols;
    slot = math.min(room.width * 0.9 / cols, room.height * 0.42 / rows);
    trayLeft = (room.width - slot * cols) / 2;
    trayTop = room.height * 0.02;
    layoutTop = trayTop + slot * rows + room.height * 0.05;
    layoutHeight = room.height - layoutTop - room.height * 0.02;
  }

  final Play play;

  late final int cols;
  late final int rows;
  late final double slot;
  late final double trayLeft;
  late final double trayTop;

  /// Where the layings-out by each row length begin, and the room
  /// they have.
  late final double layoutTop;
  late final double layoutHeight;

  /// The middle of slot [k], counted from one along the rows.
  Offset slotAt(int k) {
    final index = k - 1;
    return Offset(
      trayLeft + (index % cols + 0.5) * slot,
      trayTop + (index ~/ cols + 0.5) * slot,
    );
  }

  /// The slot under a touch, one to the capacity, or null.
  int? under(Offset touch) {
    final col = ((touch.dx - trayLeft) / slot).floor();
    final row = ((touch.dy - trayTop) / slot).floor();
    if (col < 0 || col >= cols || row < 0 || row >= rows) return null;
    return row * cols + col + 1;
  }
}

/// The board itself: the tray of eggs, and beneath it the same eggs
/// laid out by threes, by fives, by sevens, the leftovers ringed.
class TrayView extends CustomPainter {
  TrayView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// The count the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final slot = metrics.slot;

    // The tray.
    final tray = Rect.fromLTWH(
      metrics.trayLeft,
      metrics.trayTop,
      slot * metrics.cols,
      slot * metrics.rows,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tray.inflate(slot * 0.08), Radius.circular(slot * 0.2)),
      Paint()..color = Palette.tray,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tray.inflate(slot * 0.08), Radius.circular(slot * 0.2)),
      Paint()
        ..color = Palette.trayRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, slot * 0.03),
    );
    for (var k = 1; k <= play.rules.capacity; k++) {
      final at = metrics.slotAt(k);
      canvas.drawCircle(at, slot * 0.36, Paint()..color = Palette.slot);
      if (k <= play.eggs) _egg(canvas, at, slot * 0.3);
    }
    if (pointing != null && pointing! >= 1) {
      canvas.drawCircle(
        metrics.slotAt(pointing!),
        slot * 0.44,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, slot * 0.06),
      );
    }

    // The layings-out, one band per row length.
    final bands = play.tray.rows.length;
    final bandHeight = metrics.layoutHeight / bands;
    for (var b = 0; b < bands; b++) {
      final row = play.tray.rows[b];
      final top = metrics.layoutTop + b * bandHeight;
      final label = 'by ${row}s: ${play.leftovers[b]} over, asked ${play.tray.asked[b]}';
      _write(
        canvas,
        label,
        Offset(size.width * 0.5, top + bandHeight * 0.1),
        labels.copyWith(
          color: play.met[b] ? Palette.met : Palette.unmet,
          fontSize: math.max(10, bandHeight * 0.14),
          fontWeight: FontWeight.w700,
        ),
      );
      // The eggs in rows of [row], each full row a cluster, the
      // clusters flowing across the band and wrapping; the last,
      // short cluster is the leftover, ringed gold.
      final full = play.eggs ~/ row;
      final left = play.eggs % row;
      final clusters = full + (left > 0 ? 1 : 0);
      if (clusters == 0) continue;
      final roomWidth = size.width * 0.9;
      final roomHeight = bandHeight * 0.62;
      var pitch = bandHeight * 0.26;
      var perLine = math.max(1, (roomWidth / ((row + 0.6) * pitch)).floor());
      var lines = (clusters + perLine - 1) ~/ perLine;
      if (lines * pitch * 1.15 > roomHeight) {
        pitch = roomHeight / (lines * 1.15);
        perLine = math.max(1, (roomWidth / ((row + 0.6) * pitch)).floor());
        lines = (clusters + perLine - 1) ~/ perLine;
      }
      final clusterWidth = (row + 0.6) * pitch;
      for (var c = 0; c < clusters; c++) {
        final line = c ~/ perLine;
        final onLine = math.min(perLine, clusters - line * perLine);
        final lineLeft = size.width / 2 - onLine * clusterWidth / 2;
        final x0 = lineLeft + (c % perLine) * clusterWidth + pitch * 0.5;
        final y = top + bandHeight * 0.36 + line * pitch * 1.15;
        final inRow = c < full ? row : left;
        for (var i = 0; i < inRow; i++) {
          final at = Offset(x0 + i * pitch, y);
          _egg(canvas, at, pitch * 0.34);
          if (c == full && left > 0) {
            canvas.drawCircle(
              at,
              pitch * 0.44,
              Paint()
                ..color = Palette.over
                ..style = PaintingStyle.stroke
                ..strokeWidth = math.max(1, pitch * 0.08),
            );
          }
        }
      }
    }
  }

  void _egg(Canvas canvas, Offset at, double r) {
    canvas.drawOval(
      Rect.fromCenter(center: at, width: r * 1.7, height: r * 2.1),
      Paint()..color = Palette.eggShade,
    );
    canvas.drawOval(
      Rect.fromCenter(center: at + Offset(-r * 0.08, -r * 0.1), width: r * 1.5, height: r * 1.9),
      Paint()..color = Palette.egg,
    );
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(TrayView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a tray as it stands.
String whyWords(Play play) {
  final tray = play.tray;
  final note = tray.note == null ? '' : ' ${tray.note}';
  if (!tray.winnable) {
    return 'Lay a count out by fours with one over and it is one more '
        'than a multiple of four, which is odd. Lay it out by sixes with '
        'two over and it is two more than a multiple of six, which is '
        'even. No count is both. Fours and sixes share a factor of two, '
        'and the leftovers must agree on it; one and two do not. The '
        'sweep filled the tray to every count and met the asking '
        'never.$note';
  }
  final second = play.rules.coprime
      ? 'Sun Tzu\'s construction builds the count with no searching, '
          'for each row length the product of the others times its '
          'inverse over that length times the leftover, all added and '
          'taken over the span, and it lands on the sweep\'s smallest '
          'count for every asking there is'
      : 'fours and sixes share a factor of two, so an asking is met '
          'exactly when its leftovers agree on it, and then twelve apart, '
          'and the arithmetic and the sweep agree on all 24 askings';
  return 'The counts are found by the sweep, every count the tray holds '
      'laid out by every row length, and held to a second voice: '
      '$second. ${tray.ways} count${tray.ways == 1 ? '' : 's'} in the '
      'tray meet${tray.ways == 1 ? 's' : ''} this asking.$note';
}

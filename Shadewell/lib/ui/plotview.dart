import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../plot/play.dart';
import '../plot/rules.dart';
import 'palette.dart';

/// Where every cell and tally lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    clueW = width * 0.22;
    clueH = height * 0.16;
    cell = math.min(
      math.min((width - clueW - width * 0.04) / play.plot.wide,
          (height - clueH - height * 0.04) / play.plot.high),
      64.0,
    );
    left = clueW +
        (width - clueW - cell * play.plot.wide) / 2;
    top = clueH +
        (height - clueH - cell * play.plot.high) / 2;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double clueW;
  late final double clueH;
  late final double cell;
  late final double left;
  late final double top;

  Rect cellRect(int row, int col) => Rect.fromLTWH(
        left + col * cell,
        top + row * cell,
        cell,
        cell,
      );

  /// The cell under a touch, or null.
  (int, int)? cellAt(Offset touch) {
    final col = ((touch.dx - left) / cell).floor();
    final row = ((touch.dy - top) / cell).floor();
    if (row < 0 ||
        col < 0 ||
        row >= play.plot.high ||
        col >= play.plot.wide) {
      return null;
    }
    return (row, col);
  }
}

/// The plot, drawn.
class PlotView extends CustomPainter {
  PlotView({
    required this.play,
    this.pointing,
    this.other,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The cell being pointed at, or null.
  final (int, int)? pointing;

  /// Another accepted picture, outlined over the marks, or null.
  final List<int>? other;

  /// Whether tallies may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final plot = play.plot;
    final fallenRows = play.fallenRows.toSet();
    final fallenCols = play.fallenCols.toSet();

    for (var row = 0; row < plot.high; row++) {
      for (var col = 0; col < plot.wide; col++) {
        _cell(canvas, metrics, row, col);
      }
    }

    // The frame and the inner lines.
    final framePaint = Paint()
      ..color = Palette.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var row = 0; row <= plot.high; row++) {
      canvas.drawLine(
        Offset(metrics.left, metrics.top + row * metrics.cell),
        Offset(metrics.left + plot.wide * metrics.cell,
            metrics.top + row * metrics.cell),
        framePaint,
      );
    }
    for (var col = 0; col <= plot.wide; col++) {
      canvas.drawLine(
        Offset(metrics.left + col * metrics.cell, metrics.top),
        Offset(metrics.left + col * metrics.cell,
            metrics.top + plot.high * metrics.cell),
        framePaint,
      );
    }

    final pointed = pointing;
    if (pointed != null) {
      canvas.drawRect(
        metrics.cellRect(pointed.$1, pointed.$2).deflate(1.2),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    final shadow = other;
    if (shadow != null) {
      for (var row = 0; row < plot.high; row++) {
        for (var col = 0; col < plot.wide; col++) {
          if (shadow[row] & (1 << col) == 0) continue;
          canvas.drawRect(
            metrics.cellRect(row, col).deflate(metrics.cell * 0.18),
            Paint()
              ..color = Palette.other
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2,
          );
        }
      }
    }

    if (!showWords) return;
    _tallies(canvas, metrics, fallenRows, fallenCols);
  }

  void _cell(Canvas canvas, Metrics metrics, int row, int col) {
    final rect = metrics.cellRect(row, col);
    canvas.drawRect(rect, Paint()..color = Palette.cell);
    if (play.isShaded(row, col)) {
      canvas.drawRect(
        rect.deflate(metrics.cell * 0.06),
        Paint()..color = Palette.shade,
      );
      canvas.drawRect(
        Rect.fromLTWH(rect.left + metrics.cell * 0.06,
            rect.bottom - metrics.cell * 0.16,
            rect.width - metrics.cell * 0.12, metrics.cell * 0.10),
        Paint()..color = Palette.shadeDeep,
      );
    } else if (play.isBare(row, col)) {
      canvas.drawCircle(
        rect.center,
        metrics.cell * 0.09,
        Paint()..color = Palette.bareDot,
      );
    }
  }

  void _tallies(Canvas canvas, Metrics metrics, Set<int> fallenRows,
      Set<int> fallenCols) {
    final plot = play.plot;
    for (var row = 0; row < plot.high; row++) {
      final done = (play.shaded[row] | play.bare[row]) ==
              (1 << plot.wide) - 1 &&
          Rules.tallyOf(play.shaded[row], plot.wide).join(',') ==
              plot.rowTallies[row].join(',');
      final words = TextPainter(
        text: TextSpan(
          text: plot.rowTallies[row].join(' '),
          style: labels.copyWith(
            color: fallenRows.contains(row)
                ? Palette.fallen
                : done
                    ? Palette.kept
                    : Palette.inkDim,
            fontSize: metrics.cell * 0.38,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        Offset(
          metrics.left - words.width - metrics.cell * 0.24,
          metrics.top +
              row * metrics.cell +
              (metrics.cell - words.height) / 2,
        ),
      );
    }

    for (var col = 0; col < plot.wide; col++) {
      final line = play.colLine(play.shaded, col);
      final decided = (play.colLine(play.shaded, col) |
              play.colLine(play.bare, col)) ==
          (1 << plot.high) - 1;
      final done = decided &&
          Rules.tallyOf(line, plot.high).join(',') ==
              plot.colTallies[col].join(',');
      final tally = plot.colTallies[col];
      for (var at = 0; at < tally.length; at++) {
        final words = TextPainter(
          text: TextSpan(
            text: '${tally[at]}',
            style: labels.copyWith(
              color: fallenCols.contains(col)
                  ? Palette.fallen
                  : done
                      ? Palette.kept
                      : Palette.inkDim,
              fontSize: metrics.cell * 0.38,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(
          canvas,
          Offset(
            metrics.left +
                col * metrics.cell +
                (metrics.cell - words.width) / 2,
            metrics.top -
                (tally.length - at) * metrics.cell * 0.5 -
                metrics.cell * 0.1,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(PlotView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.other != other;
}

/// The words the why speaks, from the plot at hand.
String whyWords(Play play) {
  final plot = play.plot;
  final note = plot.note == null ? '' : ' ${plot.note}';
  if (plot.solutions == 0) {
    return 'Every shaded cell is counted once by its row and once by '
        'its column, so the rows and the columns must ask for the '
        'same count. Here the rows ask ${plot.rowsAsk} and the '
        'columns ${plot.colsAsk}.$note';
  }
  if (plot.solutions > 1) {
    return 'The stacking tried every filling of the rows the tallies '
        'allow and found ${plot.solutions} pictures, outlined in '
        'gold one at a time.$note';
  }
  return 'The tallies name one picture: the stacking tried every '
      'filling of the rows and found exactly one, and the '
      'line-solver reaches the same picture by deduction alone, two '
      'ways that share nothing.$note';
}

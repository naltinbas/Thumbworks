import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pane/play.dart';
import 'palette.dart';

/// Where every light lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final sash = play.sash;
    cell = math.min(
      room.width * 0.88 / sash.across,
      room.height * 0.88 / sash.down,
    );
    left = (room.width - cell * sash.across) / 2;
    top = (room.height - cell * sash.down) / 2;
  }

  final Play play;

  late final double cell;
  late final double left;
  late final double top;

  /// The middle of the light at (x, y), y rising from the bottom.
  Offset lightAt(int x, int y) => Offset(
        left + (x + 0.5) * cell,
        top + (play.sash.down - 1 - y + 0.5) * cell,
      );

  /// The light under a touch, or null for the frame.
  (int, int)? lightUnder(Offset touch) {
    for (var x = 0; x < play.sash.across; x++) {
      for (var y = 0; y < play.sash.down; y++) {
        if ((lightAt(x, y) - touch).distance <= cell * 0.44) {
          return (x, y);
        }
      }
    }
    return null;
  }
}

/// The sash, drawn.
class PaneView extends CustomPainter {
  PaneView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The light being pointed at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final sash = play.sash;

    // The lights, recessed.
    for (var x = 0; x < sash.across; x++) {
      for (var y = 0; y < sash.down; y++) {
        canvas.drawRect(
          Rect.fromCenter(
            center: metrics.lightAt(x, y),
            width: metrics.cell * 0.92,
            height: metrics.cell * 0.92,
          ),
          Paint()..color = Palette.light,
        );
      }
    }

    // The glazing bars and the outer frame.
    final bars = Paint()
      ..color = Palette.frame
      ..strokeWidth = math.max(metrics.cell * 0.07, 3.0);
    for (var x = 0; x <= sash.across; x++) {
      canvas.drawLine(
        Offset(metrics.left + x * metrics.cell, metrics.top),
        Offset(metrics.left + x * metrics.cell,
            metrics.top + sash.down * metrics.cell),
        bars,
      );
    }
    for (var y = 0; y <= sash.down; y++) {
      canvas.drawLine(
        Offset(metrics.left, metrics.top + y * metrics.cell),
        Offset(metrics.left + sash.across * metrics.cell,
            metrics.top + y * metrics.cell),
        bars,
      );
    }

    // The panes in the window's corners, marked before the glass
    // goes down so the rust rims read through.
    final windowed = <(int, int)>{};
    for (final (a, b, c, d) in play.framed) {
      windowed.addAll([a, b, c, d]);
    }

    // The glass.
    for (final (x, y) in play.panes) {
      final middle = metrics.lightAt(x, y);
      final pane = Rect.fromCenter(
        center: middle,
        width: metrics.cell * 0.74,
        height: metrics.cell * 0.74,
      );
      canvas.drawRect(pane, Paint()..color = Palette.glass);
      canvas.drawLine(
        pane.topLeft + Offset(pane.width * 0.14, pane.height * 0.3),
        pane.topLeft + Offset(pane.width * 0.38, pane.height * 0.08),
        Paint()
          ..color = Palette.glint
          ..strokeWidth = math.max(metrics.cell * 0.05, 2.4)
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawRect(
        pane,
        Paint()
          ..color = windowed.contains((x, y))
              ? Palette.window
              : Palette.glassRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = windowed.contains((x, y)) ? 3.0 : 1.6,
      );
    }

    // Each framed window, drawn whole.
    for (final (a, _, _, d) in play.framed) {
      final one = metrics.lightAt(a.$1, a.$2);
      final two = metrics.lightAt(d.$1, d.$2);
      canvas.drawRect(
        Rect.fromPoints(one, two),
        Paint()
          ..color = Palette.window
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    // The pointed light.
    final pointed = pointing;
    if (pointed != null) {
      canvas.drawRect(
        Rect.fromCenter(
          center: metrics.lightAt(pointed.$1, pointed.$2),
          width: metrics.cell * 0.86,
          height: metrics.cell * 0.86,
        ),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }
  }

  @override
  bool shouldRepaint(PaneView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the sash at hand.
String whyWords(Play play) {
  final sash = play.sash;
  final rules = play.rules;
  final note = sash.note == null ? '' : ' ${sash.note}';
  if (!sash.winnable) {
    return 'Ten panes split across four columns must spend at '
        'least ${rules.fewestSpend(sash.count)} row-pairs, and a '
        'window-free sash may spend each of its ${rules.rowPairs} '
        'at most once: that arithmetic alone bars the tenth pane, '
        'and the sweep of all ${withComma(8008)} placings of ten, '
        'windows counted down the columns and across the rows '
        'both, found a window in every one.$note';
  }
  return 'Windows are counted two ways that share nothing: down '
      'the columns, two columns sharing two rows, and across the '
      'rows, two rows sharing two columns. The sweep of all '
      '${withComma(32564)} placings on the two sashes finds the '
      'counts agreeing on every one. ${withComma(sash.ways)} '
      'placings land this sash\'s asking.$note';
}

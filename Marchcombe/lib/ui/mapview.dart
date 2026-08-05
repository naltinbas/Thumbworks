import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../dye/land.dart';
import '../dye/play.dart';
import 'palette.dart';

/// Where everything on the map is.
///
/// The painter and the finger both use this, which is the point of it: a field
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.land, Size room) {
    // A little off each way round, so the hedge drawn round the outside of
    // the estate is not half off the screen.
    side = math.min(
      (room.width - _edge) / land.wide,
      (room.height - _edge) / land.tall,
    );
    corner = Offset(
      (room.width - side * land.wide) / 2,
      (room.height - side * land.tall) / 2,
    );
  }

  static const _edge = 8.0;

  final Land land;

  /// How big one square of the map is drawn.
  late final double side;
  late final Offset corner;

  Rect squareAt(int column, int row) => Rect.fromLTWH(
        corner.dx + column * side,
        corner.dy + row * side,
        side,
        side,
      );

  /// The field under a point, or -1.
  int fieldAt(Offset touch) {
    final column = ((touch.dx - corner.dx) / side).floor();
    final row = ((touch.dy - corner.dy) / side).floor();
    return land.at(column, row);
  }

  /// Where to write a field's name, and how much room there is for it: the
  /// middle of the longest unbroken run of its squares along a row, so the
  /// words always sit inside the field and in the widest part of it.
  (Offset, double) nameRoom(int field) {
    var bestRow = 0, bestFrom = 0, bestRun = 0;
    for (var row = 0; row < land.tall; row++) {
      var from = -1;
      for (var column = 0; column <= land.wide; column++) {
        final here = column < land.wide && land.at(column, row) == field;
        if (here && from < 0) from = column;
        if (!here && from >= 0) {
          if (column - from > bestRun) {
            bestRun = column - from;
            bestFrom = from;
            bestRow = row;
          }
          from = -1;
        }
      }
    }
    return (
      corner + Offset((bestFrom + bestRun / 2) * side, (bestRow + 0.5) * side),
      bestRun * side,
    );
  }

  /// Where to write a field's name.
  Offset nameSpot(int field) => nameRoom(field).$1;
}

/// The map: the fields, the hedges between them and whatever is on them.
class MapView extends CustomPainter {
  const MapView({
    required this.play,
    required this.pointing,
    required this.showRing,
    required this.labels,
    this.showNames = true,
  });

  final Play play;

  /// A field the game is pointing at, or -1.
  final int pointing;

  /// Whether to mark the fields that all share a hedge with each other, which
  /// is what the game shows when it is asked why a map takes what it does.
  final bool showRing;

  /// The style the names are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the fields.
  final bool showNames;

  @override
  void paint(Canvas canvas, Size size) {
    final land = play.land;
    final metrics = Metrics(land, size);
    final ring = showRing ? play.painting.ring : const <int>[];

    final clashing = <int>{};
    for (final (one, other) in play.clashes) {
      clashing..add(one)..add(other);
    }

    for (var row = 0; row < land.tall; row++) {
      for (var column = 0; column < land.wide; column++) {
        final field = land.at(column, row);
        if (field < 0) continue;
        final dye = play.dyeOf(field);
        canvas.drawRect(
          metrics.squareAt(column, row).inflate(0.5),
          Paint()..color = dye < 0 ? Palette.bare : Palette.dyes[dye],
        );
      }
    }

    // The hedges: every side of a square where the field on the other side is
    // a different one, or where there is no field at all.
    final hedge = Paint()
      ..color = Palette.hedge
      ..strokeWidth = metrics.side * 0.11
      ..strokeCap = StrokeCap.round;
    final clash = Paint()
      ..color = Palette.bad
      ..strokeWidth = metrics.side * 0.17
      ..strokeCap = StrokeCap.round;

    for (var row = 0; row < land.tall; row++) {
      for (var column = 0; column < land.wide; column++) {
        final field = land.at(column, row);
        if (field < 0) continue;
        final square = metrics.squareAt(column, row);

        for (final (across, down) in const [(1, 0), (0, 1), (-1, 0), (0, -1)]) {
          final other = land.at(column + across, row + down);
          if (other == field) continue;

          final bad = other >= 0 &&
              play.dyeOf(field) >= 0 &&
              play.dyeOf(field) == play.dyeOf(other);
          final line = switch ((across, down)) {
            (1, 0) => (square.topRight, square.bottomRight),
            (-1, 0) => (square.topLeft, square.bottomLeft),
            (0, 1) => (square.bottomLeft, square.bottomRight),
            _ => (square.topLeft, square.topRight),
          };
          canvas.drawLine(line.$1, line.$2, bad ? clash : hedge);
        }
      }
    }

    // The ring, and whatever the game is pointing at: a bright edge drawn
    // round the outside of the field.
    for (var field = 0; field < land.count; field++) {
      final marked = field == pointing || ring.contains(field);
      if (!marked) continue;
      _outline(
        canvas,
        metrics,
        field,
        Paint()
          ..color = Palette.ink
          ..strokeWidth = metrics.side * 0.09
          ..strokeCap = StrokeCap.round,
      );
    }

    if (!showNames) return;

    for (var field = 0; field < land.count; field++) {
      final dye = play.dyeOf(field);
      final colour = clashing.contains(field)
          ? Palette.ink
          : dye < 0
              ? Palette.inkDim
              : Palette.night;
      final (middle, room) = metrics.nameRoom(field);

      var name = _wordsOf(land.fields[field].name, labels.copyWith(color: colour));
      // A narrow field gets its name set smaller rather than spilling over
      // the hedge into somebody else's land.
      if (name.width > room * 0.9) {
        final smaller = (labels.fontSize ?? 12) * (room * 0.9) / name.width;
        name = _wordsOf(
          land.fields[field].name,
          labels.copyWith(color: colour, fontSize: math.max(smaller, 5)),
        );
      }
      name.paint(canvas, middle - Offset(name.width / 2, name.height / 2));
    }
  }

  static TextPainter _wordsOf(String words, TextStyle style) => TextPainter(
        text: TextSpan(text: words, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

  /// Traces the outside edge of a field.
  void _outline(Canvas canvas, Metrics metrics, int field, Paint paint) {
    final land = play.land;
    for (var row = 0; row < land.tall; row++) {
      for (var column = 0; column < land.wide; column++) {
        if (land.at(column, row) != field) continue;
        final square = metrics.squareAt(column, row);
        for (final (across, down) in const [(1, 0), (0, 1), (-1, 0), (0, -1)]) {
          if (land.at(column + across, row + down) == field) continue;
          final line = switch ((across, down)) {
            (1, 0) => (square.topRight, square.bottomRight),
            (-1, 0) => (square.topLeft, square.bottomLeft),
            (0, 1) => (square.bottomLeft, square.bottomRight),
            _ => (square.topLeft, square.topRight),
          };
          canvas.drawLine(line.$1, line.$2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(MapView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showRing != showRing;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../moor/play.dart';
import '../moor/rules.dart';
import 'palette.dart';

/// Where every plot lies, shared by the painter and the hit-testing, so
/// where a plot is drawn is exactly where a plot is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final size = play.moor.size;
    plot = math.min(room.width / (size + 0.4), room.height / (size + 0.4));
    final across = plot * size;
    corner = Offset(
      (room.width - across) / 2,
      (room.height - across) / 2,
    );
    board = Rect.fromLTWH(corner.dx, corner.dy, across, across);
  }

  final Play play;

  late final double plot;
  late final Offset corner;
  late final Rect board;

  /// The plot at a file and row, files across, row nought at the foot.
  Rect plotRect(int file, int row) => Rect.fromLTWH(
        corner.dx + file * plot,
        corner.dy + (play.moor.size - 1 - row) * plot,
        plot,
        plot,
      );

  /// The plot under a touch, as (file, row), or null off the moor.
  (int, int)? plotAt(Offset touch) {
    if (!board.contains(touch)) return null;
    final file = ((touch.dx - corner.dx) / plot).floor();
    final row =
        play.moor.size - 1 - ((touch.dy - corner.dy) / plot).floor();
    if (file < 0 || row < 0 ||
        file >= play.moor.size || row >= play.moor.size) {
      return null;
    }
    return (file, row);
  }
}

/// The moor, drawn.
class MoorView extends CustomPainter {
  MoorView({
    required this.play,
    required this.pointing,
    required this.showBuilt,
    required this.labels,
  });

  final Play play;

  /// The plot being pointed at, or null.
  final (int, int)? pointing;

  /// Whether to raise the built rows as ghosts.
  final bool showBuilt;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var file = 0; file < play.moor.size; file++) {
      for (var row = 0; row < play.moor.size; row++) {
        canvas.drawRect(
          metrics.plotRect(file, row),
          Paint()
            ..color = (file + row).isEven
                ? Palette.heath
                : Palette.heathLight,
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

    if (showBuilt) {
      final built = Rules.built(play.moor.size);
      if (built != null) {
        for (var file = 0; file < play.moor.size; file++) {
          _mill(canvas, metrics.plotRect(file, built[file]),
              ghost: true);
        }
      }
    }

    for (var file = 0; file < play.moor.size; file++) {
      if (play.rows[file] < 0) continue;
      _mill(canvas, metrics.plotRect(file, play.rows[file]));
    }

    if (pointing != null) {
      final rect = metrics.plotRect(pointing!.$1, pointing!.$2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(metrics.plot * 0.07),
          Radius.circular(metrics.plot * 0.14),
        ),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
  }

  void _mill(Canvas canvas, Rect rect, {bool ghost = false}) {
    final middle = rect.center;
    final reach = rect.width;
    final post = Paint()
      ..color = ghost
          ? Palette.ghost.withValues(alpha: 0.55)
          : Palette.post
      ..strokeWidth = math.max(2.0, reach * 0.09)
      ..strokeCap = StrokeCap.round;
    final sail = Paint()
      ..color = ghost
          ? Palette.ghost.withValues(alpha: 0.55)
          : Palette.sail
      ..strokeWidth = math.max(1.8, reach * 0.075)
      ..strokeCap = StrokeCap.round;

    // The post, from the plot's foot to its middle.
    canvas.drawLine(
      Offset(middle.dx, rect.bottom - reach * 0.12),
      Offset(middle.dx, middle.dy + reach * 0.04),
      post,
    );
    // Four sails in a saltire from the cap.
    final cap = Offset(middle.dx, middle.dy - reach * 0.06);
    for (final turn in const [0.8, 2.35, 3.9, 5.45]) {
      canvas.drawLine(
        cap,
        cap + Offset(math.cos(turn), math.sin(turn)) * reach * 0.3,
        sail,
      );
    }
    canvas.drawCircle(
      cap,
      math.max(1.6, reach * 0.055),
      Paint()..color = ghost ? Palette.ghost : Palette.cap,
    );
  }

  @override
  bool shouldRepaint(MoorView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showBuilt != showBuilt;
}

/// The words the why speaks, from the moor at hand.
String whyWords(Play play) {
  final size = play.moor.size;
  final start = play.moor.possible
      ? 'A setting for this moor needs no search: step the mills two '
          'rows at a time, the odd rows then the even, shifted a little '
          'on the sizes the plain staircase trips on. The gold mills are '
          'that build, written straight down, and the wind check passes '
          'them plot by plot.'
      : 'No setting exists on $size plots a side, and the walk of every '
          'placement agrees.';
  final note = play.moor.note;
  return '$start${note == null ? '' : ' $note'}';
}

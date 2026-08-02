import 'package:flutter/rendering.dart';

import '../game/play.dart';
import '../game/reason.dart';
import 'palette.dart';

/// Where the board is on the screen, and how big a square is.
///
/// The squares are square. A board stretched to fill a phone would put the
/// numbers at different distances across than down, and a player reads a
/// board by looking at what touches what.
class Metrics {
  factory Metrics(Size space, int across, int down) {
    final side = space.width / across < space.height / down
        ? space.width / across
        : space.height / down;
    return Metrics._(
      side: side,
      across: across,
      down: down,
      origin: Offset(
        (space.width - across * side) / 2,
        (space.height - down * side) / 2,
      ),
    );
  }

  const Metrics._({
    required this.side,
    required this.across,
    required this.down,
    required this.origin,
  });

  /// How many pixels one square is.
  final double side;

  final int across;
  final int down;
  final Offset origin;

  Rect squareAt(int at) => Rect.fromLTWH(
        origin.dx + (at % across) * side,
        origin.dy + (at ~/ across) * side,
        side,
        side,
      );

  /// Which square a finger landed on, or null if it landed off the board.
  int? under(Offset at) {
    final column = ((at.dx - origin.dx) / side).floor();
    final row = ((at.dy - origin.dy) / side).floor();
    if (column < 0 || column >= across || row < 0 || row >= down) return null;
    return row * across + column;
  }

  Rect get board => Rect.fromLTWH(
        origin.dx,
        origin.dy,
        across * side,
        down * side,
      );
}

/// Draws the plot.
class PlotPainter extends CustomPainter {
  PlotPainter({
    required this.play,
    required this.metrics,
    this.showing,
  });

  final Play play;
  final Metrics metrics;

  /// The step being explained, if the player asked why.
  final Finding? showing;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Palette.night);

    final lost = play.ending == Ending.blown;
    final pointedAt = <int>{
      if (showing != null) ...[
        if (showing!.clue >= 0) showing!.clue,
        if (showing!.other >= 0) showing!.other,
      ],
    };
    final answered = <int>{
      if (showing != null) ...showing!.safe,
      if (showing != null) ...showing!.mined,
    };

    for (var at = 0; at < play.field.cells; at++) {
      final square = metrics.squareAt(at).deflate(metrics.side * 0.035);
      final round = Radius.circular(metrics.side * 0.16);

      switch (play.faceAt(at)) {
        case Face.open:
          canvas.drawRRect(
            RRect.fromRectAndRadius(square, round),
            Paint()
              ..color = pointedAt.contains(at)
                  ? Palette.furrow
                  : Palette.turned,
          );
          if (play.field.holdsMine(at)) {
            _paintMine(canvas, square, Palette.mine);
          } else {
            _paintNumber(canvas, square, play.field.countAt(at));
          }
        case Face.shut:
        case Face.flagged:
          canvas.drawRRect(
            RRect.fromRectAndRadius(square, round),
            Paint()..color = Palette.shut,
          );
          // A lip along the top, so a shut square reads as standing up.
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                square.left,
                square.top,
                square.width,
                square.height * 0.22,
              ),
              round,
            ),
            Paint()..color = Palette.shutEdge,
          );
          if (play.faceAt(at) == Face.flagged) {
            _paintFlag(canvas, square);
          } else if (lost && play.field.holdsMine(at)) {
            // Once it is over, the rest of them are shown. There is nothing
            // left to spoil and plenty to learn.
            _paintMine(canvas, square, Palette.mine.withValues(alpha: 0.55));
          }
      }

      if (pointedAt.contains(at)) {
        _paintRing(canvas, square, round, Palette.ink);
      } else if (answered.contains(at)) {
        _paintRing(
          canvas,
          square,
          round,
          showing!.mined.contains(at) ? Palette.ember : Palette.proved,
        );
      }
    }
  }

  void _paintRing(Canvas canvas, Rect square, Radius round, Color colour) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(square.deflate(metrics.side * 0.03), round),
      Paint()
        ..color = colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = metrics.side * 0.075,
    );
  }

  void _paintNumber(Canvas canvas, Rect square, int count) {
    if (count == 0) return;
    final text = TextPainter(
      text: TextSpan(
        text: '$count',
        // Every part of the style is given here. A painter inherits nothing
        // from the tree above it, and a TextStyle with no family in it comes
        // out as a row of boxes on a phone that has no default.
        style: TextStyle(
          color: Palette.forNumber(count),
          fontSize: square.height * 0.58,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      square.center - Offset(text.width / 2, text.height / 2),
    );
  }

  void _paintFlag(Canvas canvas, Rect square) {
    final side = square.width;
    final foot = Offset(square.center.dx + side * 0.06, square.center.dy + side * 0.26);
    final head = Offset(square.center.dx + side * 0.06, square.center.dy - side * 0.28);
    canvas.drawLine(
      foot,
      head,
      Paint()
        ..color = Palette.ink
        ..strokeWidth = side * 0.075
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(head.dx, head.dy)
        ..lineTo(head.dx - side * 0.32, head.dy + side * 0.15)
        ..lineTo(head.dx, head.dy + side * 0.30)
        ..close(),
      Paint()..color = Palette.ember,
    );
  }

  void _paintMine(Canvas canvas, Rect square, Color colour) {
    final paint = Paint()..color = colour;
    canvas.drawCircle(square.center, square.width * 0.22, paint);
    // Four short spines, so it is not just another round thing.
    final spine = Paint()
      ..color = colour
      ..strokeWidth = square.width * 0.075
      ..strokeCap = StrokeCap.round;
    for (final way in const [Offset(1, 0), Offset(0, 1)]) {
      canvas.drawLine(
        square.center - way * square.width * 0.36,
        square.center + way * square.width * 0.36,
        spine,
      );
    }
  }

  @override
  bool shouldRepaint(PlotPainter old) =>
      old.play != play || old.showing != showing || old.metrics != metrics;
}

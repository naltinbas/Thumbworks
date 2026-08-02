import 'package:flutter/rendering.dart';

import '../yard/yard.dart';
import 'palette.dart';

/// Where the yard is on the screen, and how big a square is.
///
/// The squares are square. A yard stretched to fill a phone would put the
/// crates at different distances across than down, and the whole of this game
/// is judging what is next to what.
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

  /// Which square a finger landed on, or null if it landed off the yard.
  int? under(Offset at) {
    final column = ((at.dx - origin.dx) / side).floor();
    final row = ((at.dy - origin.dy) / side).floor();
    if (column < 0 || column >= across || row < 0 || row >= down) return null;
    return row * across + column;
  }

  Rect get board =>
      Rect.fromLTWH(origin.dx, origin.dy, across * side, down * side);
}

/// Draws the yard.
class YardPainter extends CustomPainter {
  YardPainter({
    required this.yard,
    required this.metrics,
    this.pointAt,
    this.pointWay,
    this.spoiled,
  });

  final Yard yard;
  final Metrics metrics;

  /// A crate the game is pointing at, and which way it says to shove it.
  final int? pointAt;
  final Way? pointWay;

  /// A crate that can no longer be moved to a mark.
  final int? spoiled;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Palette.night);

    final ground = yard.ground;
    for (var at = 0; at < ground.squares; at++) {
      final square = metrics.squareAt(at);
      if (ground.isWall(at)) {
        _paintWall(canvas, square, at);
      } else {
        canvas.drawRect(square, Paint()..color = Palette.floor);
        // A faint line round every floor square. Judging what is two along
        // from what is the whole of this game, and counting squares off a
        // flat expanse is harder than it has any need to be.
        canvas.drawRect(
          square.deflate(0.25),
          Paint()
            ..color = Palette.night.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        if (ground.isMark(at)) _paintMark(canvas, square);
      }
    }

    for (final crate in yard.crates) {
      _paintCrate(
        canvas,
        metrics.squareAt(crate),
        home: ground.isMark(crate),
        wrong: crate == spoiled,
      );
    }

    _paintHauler(canvas, metrics.squareAt(yard.hauler));

    final point = pointAt;
    if (point != null) _paintPointer(canvas, metrics.squareAt(point));
  }

  void _paintWall(Canvas canvas, Rect square, int at) {
    // Only walls with floor above them get a lit top. A block of wall drawn
    // with a line across every course reads as brickwork, which is a texture
    // nobody needs on a puzzle.
    // Half a pixel over, so two walls side by side do not leave a seam of
    // background showing between them.
    canvas.drawRect(square.inflate(0.5), Paint()..color = Palette.wall);
    final above = yard.ground.rowOf(at) > 0
        ? at - yard.ground.across
        : -1;
    if (above >= 0 && !yard.ground.isWall(above)) {
      canvas.drawRect(
        Rect.fromLTWH(square.left, square.top, square.width, square.height * 0.16),
        Paint()..color = Palette.wallTop,
      );
    }
  }

  void _paintMark(Canvas canvas, Rect square) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        square.deflate(square.width * 0.32),
        Radius.circular(square.width * 0.06),
      ),
      Paint()
        ..color = Palette.mark
        ..style = PaintingStyle.stroke
        ..strokeWidth = square.width * 0.075,
    );
  }

  void _paintCrate(Canvas canvas, Rect square, {
    required bool home,
    required bool wrong,
  }) {
    final box = square.deflate(square.width * 0.09);
    final round = Radius.circular(square.width * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(box, round),
      Paint()..color = home ? Palette.crateHome : Palette.crate,
    );
    // A band across it, so a crate is not just a coloured square.
    canvas.drawRRect(
      RRect.fromRectAndRadius(box.deflate(box.width * 0.19), round),
      Paint()
        ..color = home ? Palette.crateHomeEdge : Palette.crateEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = square.width * 0.07,
    );
    if (wrong) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, round),
        Paint()
          ..color = Palette.warn
          ..style = PaintingStyle.stroke
          ..strokeWidth = square.width * 0.09,
      );
    }
  }

  void _paintHauler(Canvas canvas, Rect square) {
    canvas.drawCircle(
      square.center,
      square.width * 0.30,
      Paint()..color = Palette.hauler,
    );
    canvas.drawCircle(
      square.center - Offset(0, square.width * 0.08),
      square.width * 0.11,
      Paint()..color = Palette.night.withValues(alpha: 0.45),
    );
  }

  /// The crate the game is pointing at, and an arrow off it the way it says.
  void _paintPointer(Canvas canvas, Rect square) {
    final paint = Paint()
      ..color = Palette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = square.width * 0.075;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        square.deflate(square.width * 0.05),
        Radius.circular(square.width * 0.14),
      ),
      paint,
    );

    final way = pointWay;
    if (way == null) return;
    final step = Offset(way.column.toDouble(), way.row.toDouble());
    final tip = square.center + step * square.width;
    final tail = square.center + step * (square.width * 0.55);
    canvas.drawLine(
      tail,
      tip - step * (square.width * 0.22),
      Paint()
        ..color = Palette.ink
        ..strokeWidth = square.width * 0.09
        ..strokeCap = StrokeCap.round,
    );
    final side = Offset(-step.dy, step.dx) * (square.width * 0.16);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tip.dx - step.dx * square.width * 0.26 + side.dx,
            tip.dy - step.dy * square.width * 0.26 + side.dy)
        ..lineTo(tip.dx - step.dx * square.width * 0.26 - side.dx,
            tip.dy - step.dy * square.width * 0.26 - side.dy)
        ..close(),
      Paint()..color = Palette.ink,
    );
  }

  @override
  bool shouldRepaint(YardPainter old) =>
      old.yard != yard ||
      old.pointAt != pointAt ||
      old.pointWay != pointWay ||
      old.spoiled != spoiled;
}

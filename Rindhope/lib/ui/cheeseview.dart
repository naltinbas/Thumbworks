import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cheese/play.dart';
import 'palette.dart';

/// Where every crumb sits, shared by the painter and the hit-testing, so
/// where a crumb is drawn is exactly where a crumb is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final block = play.block;
    // Proportional margins, so the tiniest launcher icon still gets
    // positive crumbs.
    cell = math.min(
      width / (block.width + 0.5),
      height / (block.height + 0.5),
    );
    final wide = cell * block.width;
    final high = cell * block.height;
    corner = Offset((width - wide) / 2, (height - high) / 2);
    board = Rect.fromLTWH(corner.dx, corner.dy, wide, high);
  }

  final Play play;

  late final double width;
  late final double height;
  late final double cell;
  late final Offset corner;
  late final Rect board;

  /// The crumb at column [x], height [y]. The mould sits bottom-left.
  Rect crumbRect(int x, int y) => Rect.fromLTWH(
        corner.dx + x * cell,
        corner.dy + (play.block.height - 1 - y) * cell,
        cell,
        cell,
      );

  /// The crumb under a touch, or null off the block.
  (int, int)? crumbAt(Offset touch) {
    if (!board.contains(touch)) return null;
    final x = ((touch.dx - corner.dx) / cell).floor();
    final row = ((touch.dy - corner.dy) / cell).floor();
    final y = play.block.height - 1 - row;
    if (x < 0 || y < 0 || x >= play.block.width || y >= play.block.height) {
      return null;
    }
    return (x, y);
  }
}

/// The cheese, drawn.
class CheeseView extends CustomPainter {
  CheeseView({
    required this.play,
    required this.pointing,
    required this.showWhy,
  });

  final Play play;

  /// The crumb being pointed at, or null.
  final (int, int)? pointing;

  /// Whether to draw the argument: the mirror line on squares, the longer
  /// bottom row on strips, and the mould ringed everywhere.
  final bool showWhy;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var x = 0; x < play.block.width; x++) {
      for (var y = 0; y < play.block.height; y++) {
        if (!play.standing(x, y)) continue;
        if (x == 0 && y == 0) {
          _mould(canvas, metrics.crumbRect(x, y));
        } else {
          _crumb(canvas, metrics.crumbRect(x, y), x, y);
        }
      }
    }
    if (play.theirBite != null) _mouse(canvas, metrics);
    if (showWhy) _why(canvas, metrics);
    if (pointing != null) _point(canvas, metrics);
  }

  void _crumb(Canvas canvas, Rect rect, int x, int y) {
    final round = RRect.fromRectAndRadius(
        rect.deflate(rect.width * 0.05), Radius.circular(rect.width * 0.16));
    canvas.drawRRect(round, Paint()..color = Palette.cheese);
    canvas.drawRRect(
      round,
      Paint()
        ..color = Palette.rind
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    // A hole or two, steady per crumb so the cheese does not shimmer.
    final holes = (x * 7 + y * 13) % 3;
    final hole = Paint()..color = Palette.hole;
    if (holes >= 1) {
      canvas.drawCircle(
        rect.center + Offset(rect.width * 0.18, -rect.height * 0.14),
        rect.width * 0.11,
        hole,
      );
    }
    if (holes >= 2) {
      canvas.drawCircle(
        rect.center + Offset(-rect.width * 0.16, rect.height * 0.18),
        rect.width * 0.08,
        hole,
      );
    }
  }

  void _mould(Canvas canvas, Rect rect) {
    final round = RRect.fromRectAndRadius(
        rect.deflate(rect.width * 0.05), Radius.circular(rect.width * 0.16));
    canvas.drawRRect(round, Paint()..color = Palette.mould);
    canvas.drawRRect(
      round,
      Paint()
        ..color = Palette.mouldDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // The mottling.
    final spot = Paint()..color = Palette.mouldDark;
    for (final speck in const [(-0.2, -0.15), (0.15, 0.05), (-0.05, 0.22)]) {
      canvas.drawCircle(
        rect.center + Offset(rect.width * speck.$1, rect.height * speck.$2),
        rect.width * 0.08,
        spot,
      );
    }
  }

  void _mouse(Canvas canvas, Metrics metrics) {
    // The grey mouse, sitting where its last bite began.
    final (x, y) = play.theirBite!;
    final rect = metrics.crumbRect(x, y);
    final middle = rect.center;
    final body = Paint()..color = Palette.mouse;

    canvas.drawOval(
      Rect.fromCenter(
        center: middle + Offset(0, rect.height * 0.08),
        width: rect.width * 0.52,
        height: rect.height * 0.38,
      ),
      body,
    );
    // Head and ear toward the cheese, tail away.
    canvas.drawCircle(
      middle + Offset(-rect.width * 0.26, rect.height * 0.02),
      rect.width * 0.15,
      body,
    );
    canvas.drawCircle(
      middle + Offset(-rect.width * 0.22, -rect.height * 0.14),
      rect.width * 0.09,
      body,
    );
    final tail = Path()
      ..moveTo(middle.dx + rect.width * 0.24, middle.dy + rect.height * 0.1)
      ..quadraticBezierTo(
        middle.dx + rect.width * 0.46,
        middle.dy + rect.height * 0.02,
        middle.dx + rect.width * 0.44,
        middle.dy - rect.height * 0.18,
      );
    canvas.drawPath(
      tail,
      Paint()
        ..color = Palette.mouse
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.6, rect.width * 0.05)
        ..strokeCap = StrokeCap.round,
    );
  }

  void _why(Canvas canvas, Metrics metrics) {
    // The mould, ringed: the crumb the whole game is about.
    final mould = metrics.crumbRect(0, 0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        mould.inflate(3),
        Radius.circular(mould.width * 0.2),
      ),
      Paint()
        ..color = Palette.mirror
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // On squares, the mirror line the strategy answers across.
    if (play.block.width == play.block.height) {
      final from = metrics.crumbRect(0, 0).center;
      final to = metrics
          .crumbRect(play.block.width - 1, play.block.height - 1)
          .center;
      final line = Paint()
        ..color = Palette.mirror.withValues(alpha: 0.8)
        ..strokeWidth = 2;
      var along = 0.0;
      final way = to - from;
      final length = way.distance;
      final step = way / length;
      while (along < length) {
        canvas.drawLine(
          from + step * along,
          from + step * math.min(along + 7, length),
          line,
        );
        along += 13;
      }
    }
  }

  void _point(Canvas canvas, Metrics metrics) {
    final rect = metrics.crumbRect(pointing!.$1, pointing!.$2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(rect.width * 0.06),
        Radius.circular(rect.width * 0.2),
      ),
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(CheeseView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showWhy != showWhy;
}

/// The words the why speaks, from the block at hand.
String whyWords(Play play) {
  final block = play.block;
  final start = 'Whoever takes the mouldy crumb has lost, and the first '
      'mouse wins every block: if the far corner nibble could be answered, '
      'that answer could have been bitten first. The argument names no '
      'bite, which is its own lesson.';
  return '$start${block.note == null ? '' : ' ${block.note}'}';
}

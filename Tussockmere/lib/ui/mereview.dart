import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mere/play.dart';
import 'palette.dart';

/// Where every tussock lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final size = play.field.size;
    wide = room.width * 0.88 / (size + (size - 1) * 0.5);
    tall = wide * 2 / math.sqrt(3);
    left = (room.width - wide * (size + (size - 1) * 0.5)) / 2;
    top = (room.height - tall * (1 + (size - 1) * 0.75)) * 0.46;
  }

  final Play play;

  /// One hexagon's width and height.
  late final double wide;
  late final double tall;
  late final double left;
  late final double top;

  /// The middle of a tussock.
  Offset middleOf(int at) {
    final size = play.field.size;
    final row = at ~/ size;
    final col = at % size;
    return Offset(
      left + wide * (col + row * 0.5) + wide / 2,
      top + tall * (0.5 + row * 0.75),
    );
  }

  /// The tussock under a touch, or null.
  int? tussockUnder(Offset touch) {
    for (var at = 0; at < play.field.size * play.field.size; at++) {
      if ((middleOf(at) - touch).distance <= wide * 0.5) return at;
    }
    return null;
  }
}

/// The marsh, drawn.
class MereView extends CustomPainter {
  MereView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The tussock being pointed at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final n = play.field.size;

    _banks(canvas, metrics, n);

    for (var at = 0; at < n * n; at++) {
      final middle = metrics.middleOf(at);
      final hex = _hex(middle, metrics.wide * 0.55);
      canvas.drawPath(hex, Paint()..color = Palette.tussock);
      canvas.drawPath(
        hex,
        Paint()
          ..color =
              at == pointing ? Palette.shown : Palette.tussockRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = at == pointing ? 2.8 : 1.3,
      );

      if (play.cells[at] == 1) {
        canvas.drawCircle(middle, metrics.wide * 0.3,
            Paint()..color = Palette.gold);
        canvas.drawCircle(
          middle,
          metrics.wide * 0.3,
          Paint()
            ..color = Palette.goldDark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      } else if (play.cells[at] == 2) {
        _rushes(canvas, middle, metrics.wide);
      }
    }
  }

  void _banks(Canvas canvas, Metrics metrics, int n) {
    // Your two banks in gold, west and east; the mere's in rush.
    final westTop = metrics.middleOf(0);
    final westBottom = metrics.middleOf(n * (n - 1));
    final eastTop = metrics.middleOf(n - 1);
    final eastBottom = metrics.middleOf(n * n - 1);

    final gold = Paint()
      ..color = Palette.gold.withValues(alpha: 0.75)
      ..strokeWidth = metrics.wide * 0.16
      ..strokeCap = StrokeCap.round;
    final rush = Paint()
      ..color = Palette.rush.withValues(alpha: 0.75)
      ..strokeWidth = metrics.wide * 0.16
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        westTop.translate(-metrics.wide * 0.75, 0),
        westBottom.translate(-metrics.wide * 0.75, 0),
        gold);
    canvas.drawLine(
        eastTop.translate(metrics.wide * 0.75, 0),
        eastBottom.translate(metrics.wide * 0.75, 0),
        gold);
    canvas.drawLine(
        westTop.translate(-metrics.wide * 0.4, -metrics.tall * 0.62),
        eastTop.translate(metrics.wide * 0.4, -metrics.tall * 0.62),
        rush);
    canvas.drawLine(
        westBottom.translate(
            -metrics.wide * 0.4, metrics.tall * 0.62),
        eastBottom.translate(
            metrics.wide * 0.4, metrics.tall * 0.62),
        rush);
  }

  Path _hex(Offset middle, double reach) {
    final path = Path();
    for (var corner = 0; corner < 6; corner++) {
      final turn = math.pi / 6 + corner * math.pi / 3;
      final spot = middle +
          Offset(math.cos(turn), math.sin(turn)) * reach * 1.12;
      if (corner == 0) {
        path.moveTo(spot.dx, spot.dy);
      } else {
        path.lineTo(spot.dx, spot.dy);
      }
    }
    path.close();
    return path;
  }

  void _rushes(Canvas canvas, Offset middle, double wide) {
    final paint = Paint()
      ..color = Palette.rush
      ..strokeWidth = wide * 0.07
      ..strokeCap = StrokeCap.round;
    for (final lean in const [-0.28, 0.0, 0.28]) {
      canvas.drawLine(
        middle.translate(0, wide * 0.26),
        middle.translate(wide * lean, -wide * 0.28),
        paint,
      );
    }
    canvas.drawCircle(middle.translate(0, wide * 0.26), wide * 0.09,
        Paint()..color = Palette.rushDark);
  }

  @override
  bool shouldRepaint(MereView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the field at hand.
String whyWords(Play play) {
  final field = play.field;
  final note = field.note == null ? '' : ' ${field.note}';
  final base =
      'A full marsh always carries exactly one crossing, never '
      'both and never neither: all 512 fillings of the three-field '
      'and 65,536 of the four are swept, so a finished game has '
      'one winner and the game is solved to its end.';
  if (!field.winnable) {
    return '$base From the second chair of the four-field the '
        'solve holds every line, and each one loses: the first '
        'move was the whole game.$note';
  }
  return '$base The first chair wins both marshes, and on the '
      'four-field only the short diagonal\'s four openings survive '
      'a perfect reply.$note';
}

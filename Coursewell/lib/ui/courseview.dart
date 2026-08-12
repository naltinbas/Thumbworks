import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../course/play.dart';
import 'palette.dart';

/// Where every cell lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final yard = play.yard;
    cell = math.min(
      room.width * 0.82 / yard.width,
      room.height * 0.82 / yard.height,
    );
    left = (room.width - cell * yard.width) / 2 + cell * 0.09;
    top = (room.height - cell * yard.height) / 2 + cell * 0.09;
  }

  final Play play;

  late final double cell;
  late final double left;
  late final double top;

  /// The middle of a cell, rows read from the top.
  Offset middleOf(int at) => Offset(
        left + (at % play.yard.width + 0.5) * cell,
        top + (at ~/ play.yard.width + 0.5) * cell,
      );

  /// The cell under a touch, or -1 for the verge.
  int cellUnder(Offset touch) {
    final x = ((touch.dx - left) / cell).floor();
    final y = ((touch.dy - top) / cell).floor();
    if (x < 0 ||
        x >= play.yard.width ||
        y < 0 ||
        y >= play.yard.height) {
      return -1;
    }
    return y * play.yard.width + x;
  }
}

/// The yard, drawn: bed, bricks, and every inner line's
/// crossing count on the walls.
class CourseView extends CustomPainter {
  CourseView({
    required this.play,
    this.pointing,
    this.showCounts = true,
    required this.labels,
  });

  final Play play;

  /// The brick the show-me points at, to lay or lift, or null.
  final ((int, int), bool)? pointing;

  /// Whether the walls carry the crossing counts. Off for the
  /// mark, which is just the wall itself.
  final bool showCounts;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final yard = play.yard;
    final cell = metrics.cell;
    final wide = yard.width * cell;
    final high = yard.height * cell;
    final bed =
        Rect.fromLTWH(metrics.left, metrics.top, wide, high);

    canvas.drawRect(bed, Paint()..color = Palette.bed);

    // The mortar grid.
    final mortar = Paint()
      ..color = Palette.line
      ..strokeWidth = 1;
    for (var x = 1; x < yard.width; x++) {
      canvas.drawLine(
        Offset(metrics.left + x * cell, metrics.top),
        Offset(metrics.left + x * cell, metrics.top + high),
        mortar,
      );
    }
    for (var y = 1; y < yard.height; y++) {
      canvas.drawLine(
        Offset(metrics.left, metrics.top + y * cell),
        Offset(metrics.left + wide, metrics.top + y * cell),
        mortar,
      );
    }

    // The bricks.
    for (final (a, b) in play.laid) {
      final brick = Rect.fromPoints(
        metrics.middleOf(a),
        metrics.middleOf(b),
      ).inflate(cell * 0.40);
      final round =
          RRect.fromRectAndRadius(brick, Radius.circular(cell * 0.14));
      canvas.drawRRect(round, Paint()..color = Palette.brick);
      canvas.drawRRect(
        round,
        Paint()
          ..color = Palette.brickRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(cell * 0.05, 1.6),
      );
      canvas.drawLine(
        brick.topLeft + Offset(cell * 0.14, cell * 0.2),
        brick.topLeft + Offset(cell * 0.34, cell * 0.09),
        Paint()
          ..color = Palette.glint
          ..strokeWidth = math.max(cell * 0.05, 2.0)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The seams, once the yard is bricked whole: gold, wall
    // to wall.
    if (play.bricked) {
      final gold = Paint()
        ..color = Palette.seam
        ..strokeWidth = math.max(cell * 0.08, 3.0)
        ..strokeCap = StrokeCap.round;
      for (final (upright, line) in play.seams) {
        if (upright) {
          canvas.drawLine(
            Offset(metrics.left + line * cell, metrics.top),
            Offset(metrics.left + line * cell, metrics.top + high),
            gold,
          );
        } else {
          canvas.drawLine(
            Offset(metrics.left, metrics.top + line * cell),
            Offset(metrics.left + wide, metrics.top + line * cell),
            gold,
          );
        }
      }
    }

    // The wall.
    canvas.drawRect(
      bed,
      Paint()
        ..color = Palette.wall
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(cell * 0.09, 3.0),
    );

    // Every inner line's crossing count, upright counts on the
    // top wall, lying counts on the left: nought is a seam in
    // the making and wears the gold.
    if (showCounts) {
      final upright = List.filled(yard.width, 0);
      final level = List.filled(yard.height, 0);
      for (final (a, b) in play.laid) {
        final ax = a % yard.width, ay = a ~/ yard.width;
        final bx = b % yard.width, by = b ~/ yard.width;
        if (ax != bx) {
          upright[math.max(ax, bx)]++;
        } else {
          level[math.max(ay, by)]++;
        }
      }
      for (var x = 1; x < yard.width; x++) {
        _count(
          canvas,
          upright[x],
          Offset(metrics.left + x * cell, metrics.top - cell * 0.34),
          cell,
        );
      }
      for (var y = 1; y < yard.height; y++) {
        _count(
          canvas,
          level[y],
          Offset(metrics.left - cell * 0.34, metrics.top + y * cell),
          cell,
        );
      }
    }

    // The picked cell.
    final picked = play.picked;
    if (picked != null) {
      canvas.drawRect(
        Rect.fromCenter(
          center: metrics.middleOf(picked),
          width: cell * 0.84,
          height: cell * 0.84,
        ),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }

    // The pointed brick, struck through when it should go.
    final aim = pointing;
    if (aim != null) {
      final ((a, b), lay) = aim;
      final brick = Rect.fromPoints(
        metrics.middleOf(a),
        metrics.middleOf(b),
      ).inflate(cell * 0.40);
      canvas.drawRRect(
        RRect.fromRectAndRadius(brick, Radius.circular(cell * 0.14)),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
      if (!lay) {
        canvas.drawLine(
          brick.topLeft + Offset(cell * 0.1, cell * 0.1),
          brick.bottomRight - Offset(cell * 0.1, cell * 0.1),
          Paint()
            ..color = Palette.shown
            ..strokeWidth = 2.4,
        );
      }
    }
  }

  void _count(Canvas canvas, int crossings, Offset at, double cell) {
    final seam = crossings == 0;
    final wear = TextPainter(
      text: TextSpan(
        text: '$crossings',
        style: labels.copyWith(
          color: seam
              ? (play.bricked ? Palette.seam : Palette.inkDim)
              : Palette.ink,
          fontSize: cell * 0.3,
          fontWeight: seam && play.bricked
              ? FontWeight.w800
              : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    wear.paint(
      canvas,
      at - Offset(wear.width / 2, wear.height / 2),
    );
  }

  @override
  bool shouldRepaint(CourseView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showCounts != showCounts;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the yard at hand.
String whyWords(Play play) {
  final yard = play.yard;
  final note = yard.note == null ? '' : ' ${yard.note}';
  final all = play.rules.waysTo(null);
  if (!yard.winnable) {
    return 'Every brick crosses exactly one inner line, the one '
        'between its two cells. Take any line: the cells on its one '
        'side come even, whole bricks there take two apiece, so the '
        'bricks poking across must also take an even count, one '
        'cell each. Crossings come in pairs, a crossed line is '
        'crossed twice at least, and sound needs all ten lines '
        'crossed: twenty crossings asked, and eighteen bricks '
        'carry eighteen. The sweep laid all ${withComma(all)} '
        'layings of the yard and found seams in every one.$note';
  }
  return 'A seam is read straight off the laying: an inner line no '
      'brick crosses, gold when it happens. The sweep lays all '
      '${withComma(all)} layings of this yard and counts each '
      'one\'s seams, while a second walk counts every line\'s '
      'crossings brick by brick, held even on every full laying: '
      'crossings only come in pairs. ${withComma(yard.ways)} '
      'laying${yard.ways == 1 ? '' : 's'} land'
      '${yard.ways == 1 ? 's' : ''} this yard\'s asking.$note';
}

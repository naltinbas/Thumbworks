import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fold/green.dart';
import '../fold/play.dart';
import '../fold/rules.dart';
import 'palette.dart';

/// Where every crossing lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    final size = play.green.size;
    final span = math.min(room.width, room.height) * 0.88;
    cell = span / (size - 1);
    left = (room.width - span) / 2;
    top = (room.height - span) * 0.42;
  }

  final Play play;

  late final double cell;
  late final double left;
  late final double top;

  /// The point of the crossing at (x, y), y rising from the bottom.
  Offset crossAt(int x, int y) => Offset(
        left + x * cell,
        top + (play.green.size - 1 - y) * cell,
      );

  /// The crossing under a touch, or null for the surrounds.
  (int, int)? crossUnder(Offset touch) {
    for (var x = 0; x < play.green.size; x++) {
      for (var y = 0; y < play.green.size; y++) {
        if ((crossAt(x, y) - touch).distance <= cell * 0.34) {
          return (x, y);
        }
      }
    }
    return null;
  }
}

/// The green, drawn.
class FoldView extends CustomPainter {
  FoldView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The crossing being pointed at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final green = play.green;

    // The mowing lines.
    for (var at = 0; at < green.size; at++) {
      canvas.drawLine(
        metrics.crossAt(at, 0),
        metrics.crossAt(at, green.size - 1),
        Paint()
          ..color = Palette.mowing
          ..strokeWidth = 1.4,
      );
      canvas.drawLine(
        metrics.crossAt(0, at),
        metrics.crossAt(green.size - 1, at),
        Paint()
          ..color = Palette.mowing
          ..strokeWidth = 1.4,
      );
    }

    // The pen's wash, under everything else, once the fence stands.
    if (play.closed) {
      final wash = Path()
        ..moveTo(metrics.crossAt(play.posts.first.$1, play.posts.first.$2).dx,
            metrics.crossAt(play.posts.first.$1, play.posts.first.$2).dy);
      for (final (x, y) in play.posts.skip(1)) {
        final spot = metrics.crossAt(x, y);
        wash.lineTo(spot.dx, spot.dy);
      }
      wash.close();
      canvas.drawPath(wash, Paint()..color = Palette.pen);
    }

    // The crossings.
    for (var x = 0; x < green.size; x++) {
      for (var y = 0; y < green.size; y++) {
        canvas.drawCircle(
          metrics.crossAt(x, y),
          metrics.cell * 0.045,
          Paint()..color = Palette.cross,
        );
      }
    }

    // The rails.
    final rail = Paint()
      ..color = Palette.rail
      ..strokeWidth = math.max(metrics.cell * 0.07, 3.0)
      ..strokeCap = StrokeCap.round;
    for (var at = 0; at + 1 < play.posts.length; at++) {
      canvas.drawLine(
        metrics.crossAt(play.posts[at].$1, play.posts[at].$2),
        metrics.crossAt(play.posts[at + 1].$1, play.posts[at + 1].$2),
        rail,
      );
    }
    if (play.closed) {
      canvas.drawLine(
        metrics.crossAt(play.posts.last.$1, play.posts.last.$2),
        metrics.crossAt(play.posts.first.$1, play.posts.first.$2),
        rail,
      );
    }

    // The walked crossings between hurdles, once the fence stands.
    if (play.closed) {
      for (var x = 0; x < green.size; x++) {
        for (var y = 0; y < green.size; y++) {
          if (play.posts.contains((x, y))) continue;
          if (Rules.onFence(play.posts, (x, y))) {
            canvas.drawCircle(
              metrics.crossAt(x, y),
              metrics.cell * 0.09,
              Paint()..color = Palette.rail,
            );
          }
        }
      }
    }

    // The pointed crossing.
    final pointed = pointing;
    if (pointed != null) {
      canvas.drawCircle(
        metrics.crossAt(pointed.$1, pointed.$2),
        metrics.cell * 0.24,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }

    // The hurdles, first one gilt.
    for (var at = 0; at < play.posts.length; at++) {
      final middle =
          metrics.crossAt(play.posts[at].$1, play.posts[at].$2);
      canvas.drawCircle(
          middle, metrics.cell * 0.13, Paint()..color = Palette.hurdle);
      canvas.drawCircle(
        middle,
        metrics.cell * 0.13,
        Paint()
          ..color = at == 0 ? Palette.first : Palette.hurdleRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = at == 0 ? 2.8 : 1.6,
      );
    }

    // The sheep, at every swallowed crossing of a standing fence.
    if (play.closed) {
      for (var x = 0; x < green.size; x++) {
        for (var y = 0; y < green.size; y++) {
          if (Rules.onFence(play.posts, (x, y))) continue;
          if (!_rayIn(play.posts, (x, y))) continue;
          _sheep(canvas, metrics.crossAt(x, y), metrics.cell);
        }
      }
    }
  }

  bool _rayIn(List<(int, int)> posts, (int, int) spot) {
    final (x, y) = spot;
    var cuts = 0;
    for (var at = 0; at < posts.length; at++) {
      final (x1, y1) = posts[at];
      final (x2, y2) = posts[(at + 1) % posts.length];
      if ((y1 > y) != (y2 > y)) {
        final side = (y - y1) * (x2 - x1) - (x - x1) * (y2 - y1);
        if (y2 - y1 > 0 ? side > 0 : side < 0) cuts++;
      }
    }
    return cuts.isOdd;
  }

  void _sheep(Canvas canvas, Offset middle, double cell) {
    final body = cell * 0.16;
    canvas.drawOval(
      Rect.fromCenter(
          center: middle, width: body * 2.3, height: body * 1.6),
      Paint()..color = Palette.sheep,
    );
    canvas.drawCircle(
      middle + Offset(body * 1.05, -body * 0.35),
      body * 0.52,
      Paint()..color = Palette.sheepDark,
    );
    canvas.drawCircle(
      middle + Offset(body * 1.22, -body * 0.5),
      body * 0.14,
      Paint()..color = Palette.sheep,
    );
  }

  @override
  bool shouldRepaint(FoldView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the green at hand.
String whyWords(Play play) {
  final green = play.green;
  final note = green.note == null ? '' : ' ${green.note}';
  if (!green.winnable) {
    return 'Twice a fence\'s acreage, reckoned by the shoelace from '
        'hurdle coordinates alone, is always a whole number, and '
        'twice a third of an acre is not: no fence on any green ever '
        'pens it. The sweep of every fence of four hurdles or fewer '
        'here, 18,934 of them, finds acreages only in whole steps of '
        'a half.$note';
  }
  final closed = play.closed
      ? ' The fence standing now pens ${Green.acres(play.pens!)}: '
          '${play.swallows} swallowed and ${play.walks} walked make '
          '${play.swallows} + ${play.walks}/2 - 1 of it, and the '
          'shoelace says the same from coordinates alone.'
      : '';
  return 'Acreage is counted two ways that share nothing: the '
      'shoelace reckons it from the hurdles\' coordinates, and Pick '
      'counts crossings, acreage = swallowed + walked/2 - 1. The '
      'sweep of every fence of four hurdles or fewer on this green, '
      '18,934 of them, finds the two agreeing on every one. '
      '${withComma(green.ways!)} of those fences settle this '
      'task, ${green.posts} hurdles at fewest.$closed$note';
}

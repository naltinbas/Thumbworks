import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../link/play.dart';
import 'palette.dart';

/// What the game is marking on the map, when it is explaining itself.
class Marking {
  const Marking({
    this.thisSide = const [],
    this.thatSide = const [],
    this.crossing = const [],
    this.loop = const [],
    this.pointing = -1,
  });

  /// The hamlets on each side of a line, when a path is being explained.
  final List<int> thisSide;
  final List<int> thatSide;

  /// The paths that cross that line.
  final List<int> crossing;

  /// A loop, when a path outside the answer is being explained.
  final List<int> loop;

  /// The path being explained, or -1.
  final int pointing;

  bool get isEmpty =>
      thisSide.isEmpty && loop.isEmpty && pointing < 0;
}

/// Where everything on the map is.
///
/// The painter and the finger both use this, which is the point of it: a path
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    final side = math.min(room.width, room.height);
    spot = side * 0.032;
    final margin = spot * 3.2;
    across = room.width - margin * 2;
    down = room.height - margin * 2;
    corner = Offset(margin, margin);
  }

  final Play play;

  /// How big a hamlet is drawn.
  late final double spot;
  late final double across;
  late final double down;
  late final Offset corner;

  Offset middleOf(int place) =>
      corner +
      Offset(play.parish.places[place].x * across,
          play.parish.places[place].y * down);

  (Offset, Offset) endsOf(int trod) => (
        middleOf(play.parish[trod].from),
        middleOf(play.parish[trod].to),
      );

  Offset halfWay(int trod) {
    final (one, other) = endsOf(trod);
    return Offset((one.dx + other.dx) / 2, (one.dy + other.dy) / 2);
  }

  /// The path under a point, or -1. The yards written at the middle of a path
  /// are part of it, so a short path is no harder to hit than a long one.
  int trodAt(Offset touch) {
    var nearest = -1;
    var best = spot * 1.6;
    for (var trod = 0; trod < play.parish.many; trod++) {
      final (one, other) = endsOf(trod);
      final away = _awayFrom(touch, one, other);
      if (away < best) {
        best = away;
        nearest = trod;
      }
    }
    return nearest;
  }

  static double _awayFrom(Offset point, Offset one, Offset other) {
    final along = other - one;
    final length = along.distanceSquared;
    if (length == 0) return (point - one).distance;
    final how = (((point - one).dx * along.dx + (point - one).dy * along.dy) /
            length)
        .clamp(0.0, 1.0);
    return (point - (one + along * how)).distance;
  }
}

/// The map: the hamlets, the paths that could be cut, and the ones that have
/// been.
class MapView extends CustomPainter {
  const MapView({
    required this.play,
    required this.marking,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// Whatever the game is explaining, or an empty marking.
  final Marking marking;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the paths.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final parish = play.parish;
    final crossing = marking.crossing.toSet();
    final loop = marking.loop.toSet();

    for (var trod = 0; trod < parish.many; trod++) {
      final (one, other) = metrics.endsOf(trod);
      final cut = play.has(trod);

      final colour = loop.contains(trod)
          ? Palette.loop
          : crossing.contains(trod)
              ? Palette.thisSide
              : cut
                  ? Palette.trod
                  : Palette.could;
      final width = cut || loop.contains(trod) || crossing.contains(trod)
          ? metrics.spot * 0.44
          : metrics.spot * 0.16;

      canvas.drawLine(
        one,
        other,
        Paint()
          ..color = colour
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );

      if (trod == marking.pointing) {
        canvas.drawLine(
          one,
          other,
          Paint()
            ..color = Palette.ink
            ..strokeWidth = metrics.spot * 0.16
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    for (var place = 0; place < parish.count; place++) {
      final middle = metrics.middleOf(place);
      final side = marking.thisSide.contains(place)
          ? Palette.thisSide
          : marking.thatSide.contains(place)
              ? Palette.thatSide
              : null;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: middle,
            width: metrics.spot * 1.5,
            height: metrics.spot * 1.5,
          ),
          Radius.circular(metrics.spot * 0.3),
        ),
        Paint()..color = side ?? Palette.place,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: middle,
            width: metrics.spot * 0.7,
            height: metrics.spot * 0.7,
          ),
          Radius.circular(metrics.spot * 0.14),
        ),
        Paint()..color = Palette.night,
      );

      if (!showWords) continue;
      final name = TextPainter(
        text: TextSpan(
          text: parish.places[place].name,
          style: labels.copyWith(
            color: side ?? Palette.inkDim,
            fontWeight: side == null ? FontWeight.w500 : FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      _behind(canvas, name, middle + Offset(-name.width / 2, metrics.spot));
    }

    if (!showWords) return;

    // The yards on each path, in the middle of it.
    for (var trod = 0; trod < parish.many; trod++) {
      final cut = play.has(trod);
      final yards = TextPainter(
        text: TextSpan(
          text: '${parish[trod].yards}',
          style: labels.copyWith(
            color: loop.contains(trod)
                ? Palette.loop
                : crossing.contains(trod)
                    ? Palette.thisSide
                    : cut
                        ? Palette.trod
                        : Palette.inkDim,
            fontWeight: cut ? FontWeight.w700 : FontWeight.w500,
            fontSize: (labels.fontSize ?? 11) * 0.92,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final middle = metrics.halfWay(trod);
      _behind(canvas, yards,
          middle - Offset(yards.width / 2, yards.height / 2));
    }
  }

  /// Words on a map need something behind them, because paths go everywhere.
  void _behind(Canvas canvas, TextPainter words, Offset where) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(where.dx, where.dy, words.width, words.height)
            .inflate(2.4),
        const Radius.circular(3),
      ),
      Paint()..color = Palette.night.withValues(alpha: 0.86),
    );
    words.paint(canvas, where);
  }

  @override
  bool shouldRepaint(MapView old) =>
      old.play != play || old.marking != marking;
}

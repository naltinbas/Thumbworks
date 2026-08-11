import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../walk/play.dart';
import 'palette.dart';

/// Where every landing and bridge lies, shared by the painter and the
/// hit-testing, so where a thing is drawn is exactly where it is
/// tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    ground = math.min(math.min(width, height) * 0.105, 58.0);
    for (final (x, y) in play.town.spots) {
      centers.add(Offset(
        ground * 1.2 + x * (width - ground * 2.4),
        ground * 1.2 + y * (height - ground * 2.4),
      ));
    }
  }

  final Play play;

  late final double width;
  late final double height;

  /// A landing's radius.
  late final double ground;

  final List<Offset> centers = [];

  Offset groundCenter(int at) => centers[at];

  /// How far a bridge bows off the straight line: twins bow apart, and
  /// a town may bow any bridge further to keep it clear of a landing
  /// it passes.
  double _bow(int bridge) {
    final pair = play.town.bridges[bridge];
    final twins = <int>[];
    for (var other = 0; other < play.town.bridges.length; other++) {
      final that = play.town.bridges[other];
      if (that == pair || (that.$2, that.$1) == pair) twins.add(other);
    }
    final told = bridge < play.town.bows.length
        ? play.town.bows[bridge] * ground
        : 0.0;
    if (twins.length == 1) return told;
    final at = twins.indexOf(bridge);
    return (at - (twins.length - 1) / 2) * ground * 1.5 + told;
  }

  /// A point along a bridge, nought to one.
  Offset bridgePoint(int bridge, double t) {
    final (one, other) = play.town.bridges[bridge];
    final from = centers[one];
    final to = centers[other];
    final way = to - from;
    final side =
        Offset(-way.dy, way.dx) / way.distance * _bow(bridge);
    final mid = (from + to) / 2 + side;
    // A quadratic bend through the bowed middle.
    final a = Offset.lerp(from, mid, t)!;
    final b = Offset.lerp(mid, to, t)!;
    return Offset.lerp(a, b, t)!;
  }

  /// The landing under a touch, or -1.
  int groundAt(Offset touch) {
    for (var at = 0; at < centers.length; at++) {
      if ((centers[at] - touch).distance <= ground * 1.25) return at;
    }
    return -1;
  }

  /// The bridge under a touch, or -1. Landings win over bridges.
  int bridgeAt(Offset touch) {
    if (groundAt(touch) >= 0) return -1;
    var best = -1;
    var nearest = ground * 0.85;
    for (var bridge = 0; bridge < play.town.bridges.length; bridge++) {
      for (var step = 0; step <= 20; step++) {
        final away = (bridgePoint(bridge, step / 20) - touch).distance;
        if (away < nearest) {
          nearest = away;
          best = bridge;
        }
      }
    }
    return best;
  }
}

/// The town, drawn.
class WalkView extends CustomPainter {
  WalkView({
    required this.play,
    required this.pointingBridge,
    required this.pointingGround,
    this.showOdd = false,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The bridge or landing being pointed at, or -1.
  final int pointingBridge;
  final int pointingGround;

  /// Whether to rim the odd landings red.
  final bool showOdd;

  /// Whether names and tallies may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var bridge = 0; bridge < play.town.bridges.length; bridge++) {
      _bridge(canvas, metrics, bridge);
    }
    for (var ground = 0; ground < play.town.grounds.length; ground++) {
      _ground(canvas, metrics, ground);
    }
  }

  void _bridge(Canvas canvas, Metrics metrics, int bridge) {
    final walked = play.bridgeWalked(bridge);
    final path = Path()
      ..moveTo(
          metrics.bridgePoint(bridge, 0).dx, metrics.bridgePoint(bridge, 0).dy);
    for (var step = 1; step <= 20; step++) {
      final at = metrics.bridgePoint(bridge, step / 20);
      path.lineTo(at.dx, at.dy);
    }

    final wide = metrics.ground * (walked ? 0.2 : 0.3);
    canvas.drawPath(
      path,
      Paint()
        ..color = walked ? Palette.walkedPlank : Palette.plankEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = wide + metrics.ground * 0.08
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = walked
            ? Palette.walkedPlank
            : bridge == pointingBridge
                ? Palette.shown
                : Palette.plank
        ..style = PaintingStyle.stroke
        ..strokeWidth = wide
        ..strokeCap = StrokeCap.round,
    );

    if (!showWords || !walked) return;
    // The crossing's place in the walk, written at the middle.
    final at = play.order.indexOf(bridge) + 1;
    final mid = metrics.bridgePoint(bridge, 0.5);
    final words = TextPainter(
      text: TextSpan(
        text: '$at',
        style: labels.copyWith(
          color: Palette.inkDim,
          fontSize: metrics.ground * 0.34,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(canvas, mid - Offset(words.width / 2, words.height / 2));
  }

  void _ground(Canvas canvas, Metrics metrics, int ground) {
    final middle = metrics.groundCenter(ground);
    final round = metrics.ground;
    final odd = play.town.degree(ground).isOdd;

    canvas.drawCircle(middle, round, Paint()..color = Palette.ground);
    canvas.drawCircle(
      middle,
      round,
      Paint()
        ..color = ground == play.standing
            ? Palette.standing
            : ground == pointingGround
                ? Palette.shown
                : (showOdd && odd)
                    ? Palette.odd
                    : Palette.groundEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            ground == play.standing || ground == pointingGround || (showOdd && odd)
                ? 2.8
                : 1.6,
    );

    if (!showWords) return;

    // The tally: how many bridges, odd red, even green.
    final tally = TextPainter(
      text: TextSpan(
        text: '${play.town.degree(ground)}',
        style: labels.copyWith(
          color: odd ? Palette.odd : Palette.even,
          fontSize: round * 0.62,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tally.paint(
        canvas, middle - Offset(tally.width / 2, tally.height / 2));

    final name = TextPainter(
      text: TextSpan(
        text: play.town.grounds[ground],
        style: labels.copyWith(
          color: Palette.inkDim,
          fontSize: round * 0.3,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    name.paint(
      canvas,
      Offset(
        (middle.dx - name.width / 2)
            .clamp(2.0, metrics.width - name.width - 2.0),
        middle.dy + round * 1.12,
      ),
    );
  }

  @override
  bool shouldRepaint(WalkView old) =>
      old.play != play ||
      old.pointingBridge != pointingBridge ||
      old.pointingGround != pointingGround ||
      old.showOdd != showOdd;
}

/// The words the why speaks, from the town at hand.
String whyWords(Play play) {
  final town = play.town;
  final note = town.note == null ? '' : ' ${town.note}';
  final odd = play.rules.oddGrounds;
  if (!town.walkable) {
    return 'Crossing a landing spends two bridges, one in and one out, '
        'so a landing not at a walk\'s end must hold an even count. '
        'Only the two ends may be odd, and this town holds '
        '${odd.length} odd landings, red on the map. The search tried '
        'every trail from every landing all the same: none crosses '
        'every bridge.$note';
  }
  final where = odd.isEmpty
      ? 'No landing is odd, so a walk starts anywhere and ends where '
          'it began.'
      : 'The odd landings are ${town.grounds[odd[0]]} and '
          '${town.grounds[odd[1]]}, and every complete walk runs '
          'between them: the search counted the walks from every '
          'landing and found them nowhere else.';
  return 'Crossing a landing spends two bridges, one in and one out, '
      'so only a walk\'s two ends may hold an odd count. $where$note';
}

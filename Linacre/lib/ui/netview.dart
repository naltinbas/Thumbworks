import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wire/play.dart';
import '../wire/webs.dart';
import 'palette.dart';

/// Where every post and wire is drawn.
///
/// The painter and the finger both use this, which is the point of it: a wire
/// is where it is drawn, and there is no second sum that could disagree with
/// the first. Wires that share both posts are bowed apart so each can be seen
/// and touched on its own.
class Metrics {
  Metrics(this.play, Size room) {
    final side = math.min(room.width, room.height);
    spot = side * 0.034;
    final margin = spot * 3;
    across = room.width - margin * 2;
    down = room.height - margin * 2;
    corner = Offset(margin, margin);
  }

  final Play play;

  late final double spot;
  late final double across;
  late final double down;
  late final Offset corner;

  Offset middleOf(int post) =>
      corner +
      Offset(play.net.posts[post].x * across, play.net.posts[post].y * down);

  /// Where a wire bows out to, so twins between the same posts part company.
  Offset bendOf(int wire) {
    final ends = play.net[wire];
    final one = middleOf(ends.from);
    final other = middleOf(ends.to);
    final mid = Offset((one.dx + other.dx) / 2, (one.dy + other.dy) / 2);

    // Which of the wires between this same pair is this one?
    final twins = <int>[];
    for (var each = 0; each < play.net.many; each++) {
      final w = play.net[each];
      final same = (w.from == ends.from && w.to == ends.to) ||
          (w.from == ends.to && w.to == ends.from);
      if (same) twins.add(each);
    }
    if (twins.length == 1) return mid;

    final at = twins.indexOf(wire);
    final off = (at - (twins.length - 1) / 2) * spot * 1.7;
    final along = other - one;
    final length = along.distance;
    if (length == 0) return mid;
    final sideways = Offset(-along.dy / length, along.dx / length);
    return mid + sideways * off;
  }

  /// The wire under a point, or -1.
  int wireAt(Offset touch) {
    var nearest = -1;
    var best = spot * 1.7;
    for (var wire = 0; wire < play.net.many; wire++) {
      final one = middleOf(play.net[wire].from);
      final other = middleOf(play.net[wire].to);
      final bend = bendOf(wire);
      final away = math.min(
        _awayFrom(touch, one, bend),
        _awayFrom(touch, bend, other),
      );
      if (away < best) {
        best = away;
        nearest = wire;
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

/// The line: stations, posts, and every wire in its state.
class NetView extends CustomPainter {
  const NetView({
    required this.play,
    required this.pointing,
    required this.webs,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// A wire the game is pointing at, or -1.
  final int pointing;

  /// Two webs to tint, when the game is explaining itself, or null.
  final TwoWebs? webs;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the wires.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final net = play.net;

    for (var wire = 0; wire < net.many; wire++) {
      final one = metrics.middleOf(net[wire].from);
      final other = metrics.middleOf(net[wire].to);
      final bend = metrics.bendOf(wire);

      final inOne = webs != null && (webs!.one & (1 << wire)) != 0;
      final inOther = webs != null && (webs!.other & (1 << wire)) != 0;

      final colour = play.isBraced(wire)
          ? Palette.braced
          : inOne
              ? Palette.webOne
              : inOther
                  ? Palette.webOther
                  : play.isCut(wire)
                      ? Palette.stub
                      : Palette.wire;
      final width = play.isBraced(wire) || inOne || inOther
          ? metrics.spot * 0.42
          : metrics.spot * 0.16;

      final path = Path()
        ..moveTo(one.dx, one.dy)
        ..quadraticBezierTo(bend.dx, bend.dy, other.dx, other.dy);

      if (play.isCut(wire)) {
        // The two stubs of a cut wire, with the middle gone.
        for (final (from, toward) in [(one, bend), (other, bend)]) {
          final stub = Offset(
            from.dx + (toward.dx - from.dx) * 0.32,
            from.dy + (toward.dy - from.dy) * 0.32,
          );
          canvas.drawLine(
            from,
            stub,
            Paint()
              ..color = Palette.stub
              ..strokeWidth = metrics.spot * 0.16
              ..strokeCap = StrokeCap.round,
          );
          canvas.drawCircle(stub, metrics.spot * 0.14,
              Paint()..color = Palette.stub);
        }
      } else {
        canvas.drawPath(
          path,
          Paint()
            ..color = colour
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round,
        );
      }

      if (wire == pointing || wire == play.theirLast) {
        canvas.drawCircle(
          metrics.bendOf(wire),
          metrics.spot * 0.75,
          Paint()
            ..color = wire == pointing ? Palette.ink : Palette.braced
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.spot * 0.14,
        );
      }
    }

    for (var post = 0; post < net.count; post++) {
      final middle = metrics.middleOf(post);
      final isStation = post == net.stationA || post == net.stationB;

      if (isStation) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: middle,
              width: metrics.spot * 2.4,
              height: metrics.spot * 2.4,
            ),
            Radius.circular(metrics.spot * 0.4),
          ),
          Paint()..color = Palette.station,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: middle,
              width: metrics.spot * 1.3,
              height: metrics.spot * 1.3,
            ),
            Radius.circular(metrics.spot * 0.2),
          ),
          Paint()..color = Palette.night,
        );
      } else {
        canvas.drawCircle(middle, metrics.spot * 0.8,
            Paint()..color = Palette.post);
        canvas.drawCircle(
          middle,
          metrics.spot * 0.8,
          Paint()
            ..color = Palette.edge
            ..style = PaintingStyle.stroke
            ..strokeWidth = metrics.spot * 0.16,
        );
      }

      if (!showWords) continue;
      final name = TextPainter(
        text: TextSpan(
          text: net.posts[post].name,
          style: labels.copyWith(
            color: isStation ? Palette.ink : Palette.inkDim,
            fontWeight: isStation ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final where = middle +
          Offset(-name.width / 2, metrics.spot * (isStation ? 1.5 : 1.1));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(where.dx, where.dy, name.width, name.height)
              .inflate(2.4),
          const Radius.circular(3),
        ),
        Paint()..color = Palette.night.withValues(alpha: 0.85),
      );
      name.paint(canvas, where);
    }
  }

  @override
  bool shouldRepaint(NetView old) =>
      old.play != play || old.pointing != pointing || old.webs != webs;
}

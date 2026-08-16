import 'dart:math';

import 'package:flutter/material.dart';

import '../lever/frac.dart';
import '../lever/play.dart';
import 'palette.dart';

/// Where the loop and the purse's graph sit in a board of a given size:
/// the slots stand round a ring in the upper part, the graph runs across
/// the lower.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final room = bare ? size.height : size.height * 0.56;
    final across = min(size.width, room);
    // The ring has to leave room for the slots that stand on it, and on
    // a launcher icon of a few dozen pixels there is not much of it.
    ring = max(across * 0.24, across / 2 - across * 0.22);
    middle = Offset(size.width / 2, room / 2);
    slot = max(2.0, min(ring * (bare ? 0.58 : 0.42), bare ? 70.0 : 26.0));
    graph = Rect.fromLTRB(
      34,
      room + 6,
      size.width - 10,
      size.height - (bare ? 0 : 18),
    );
  }

  final Play play;
  final Size size;
  final bool bare;

  /// How far the slots stand from the middle.
  late final double ring;
  late final Offset middle;

  /// How big a slot is drawn.
  late final double slot;

  /// Where the purse's graph goes.
  late final Rect graph;

  /// Where slot [i] of the loop stands.
  Offset at(int i) {
    final turn = 2 * pi * i / play.loop.length - pi / 2;
    return middle + Offset(cos(turn), sin(turn)) * ring;
  }

  /// Which slot lies under [where], or null when none is near enough.
  int? under(Offset where) {
    var nearest = -1;
    var best = double.infinity;
    for (var i = 0; i < play.loop.length; i++) {
      final far = (at(i) - where).distance;
      if (far < best) {
        best = far;
        nearest = i;
      }
    }
    return best <= slot * 1.7 ? nearest : null;
  }

  bool get roomy => !bare && graph.height >= 60 && size.width >= 260;
}

/// The loop of levers, and what the purse does when it is run.
class LeverView extends CustomPainter {
  const LeverView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the loop alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final loop = play.loop;

    // The track the loop runs round, and which way it runs.
    if (loop.length > 1) {
      canvas.drawCircle(
        m.middle,
        m.ring,
        Paint()
          ..color = bare ? Palette.gold.withValues(alpha: 0.5) : Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.5, m.slot * (bare ? 0.16 : 0.12)),
      );
      for (var k = 0; k < loop.length; k++) {
        final turn = 2 * pi * (k + 0.5) / loop.length - pi / 2;
        final at = m.middle + Offset(cos(turn), sin(turn)) * m.ring;
        final along = Offset(-sin(turn), cos(turn));
        final side = Offset(-along.dy, along.dx);
        final head = m.slot * 0.34;
        canvas.drawPath(
          Path()
            ..moveTo(at.dx + along.dx * head, at.dy + along.dy * head)
            ..lineTo(at.dx - along.dx * head + side.dx * head * 0.7,
                at.dy - along.dy * head + side.dy * head * 0.7)
            ..lineTo(at.dx - along.dx * head - side.dx * head * 0.7,
                at.dy - along.dy * head - side.dy * head * 0.7)
            ..close(),
          Paint()..color = bare ? Palette.gold : Palette.line,
        );
      }
    }

    for (var i = 0; i < loop.length; i++) {
      final at = m.at(i);
      final gear = loop[i] == 'B';
      final lit = pointing != null &&
          pointing!.$1 == 'flip' &&
          pointing!.$2 == i;
      final box = Rect.fromCenter(
        center: at,
        width: m.slot * 1.6,
        height: m.slot * 1.6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(m.slot * 0.4)),
        Paint()..color = gear ? Palette.gear : Palette.plain,
      );
      if (lit) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            box.inflate(m.slot * 0.22),
            Radius.circular(m.slot * 0.5),
          ),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.6, m.slot * 0.14),
        );
      }
      _word(canvas, loop[i], at, m.slot * 1.1, Palette.night, bold: true);
    }

    if (bare) return;

    // The purse, round by round.
    final purse = play.purse;
    final graph = m.graph;
    if (graph.height < 40 || graph.width < 80) return;
    var high = 0.0, low = 0.0;
    for (final at in purse) {
      final coin = at.toDouble;
      high = max(high, coin);
      low = min(low, coin);
    }
    if (high - low < 0.5) {
      high += 0.25;
      low -= 0.25;
    }
    double yOf(double coin) =>
        graph.bottom - (coin - low) / (high - low) * graph.height;
    double xOf(int round) =>
        graph.left + graph.width * round / (Play.rounds - 1);

    canvas.drawLine(
      Offset(graph.left, yOf(0)),
      Offset(graph.right, yOf(0)),
      Paint()
        ..color = Palette.grid
        ..strokeWidth = 1.2,
    );
    final path = Path()..moveTo(xOf(0), yOf(0));
    for (var round = 0; round < purse.length; round++) {
      path.lineTo(xOf(round), yOf(purse[round].toDouble));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = play.climb > Frac.zero ? Palette.gold : Palette.inkDim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
      Offset(xOf(purse.length - 1), yOf(purse.last.toDouble)),
      3.4,
      Paint()..color = Palette.gold,
    );
    _word(
      canvas,
      'purse',
      Offset(graph.left - 17, yOf(0)),
      11,
      Palette.inkDim,
    );
    _word(
      canvas,
      '${Play.rounds} rounds',
      Offset(graph.right - 34, graph.bottom + 9),
      11,
      Palette.inkDim,
    );
    _word(
      canvas,
      purse.last.toDouble.toStringAsFixed(2),
      Offset(xOf(purse.length - 1) - 16, yOf(purse.last.toDouble) - 10),
      11,
      Palette.gold,
    );
  }

  void _word(
    Canvas canvas,
    String words,
    Offset at,
    double size,
    Color colour, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(
          color: colour,
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(LeverView old) =>
      old.play != play || old.pointing != pointing;
}

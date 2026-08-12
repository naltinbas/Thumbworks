import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../chase/play.dart';
import 'palette.dart';

/// Where every post lies, shared by the painter and the hit-testing,
/// so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    post = math.min(width, height) * 0.052;
    for (final (x, y) in play.ground.spots) {
      centers.add(Offset(
        post * 2 + x * (width - post * 4),
        post * 2 + y * (height - post * 4),
      ));
    }
  }

  final Play play;

  late final double width;
  late final double height;
  late final double post;
  final List<Offset> centers = [];

  Offset postAt(int at) => centers[at];

  /// The post under a touch, or -1.
  int postUnder(Offset touch) {
    for (var at = 0; at < play.ground.posts; at++) {
      if ((centers[at] - touch).distance <= post * 2.1) return at;
    }
    return -1;
  }
}

/// The ground, drawn.
class ChaseView extends CustomPainter {
  ChaseView({
    required this.play,
    required this.pointing,
    this.folding,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The post being pointed at, or -1.
  final int pointing;

  /// The folding order to number in gold, or null.
  final List<int>? folding;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (final (a, b) in play.ground.paths) {
      canvas.drawLine(
        metrics.postAt(a),
        metrics.postAt(b),
        Paint()
          ..color = Palette.path
          ..strokeWidth = math.max(metrics.post * 0.32, 2.0)
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var at = 0; at < play.ground.posts; at++) {
      final middle = metrics.postAt(at);
      canvas.drawCircle(
          middle, metrics.post, Paint()..color = Palette.post);
      canvas.drawCircle(
        middle,
        metrics.post,
        Paint()
          ..color =
              at == pointing ? Palette.shown : Palette.postRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = at == pointing ? 2.8 : 1.6,
      );
    }

    final order = folding;
    if (order != null && showWords) {
      for (var at = 0; at < order.length; at++) {
        final middle = metrics.postAt(order[at]);
        final words = TextPainter(
          text: TextSpan(
            text: '${at + 1}',
            style: labels.copyWith(
              color: Palette.fold,
              fontSize: metrics.post * 0.9,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        // The beasts hover above their posts, so a numbered post with
        // a beast on it takes its number below instead.
        final stoodOn =
            order[at] == play.cat || order[at] == play.mouse;
        words.paint(
          canvas,
          middle +
              (stoodOn
                  ? Offset(metrics.post * 1.05, metrics.post * 0.55)
                  : Offset(
                      metrics.post * 1.2, -metrics.post * 1.9)),
        );
      }
    }

    _beast(canvas, metrics, play.mouse, isCat: false);
    _beast(canvas, metrics, play.cat, isCat: true);
  }

  void _beast(Canvas canvas, Metrics metrics, int at,
      {required bool isCat}) {
    final middle = metrics.postAt(at) +
        Offset(isCat ? -metrics.post * 0.55 : metrics.post * 0.55,
            -metrics.post * 1.35);
    final body = metrics.post * 0.85;
    final coat = isCat ? Palette.cat : Palette.mouse;
    final dark = isCat ? Palette.catDark : Palette.mouseDark;

    canvas.drawCircle(middle, body, Paint()..color = coat);
    if (isCat) {
      for (final side in const [-1.0, 1.0]) {
        final ear = Path()
          ..moveTo(middle.dx + side * body * 0.75,
              middle.dy - body * 0.5)
          ..lineTo(middle.dx + side * body * 0.35,
              middle.dy - body * 0.85)
          ..lineTo(middle.dx + side * body * 0.9,
              middle.dy - body * 1.15)
          ..close();
        canvas.drawPath(ear, Paint()..color = coat);
      }
    } else {
      for (final side in const [-1.0, 1.0]) {
        canvas.drawCircle(
          middle + Offset(side * body * 0.7, -body * 0.75),
          body * 0.42,
          Paint()..color = coat,
        );
      }
      canvas.drawLine(
        middle + Offset(body * 0.9, body * 0.2),
        middle + Offset(body * 1.9, body * 0.55),
        Paint()
          ..color = dark
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
        middle + Offset(-body * 0.3, -body * 0.1),
        body * 0.11,
        Paint()..color = dark);
    canvas.drawCircle(
        middle + Offset(body * 0.3, -body * 0.1),
        body * 0.11,
        Paint()..color = dark);
  }

  @override
  bool shouldRepaint(ChaseView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.folding != folding;
}

/// The words the why speaks, from the ground at hand.
String whyWords(Play play) {
  final ground = play.ground;
  final note = ground.note == null ? '' : ' ${ground.note}';
  if (!ground.winnable) {
    return 'A corner is a post whose every move lies within some '
        'other post\'s reach, and a ground the cat can sweep folds '
        'up corner by corner to a single post. This one has no '
        'corner to start with, and the search of every chase says '
        'the same from the other side: no standing ever catches. '
        'The rule and the search agree on every ground of six posts '
        'or fewer, all 27,475 of them.$note';
  }
  return 'This ground folds up corner by corner, gold numbers in '
      'folding order, which is exactly the old rule for a ground '
      'the cat can sweep: proved against the search of every chase '
      'on all 27,475 small grounds. From post ${ground.catStart} '
      'the catch takes ${ground.rounds} round'
      '${ground.rounds == 1 ? '' : 's'} at worst.$note';
}

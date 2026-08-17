import 'dart:math';

import 'package:flutter/material.dart';

import '../rod/play.dart';
import '../rod/rules.dart';
import 'palette.dart';

/// Where the rod lies in a board of a given size: across the middle,
/// marked off in hands, with the cuts between them.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    // The pad has to shrink with the board, or a launcher icon of a few
    // dozen pixels leaves the rod no width at all.
    final pad = min(bare ? 14.0 : 20.0, size.width * 0.06);
    hand = max(1.0, (size.width - 2 * pad) / play.hands);
    left = (size.width - hand * play.hands) / 2;
    middle = size.height * (bare ? 0.5 : 0.42);
    thick = max(2.0, min(hand * 1.5, bare ? 90.0 : 64.0));
  }

  final Play play;
  final Size size;
  final bool bare;

  /// How wide a hand of the rod is drawn.
  late final double hand;
  late final double left;
  late final double middle;

  /// How deep the rod is drawn.
  late final double thick;

  Rect handAt(int which) =>
      Rect.fromLTWH(left + which * hand, middle - thick / 2, hand, thick);

  /// Where the cut after hand [place] + 1 falls.
  double cutAt(int place) => left + (place + 1) * hand;

  /// Which cut place lies under [where], or null when none is near
  /// enough.
  int? under(Offset where) {
    if ((where.dy - middle).abs() > thick) return null;
    var nearest = -1;
    var best = double.infinity;
    for (var place = 0; place < Rules.places(play.hands); place++) {
      final far = (cutAt(place) - where.dx).abs();
      if (far < best) {
        best = far;
        nearest = place;
      }
    }
    return best <= hand * 0.5 ? nearest : null;
  }

  bool get roomy => hand >= 18;
}

/// The rod, the cuts in it, the parts they leave and what they
/// multiply to.
class RodView extends CustomPainter {
  const RodView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The cut the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the rod alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final parts = play.parts;

    // The parts, each a length of rod with a gap where it was cut.
    var hand = 0;
    for (var which = 0; which < parts.length; which++) {
      final part = parts[which];
      final gap = m.hand * 0.08;
      final box = Rect.fromLTRB(
        m.left + hand * m.hand + (which == 0 ? 0 : gap),
        m.middle - m.thick / 2,
        m.left + (hand + part) * m.hand -
            (which == parts.length - 1 ? 0 : gap),
        m.middle + m.thick / 2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(m.thick * 0.16)),
        Paint()..color = Palette.timber,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(m.thick * 0.16)),
        Paint()
          ..color = Palette.timberDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.2, m.thick * 0.04),
      );
      _word(
        canvas,
        '$part',
        box.center,
        min(m.thick * 0.5, 30.0),
        Palette.night,
        bold: true,
      );
      hand += part;
    }

    // The marks between the hands, and the cut the pointer names.
    for (var place = 0; place < Rules.places(play.hands); place++) {
      final x = m.cutAt(place);
      final cut = play.cuts.contains(place);
      if (!cut) {
        canvas.drawLine(
          Offset(x, m.middle - m.thick * 0.36),
          Offset(x, m.middle + m.thick * 0.36),
          Paint()
            ..color = Palette.timberDark.withValues(alpha: 0.6)
            ..strokeWidth = 1.2,
        );
      }
      if (place == pointing) {
        canvas.drawLine(
          Offset(x, m.middle - m.thick * 0.7),
          Offset(x, m.middle + m.thick * 0.7),
          Paint()
            ..color = Palette.shown
            ..strokeWidth = max(2.0, m.hand * 0.1),
        );
      }
    }

    if (bare) return;

    _word(
      canvas,
      Rules.tellParts(parts),
      Offset(size.width / 2, m.middle + m.thick * 0.9),
      13,
      Palette.inkDim,
    );
    _word(
      canvas,
      Rules.tellProduct(play.product),
      Offset(size.width / 2, m.middle + m.thick * 0.9 + 30),
      26,
      play.product == play.best ? Palette.gold : Palette.ink,
    );
    if (m.roomy) {
      _word(
        canvas,
        play.product == play.best
            ? 'the most this rod will give'
            : 'the most it will give is ${Rules.tellProduct(play.best)}',
        Offset(size.width / 2, m.middle + m.thick * 0.9 + 52),
        11,
        Palette.inkDim,
      );
    }
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
  bool shouldRepaint(RodView old) =>
      old.play != play || old.pointing != pointing;
}

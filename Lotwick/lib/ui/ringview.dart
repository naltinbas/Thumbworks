import 'dart:math';

import 'package:flutter/material.dart';

import '../ring/play.dart';
import '../ring/rules.dart';
import 'palette.dart';

/// Where the payoff strip sits in a board of a given size. One column
/// for every bid a rival might make, a line across the middle for
/// earning nothing, gains above it and losses below.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    pad = bare ? size.width * 0.05 : 14.0;
    final words = bare ? 0.0 : 30.0;
    wide = (size.width - pad * 2) / (Rules.most + 1);
    final top = bare ? 0.0 : 14.0;
    final room = size.height - words - top;
    // The strip is drawn to whatever it actually reaches, so a loss of
    // one crown is still something a thumb can see.
    var up = 1, down = 0;
    for (var rival = 0; rival <= Rules.most; rival++) {
      final paid = play.paidAgainst(rival), truth = play.truthAgainst(rival);
      up = max(up, max(paid, truth));
      down = max(down, max(-paid, -truth));
    }
    this.up = up;
    this.down = down;
    // A strip that never drops still leaves a little room under the
    // line for the marks and the numbers.
    final under = max(down.toDouble(), up * 0.18);
    final all = up + under;
    zero = top + room * up / all;
    unit = room / all;
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double pad, wide, zero, unit;

  /// The most the strip climbs and the most it drops.
  late final int up, down;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 160 && size.width >= 240;

  /// The column for a rival bid.
  Rect column(int rival) =>
      Rect.fromLTWH(pad + rival * wide, 0, wide, size.height);

  /// A bar of [coins], drawn from the line across the middle.
  Rect bar(int rival, int coins) {
    final left = pad + rival * wide + wide * 0.16;
    final width = wide * 0.68;
    final high = coins * unit;
    return coins >= 0
        ? Rect.fromLTWH(left, zero - high, width, max(1.0, high))
        : Rect.fromLTWH(left, zero, width, max(1.0, -high));
  }
}

/// The strip: what the bid earns against every bid a rival might make,
/// and what the truthful bid would have earned.
class RingView extends CustomPainter {
  const RingView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the strip alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    // The rival actually bidding, lit behind everything. The mark
    // leaves it out: there is no dial there to point at.
    if (!bare) {
      canvas.drawRect(m.column(play.rival), Paint()..color = Palette.board);
    }
    for (var rival = 0; rival <= Rules.most; rival++) {
      final truth = play.truthAgainst(rival);
      final paid = play.paidAgainst(rival);
      if (truth != 0) {
        canvas.drawRect(
          m.bar(rival, truth),
          Paint()
            ..color = Palette.truth
            ..style = PaintingStyle.stroke
            ..strokeWidth = bare ? 3 : 1.6,
        );
      }
      if (paid != 0) {
        canvas.drawRect(m.bar(rival, paid),
            Paint()..color = paid > 0 ? Palette.gain : Palette.loss);
      }
    }
    canvas.drawLine(Offset(m.pad, m.zero),
        Offset(size.width - m.pad, m.zero), Paint()
          ..color = Palette.line
          ..strokeWidth = bare ? 3 : 1.6);
    if (bare) return;
    // The worth and the bid, marked along the same run of crowns.
    for (final (at, name, colour) in [
      (play.worth, 'worth', Palette.truth),
      (play.bid, 'bid', Palette.ink),
    ]) {
      final x = m.pad + at * m.wide + m.wide / 2;
      canvas.drawLine(Offset(x, m.zero - 3), Offset(x, m.zero + 3),
          Paint()..color = colour..strokeWidth = 2);
      _word(canvas, name, Offset(x, m.zero + (name == 'bid' ? 20 : 10)),
          colour, size, 9);
    }
    if (!m.roomy) return;
    for (var rival = 0; rival <= Rules.most; rival += 2) {
      _word(canvas, '$rival',
          Offset(m.pad + rival * m.wide + m.wide / 2, size.height - 20),
          Palette.inkDim, size, 9);
    }
    _word(canvas, 'what the best bid against you might be',
        Offset(size.width / 2, size.height - 8), Palette.inkDim, size, 10);
    var truthEarns = false;
    for (var rival = 0; rival <= Rules.most; rival++) {
      if (play.truthAgainst(rival) != 0) truthEarns = true;
    }
    _word(
        canvas,
        truthEarns
            ? 'the brass outline is what the truthful bid earns'
            : 'the truthful bid earns nothing against any rival here',
        Offset(size.width / 2, 8),
        Palette.inkDim,
        size,
        10);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(RingView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}

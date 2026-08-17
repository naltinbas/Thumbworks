import 'dart:math';

import 'package:flutter/material.dart';

import '../toss/play.dart';
import '../toss/rules.dart';
import 'palette.dart';

/// Where the standings sit in a board of a given size: the tosses run
/// across and the purse up and down, so the runs of the coin are paths
/// from the left edge to the right.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 26.0;
    pad = bare ? size.width * 0.06 : 20.0;
    across = (size.width - pad * 2) / Rules.tosses;
    final room = size.height - words - (bare ? 0.0 : 10.0);
    down = room / (2 * Rules.tosses + 1);
    middle = (bare ? 0.0 : 10.0) + room / 2;
    radius = min(across * 0.2, down * 0.42);
  }

  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double pad, across, down, middle, radius;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 180 && size.width >= 240;

  Offset at((int, int) standing) => Offset(
        pad + standing.$1 * across,
        middle - standing.$2 * down,
      );

  /// The standing a tap at [where] means, or null when it lands
  /// nowhere near one.
  (int, int)? nearest(Offset where) {
    (int, int)? best;
    var away = radius * 2.2;
    for (var toss = 0; toss < Rules.tosses; toss++) {
      for (var purse = -toss; purse <= toss; purse += 2) {
        final d = (at((toss, purse)) - where).distance;
        if (d < away) {
          away = d;
          best = (toss, purse);
        }
      }
    }
    return best;
  }
}

/// The lattice of standings, the marks on it, and where the runs walk
/// away.
class TossView extends CustomPainter {
  const TossView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the lattice alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);
    final ending = play.ending;
    // The tosses out of every standing the coin can still reach.
    for (var toss = 0; toss < Rules.tosses; toss++) {
      for (var purse = -toss; purse <= toss; purse += 2) {
        final from = (toss, purse);
        if (!play.alive(from) || play.marked(from)) continue;
        for (final to in [(toss + 1, purse + 1), (toss + 1, purse - 1)]) {
          canvas.drawLine(
            m.at(from),
            m.at(to),
            Paint()
              ..color = Palette.step
              ..strokeWidth = bare ? 3 : 1.6,
          );
        }
      }
    }
    for (var toss = 0; toss <= Rules.tosses; toss++) {
      for (var purse = -toss; purse <= toss; purse += 2) {
        final at = (toss, purse);
        final live = play.alive(at);
        final marked = toss < Rules.tosses && play.marked(at);
        final walks = ending[Rules.mark(at)] ?? 0;
        final where = m.at(at);
        final lit = pointing == at;
        if (!live) {
          // The mark leaves the cut-off standings out; the board keeps
          // them as small dots so the shape of the rule is visible.
          if (!bare) {
            canvas.drawCircle(
                where, m.radius * 0.35, Paint()..color = Palette.line);
          }
          continue;
        }
        canvas.drawCircle(
          where,
          m.radius,
          Paint()
            ..color = marked || walks > 0
                ? (purse > 0
                    ? Palette.up
                    : purse < 0
                        ? Palette.down
                        : Palette.level)
                : Palette.board,
        );
        canvas.drawCircle(
          where,
          m.radius,
          Paint()
            ..color = lit
                ? Palette.shown
                : marked
                    ? Palette.marked
                    : Palette.step
            ..style = PaintingStyle.stroke
            ..strokeWidth = bare ? 3 : (marked || lit ? 2.4 : 1.2),
        );
        if (bare || m.radius < 8) continue;
        if (walks > 0) {
          _word(canvas, '$walks', where, Palette.night, size,
              m.radius * 0.95);
        }
      }
    }
    if (bare || !m.roomy) return;
    for (var purse = -Rules.tosses; purse <= Rules.tosses; purse += 2) {
      _word(canvas, Rules.tellPurse(purse),
          Offset(m.pad - 14, m.middle - purse * m.down), Palette.inkDim, size,
          9);
    }
    _word(
        canvas,
        'the number in a standing is how many of the 32 runs walk away there',
        Offset(size.width / 2, size.height - 8),
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
  bool shouldRepaint(TossView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}

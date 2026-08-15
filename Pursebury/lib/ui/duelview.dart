import 'dart:math';

import 'package:flutter/material.dart';

import '../duel/play.dart';
import '../duel/rules.dart';
import 'palette.dart';

/// Where the pot and the chain sit in a board of a given size.
class Metrics {
  Metrics(this.play, this.size) {
    final top = roomy ? 26.0 : 10.0;
    coinRow = top + coinR;
    // The chain takes the rest: posts from left to right, one a purse.
    left = 24;
    right = size.width - 24;
    floor = size.height - (roomy ? 30 : 12);
    ceiling = coinRow + coinR + (roomy ? 26 : 12);
  }

  final Play play;
  final Size size;
  late final double coinRow, left, right, floor, ceiling;

  double get coinR => min(12.0, (size.width - 40) / (2 * (Rules.most * 2 + 1)));

  /// Coin [i] of the pot, Ash's first from the left.
  Offset coinAt(int i) {
    final n = play.pot;
    final span = min(size.width - 40, n * (coinR * 2 + 4));
    final x0 = size.width / 2 - span / 2 + coinR;
    return Offset(x0 + i * (span - 2 * coinR) / max(1, n - 1), coinRow);
  }

  /// The top of post [i], the chance from a purse of i.
  Offset post(int i, double chance) => Offset(left + (right - left) * i / play.pot, floor - (floor - ceiling) * chance);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The pot and the chain of chances.
class DuelView extends CustomPainter {
  const DuelView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the chain only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final chain = play.chain;
    final n = play.pot;
    if (!bare) {
      // The pot: Ash's coins in gold, Birch's in silver.
      for (var i = 0; i < n; i++) {
        final ashs = i < play.ash;
        final c = m.coinAt(i);
        canvas.drawCircle(c, m.coinR, Paint()..color = ashs ? Palette.ashDark : Palette.birchDark);
        canvas.drawCircle(c, m.coinR - 2.5, Paint()..color = ashs ? Palette.ash : Palette.birch);
      }
    }
    // The fair line, faint, when the coin is crooked.
    if (play.coin != 1) {
      canvas.drawLine(
        m.post(0, 0),
        m.post(n, 1),
        Paint()
          ..color = Palette.fairLine
          ..strokeWidth = bare ? 4 : 1.5,
      );
    }
    // The floor, the posts and the chain.
    canvas.drawLine(m.post(0, 0), m.post(n, 0), Paint()..color = Palette.post..strokeWidth = bare ? 4 : 1.5);
    for (var i = 0; i <= n; i++) {
      final top = m.post(i, chain[i].toDouble);
      canvas.drawLine(m.post(i, 0), top, Paint()..color = Palette.post..strokeWidth = bare ? 3 : 1);
    }
    final path = Path();
    for (var i = 0; i <= n; i++) {
      final p = m.post(i, chain[i].toDouble);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.chain
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 6 : 2.5
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i <= n; i++) {
      canvas.drawCircle(m.post(i, chain[i].toDouble), bare ? 7 : 3.5, Paint()..color = Palette.chain);
    }
    // Where Ash stands.
    final here = m.post(play.ash, chain[play.ash].toDouble);
    canvas.drawCircle(here, bare ? 12 : 7, Paint()..color = Palette.here);
    canvas.drawCircle(here, bare ? 5 : 3, Paint()..color = Palette.ink);
    if (bare || !m.roomy) return;
    // The words: the purses over the pot, the chance by the mark, the
    // ends of the chain, and the coin.
    _word(canvas, 'Ash ${play.ash}', m.coinAt(0) + Offset(0, -m.coinR - 10), Palette.ash, size, left: true);
    _word(canvas, 'Birch ${play.birch}', m.coinAt(n - 1) + Offset(0, -m.coinR - 10), Palette.birch, size, right: true);
    _word(canvas, 'chance ${play.chance}', here + const Offset(0, -18), Palette.here, size);
    _word(canvas, 'empty', m.post(0, 0) + const Offset(0, 12), Palette.inkDim, size, left: true);
    _word(canvas, 'the pot', m.post(n, 0) + const Offset(0, 12), Palette.inkDim, size, right: true);
    _word(canvas, 'the coin ${Rules.coinNames[play.coin]}, ${Rules.coins[play.coin]} a toss', Offset(size.width / 2, size.height - 12), Palette.inkDim, size);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, {bool left = false, bool right = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final ax = left ? at.dx : right ? at.dx - text.width : at.dx - text.width / 2;
    final x = ax.clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(DuelView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../coffer/frac.dart';
import '../coffer/play.dart';
import '../coffer/rules.dart';
import 'palette.dart';

/// Where the coffers and their coins sit in a board of a given size, and
/// the row of draws and the chance bar under them.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final w = size.width;
    if (bare) {
      // The mark stacks the three coffers, to fill a square.
      cofferWidth = w * 0.72;
      cofferHeight = size.height * 0.24;
      gap = size.height * 0.05;
      coin = min(cofferWidth * 0.14, cofferHeight * 0.36);
      top = (size.height - 3 * cofferHeight - 2 * gap) / 2;
    } else {
      cofferWidth = min(118.0, (w - 32) / 3);
      gap = min(12.0, (w - 3 * cofferWidth) / 4);
      cofferHeight = min(96.0, size.height * 0.36);
      coin = min(cofferWidth * 0.19, cofferHeight * 0.3);
      top = min(18.0, size.height * 0.06);
    }
  }

  final Play play;
  final Size size;
  final bool bare;
  late final double cofferWidth, gap, cofferHeight, coin, top;

  double get left => bare ? (size.width - cofferWidth) / 2 : (size.width - 3 * cofferWidth - 2 * gap) / 2;

  /// The rectangle of coffer [c]: in a row, or stacked for the mark.
  Rect cofferRect(int c) => bare
      ? Rect.fromLTWH(left, top + c * (cofferHeight + gap), cofferWidth, cofferHeight)
      : Rect.fromLTWH(left + c * (cofferWidth + gap), top, cofferWidth, cofferHeight);

  /// The centre of coin [i], coffer i ~/ 2, left or right.
  Offset coinAt(int i) {
    final r = cofferRect(i ~/ 2);
    return Offset(r.left + r.width * (i.isEven ? 0.28 : 0.72), r.top + r.height * 0.6);
  }

  /// The row of the six draws.
  double get drawsTop => top + cofferHeight + 34;

  /// The chance bar.
  Rect get bar => Rect.fromLTWH(left, drawsTop + 46, 3 * cofferWidth + 2 * gap, 14);

  /// The coin under a point, or null.
  int? under(Offset p) {
    for (var i = 0; i < Rules.slots; i++) {
      if ((coinAt(i) - p).distance <= coin * 0.75) return i;
    }
    for (var c = 0; c < 3; c++) {
      if (cofferRect(c).contains(p)) return p.dx < cofferRect(c).center.dx ? 2 * c : 2 * c + 1;
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The three coffers, the coins, the draws and the chance.
class CofferView extends CustomPainter {
  const CofferView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The coin the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the coffers and coins only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    for (var c = 0; c < 3; c++) {
      final r = m.cofferRect(c);
      final rr = RRect.fromRectAndRadius(r, Radius.circular(bare ? 10 : 8));
      canvas.drawRRect(rr, Paint()..color = Palette.oak);
      canvas.drawRRect(rr, Paint()..color = Palette.oakRim..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
      // The lid line.
      canvas.drawLine(Offset(r.left, r.top + r.height * 0.24), Offset(r.right, r.top + r.height * 0.24), Paint()..color = Palette.oakRim..strokeWidth = bare ? 2 : 1);
      if (!bare) _word(canvas, Rules.cofferNames[c], Offset(r.center.dx, r.top + r.height * 0.12), Palette.inkDim, size, 10);
    }
    for (var i = 0; i < Rules.slots; i++) {
      _coin(canvas, m.coinAt(i), m.coin, play.coins[i], bare);
      if (pointing == i && !bare) {
        canvas.drawCircle(m.coinAt(i), m.coin * 0.75, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
      }
    }
    if (bare) return;
    // The six draws, coffer then coin, each as the coin drawn with its
    // mate small beside it; the gold draws stand out.
    final w = (size.width - 24) / Rules.slots;
    for (var i = 0; i < Rules.slots; i++) {
      final gold = play.coins[i], mate = play.coins[i.isEven ? i + 1 : i - 1];
      final x = 12 + w * (i + 0.5);
      final y = m.drawsTop + 12;
      _coin(canvas, Offset(x - 5, y), gold ? 8 : 6, gold, false, dim: !gold);
      _coin(canvas, Offset(x + 8, y + 5), 4.5, mate, false, dim: !gold);
      if (gold && mate) {
        canvas.drawCircle(Offset(x - 5, y), 11, Paint()..color = Palette.chance..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }
    if (!m.roomy) return;
    // The chance bar: gold draws with a gold mate over gold draws.
    final p = play.chance;
    final bar = m.bar;
    canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(7)), Paint()..color = Palette.bar);
    if (p != null) {
      final filled = Rect.fromLTWH(bar.left, bar.top, bar.width * p.toDouble, bar.height);
      canvas.drawRRect(RRect.fromRectAndRadius(filled, const Radius.circular(7)), Paint()..color = Palette.chance);
    }
    final golds = play.golds;
    final mates = p == null ? 0 : (p * Frac.of(golds)).n.toInt();
    _word(
      canvas,
      p == null ? 'no gold coin to draw' : 'gold mate on $mates of the $golds gold draws: chance ${Rules.tellChance(p)}',
      Offset(size.width / 2, bar.bottom + 14),
      Palette.inkDim,
      size,
      12,
    );
    _word(canvas, 'the six draws', Offset(size.width / 2, m.drawsTop - 10), Palette.inkDim, size, 10);
  }

  void _coin(Canvas canvas, Offset at, double r, bool gold, bool bare, {bool dim = false}) {
    final fill = dim ? Palette.dim : gold ? Palette.gold : Palette.silver;
    final rim = dim ? Palette.line : gold ? Palette.goldRim : Palette.silverRim;
    canvas.drawCircle(at, r, Paint()..color = fill);
    canvas.drawCircle(at, r, Paint()..color = rim..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
    if (r > 6) canvas.drawCircle(at, r * 0.55, Paint()..color = rim..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(CofferView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

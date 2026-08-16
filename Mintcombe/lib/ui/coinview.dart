import 'dart:math';

import 'package:flutter/material.dart';

import '../coin/play.dart';
import '../coin/rules.dart';
import 'palette.dart';

/// Where the rack and the counter sit in a board of a given size: the
/// rack of ten coins along the top, the counter below it where the
/// coins laid stand in rows of five, in the order laid.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    if (bare) {
      // The mark lays its coins in two rows, the dearer above, each
      // coin as big as the fourth root of its worth, and fits the lot
      // to the square.
      final coins = play.picked;
      final units = coins.map((c) => pow(c.toDouble(), 0.25).toDouble()).toList();
      final split = coins.length ~/ 2;
      final rows = [units.sublist(0, split), units.sublist(split)];
      double across(List<double> row) => row.fold(0.0, (a, u) => a + 2 * u) + max(0, row.length - 1) * 0.35;
      double tall(List<double> row) => row.isEmpty ? 0 : 2 * row.reduce(max);
      final wide = rows.map(across).reduce(max);
      final high = tall(rows[0]) + (rows[1].isEmpty ? 0 : 0.35 + tall(rows[1]));
      final scale = min(size.width, size.height) * 0.94 / max(wide, high);
      final top = (size.height - high * scale) / 2;
      laidAt = [];
      laidRadius = [];
      var y = top;
      for (final row in rows) {
        if (row.isEmpty) continue;
        final middle = y + tall(row) * scale / 2;
        var x = (size.width - across(row) * scale) / 2;
        for (final u in row) {
          laidAt.add(Offset(x + u * scale, middle));
          laidRadius.add(u * scale);
          x += (2 * u + 0.35) * scale;
        }
        y += (tall(row) + 0.35) * scale;
      }
      cell = 0;
      rackRadius = 0;
      rackY = 0;
      counterTop = 0;
      counterBottom = size.height;
      return;
    }
    cell = size.width / Rules.count;
    rackRadius = min(cell * 0.42, 20.0);
    rackY = 10 + rackRadius;
    final strip = roomy ? 26.0 : 0.0;
    counterTop = rackY + rackRadius + 22;
    counterBottom = size.height - strip - 6;
    final rows = max(1, (play.picked.length + 4) ~/ 5);
    final r = min(min((size.width - 24) / 12.0, 36.0), (counterBottom - counterTop - 16) / (rows * 2.3));
    final block = rows * 2.3 * r - 0.3 * r;
    final top = counterTop + (counterBottom - counterTop - block) / 2;
    laidAt = [];
    laidRadius = [];
    for (var i = 0; i < play.picked.length; i++) {
      final row = i ~/ 5, col = i % 5;
      final inRow = min(5, play.picked.length - row * 5);
      final left = (size.width - inRow * 2.4 * r) / 2 + 1.2 * r;
      laidAt.add(Offset(left + col * 2.4 * r, top + r + row * 2.3 * r));
      laidRadius.add(r);
    }
  }

  final Play play;
  final Size size;

  /// A rack coin's room across, and its size and height.
  late final double cell, rackRadius, rackY;

  /// Where the counter runs, top to bottom.
  late final double counterTop, counterBottom;

  /// Where each laid coin stands, in the order laid, and how big.
  late final List<Offset> laidAt;
  late final List<double> laidRadius;

  /// The middle of coin [coin] on the rack.
  Offset rackAt(int coin) => Offset(cell * (Rules.placeOf(coin) + 0.5), rackY);

  /// The middle of coin [coin] on the counter, or null when it is not laid.
  Offset? counterAt(int coin) {
    final i = play.picked.indexOf(coin);
    return i < 0 ? null : laidAt[i];
  }

  /// What is under a point: ('rack', coin), ('counter', coin), or null.
  (String, int)? under(Offset p) {
    if ((p.dy - rackY).abs() <= rackRadius + 8) {
      final i = (p.dx / cell).floor();
      if (i >= 0 && i < Rules.count) return ('rack', Rules.coins[i]);
      return null;
    }
    for (var i = 0; i < play.picked.length; i++) {
      if ((laidAt[i] - p).distance <= laidRadius[i] + 4) return ('counter', play.picked[i]);
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The rack, the counter and the coins.
class CoinView extends CustomPainter {
  const CoinView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (coin, lift).
  final (int, bool)? pointing;

  final TextStyle labels;

  /// Whether to draw the coins laid only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    if (bare) {
      for (var i = 0; i < play.picked.length; i++) {
        _coin(canvas, m.laidAt[i], m.laidRadius[i], play.picked[i], size);
      }
      return;
    }
    // The rack.
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(4, 4, size.width - 8, m.rackRadius * 2 + 12), const Radius.circular(8)), Paint()..color = Palette.rack);
    for (final coin in Rules.coins) {
      final at = m.rackAt(coin);
      if (coin == play.level.barred) {
        canvas.drawCircle(at, m.rackRadius, Paint()..color = Palette.barred);
        _word(canvas, '$coin', at, Palette.inkDim, size, m.rackRadius * 0.75);
        final d = m.rackRadius * 0.7;
        canvas.drawLine(at + Offset(-d, -d), at + Offset(d, d), Paint()..color = Palette.bad..strokeWidth = 2);
      } else if (play.picked.contains(coin)) {
        canvas.drawCircle(at, m.rackRadius - 1, Paint()..color = Palette.goldDim..style = PaintingStyle.stroke..strokeWidth = 1.5);
      } else {
        _coin(canvas, at, m.rackRadius, coin, size, dim: !play.fits(coin));
      }
    }
    // The counter and the coins laid, neighbours ringed.
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTRB(4, m.counterTop, size.width - 4, m.counterBottom), const Radius.circular(8)), Paint()..color = Palette.counter);
    final pairs = play.pairs;
    final ringed = {for (final p in pairs) p.$1, for (final p in pairs) p.$2};
    for (var i = 0; i < play.picked.length; i++) {
      final coin = play.picked[i];
      _coin(canvas, m.laidAt[i], m.laidRadius[i], coin, size);
      if (ringed.contains(coin)) {
        canvas.drawCircle(m.laidAt[i], m.laidRadius[i] + 4, Paint()..color = Palette.bad..style = PaintingStyle.stroke..strokeWidth = 2.5);
      }
    }
    for (final (a, b) in pairs) {
      final p = m.counterAt(a)!, q = m.counterAt(b)!;
      final d = (q - p) / (q - p).distance;
      final ra = m.laidRadius[play.picked.indexOf(a)] + 4, rb = m.laidRadius[play.picked.indexOf(b)] + 4;
      canvas.drawLine(p + d * ra, q - d * rb, Paint()..color = Palette.bad..strokeWidth = 2);
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final at = aim.$2 ? m.counterAt(aim.$1) : m.rackAt(aim.$1);
      if (at != null) {
        final r = aim.$2 ? m.laidRadius[play.picked.indexOf(aim.$1)] : m.rackRadius;
        canvas.drawCircle(at, r + 7, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
      }
    }
    if (!m.roomy) return;
    final String words;
    if (play.picked.isEmpty) {
      words = 'nothing laid: ${play.level.price} to pay';
    } else {
      words = '${play.picked.join(' + ')} = ${play.sum}${play.left > 0 ? ', ${play.left} to go' : ''}';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), play.sum == play.level.price ? Palette.gold : Palette.inkDim, size, 12);
  }

  void _coin(Canvas canvas, Offset at, double r, int coin, Size size, {bool dim = false}) {
    canvas.drawCircle(at, r, Paint()..color = dim ? Palette.goldDim : Palette.gold);
    canvas.drawCircle(at, r * 0.82, Paint()..color = dim ? Palette.rack : Palette.goldRim..style = PaintingStyle.stroke..strokeWidth = max(1, r * 0.06));
    _word(canvas, '$coin', at, dim ? Palette.inkDim : Palette.face, size, r * (coin >= 10 ? 0.78 : 0.95), bold: true);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool bold = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize), fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(CoinView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

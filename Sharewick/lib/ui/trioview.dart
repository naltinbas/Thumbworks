import 'dart:math';

import 'package:flutter/material.dart';

import '../trio/play.dart';
import '../trio/rules.dart';
import 'palette.dart';

/// Where the twenty trios sit in a board of a given size: five across
/// and four down, in name order, the friends' hands in a row above.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    handsTop = bare ? 0 : 4;
    final gridTop = bare ? 0.0 : handsTop + 24;
    cell = min((size.width - 12) / columns, (size.height - strip - gridTop - 6) / rows);
    if (bare) cell = min(size.width / columns, size.height / rows);
    left = (size.width - columns * cell) / 2;
    top = bare ? (size.height - rows * cell) / 2 : gridTop;
  }

  static const columns = 5, rows = 4;

  final Play play;
  final Size size;
  late double cell;
  late final double left, top, handsTop;

  /// The tile of the trio at [place] in name order.
  Rect tileAt(int place) => Rect.fromLTWH(left + (place % columns) * cell, top + (place ~/ columns) * cell, cell, cell).deflate(cell * 0.06);

  /// The middle of a trio's tile.
  Offset at(int trio) => tileAt(Rules.placeOf(trio)).center;

  /// The trio under a point, or null.
  int? under(Offset p) {
    for (var i = 0; i < Rules.count; i++) {
      if (tileAt(i).inflate(cell * 0.06).contains(p)) return Rules.trios[i];
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The twenty trios as tiles, the picked in gold, pairs apart ringed.
class TrioView extends CustomPainter {
  const TrioView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (trio, unpick).
  final (int, bool)? pointing;

  final TextStyle labels;

  /// Whether to draw the tiles only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final apart = play.apart;
    final ringed = {for (final p in apart) p.$1, for (final p in apart) p.$2};
    for (var i = 0; i < Rules.count; i++) {
      final trio = Rules.trios[i];
      final r = m.tileAt(i);
      final rr = RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.16));
      final picked = Rules.picked(play.family, trio);
      canvas.drawRRect(rr, Paint()..color = picked ? Palette.gold : Palette.tile);
      canvas.drawRRect(rr, Paint()..color = picked ? Palette.goldRim : Palette.tileRim..style = PaintingStyle.stroke..strokeWidth = max(1, r.width * 0.04));
      _word(canvas, Rules.nameOf(trio), r.center, picked ? Palette.night : Palette.inkDim, size, r.width * (bare ? 0.3 : 0.28), bold: true);
      if (!bare && ringed.contains(trio)) {
        canvas.drawRRect(rr.inflate(2.5), Paint()..color = Palette.bad..style = PaintingStyle.stroke..strokeWidth = 2.5);
      } else if (!bare && !picked && Rules.picked(play.family, Rules.otherThree(trio))) {
        // Its other three is picked: this one would be a pair apart.
        canvas.drawCircle(r.topRight + Offset(-r.width * 0.14, r.width * 0.14), r.width * 0.06, Paint()..color = Palette.bad);
      }
    }
    final aim = pointing;
    if (aim != null && !bare) {
      final r = m.tileAt(Rules.placeOf(aim.$1));
      canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(5), Radius.circular(r.width * 0.2)), Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
    }
    if (bare) return;
    // The hands: how many picked trios hold each friend.
    final hands = play.hands;
    for (var f = 0; f < Rules.friends; f++) {
      final x = m.left + (f + 0.5) * m.cell * Metrics.columns / Rules.friends;
      _word(canvas, '${Rules.names[f]} ${hands[f]}', Offset(x, m.handsTop + 9), hands[f] == 0 ? Palette.inkDim : Palette.chalk, size, 12);
    }
    if (!m.roomy) return;
    final String words;
    if (play.size == 0) {
      words = 'no trios picked';
    } else if (apart.isEmpty) {
      words = 'trios ${play.size}: every two share a friend';
    } else {
      final told = apart.take(2).map((p) => '${Rules.nameOf(p.$1)} and ${Rules.nameOf(p.$2)}').join(', ');
      words = 'trios ${play.size}, ${apart.length} pair${apart.length == 1 ? '' : 's'} apart: $told${apart.length > 2 ? ' and more' : ''}';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), apart.isEmpty && play.size > 0 ? Palette.gold : Palette.inkDim, size, 12);
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
  bool shouldRepaint(TrioView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

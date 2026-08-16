import 'dart:math';

import 'package:flutter/material.dart';

import '../feint/play.dart';
import '../feint/rules.dart';
import 'palette.dart';

/// Where the bench, the squares and the stamp sit in a board of a given
/// size.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    final high = size.height - strip;
    ladder = Rules.squares(play.base, play.number).length;
    across = min(6, ladder);
    rows = (ladder + across - 1) ~/ across;
    if (bare) {
      final room = min(size.width, high);
      left = (size.width - room) / 2 + room * 0.04;
      width = room * 0.92;
      headY = (high - room) / 2 + room * 0.18;
      squaresY = headY + room * 0.22;
      cell = min(width / across, 90.0);
      landingY = squaresY + rows * cell * 0.9 + room * 0.08;
      return;
    }
    left = 14;
    width = size.width - 28;
    headY = 26;
    squaresY = headY + 52;
    // The ladder takes what is left above the landing lines, and its
    // tiles shrink rather than run over them.
    final room = max(40.0, high - squaresY - 92);
    cell = min(min(width / across, 52.0), room / (rows * 0.78));
    landingY = squaresY + rows * cell * 0.78 + 50;
  }

  final Play play;
  final Size size;
  final bool bare;

  /// How many squares the ladder holds, how many go across, and how
  /// many rows they make.
  late final int ladder, across, rows;

  late final double left, width, headY, squaresY, landingY, cell;

  /// The tile of the [i]th square of the ladder.
  Rect squareAt(int i) {
    final row = i ~/ across, col = i % across;
    final inRow = min(across, ladder - row * across);
    final x = left + (width - inRow * cell) / 2 + col * cell;
    return Rect.fromLTWH(x, squaresY + row * cell * (bare ? 0.9 : 0.78), cell, cell * (bare ? 0.86 : 0.72)).deflate(cell * 0.06);
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The bench: the number, its factors, the squares of the base with the
/// ones the power takes lit, the landing and the stamp.
class FeintView extends CustomPainter {
  const FeintView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: ('n' or 'a', by).
  final (String, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the number and its squares only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final squares = Rules.squares(play.base, play.number);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // The head: the number, the base, and what the number is made of.
    final passes = play.passes;
    if (bare) {
      _word(canvas, '${play.number}', Offset(size.width / 2, m.headY), Palette.chalk, size, m.width * 0.22, bold: true);
      _word(canvas, 'base ${play.base}', Offset(size.width / 2, m.headY + m.width * 0.15), Palette.copper, size, m.width * 0.08);
    } else {
      _word(canvas, '${play.number} on base ${play.base}', Offset(size.width / 2, m.headY - 6), Palette.chalk, size, 20, bold: true);
      final made = play.prime ? 'prime' : 'composite, ${play.factor} times ${play.number ~/ play.factor!}';
      _word(canvas, made, Offset(size.width / 2, m.headY + 16), play.prime ? Palette.good : Palette.inkDim, size, 12);
    }
    // The squares of the base, the ones the power takes lit.
    for (var i = 0; i < squares.length; i++) {
      final (k, value, used) = squares[i];
      final r = m.squareAt(i);
      final rr = RRect.fromRectAndRadius(r, Radius.circular(r.width * 0.16));
      canvas.drawRRect(rr, Paint()..color = used ? Palette.gold : Palette.bench);
      canvas.drawRRect(rr, Paint()..color = used ? Palette.gold : Palette.benchRim..style = PaintingStyle.stroke..strokeWidth = max(1, r.width * 0.04));
      _word(canvas, '$value', r.center + Offset(0, r.height * 0.06), used ? Palette.face : Palette.inkDim, size, min(r.width * 0.34, bare ? 40 : 15), bold: true);
      if (!bare) _word(canvas, k == 0 ? 'base' : 'squared $k', Offset(r.center.dx, r.top + r.height * 0.2), used ? Palette.face : Palette.inkDim, size, min(r.width * 0.16, 9));
    }
    canvas.restore();
    if (bare) {
      _word(canvas, 'lands on ${play.landing}', Offset(size.width / 2, m.landingY), passes ? Palette.good : Palette.bad, size, m.width * 0.09, bold: true);
      return;
    }
    // The landing and the stamp.
    final used = squares.where((s) => s.$3).map((s) => '${s.$2}').join(' x ');
    _word(canvas, 'the lit ones multiplied: $used', Offset(size.width / 2, m.landingY - 34), Palette.inkDim, size, 11);
    _word(canvas, 'lands on ${play.landing}', Offset(size.width / 2, m.landingY - 14), passes ? Palette.good : Palette.inkDim, size, 14, bold: true);
    final stamp = Offset(size.width / 2, m.landingY + 8);
    final honest = passes && play.prime;
    final stampColour = honest ? Palette.good : Palette.bad;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: stamp, width: 108, height: 22), const Radius.circular(4)), Paint()..color = stampColour..style = PaintingStyle.stroke..strokeWidth = 2);
    _word(canvas, passes ? (play.prime ? 'PASSES' : 'PASSES, A LIAR') : 'FAILS', stamp, stampColour, size, 11, bold: true);
    if (!m.roomy) return;
    final words = play.prime
        ? 'a prime: it passes on every base it does not divide'
        : play.passes
            ? 'a composite that passes: a liar for this base'
            : 'a composite caught out on this base';
    _word(canvas, words, Offset(size.width / 2, size.height - 11), play.liar ? Palette.bad : Palette.inkDim, size, 12);
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
  bool shouldRepaint(FeintView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

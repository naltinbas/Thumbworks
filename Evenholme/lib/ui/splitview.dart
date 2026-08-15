import 'dart:math';

import 'package:flutter/material.dart';

import '../split/play.dart';
import '../split/rules.dart';
import 'palette.dart';

/// Where the numbers sit in a board of a given size: rows of ten.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 22.0 : 0.0;
    final n = play.level.number;
    columns = n <= 30 ? 10 : 10;
    rows = (n + columns - 1) ~/ columns;
    cell = min((size.width - 16) / columns, (size.height - strip - 16) / rows);
    origin = Offset(size.width / 2 - columns * cell / 2, (size.height - strip) / 2 - rows * cell / 2);
  }

  final Play play;
  final Size size;
  late final int columns, rows;
  late final double cell;
  late final Offset origin;

  /// The rectangle of number [k], 1 to the number.
  Rect rect(int k) {
    final i = k - 1;
    return Rect.fromLTWH(origin.dx + (i % columns) * cell, origin.dy + (i ~/ columns) * cell, cell, cell);
  }

  /// The number under a point, or null.
  int? under(Offset p) {
    final c = ((p.dx - origin.dx) / cell).floor(), r = ((p.dy - origin.dy) / cell).floor();
    if (c < 0 || c >= columns || r < 0 || r >= rows) return null;
    final k = r * columns + c + 1;
    return k <= play.level.number ? k : null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The numbers, the primes marked, the pick and its partner.
class SplitView extends CustomPainter {
  const SplitView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The number the show-me rings, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the slate only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.level.number;
    for (var k = 1; k <= n; k++) {
      final r = m.rect(k).deflate(bare ? 3 : 1.5);
      final prime = Rules.isPrime(k);
      final isPick = k == play.picked, isPartner = k == play.partner;
      final face = isPick ? Palette.pick : isPartner ? (prime ? Palette.partner : Palette.wrong) : prime ? Palette.prime : Palette.cell;
      final rr = RRect.fromRectAndRadius(r, Radius.circular(m.cell * 0.12));
      canvas.drawRRect(rr, Paint()..color = face);
      canvas.drawRRect(
        rr,
        Paint()
          ..color = isPick || isPartner ? Palette.chalk : prime ? Palette.primeRim : Palette.cellRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = isPick || isPartner ? 2 : 1,
      );
      if (!bare || m.cell >= 14) {
        _word(canvas, '$k', r.center, isPick || isPartner ? Palette.night : prime ? Palette.chalk : Palette.inkDim, size, max(9.0, min(14.0, m.cell * 0.4)));
      }
    }
    if (bare) return;
    final aim = pointing;
    if (aim != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(m.rect(aim).deflate(0.5), Radius.circular(m.cell * 0.14)),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (!m.roomy) return;
    final p = play.picked;
    final told = p == null
        ? 'primes marked; tap one, and its partner to $n lights'
        : '$p + ${play.partner}: ${play.pickedPrime ? '$p prime' : '$p not prime'}, ${play.partnerPrime ? '${play.partner} prime' : '${play.partner} not prime'}';
    _word(canvas, told, Offset(size.width / 2, size.height - 11), Palette.inkDim, size, 11);
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
  bool shouldRepaint(SplitView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

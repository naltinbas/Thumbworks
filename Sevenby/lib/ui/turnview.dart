import 'dart:math';

import 'package:flutter/material.dart';

import '../turn/play.dart';
import 'palette.dart';

/// Where the decimal and the ring of remainders sit in a board of a
/// given size.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final n = play.digits.length;
    final columns = bare ? n : min(n, 16);
    digitCell = bare ? min(size.width / (n + 3), size.height * 0.3) : min(22.0, (size.width - 40) / (columns + 2));
    digitRows = (n + columns - 1) ~/ columns;
    this.columns = columns;
    decimalTop = bare ? size.height * 0.16 : 8;
    final ringTop = decimalTop + digitRows * digitCell + (bare ? size.height * 0.08 : 24);
    final strip = bare ? 0.0 : (roomy ? 30.0 : 0.0);
    radius = max(10.0, min((size.height - strip - ringTop) / 2 - (bare ? 8 : 20), size.width / 2 - (bare ? 12 : 26)));
    centre = Offset(size.width / 2, ringTop + radius + (bare ? 8 : 20));
  }

  final Play play;
  final Size size;
  late final double digitCell, decimalTop, radius;
  late final int digitRows, columns;
  late final Offset centre;

  /// The left of the decimal's first row: '0.' then the digits.
  double get decimalLeft => (size.width - (columns + 2) * digitCell) / 2;

  Offset hourAt(int h) {
    final a = 2 * pi * (h % play.prime) / play.prime;
    return centre + Offset(sin(a), -cos(a)) * radius;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The decimal with its repeating block barred, and the ring of the
/// remainders under it, walked by tens.
class TurnView extends CustomPainter {
  const TurnView({
    required this.play,
    required this.labels,
    this.bare = false,
  });

  final Play play;
  final TextStyle labels;

  /// Whether to draw the decimal and the ring only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final digits = play.digits, remainders = play.remainders;
    // The decimal: '0.' then the block, a bar over it.
    final fs = m.digitCell * 0.75;
    _word(canvas, '0.', Offset(m.decimalLeft + m.digitCell, m.decimalTop + m.digitCell / 2), Palette.ink, size, fs);
    for (var i = 0; i < digits.length; i++) {
      final col = i % m.columns, row = i ~/ m.columns;
      final x = m.decimalLeft + (col + 2.5) * m.digitCell, y = m.decimalTop + (row + 0.5) * m.digitCell;
      _word(canvas, '${digits[i]}', Offset(x, y), Palette.digit, size, fs);
    }
    // The bar over every row of the block.
    for (var row = 0; row < m.digitRows; row++) {
      final inRow = min(m.columns, digits.length - row * m.columns);
      final x0 = m.decimalLeft + 2 * m.digitCell + 2, x1 = m.decimalLeft + (2 + inRow) * m.digitCell - 2;
      final y = m.decimalTop + row * m.digitCell + 2;
      canvas.drawLine(Offset(x0, y), Offset(x1, y), Paint()..color = Palette.bar..strokeWidth = bare ? 3 : 1.5);
    }
    // The ring of hours and the remainders' walk.
    final p = play.prime;
    canvas.drawCircle(m.centre, m.radius, Paint()..color = Palette.face..style = PaintingStyle.stroke..strokeWidth = bare ? 3 : 1.5);
    final visited = remainders.toSet();
    for (var i = 0; i < remainders.length; i++) {
      final from = m.hourAt(remainders[i]), to = m.hourAt(remainders[(i + 1) % remainders.length]);
      canvas.drawLine(from, to, Paint()..color = Palette.walk..strokeWidth = bare ? 3 : 1.8..strokeCap = StrokeCap.round);
    }
    final showLabels = !bare && p <= 31 && m.radius >= 40;
    for (var h = 0; h < p; h++) {
      final at = m.hourAt(h);
      final lit = visited.contains(h);
      canvas.drawCircle(at, bare ? 6 : (p > 31 ? 3 : 4.5), Paint()..color = lit ? Palette.walk : Palette.hourDim);
      if (h == remainders.first) canvas.drawCircle(at, bare ? 10 : 8, Paint()..color = Palette.start..style = PaintingStyle.stroke..strokeWidth = 2);
      if (showLabels) {
        final out = (at - m.centre) / (at - m.centre).distance;
        _word(canvas, '$h', at + out * 13, lit ? Palette.ink : Palette.inkDim, size, 10);
      }
    }
    if (bare || !m.roomy) return;
    _word(
      canvas,
      'period ${play.period}: 10 comes back to 1 in ${play.periodByClock} step${play.periodByClock == 1 ? '' : 's'} on the $p-hour clock',
      Offset(size.width / 2, size.height - 12),
      Palette.inkDim,
      size,
      12,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize))),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(TurnView old) => old.play != play || old.bare != bare;
}

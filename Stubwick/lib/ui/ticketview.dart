import 'dart:math';

import 'package:flutter/material.dart';

import '../ticket/play.dart';
import '../ticket/rules.dart';
import 'palette.dart';

/// Where the stub and its digits sit in a board of a given size.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    if (bare) {
      final room = min(size.width, size.height);
      stub = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: room * 0.96, height: room * 0.66);
      cell = stub.width / (Rules.places + 0.6);
      digitY = stub.center.dy;
      return;
    }
    final strip = roomy ? 26.0 : 0.0;
    cell = min(48.0, (size.width - 24) / Rules.places);
    final high = min(size.height - strip - 12, 160.0);
    stub = Rect.fromCenter(center: Offset(size.width / 2, 6 + high / 2), width: cell * Rules.places + 24, height: high);
    digitY = stub.top + high * 0.34;
  }

  final Play play;
  final Size size;
  late final Rect stub;

  /// A digit's room across, and the height the digits sit at.
  late final double cell, digitY;

  /// The middle of the digit at [place].
  Offset digitAt(int place) => Offset(stub.center.dx + (place - (Rules.places - 1) / 2) * cell, digitY);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The stub, its digits, what each adds, the sum and the stamp.
class TicketView extends CustomPainter {
  const TicketView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (place, by).
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the stub and the digits only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final r = m.stub;
    final rr = RRect.fromRectAndRadius(r, Radius.circular(r.height * 0.1));
    canvas.drawRRect(rr, Paint()..color = Palette.stub);
    canvas.drawRRect(rr, Paint()..color = Palette.stubRim..style = PaintingStyle.stroke..strokeWidth = max(1, r.height * 0.015));
    // The perforated edge, dots down the left.
    final dots = bare ? 7 : 5;
    for (var i = 0; i < dots; i++) {
      canvas.drawCircle(Offset(r.left + r.height * 0.07, r.top + r.height * (i + 0.5) / dots), r.height * 0.02, Paint()..color = Palette.night);
    }
    final adds = play.adds;
    final size0 = bare ? m.cell * 1.05 : m.cell * 0.62;
    for (var i = 0; i < Rules.places; i++) {
      final at = m.digitAt(i) + Offset(bare ? m.cell * 0.2 : 0, 0);
      final doubled = Rules.isDoubled(i);
      _word(canvas, '${play.digits[i]}', at, doubled ? Palette.copper : Palette.chalk, size, size0, bold: true);
      if (bare) continue;
      // What it adds, and the doubling mark.
      _word(canvas, doubled ? '×2: ${adds[i]}' : '${adds[i]}', at + Offset(0, r.height * 0.3), doubled ? Palette.copper : Palette.inkDim, size, 11);
      if (pointing != null && pointing!.$1 == i) {
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: at, width: m.cell * 0.9, height: r.height * 0.5), const Radius.circular(6)), Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
      }
    }
    if (bare) {
      _word(canvas, 'passes', Offset(r.center.dx + m.cell * 0.2, r.bottom - r.height * 0.16), Palette.good, size, r.height * 0.17, bold: true);
      return;
    }
    // The sum and the stamp.
    final passes = play.passes;
    _word(canvas, '${adds.join(' + ')} = ${play.sum}', Offset(r.center.dx, r.bottom - r.height * 0.14), Palette.ink, size, 12);
    final stamp = Offset(r.right - r.width * 0.16, r.top + r.height * 0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: stamp, width: 60, height: 22), const Radius.circular(4)), Paint()..color = passes ? Palette.good : Palette.bad..style = PaintingStyle.stroke..strokeWidth = 2);
    _word(canvas, passes ? 'PASSES' : 'FAILS', stamp, passes ? Palette.good : Palette.bad, size, 11, bold: true);
    // The table of doubles beneath, the second voice: each digit over
    // what it doubles to.
    if (size.height - r.bottom > 90) {
      final top = r.bottom + 14;
      _word(canvas, 'a digit doubled, nine off past nine', Offset(size.width / 2, top + 6), Palette.inkDim, size, 11);
      final w = min(30.0, (size.width - 24) / 10);
      final left = (size.width - 10 * w) / 2;
      for (var d = 0; d < 10; d++) {
        final x = left + (d + 0.5) * w;
        _word(canvas, '$d', Offset(x, top + 28), Palette.chalk, size, 12);
        _word(canvas, '${Rules.doubles[d]}', Offset(x, top + 46), Palette.copper, size, 12, bold: true);
      }
    }
    if (!m.roomy) return;
    final String words;
    if (play.slipped) {
      final was = play.before!;
      words = 'one digit turned: ${Rules.tell(was.digits)} passed, sum ${was.sum}, and this ${passes ? 'passes' : 'fails'}, sum ${play.sum}';
    } else if (passes) {
      final extras = <String>[];
      if (play.swapPlaces.isNotEmpty) extras.add('a 0 by a 9, swapped it passes still');
      if (play.twinPlaces.isNotEmpty) extras.add('a slipping twin in it');
      words = 'sum ${play.sum} ends in nought: passes${extras.isEmpty ? '' : ', ${extras.join(', ')}'}';
    } else {
      words = 'sum ${play.sum} ends in ${play.sum % 10}: fails, ${(10 - play.sum % 10) % 10} short of a ten';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), passes ? Palette.gold : Palette.inkDim, size, 11);
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
  bool shouldRepaint(TicketView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

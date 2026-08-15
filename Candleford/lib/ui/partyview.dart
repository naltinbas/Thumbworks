import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../party/play.dart';
import 'palette.dart';

/// Where things lie on the board: the guests as candles in rows across
/// the top, and the chance as a bar of icing below.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    perRow = play.guests <= 30 ? 10 : play.guests <= 120 ? 20 : 30;
    rows = (play.guests + perRow - 1) ~/ perRow;
    crowdHeight = room.height * (bare ? 0.9 : 0.6);
    barRect = Rect.fromLTWH(room.width * 0.08, room.height * 0.8, room.width * 0.84, room.height * 0.09);
    final rowH = math.min(crowdHeight / math.max(rows, 1), room.height * (bare ? 0.3 : 0.16));
    // The rows sit in the middle of their room.
    crowdTop = room.height * (bare ? 0.05 : 0.03) + (crowdHeight - rowH * math.max(rows, 1)) / 2;
    candleHeight = rowH * 0.8;
    candleGap = room.width * 0.86 / perRow;
    candleWide = bare ? candleGap * 0.3 : (candleGap * 0.28).clamp(1.5, 8.0);
    crowdLeft = (room.width - candleGap * math.min(perRow, play.guests)) / 2;
    rowHeight = rowH;
  }

  final Play play;

  late final double width;
  late final double height;
  late final int perRow;
  late final int rows;
  late final double crowdTop;
  late final double crowdHeight;
  late final double rowHeight;
  late final double candleHeight;
  late final double candleGap;
  late final double candleWide;
  late final double crowdLeft;
  late final Rect barRect;

  /// Where guest [i]'s candle stands, its foot.
  Offset candle(int i) {
    final row = i ~/ perRow, col = i % perRow;
    final inRow = math.min(perRow, play.guests - row * perRow);
    final left = (width - candleGap * inRow) / 2;
    return Offset(left + (col + 0.5) * candleGap, crowdTop + (row + 1) * rowHeight);
  }
}

/// The party: a candle for every guest, and the chance of a shared day
/// as a bar with the ask's mark on it.
class PartyView extends CustomPainter {
  PartyView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The step the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  /// Whether to leave the words and the bar off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.room);
    // The candles.
    final wide = m.candleWide;
    final tall = m.candleHeight;
    for (var i = 0; i < play.guests; i++) {
      final foot = m.candle(i);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(foot.dx - wide / 2, foot.dy - tall * 0.7, wide, tall * 0.7), Radius.circular(wide * 0.3)), Paint()..color = Palette.wax);
      canvas.drawLine(Offset(foot.dx, foot.dy - tall * 0.7), Offset(foot.dx, foot.dy - tall * 0.78), Paint()
        ..color = Palette.wick
        ..strokeWidth = math.max(1, wide * 0.25));
      final flameR = math.max(1.5, math.min(wide * 0.7, tall * 0.14));
      canvas.drawOval(Rect.fromCenter(center: Offset(foot.dx, foot.dy - tall * 0.86), width: flameR * 1.4, height: flameR * 2.4), Paint()..color = Palette.flame);
      canvas.drawOval(Rect.fromCenter(center: Offset(foot.dx, foot.dy - tall * 0.84), width: flameR * 0.7, height: flameR * 1.2), Paint()..color = Palette.flameCore);
    }
    if (bare) return;

    // The chance bar, filled to the exact fraction, the ask marked.
    final bar = m.barRect;
    canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(6)), Paint()..color = Palette.barBack);
    final (p, q) = play.shared;
    final fill = (p * BigInt.from(100000) ~/ q).toInt() / 100000;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bar.left, bar.top, bar.width * fill, bar.height), const Radius.circular(6)), Paint()..color = play.reaches ? Palette.barFill : Palette.barShort);
    final askX = bar.left + bar.width * play.level.num / play.level.den;
    canvas.drawLine(Offset(askX, bar.top - 6), Offset(askX, bar.bottom + 6), Paint()
      ..color = Palette.mark
      ..strokeWidth = 3);
    _write(canvas, '${play.inHundred} in a hundred', Offset(bar.center.dx, bar.top - 16), labels.copyWith(color: Palette.ink, fontSize: 13, fontWeight: FontWeight.w800));
    final askWords = play.level.certain
        ? 'certain'
        : play.level.strict && play.level.num * 2 == play.level.den
            ? 'a half'
            : '${play.level.num} in ${play.level.den}';
    _write(canvas, askWords, Offset(askX.clamp(bar.left + 20, bar.right - 20), bar.bottom + 16), labels.copyWith(color: Palette.mark, fontSize: 11));
    if (size.height >= 220) {
      _write(canvas, '${play.guests} guest${play.guests == 1 ? '' : 's'}, ${play.level.days == 12 ? 'twelve months' : 'a year of 365 days'}', Offset(size.width / 2, bar.top - 36), labels.copyWith(color: Palette.inkDim, fontSize: 12));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(PartyView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'With a year of d days and n guests, all birthdays equally likely, the '
      'chance that no two share is d times d - 1 and on down to d - n + 1, over d '
      'to the n, since each guest in turn must miss the days taken; the chance of '
      'a shared day is one less that, and it grows with the pairs of guests, not '
      'the guests, 253 pairs at twenty-three. Every party is worked as an exact '
      'fraction in whole numbers, and the fraction agrees with a literal count of '
      'every way to give the guests a day on the small years. At d + 1 guests the '
      'product has a nought in it and the chance is one, the pigeonhole: 366 guests '
      'and 365 days.';
  return '$law ${level.note}';
}

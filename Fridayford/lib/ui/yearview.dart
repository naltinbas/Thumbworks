import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../almanac/play.dart';
import '../almanac/rules.dart';
import 'palette.dart';

/// Where the months lie on the board, so the screen and the tests can
/// find every one: an almanac page with the year's kind written across
/// the top and the twelve months in three columns of four.
class Metrics {
  Metrics(this.play, Size room) {
    page = Rect.fromLTWH(room.width * 0.05, room.height * 0.03, room.width * 0.9, room.height * 0.94);
    headTop = page.top + page.height * 0.06;
    gridTop = page.top + page.height * 0.2;
    cardW = page.width / 3;
    cardH = math.min((page.bottom - gridTop) / 4, cardW * 0.8);
  }

  final Play play;

  late final Rect page;
  late final double headTop;
  late final double gridTop;
  late final double cardW;
  late final double cardH;

  /// The card of month [m].
  Rect cardOf(int m) => Rect.fromLTWH(page.left + (m % 3) * cardW, gridTop + (m ~/ 3) * cardH, cardW, cardH).deflate(4);

  /// The middle of month [m]'s card.
  Offset at(int m) => cardOf(m).center;
}

/// The almanac page: the day the year begins and its February at the
/// top, the twelve months below with the day of the week their
/// thirteenth falls on, the Fridays ringed in red.
class YearView extends CustomPainter {
  YearView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, 'day' or 'leap', or null.
  final String? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.desk);
    canvas.drawRect(m.page.translate(3, 4), Paint()..color = Palette.night.withValues(alpha: 0.4));
    canvas.drawRect(m.page, Paint()..color = Palette.paper);
    final headSize = math.max(11.0, math.min(m.cardH * 0.28, 16.0));
    _write(canvas, 'The year begins on a ${Rules.days[play.start]}', Offset(m.page.center.dx, m.headTop), labels.copyWith(color: pointing == 'day' ? Palette.shown : Palette.blue, fontSize: headSize, fontWeight: FontWeight.w800));
    _write(canvas, play.isLeap ? 'a leap year, February of twenty-nine days' : 'a common year, February of twenty-eight days', Offset(m.page.center.dx, m.headTop + headSize * 1.5), labels.copyWith(color: pointing == 'leap' ? Palette.shown : Palette.faint, fontSize: headSize * 0.8, fontStyle: FontStyle.italic));
    final thirteenths = play.thirteenths;
    for (var mo = 0; mo < 12; mo++) {
      final rect = m.cardOf(mo);
      final isFriday = thirteenths[mo] == Rules.friday;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()..color = Palette.card);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), Paint()
        ..color = isFriday ? Palette.red : Palette.faint.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isFriday ? 2.5 : 1);
      final nameSize = math.max(9.0, math.min(m.cardH * 0.2, 13.0));
      _write(canvas, Rules.months[mo], Offset(rect.center.dx, rect.top + rect.height * 0.24), labels.copyWith(color: Palette.pen, fontSize: nameSize, fontWeight: FontWeight.w700));
      _write(canvas, '13', Offset(rect.center.dx, rect.center.dy + rect.height * 0.08), labels.copyWith(color: isFriday ? Palette.red : Palette.pen, fontSize: nameSize * 1.6, fontWeight: FontWeight.w800));
      _write(canvas, Rules.days[thirteenths[mo]], Offset(rect.center.dx, rect.bottom - rect.height * 0.18), labels.copyWith(color: isFriday ? Palette.red : Palette.faint, fontSize: nameSize * 0.85, fontWeight: isFriday ? FontWeight.w800 : FontWeight.w400));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(YearView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final law = 'The thirteenth of each month falls a fixed count of days along the week from '
      'the first of January, the days of the months before it: ${Rules.offsets(false).join(', ')} '
      'in a common year and ${Rules.offsets(true).join(', ')} in a leap year, and every '
      'day of the week is among them either way, so whatever day the year begins some '
      'thirteenth is a Friday, and since no day comes more than three times, never '
      'more than three. All fourteen kinds of year are swept, and two hundred real '
      'years, 1901 to 2100, walked day by day by the calendar itself.';
  if (!level.winnable) {
    return '$law No kind of year has no Friday the thirteenth.$note';
  }
  return '$law Of the fourteen kinds, ${level.ways} land this ask.$note';
}

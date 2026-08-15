import 'package:flutter/material.dart';

import '../garden/play.dart';
import '../garden/rules.dart';
import 'palette.dart';

/// Where the dials lie on the board, so the screen and the tests can
/// find every one: Ash's spring and autumn bars in the top half, Birch's
/// in the bottom, each bar as long as the patients seen and filled as
/// far as those cured, and each healer's year bar under the two.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    left = room.width * (bare ? 0.08 : 0.24);
    right = room.width * 0.95;
    unit = (right - left) / 50;
    rowHeight = room.height * 0.105;
    barHeight = rowHeight * 0.55;
    blockTops = [room.height * 0.02, room.height * 0.52];
    tops = [
      blockTops[0] + rowHeight * 0.85,
      blockTops[0] + rowHeight * 1.85,
      blockTops[1] + rowHeight * 0.85,
      blockTops[1] + rowHeight * 1.85,
    ];
    yearTops = [blockTops[0] + rowHeight * 2.85, blockTops[1] + rowHeight * 2.85];
    blockHeight = rowHeight * 4.1;
    width = room.width;
  }

  final Play play;

  late final double left;
  late final double right;
  late final double unit;
  late final double rowHeight;
  late final double barHeight;
  late final List<double> blockTops;
  late final double blockHeight;
  late final List<double> tops;
  late final List<double> yearTops;
  late final double width;

  /// The full bar of dial [i], fifty patients long.
  Rect barOf(int i) => Rect.fromLTWH(left, tops[i], unit * 50, barHeight);

  /// The middle of dial [i]'s bar.
  Offset at(int i) => barOf(i).center;

  /// The dial under a touch, or null.
  int? under(Offset touch) {
    for (var i = 0; i < 4; i++) {
      if (barOf(i).inflate(6).contains(touch)) return i;
    }
    return null;
  }
}

/// The garden ledger: for each healer a spring bar and an autumn bar,
/// as long as the patients seen and filled as far as the cured, and a
/// year bar under them with the share; Ash in green, Birch in ochre.
class GardenView extends CustomPainter {
  GardenView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The dial the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final round = Radius.circular(m.barHeight * 0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.garden);
    // The words shrink with the rows, so a small screen with the card up
    // still reads.
    final nameSize = (m.rowHeight * 0.62).clamp(8.0, 15.0);
    final labelSize = (m.rowHeight * 0.5).clamp(7.0, 12.0);
    final countSize = (m.rowHeight * 0.44).clamp(7.0, 11.0);
    for (var h = 0; h < 2; h++) {
      final colour = h == 0 ? Palette.ash : Palette.birch;
      final dark = h == 0 ? Palette.ashDark : Palette.birchDark;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.02, m.blockTops[h], size.width * 0.96, m.blockHeight), Radius.circular(m.barHeight * 0.7)), Paint()..color = Palette.bed);
      if (!bare) {
        _write(canvas, Rules.healers[h], Offset(size.width * 0.12, m.blockTops[h] + m.rowHeight * 0.4), labels.copyWith(color: colour, fontSize: nameSize, fontWeight: FontWeight.w800));
      }
      for (var s = 0; s < 2; s++) {
        final i = h * 2 + s;
        final seen = play.loads[i];
        final (cured, _) = Rules.season(h, s, seen);
        final full = m.barOf(i);
        canvas.drawRRect(RRect.fromRectAndRadius(full, round), Paint()..color = Palette.barBack);
        final seenRect = Rect.fromLTWH(full.left, full.top, m.unit * seen, full.height);
        canvas.drawRRect(RRect.fromRectAndRadius(seenRect, round), Paint()..color = dark);
        final curedRect = Rect.fromLTWH(full.left, full.top, m.unit * cured, full.height);
        canvas.drawRRect(RRect.fromRectAndRadius(curedRect, round), Paint()..color = colour);
        // Ticks at every ten.
        for (var t = 10; t <= 50; t += 10) {
          canvas.drawLine(Offset(full.left + m.unit * t, full.top), Offset(full.left + m.unit * t, full.bottom), Paint()
            ..color = Palette.garden.withValues(alpha: 0.6)
            ..strokeWidth = (m.barHeight * 0.06).clamp(1.0, 4.0));
        }
        if (!bare) {
          _write(canvas, Rules.seasons[s], Offset(size.width * 0.12, full.center.dy), labels.copyWith(color: Palette.inkDim, fontSize: labelSize));
          _write(canvas, '$cured of $seen', Offset(full.right, full.top - m.rowHeight * 0.22), labels.copyWith(color: Palette.ink, fontSize: countSize), right: true);
        }
        if (pointing == i) {
          canvas.drawRRect(RRect.fromRectAndRadius(full.inflate(4), const Radius.circular(6)), Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
        }
      }
      // The year.
      final year = h == 0 ? play.ashYear : play.birchYear;
      final yTop = m.yearTops[h];
      final yearRect = Rect.fromLTWH(m.left, yTop, m.unit * 50, m.barHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(yearRect, round), Paint()..color = Palette.barBack);
      final share = year.$1 / year.$2;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(m.left, yTop, m.unit * 50 * share, m.barHeight), round), Paint()..color = colour);
      if (!bare) {
        _write(canvas, 'the year', Offset(size.width * 0.12, yearRect.center.dy), labels.copyWith(color: Palette.inkDim, fontSize: labelSize));
        _write(canvas, '${year.$1} of ${year.$2}, ${Rules.inHundred(year)} in a hundred', Offset(yearRect.right, yearRect.top - m.rowHeight * 0.22), labels.copyWith(color: colour, fontSize: countSize, fontWeight: FontWeight.w800), right: true);
      }
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style, {bool right = false}) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, right ? at - Offset(painter.width, painter.height / 2) : at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(GardenView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final law = 'Ash cures nine in ten in spring and three in ten in autumn, Birch eight and '
      'two, so Ash cures the bigger share in both seasons at every load; the year is '
      'the seasons weighed by the patients seen, so a healer whose patients come '
      'mostly in the hard season can end the year behind a healer whose patients '
      'come mostly in the easy one, which is Simpson\'s paradox. Every setting of the '
      'loads, ten to fifty in tens, is swept with exact fractions, 625 settings.';
  if (!level.winnable) {
    return '$law With the loads alike for both healers, the two years weigh spring and '
        'autumn alike, and the healer ahead in both seasons is ahead in the year; Ash, '
        'one in ten ahead in each season, ends the year one in ten ahead exactly, '
        'whatever the loads: of the 25 equal loads none reverses, and every reversal '
        'among the 625 has the loads uneven.';
  }
  return '$law Of the 625, ${level.ways} land this ask.$note';
}

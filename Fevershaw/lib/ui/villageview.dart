import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../village/play.dart';
import '../village/rules.dart';
import 'palette.dart';

/// Where things lie on the board, so the screen and the tests can find
/// them: the village as a field of a thousand souls across the top, a
/// bar of the flagged below it, and three rows of dials at the bottom,
/// the fever, the catch and the alarm.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    // Once the ask is over the dials are put away and the field has the room.
    final over = play.isOver;
    dialTop = room.height * 0.62;
    rowHeight = room.height * 0.125;
    labelWidth = room.width * 0.2;
    field = over
        ? Rect.fromLTWH(room.width * 0.05, room.height * 0.03, room.width * 0.9, room.height * 0.62)
        : Rect.fromLTWH(room.width * 0.05, room.height * 0.03, room.width * 0.9, room.height * 0.34);
    barRect = over
        ? Rect.fromLTWH(room.width * 0.05, room.height * 0.76, room.width * 0.9, room.height * 0.07)
        : Rect.fromLTWH(room.width * 0.05, room.height * 0.44, room.width * 0.9, room.height * 0.055);
  }

  final Play play;

  late final double width;
  late final double height;
  late final double dialTop;
  late final double rowHeight;
  late final double labelWidth;
  late final Rect field;
  late final Rect barRect;

  /// How many cells dial [dial] has.
  int cellsOf(int dial) => dial == 0 ? Rules.prevalences.length : dial == 1 ? Rules.catches.length : Rules.alarms.length;

  /// The cell of dial [dial] at [i].
  Rect cell(int dial, int i) {
    final w = (width - labelWidth - width * 0.03) / cellsOf(dial);
    return Rect.fromLTWH(labelWidth + i * w, dialTop + dial * rowHeight, w, rowHeight).deflate(3);
  }

  /// The middle of that cell.
  Offset at(int dial, int i) => cell(dial, i).center;

  /// The dial and index under a touch, or null.
  (int, int)? under(Offset touch) {
    for (var dial = 0; dial < 3; dial++) {
      for (var i = 0; i < cellsOf(dial); i++) {
        if (cell(dial, i).contains(touch)) return (dial, i);
      }
    }
    return null;
  }
}

/// The village: a field of a thousand souls to the nearest soul, the ill
/// in rust and the flagged ringed gold, the flagged as a bar of ill and
/// well, and the three dials.
class VillageView extends CustomPainter {
  VillageView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The (dial, index) the show-me points at, or null.
  final (int, int)? pointing;
  final TextStyle labels;

  /// Whether to draw the field alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.parlour);
    final field = bare ? Rect.fromLTWH(size.width * 0.06, size.height * 0.06, size.width * 0.88, size.height * 0.88) : m.field;
    // The field: 1,000 souls in 40 columns of 25, the ill first, to the
    // nearest soul.
    final (ill, well, illFlagged, wellFlagged) = play.counted;
    final thousandIll = (ill * 1000 / Rules.souls).round();
    final thousandIllFlagged = (illFlagged * 1000 / Rules.souls).round();
    final thousandWellFlagged = (wellFlagged * 1000 / Rules.souls).round();
    const cols = 40, rows = 25;
    final cw = field.width / cols, ch = field.height / rows;
    final r = math.min(cw, ch) * 0.36;
    for (var i = 0; i < 1000; i++) {
      final c = Offset(field.left + (i % cols + 0.5) * cw, field.top + (i ~/ cols + 0.5) * ch);
      final Color colour;
      final bool ringed;
      if (i < thousandIll) {
        ringed = i < thousandIllFlagged;
        colour = ringed ? Palette.illFlagged : Palette.illMissed;
      } else {
        ringed = i - thousandIll < thousandWellFlagged;
        colour = ringed ? Palette.wellFlagged : Palette.wellClear;
      }
      canvas.drawCircle(c, r, Paint()..color = colour);
      if (ringed && !bare) {
        canvas.drawCircle(c, r + 1.5, Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
      }
    }
    if (bare) return;
    final roomy = size.height >= 200;
    if (roomy) {
      _write(canvas, 'a thousand souls to the nearest soul: $thousandIll ill in rust, ${thousandIllFlagged + thousandWellFlagged} flagged, the well flagged in gold', Offset(size.width / 2, field.bottom + 12), labels.copyWith(color: Palette.inkDim, fontSize: 10));
    }

    // The bar: the flagged, ill against well.
    final bar = m.barRect;
    canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(5)), Paint()..color = Palette.barBack);
    final flagged = illFlagged + wellFlagged;
    if (flagged > 0) {
      final illW = bar.width * illFlagged / flagged;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bar.left, bar.top, illW, bar.height), const Radius.circular(5)), Paint()..color = Palette.barIll);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bar.left + illW, bar.top, bar.width - illW, bar.height), const Radius.circular(5)), Paint()..color = Palette.barWell);
    }
    final share = play.share;
    if (roomy) {
      _write(canvas, 'of the flagged, ${share.$1} in ${share.$2} ill, ${Rules.inHundred(share)} in a hundred', Offset(size.width / 2, bar.bottom + 11), labels.copyWith(color: Palette.ink, fontSize: 11, fontWeight: FontWeight.w800));
      _write(canvas, '${_commas(illFlagged)} ill flagged against ${_commas(wellFlagged)} well, in ten million', Offset(size.width / 2, bar.bottom + 25), labels.copyWith(color: Palette.inkDim, fontSize: 10));
    }
    if (play.isOver) return;

    // The dials.
    const names = ['fever, 1 in', 'catch', 'alarm'];
    for (var dial = 0; dial < 3; dial++) {
      _write(canvas, names[dial], Offset(m.labelWidth * 0.5, m.dialTop + dial * m.rowHeight + m.rowHeight / 2), labels.copyWith(color: Palette.inkDim, fontSize: 12));
      final now = dial == 0 ? play.prevalence : dial == 1 ? play.catchAt : play.alarmAt;
      for (var i = 0; i < m.cellsOf(dial); i++) {
        final cell = m.cell(dial, i);
        final on = i == now;
        canvas.drawRRect(RRect.fromRectAndRadius(cell, const Radius.circular(6)), Paint()..color = on ? Palette.dialOn : Palette.dial);
        if (pointing != null && pointing!.$1 == dial && pointing!.$2 == i) {
          canvas.drawRRect(RRect.fromRectAndRadius(cell.inflate(2), const Radius.circular(7)), Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
        }
        final String words;
        if (dial == 0) {
          words = '${Rules.prevalences[i]}';
        } else {
          final rate = dial == 1 ? Rules.catches[i] : Rules.alarms[i];
          words = rate == (1, 1) ? 'all' : rate == (0, 1) ? 'none' : '${rate.$1}/${rate.$2}';
        }
        _write(canvas, words, cell.center, labels.copyWith(color: on ? Palette.night : Palette.ink, fontSize: (cell.width * 0.22).clamp(8.0, 12.0), fontWeight: FontWeight.w800));
      }
    }
  }

  static String _commas(int n) {
    final s = '$n';
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(VillageView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'A fever afflicts one soul in so many; the physician\'s test flags the '
      'ill so many times in so many, the catch, and wrongly flags the well so many '
      'times in so many, the alarm. Of the villagers flagged, the share that are '
      'ill is the ill flagged over all flagged, which is Bayes\' theorem read as '
      'counting: fever times catch over fever times catch plus the rest times '
      'alarm. Since the well outnumber the ill, a small alarm on the many well can '
      'outweigh a big catch on the few ill, and a rare fever makes a flag doubtful '
      'however sure the test seems. Every setting of the sham is counted in a '
      'village of ten million souls, every count whole, and held to the fractions '
      'of chances, the two agreeing on all 225.';
  return '$law ${level.note}';
}

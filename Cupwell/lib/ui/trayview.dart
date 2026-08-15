import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tray/play.dart';
import 'palette.dart';

/// Where the cups stand on the tray, so the screen and the tests can
/// find every one.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.level.cups;
    gap = math.min(room.width * 0.86 / n, 120);
    left = (room.width - gap * (n - 1)) / 2;
    y = room.height * 0.5;
    cupWidth = gap * 0.7;
    cupHeight = math.min(room.height * 0.4, cupWidth * 1.4);
  }

  final Play play;

  late final double gap;
  late final double left;
  late final double y;
  late final double cupWidth;
  late final double cupHeight;

  Offset at(int cup) => Offset(left + cup * gap, y);

  /// The cup under a touch, or null off the cups.
  int? under(Offset touch) {
    for (var c = 0; c < play.level.cups; c++) {
      final r = Rect.fromCenter(center: at(c), width: gap * 0.9, height: cupHeight * 1.4);
      if (r.contains(touch)) return c;
    }
    return null;
  }
}

/// The tray and its cups, up or down, the marked ones ringed, and the
/// count down written above.
class TrayView extends CustomPainter {
  TrayView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.level.cups;

    // The cloth and the tray.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.cloth);
    final tray = Rect.fromLTRB(m.left - m.gap * 0.6, m.y - m.cupHeight * 0.85, m.left + (n - 1) * m.gap + m.gap * 0.6, m.y + m.cupHeight * 0.85);
    canvas.drawRRect(RRect.fromRectAndRadius(tray, const Radius.circular(14)), Paint()..color = Palette.tray);
    canvas.drawRRect(RRect.fromRectAndRadius(tray, const Radius.circular(14)), Paint()
      ..color = Palette.trayEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4);
    // The count down, above.
    final down = play.downCount;
    _write(canvas, '$down down of $n, ${down.isOdd ? 'odd' : 'even'}', Offset(size.width / 2, tray.top - 22),
        labels.copyWith(color: down == 0 ? Palette.even : down.isOdd ? Palette.odd : Palette.ink, fontSize: 13, fontWeight: FontWeight.w700));
    _write(canvas, 'turn ${play.level.each} at a time; ${play.marked.length} of ${play.level.each} marked', Offset(size.width / 2, tray.bottom + 22),
        labels.copyWith(color: Palette.inkDim, fontSize: 12));

    // The cups.
    for (var c = 0; c < n; c++) {
      final at = m.at(c);
      final w = m.cupWidth, h = m.cupHeight;
      final downCup = play.isDown(c);
      Path body;
      if (!downCup) {
        // Up: wide mouth at the top, narrow foot at the bottom.
        body = Path()
          ..moveTo(at.dx - w * 0.5, at.dy - h * 0.5)
          ..lineTo(at.dx + w * 0.5, at.dy - h * 0.5)
          ..lineTo(at.dx + w * 0.36, at.dy + h * 0.5)
          ..lineTo(at.dx - w * 0.36, at.dy + h * 0.5)
          ..close();
      } else {
        // Down: foot up, mouth on the tray.
        body = Path()
          ..moveTo(at.dx - w * 0.36, at.dy - h * 0.5)
          ..lineTo(at.dx + w * 0.36, at.dy - h * 0.5)
          ..lineTo(at.dx + w * 0.5, at.dy + h * 0.5)
          ..lineTo(at.dx - w * 0.5, at.dy + h * 0.5)
          ..close();
      }
      canvas.drawPath(body, Paint()..color = Palette.glaze);
      canvas.drawPath(body, Paint()
        ..color = Palette.glazeShade
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      // The band round the middle.
      canvas.drawRect(Rect.fromCenter(center: at, width: w * 0.86, height: h * 0.12), Paint()..color = Palette.band);
      if (!downCup) {
        // The open mouth, seen from a little above.
        canvas.drawOval(Rect.fromCenter(center: at - Offset(0, h * 0.5), width: w, height: h * 0.18), Paint()..color = Palette.inside);
        canvas.drawOval(Rect.fromCenter(center: at - Offset(0, h * 0.5), width: w, height: h * 0.18), Paint()
          ..color = Palette.glaze
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      } else {
        // The foot on top.
        canvas.drawOval(Rect.fromCenter(center: at - Offset(0, h * 0.5), width: w * 0.72, height: h * 0.14), Paint()..color = Palette.foot);
      }
      // A mark, if picked for the turn.
      if (play.marked.contains(c)) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: at, width: w * 1.25, height: h * 1.25), const Radius.circular(10)),
            Paint()
              ..color = Palette.marked
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3);
      }
      _write(canvas, '${c + 1}', at + Offset(0, h * 0.78), labels.copyWith(color: Palette.inkDim, fontSize: 11));
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.at(aim.$2), m.cupWidth * 0.85, Paint()
        ..color = aim.$1 == 'unmark' ? Palette.bad : Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(TrayView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a tray as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'A turn of two cups changes the count down by two, when both went the '
        'same way, or by nought, when one came up as the other went down; either '
        'way an odd count stays odd and an even count even. One cup down is odd, '
        'all up is even, so no run of turns by twos brings this tray up. Every '
        'tray of two to six cups was walked from every start with every count '
        'turned at a time, and the law held on all of them.$note';
  }
  return 'Every sequence of ${level.turns} turns is swept, ${level.sequences} of '
      'them, and those ending all up counted; the fewest turns are found by '
      'walking every tray a turn can reach, nearest first, and every tray of two '
      'to six cups is walked from every start: turning an even count keeps the '
      'count down odd or even, turning an odd count short of the whole tray '
      'reaches everything, and turning the whole tray reaches only the tray and '
      'its opposite. ${level.ways} of the ${level.sequences} land it.$note';
}

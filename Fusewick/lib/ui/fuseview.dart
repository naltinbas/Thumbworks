import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../fuse/level.dart';
import '../fuse/play.dart';
import '../fuse/rules.dart';
import 'palette.dart';

/// Where the fuses, their ends and the clock lie on the board, so the
/// screen and the tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.level.fuses;
    clock = Offset(room.width / 2, room.height * 0.24);
    clockRadius = math.min(room.width * 0.2, room.height * 0.17);
    fuseLeft = room.width * 0.14;
    fuseRight = room.width * 0.86;
    fuseGap = math.min(room.height * 0.16, 90);
    firstFuseY = room.height * 0.55 + (3 - n) * fuseGap * 0.5;
  }

  final Play play;

  late final Offset clock;
  late final double clockRadius;
  late final double fuseLeft;
  late final double fuseRight;
  late final double fuseGap;
  late final double firstFuseY;

  double fuseY(int i) => firstFuseY + i * fuseGap;

  /// The end of fuse [i], left or right, where a tap lights it.
  Offset endAt(int i, bool right) => Offset(right ? fuseRight : fuseLeft, fuseY(i));

  /// What is under a touch: ('end', fuse, right), ('clock', 0, false),
  /// or null.
  (String, int, bool)? under(Offset touch) {
    if ((touch - clock).distance <= clockRadius * 1.15) return ('clock', 0, false);
    for (var i = 0; i < play.level.fuses; i++) {
      for (final right in [false, true]) {
        if ((touch - endAt(i, right)).distance <= fuseGap * 0.42) return ('end', i, right);
      }
    }
    return null;
  }
}

/// The clock, the fuses with their sparks and ash, and the time asked
/// marked on the dial.
class FuseView extends CustomPainter {
  FuseView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int, bool)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.floor);

    // The clock: a dial of two hours, the asked time marked, the hand
    // at now.
    final r = m.clockRadius;
    canvas.drawCircle(m.clock, r, Paint()..color = Palette.clockFace);
    canvas.drawCircle(m.clock, r, Paint()
      ..color = Palette.clockRim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
    for (var k = 0; k < 24; k++) {
      final a = -math.pi / 2 + k * math.pi / 12;
      final long = k % 6 == 0;
      canvas.drawLine(m.clock + Offset(math.cos(a), math.sin(a)) * (r - (long ? 12 : 6)), m.clock + Offset(math.cos(a), math.sin(a)) * (r - 2),
          Paint()
            ..color = Palette.clockRim
            ..strokeWidth = long ? 2 : 1);
    }
    for (final (mins, label) in [(0, '0'), (30, '30'), (60, '60'), (90, '90')]) {
      final a = -math.pi / 2 + mins / 120 * 2 * math.pi;
      _write(canvas, label, m.clock + Offset(math.cos(a), math.sin(a)) * (r - 24), labels.copyWith(color: Palette.inkDim, fontSize: 10));
    }
    final askedA = -math.pi / 2 + play.level.asked / 480 * 2 * math.pi;
    canvas.drawLine(m.clock, m.clock + Offset(math.cos(askedA), math.sin(askedA)) * (r - 4), Paint()
      ..color = Palette.asked.withValues(alpha: 0.6)
      ..strokeWidth = 4);
    final nowA = -math.pi / 2 + (play.now.clamp(0, 480)) / 480 * 2 * math.pi;
    canvas.drawLine(m.clock, m.clock + Offset(math.cos(nowA), math.sin(nowA)) * (r - 8), Paint()
      ..color = play.isDone ? Palette.struck : play.missed ? Palette.missed : Palette.hand
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(m.clock, 4, Paint()..color = Palette.clockRim);
    _write(canvas, Level.minutes(play.now), m.clock + Offset(0, r * 0.45),
        labels.copyWith(color: Palette.ink, fontSize: 12, fontWeight: FontWeight.w700));
    _write(canvas, play.anythingAlight ? 'tap the clock to let them burn' : 'nothing alight', m.clock + Offset(0, r + 16),
        labels.copyWith(color: Palette.inkDim, fontSize: 11));

    // The fuses.
    for (var i = 0; i < play.level.fuses; i++) {
      final y = m.fuseY(i);
      final leftQ = play.left[i];
      final width = m.fuseRight - m.fuseLeft;
      // The whole hour drawn as ash, and what is left as hemp in the
      // middle, since where the burning is along an uneven fuse cannot
      // be known: only how many minutes remain.
      canvas.drawLine(Offset(m.fuseLeft, y), Offset(m.fuseRight, y), Paint()
        ..color = Palette.ash
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round);
      final live = width * leftQ / Rules.hour;
      final start = m.fuseLeft + (width - live) / 2;
      if (leftQ > 0) {
        canvas.drawLine(Offset(start, y), Offset(start + live, y), Paint()
          ..color = Palette.fuse
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round);
        // Braid marks.
        for (var x = start + 8; x < start + live - 4; x += 12) {
          canvas.drawLine(Offset(x, y - 3), Offset(x + 4, y + 3), Paint()
            ..color = Palette.fuseDark
            ..strokeWidth = 1.5);
        }
      }
      // The ends, and their sparks.
      for (final right in [false, true]) {
        final at = m.endAt(i, right);
        final lit = right ? play.lit[i].$2 : play.lit[i].$1;
        canvas.drawCircle(at, 9, Paint()..color = lit ? Palette.flame : Palette.fuseDark);
        if (lit && leftQ > 0) {
          canvas.drawCircle(at, 14, Paint()..color = Palette.spark.withValues(alpha: 0.35));
          canvas.drawCircle(at, 6, Paint()..color = Palette.spark);
        }
        if (lit && leftQ == 0) {
          canvas.drawCircle(at, 9, Paint()..color = Palette.ash);
        }
      }
      _write(canvas, leftQ == 0 ? 'burnt out' : '${Level.minutes(leftQ)} of fuse left', Offset(size.width / 2, y - 18),
          labels.copyWith(color: leftQ == 0 ? Palette.inkDim : Palette.ink, fontSize: 12));
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final at = aim.$1 == 'burn' ? m.clock : m.endAt(aim.$2, aim.$3);
      canvas.drawCircle(at, aim.$1 == 'burn' ? m.clockRadius + 6 : 18, Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(FuseView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a time as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'A fuse burns unevenly, so nothing along it can be trusted but the '
        'whole: an hour from one end, half an hour from both. You can light an '
        'end only at the start or when a fuse burns out, so the first burnout '
        'comes at thirty or sixty, and every burnout after is a whole or a half '
        'of what some fuse had left at the one before. Every plan of lighting '
        '${level.fuses == 2 ? 'two' : 'three'} fuses was swept, ${level.plans} '
        'plans, and the burnouts fall only at 30, 45, 60, 90 and 120.$note';
  }
  return 'Every plan of lighting is swept: at the start and at every burnout, '
      'each fuse with fuse left may have any of its unlit ends lit, and the '
      'fuses burn on to the next burnout, an hour from one end or half from '
      'both of whatever is left; the times struck are read off every plan, '
      'and ${level.ways} of the ${level.plans} plans strike ${level.askedWords}.$note';
}

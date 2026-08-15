import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../train/play.dart';
import '../train/rules.dart';
import 'palette.dart';

/// Where things lie on the board: the pegboard across the top, a unit
/// of pegs a fixed number of pixels, and the tray of gears below.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    final w = play.level.width, h = play.level.height;
    final boardH = bare || play.isOver ? room.height : room.height * 0.72;
    // Room for the largest gear's teeth past the edge pegs.
    margin = [...play.level.fixed.map((g) => g.$3), ...play.level.tray].reduce(math.max) + 0.25;
    unit = math.min(room.width * 0.94 / (w - 1 + 2 * margin), boardH * 0.92 / (h - 1 + 2 * margin));
    origin = Offset((room.width - unit * (w - 1)) / 2, (boardH - unit * (h - 1)) / 2 + (bare || play.isOver ? 0 : room.height * 0.02));
    trayTop = room.height * 0.74;
    trayHeight = room.height * 0.26;
    final slots = play.level.tray.length;
    slotWidth = room.width / (slots + 1);
    for (var i = 0; i < slots; i++) {
      traySlots[i] = Rect.fromLTWH(slotWidth * (i + 0.5), trayTop, slotWidth, trayHeight);
    }
  }

  final Play play;

  late final double width;
  late final double height;

  /// One unit of the pegboard, in pixels.
  late final double unit;

  /// The board's reach past the edge pegs, in units.
  late final double margin;

  /// Where peg (0, 0) lies.
  late final Offset origin;
  late final double trayTop;
  late final double trayHeight;
  late final double slotWidth;
  final traySlots = <int, Rect>{};

  /// Where peg (x, y) lies.
  Offset peg(int x, int y) => origin + Offset(x * unit, y * unit);

  /// The middle of tray slot [i].
  Offset trayAt(int i) => traySlots[i]!.center;

  /// What is under a touch: (1, slot, 0) a tray slot, (0, x, y) a peg,
  /// or null.
  (int, int, int)? under(Offset touch) {
    for (final e in traySlots.entries) {
      if (e.value.contains(touch)) return (1, e.key, 0);
    }
    for (var y = 0; y < play.level.height; y++) {
      for (var x = 0; x < play.level.width; x++) {
        if ((peg(x, y) - touch).distance <= unit * 0.5) return (0, x, y);
      }
    }
    return null;
  }
}

/// The pegboard: pegs, gears as toothed brass wheels, the crank in copper
/// with its handle and the mill in iron with its sails, each turning
/// gear marked with its way and its speed, jams in rust; and the tray.
class TrainView extends CustomPainter {
  TrainView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int, int)? pointing;
  final TextStyle labels;

  /// Whether to draw the pegboard alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.workshop);
    final boardRect = Rect.fromPoints(m.peg(0, 0), m.peg(play.level.width - 1, play.level.height - 1)).inflate(m.unit * m.margin);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, Radius.circular(m.unit * 0.3)), Paint()..color = Palette.pegboard);
    // The pegs.
    for (var y = 0; y < play.level.height; y++) {
      for (var x = 0; x < play.level.width; x++) {
        canvas.drawCircle(m.peg(x, y), (m.unit * 0.07).clamp(2.0, 5.0), Paint()..color = Palette.peg);
      }
    }
    // The gears.
    final gears = play.gears;
    final (way, jam) = play.turning;
    for (var i = 0; i < gears.length; i++) {
      final g = gears[i];
      final c = m.peg(g.$1, g.$2);
      final r = g.$3 * m.unit;
      final fixed = i < play.level.fixed.length;
      final colour = jam && way[i] != 0
          ? Palette.jam
          : i == 0
              ? Palette.copper
              : fixed
                  ? Palette.iron
                  : way[i] == 0
                      ? Palette.still
                      : Palette.brass;
      _gear(canvas, c, r, g.$3 * 8, colour, fixed ? Palette.night : Palette.brassDark);
      if (i == 0) {
        // The crank handle.
        canvas.drawLine(c, c + Offset(r * 0.6, -r * 0.3), Paint()
          ..color = Palette.night
          ..strokeWidth = (r * 0.12).clamp(2.0, 6.0)
          ..strokeCap = StrokeCap.round);
        canvas.drawCircle(c + Offset(r * 0.6, -r * 0.3), (r * 0.12).clamp(3.0, 8.0), Paint()..color = Palette.night);
      } else if (fixed) {
        // The mill's sails.
        for (var k = 0; k < 4; k++) {
          final a = k * math.pi / 2 + math.pi / 4;
          canvas.drawLine(c, c + Offset(math.cos(a), math.sin(a)) * r * 0.55, Paint()
            ..color = Palette.night
            ..strokeWidth = (r * 0.1).clamp(1.5, 5.0));
        }
      }
      if (!bare && !jam && way[i] != 0) {
        // The way, as an arrow round the rim, and the speed.
        _wayArrow(canvas, c, r * 0.72, way[i] > 0, way[i] > 0 ? Palette.withCrank : Palette.against);
        if (i > 0) {
          final (n, d) = Rules.speed(gears[0], g);
          _write(canvas, d == 1 ? '$n turn${n == 1 ? '' : 's'}' : '$n/$d turn', c + Offset(0, r + 10), labels.copyWith(color: Palette.ink, fontSize: 10));
        }
      }
    }
    // The pointer on the board.
    if (pointing != null && pointing!.$1 == Aim.peg && play.heldRadius != null) {
      canvas.drawCircle(m.peg(pointing!.$2, pointing!.$3), play.heldRadius! * m.unit + 3, Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    if (pointing != null && pointing!.$1 == Aim.lift) {
      final i = play.gearAt(pointing!.$2, pointing!.$3);
      if (i != null) {
        canvas.drawCircle(m.peg(pointing!.$2, pointing!.$3), gears[i].$3 * m.unit + 3, Paint()
          ..color = Palette.jam
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
    if (bare || play.isOver) return;
    // The tray.
    canvas.drawLine(Offset(size.width * 0.03, m.trayTop), Offset(size.width * 0.97, m.trayTop), Paint()
      ..color = Palette.line
      ..strokeWidth = 2);
    final placed = play.slotPlaced;
    for (var i = 0; i < play.level.tray.length; i++) {
      final slot = m.traySlots[i]!;
      final r = play.level.tray[i];
      final radius = math.min(slot.width * 0.16 * r, slot.height * 0.28);
      final c = Offset(slot.center.dx, slot.top + slot.height * 0.42);
      if (placed[i]) {
        canvas.drawCircle(c, radius, Paint()
          ..color = Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
      } else {
        _gear(canvas, c, radius, r * 8, Palette.brass, Palette.brassDark);
      }
      _write(canvas, 'of ${['one', 'two', 'three'][r - 1]}', Offset(slot.center.dx, slot.bottom - 10), labels.copyWith(color: placed[i] ? Palette.inkDim : Palette.ink, fontSize: 10));
      if (play.held == i) {
        canvas.drawCircle(c, radius + 5, Paint()
          ..color = Palette.held
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
      if (pointing != null && pointing!.$1 == Aim.tray && pointing!.$2 == i) {
        canvas.drawCircle(c, radius + 8, Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
  }

  /// A gear: a toothed wheel of [teeth] teeth, [r] to the tips.
  void _gear(Canvas canvas, Offset c, double r, int teeth, Color colour, Color hub) {
    final path = Path();
    final inner = r * 0.84;
    for (var t = 0; t < teeth; t++) {
      final a0 = t * 2 * math.pi / teeth;
      final a1 = a0 + math.pi / teeth * 0.5;
      final a2 = a0 + math.pi / teeth;
      final a3 = a0 + math.pi / teeth * 1.5;
      final p0 = c + Offset(math.cos(a0), math.sin(a0)) * inner;
      final p1 = c + Offset(math.cos(a1), math.sin(a1)) * r;
      final p2 = c + Offset(math.cos(a2), math.sin(a2)) * r;
      final p3 = c + Offset(math.cos(a3), math.sin(a3)) * inner;
      if (t == 0) path.moveTo(p0.dx, p0.dy);
      path.lineTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(p3.dx, p3.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = colour);
    canvas.drawCircle(c, r * 0.5, Paint()
      ..color = hub.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (r * 0.06).clamp(1.0, 4.0));
    canvas.drawCircle(c, (r * 0.1).clamp(2.0, 8.0), Paint()..color = hub);
  }

  /// An arrow round the rim, clockwise or not.
  void _wayArrow(Canvas canvas, Offset c, double r, bool clockwise, Color colour) {
    final paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = (r * 0.09).clamp(1.5, 4.0)
      ..strokeCap = StrokeCap.round;
    const start = -math.pi / 2, sweep = math.pi * 0.9;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, clockwise ? sweep : -sweep, false, paint);
    final end = start + (clockwise ? sweep : -sweep);
    final tip = c + Offset(math.cos(end), math.sin(end)) * r;
    final tangent = clockwise ? end + math.pi / 2 : end - math.pi / 2;
    final head = (r * 0.28).clamp(4.0, 12.0);
    for (final side in [0.7, -0.7]) {
      final a = tangent + math.pi + side;
      canvas.drawLine(tip, tip + Offset(math.cos(a), math.sin(a)) * head, paint);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(TrainView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'Gears on the pegs of a board, each a whole number of units from peg '
      'to teeth, eight teeth to the unit; two mesh when their pegs lie the sum of '
      'their radii apart exactly, and overlap when less. Every mesh turns the '
      'next gear the other way, so a gear an even count of meshes from the crank '
      'turns with it and an odd count against; and a ring of gears turns only '
      'when its count is even, since round an odd ring the direction would have '
      'to be both, so an odd ring jams the train. A gear that turns makes as many '
      'turns as the crank times the crank\'s radius over its own, whatever lies '
      'between: an idler changes nothing but the way. Every placing of every '
      'train is swept, the turning walked mesh by mesh and the speeds held to the '
      'formula on every turning gear.';
  return '$law ${level.note}';
}

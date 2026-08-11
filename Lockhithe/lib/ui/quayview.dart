import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../quay/play.dart';
import 'palette.dart';

/// Where every locker stands, shared by the painter and the hit-testing,
/// so where a locker is drawn is exactly where a locker is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final lockers = play.berth.lockers;
    perRow = (lockers / 2).ceil();
    // Proportional, so the tiniest launcher icon still gets doors.
    door = math.min(width / (perRow + 0.5), height * 0.2);
    across = door * perRow;
    left = (width - across) / 2;
    top = height * 0.3;
  }

  final Play play;

  late final double width;
  late final double height;
  late final int perRow;
  late final double door;
  late final double across;
  late final double left;
  late final double top;

  Rect lockerRect(int locker) {
    final row = locker ~/ perRow;
    final column = locker % perRow;
    return Rect.fromLTWH(
      left + column * door,
      top + row * door * 1.24,
      door,
      door * 1.16,
    );
  }

  /// The locker under a touch, or -1 for nowhere.
  int lockerAt(Offset touch) {
    for (var locker = 0; locker < play.berth.lockers; locker++) {
      if (lockerRect(locker).inflate(1).contains(touch)) return locker;
    }
    return -1;
  }
}

/// The quay store, drawn.
class QuayView extends CustomPainter {
  QuayView({
    required this.play,
    required this.pointing,
    required this.showLoops,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The locker being pointed at, or -1.
  final int pointing;

  /// Whether to draw the loops as ropes over the doors.
  final bool showLoops;

  /// Whether numbers may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var locker = 0; locker < play.berth.lockers; locker++) {
      _locker(canvas, metrics, locker);
    }
    if (showLoops) _loops(canvas, metrics);
    if (pointing >= 0) _point(canvas, metrics);
  }

  void _locker(Canvas canvas, Metrics metrics, int locker) {
    final outer = metrics.lockerRect(locker);
    final rect = outer.deflate(outer.width * 0.05);
    final open = play.isOpen(locker);
    final round = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.12),
    );

    canvas.drawRRect(
      round,
      Paint()..color = open ? Palette.inside : Palette.door,
    );
    canvas.drawRRect(
      round,
      Paint()
        ..color = Palette.rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    if (!open) {
      // The handle.
      canvas.drawCircle(
        rect.centerRight + Offset(-rect.width * 0.16, 0),
        rect.width * 0.05,
        Paint()..color = Palette.rim,
      );
    }

    if (!showWords) return;

    if (open) {
      // The chit inside: whose it is.
      final chit = play.stow.chits[locker];
      final slip = Rect.fromCenter(
        center: rect.center + Offset(0, rect.height * 0.06),
        width: rect.width * 0.52,
        height: rect.height * 0.42,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(slip, Radius.circular(slip.width * 0.14)),
        Paint()..color = chit == 0 ? Palette.own : Palette.chit,
      );
      final words = TextPainter(
        text: TextSpan(
          text: '${chit + 1}',
          style: labels.copyWith(
            color: Palette.quay,
            fontSize: slip.height * 0.6,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        slip.center - Offset(words.width / 2, words.height / 2),
      );
    }

    // The locker's number on the lintel.
    final number = TextPainter(
      text: TextSpan(
        text: '${locker + 1}',
        style: labels.copyWith(
          color: locker == 0 ? Palette.you : Palette.inkDim,
          fontSize: rect.height * 0.2,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    number.paint(
      canvas,
      Offset(
        rect.center.dx - number.width / 2,
        rect.top + rect.height * 0.07,
      ),
    );
  }

  void _loops(Canvas canvas, Metrics metrics) {
    final loops = play.stow.loops;
    for (var which = 0; which < loops.length; which++) {
      final loop = loops[which];
      if (loop.length == 1) {
        canvas.drawCircle(
          metrics.lockerRect(loop.single).center,
          metrics.door * 0.14,
          Paint()
            ..color = Palette.ropes[which % Palette.ropes.length]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
        continue;
      }
      final rope = Paint()
        ..color = Palette.ropes[which % Palette.ropes.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      for (var leg = 0; leg < loop.length; leg++) {
        final from = metrics.lockerRect(loop[leg]).center;
        final to = metrics
            .lockerRect(loop[(leg + 1) % loop.length]).center;
        final middle = Offset(
          (from.dx + to.dx) / 2,
          (from.dy + to.dy) / 2 - metrics.door * 0.34,
        );
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(middle.dx, middle.dy, to.dx, to.dy);
        canvas.drawPath(path, rope);
        // The way of the rope.
        final way = (to - from) / (to - from).distance;
        final side = Offset(-way.dy, way.dx);
        final tip = to - way * metrics.door * 0.22;
        canvas.drawLine(tip, tip - way * 6 + side * 4, rope);
        canvas.drawLine(tip, tip - way * 6 - side * 4, rope);
      }
    }
  }

  void _point(Canvas canvas, Metrics metrics) {
    final rect = metrics.lockerRect(pointing);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(2),
        Radius.circular(rect.width * 0.14),
      ),
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(QuayView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showLoops != showLoops;
}

/// The words the why speaks, from the round at hand.
String whyWords(Play play) {
  final loops = play.stow.loops;
  final lengths = loops.map((loop) => loop.length).join(', ');
  final longest = play.stow.longestLoop;
  final looks = play.berth.looks;
  return 'Start at any locker, read the chit, go to that sailor\'s '
      'locker, and you come back round: every stowing is loops, and this '
      'one\'s run $lengths. A sailor following the chits walks their own '
      'loop and meets their chit on its last step, so the crew comes '
      'through exactly when no loop outruns the $looks looks. '
      '${longest <= looks ? 'The longest here is $longest: this crew is '
          'safe before anyone opens a door.' : 'The longest here is '
          '$longest: this crew was sunk before anyone opened a door.'}'
      '${play.berth.note == null ? '' : ' ${play.berth.note}'}';
}

import 'package:flutter/material.dart';

import '../sift/noughts.dart';
import '../sift/play.dart';
import 'palette.dart';

/// Where everything on the frame is.
///
/// The painter and the finger both use this, which is the point of it: a line
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    gap = room.height / (play.lines + 1);
    left = room.width * 0.16;
    right = room.width * 0.94;
    // Room for one more than is in, so there is always somewhere to put the
    // next one.
    step = (right - left) / (play.count + 1.6);
  }

  final Play play;

  /// Between one line and the next.
  late final double gap;
  late final double left;
  late final double right;

  /// Between one comparator and the next.
  late final double step;

  double yOf(int line) => gap * (line + 1);
  double xOf(int which) => left + step * (which + 0.8);

  /// The line nearest a point, or -1 if the finger is nowhere near one.
  int lineAt(Offset touch) {
    for (var line = 0; line < play.lines; line++) {
      if ((touch.dy - yOf(line)).abs() < gap * 0.42) return line;
    }
    return -1;
  }

  /// The comparator nearest a point, or -1.
  int crossAt(Offset touch) {
    for (var which = 0; which < play.count; which++) {
      final cross = play.sieve.crosses[which];
      if ((touch.dx - xOf(which)).abs() > step * 0.45) continue;
      final top = yOf(cross.upper);
      final bottom = yOf(cross.lower);
      if (touch.dy > top - gap * 0.3 && touch.dy < bottom + gap * 0.3) {
        return which;
      }
    }
    return -1;
  }
}

/// The frame: the lines, the comparators on them, and the row that is still
/// coming out wrong.
class Frame extends CustomPainter {
  const Frame({
    required this.play,
    required this.holding,
    required this.showing,
    required this.labels,
  });

  final Play play;

  /// A line the finger has taken hold of, waiting for a second, or -1.
  final int holding;

  /// A row of noughts and ones to draw going in and coming out, or -1.
  final int showing;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var line = 0; line < play.lines; line++) {
      final y = metrics.yOf(line);
      canvas.drawLine(
        Offset(metrics.left, y),
        Offset(metrics.right, y),
        Paint()
          ..color = line == holding ? Palette.ink : Palette.line
          ..strokeWidth = line == holding ? 2.6 : 1.6,
      );
    }

    for (var which = 0; which < play.count; which++) {
      final cross = play.sieve.crosses[which];
      final x = metrics.xOf(which);
      final top = metrics.yOf(cross.upper);
      final bottom = metrics.yOf(cross.lower);
      final colour = which < play.given ? Palette.given : Palette.rung;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        Paint()
          ..color = colour
          ..strokeWidth = 3.4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(Offset(x, top), 5.4, Paint()..color = colour);
      canvas.drawCircle(Offset(x, bottom), 5.4, Paint()..color = colour);
    }

    if (showing < 0) return;

    // The row going in on the left, and what it comes out as on the right.
    final wentIn = Noughts.words(showing, play.lines);
    final came = play.outOf(showing);
    for (var line = 0; line < play.lines; line++) {
      _write(
        canvas,
        wentIn[line],
        Offset(metrics.left * 0.55, metrics.yOf(line)),
        Palette.inkDim,
      );
      final out = came[line];
      final wrong = came != _sorted(came);
      _write(
        canvas,
        out,
        Offset(metrics.right + (size.width - metrics.right) * 0.5,
            metrics.yOf(line)),
        wrong ? Palette.wrong : Palette.good,
      );
    }
  }

  static String _sorted(String row) {
    final letters = row.split('')..sort();
    return letters.join();
  }

  void _write(Canvas canvas, String what, Offset middle, Color colour) {
    final painter = TextPainter(
      text: TextSpan(text: what, style: labels.copyWith(color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      middle + Offset(-painter.width / 2, -painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(Frame old) =>
      old.play != play ||
      old.holding != holding ||
      old.showing != showing;
}

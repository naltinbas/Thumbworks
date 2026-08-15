import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../deal/play.dart';
import 'palette.dart';

/// Where the columns and the placings lie on the table, so the
/// screen and the tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    // Three columns of nine on the left two thirds, three placings
    // stacked on the right.
    pitch = math.min(room.width * 0.62 / 3, room.height * 0.86 / 9);
    columnsLeft = room.width * 0.05;
    columnsTop = (room.height - pitch * 9) / 2;
    final right = columnsLeft + pitch * 3 + room.width * 0.05;
    final width = room.width - right - room.width * 0.04;
    final height = math.min(room.height * 0.16, pitch * 1.6);
    final gap = (pitch * 9 - height * 3) / 4;
    for (var p = 0; p < 3; p++) {
      placings.add(Rect.fromLTWH(
        right,
        columnsTop + gap + p * (height + gap),
        width,
        height,
      ));
    }
  }

  final Play play;

  late final double pitch;
  late final double columnsLeft;
  late final double columnsTop;

  /// The three placings, top, middle, bottom.
  final placings = <Rect>[];

  /// The middle of the counter in [column] at [row].
  Offset counterAt(int column, int row) => Offset(
        columnsLeft + (column + 0.5) * pitch,
        columnsTop + (row + 0.5) * pitch,
      );

  /// The placing under a touch, or null.
  int? under(Offset touch) {
    for (var p = 0; p < 3; p++) {
      if (placings[p].inflate(pitch * 0.15).contains(touch)) return p;
    }
    return null;
  }
}

/// The table itself: the standing stack dealt into three columns,
/// the chosen counter in gold, and the three placings to gather
/// by; once the deals are done, the stack itself, place by place.
class DealView extends CustomPainter {
  DealView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// The placing the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  static const words = ['on top', 'in the middle', 'at the bottom'];

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;

    // The felt.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.01, 0, size.width * 0.98, size.height), Radius.circular(pitch * 0.4)),
      Paint()..color = Palette.felt,
    );

    if (!play.dealsDone) {
      // The columns, the holding one washed warm.
      final columns = play.columns;
      final holding = play.holding;
      final wash = Rect.fromLTWH(
        metrics.columnsLeft + holding * pitch,
        metrics.columnsTop - pitch * 0.1,
        pitch,
        pitch * 9.2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(wash, Radius.circular(pitch * 0.3)),
        Paint()..color = Palette.holding,
      );
      for (var c = 0; c < 3; c++) {
        for (var r = 0; r < columns[c].length; r++) {
          _counter(canvas, metrics.counterAt(c, r), pitch, columns[c][r], columns[c][r] == play.walk.chosen);
        }
      }
      // The placings.
      for (var p = 0; p < 3; p++) {
        final rect = metrics.placings[p];
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.25)),
          Paint()..color = Palette.placing,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.25)),
          Paint()
            ..color = pointing == p ? Palette.shown : Palette.line
            ..style = PaintingStyle.stroke
            ..strokeWidth = pointing == p ? math.max(2, pitch * 0.08) : 1,
        );
        // Three little bars: the stack, the gold one where the
        // holding column goes.
        for (var i = 0; i < 3; i++) {
          final bar = Rect.fromLTWH(
            rect.left + rect.width * 0.12,
            rect.top + rect.height * (0.2 + i * 0.22),
            rect.width * 0.28,
            rect.height * 0.14,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(bar, Radius.circular(bar.height / 2)),
            Paint()..color = i == p ? Palette.chosen : Palette.counter.withValues(alpha: 0.5),
          );
        }
        _write(
          canvas,
          words[p],
          Offset(rect.left + rect.width * 0.7, rect.center.dy),
          labels.copyWith(
            color: Palette.placingInk,
            fontSize: math.max(9, math.min(rect.height * 0.28, rect.width * 0.11)),
            fontWeight: FontWeight.w600,
          ),
        );
      }
      _write(
        canvas,
        'deal ${play.placings.length + 1} of ${play.walk.deals}',
        Offset(metrics.placings[0].center.dx, metrics.columnsTop + pitch * 0.2),
        labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, pitch * 0.32)),
      );
      _write(
        canvas,
        'gather with the gold column',
        Offset(metrics.placings[2].center.dx, metrics.columnsTop + pitch * 8.8),
        labels.copyWith(color: Palette.inkDim, fontSize: math.max(8, pitch * 0.24)),
      );
    } else {
      // The stack, place by place, nine to a column reading down.
      final stack = play.stack;
      for (var i = 0; i < stack.length; i++) {
        final at = metrics.counterAt(i ~/ 9, i % 9);
        _counter(canvas, at, pitch, stack[i], stack[i] == play.walk.chosen);
        if (i == play.walk.place) {
          canvas.drawCircle(
            at,
            pitch * 0.46,
            Paint()
              ..color = Palette.asked
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(2, pitch * 0.07),
          );
        }
        // The place, small, in the disc's upper left.
        _write(
          canvas,
          '${i + 1}',
          at + Offset(-pitch * 0.2, -pitch * 0.24),
          labels.copyWith(color: Palette.counterInk.withValues(alpha: 0.6), fontSize: math.max(6, pitch * 0.15)),
        );
      }
      final right = metrics.placings[0].left;
      _write(
        canvas,
        'the stack, top to bottom',
        Offset((right + size.width) / 2, metrics.columnsTop + pitch * 0.5),
        labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, pitch * 0.28)),
      );
      _write(
        canvas,
        'place ${play.place + 1}',
        Offset((right + size.width) / 2, metrics.columnsTop + pitch * 1.6),
        labels.copyWith(color: Palette.chosen, fontSize: math.max(10, pitch * 0.4), fontWeight: FontWeight.w800),
      );
      _write(
        canvas,
        'asked ${play.walk.place + 1}',
        Offset((right + size.width) / 2, metrics.columnsTop + pitch * 2.4),
        labels.copyWith(color: Palette.asked, fontSize: math.max(10, pitch * 0.4), fontWeight: FontWeight.w800),
      );
    }
  }

  void _counter(Canvas canvas, Offset at, double pitch, int number, bool chosen) {
    canvas.drawCircle(at, pitch * 0.38, Paint()..color = chosen ? Palette.chosen : Palette.counter);
    canvas.drawCircle(
      at,
      pitch * 0.38,
      Paint()
        ..color = Palette.counterInk.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    _write(
      canvas,
      '${number + 1}',
      at,
      labels.copyWith(
        color: Palette.counterInk,
        fontSize: pitch * 0.34,
        fontWeight: chosen ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(DealView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a walk as it stands.
String whyWords(Play play) {
  final walk = play.walk;
  final note = walk.note == null ? '' : ' ${walk.note}';
  if (!walk.winnable) {
    return 'A deal sends the counter at place p, counted from nought, to '
        'row p over three of its column, and gathering puts that column '
        'first, second or third, so its new place is nine times the '
        'placing plus p over three. Twice over, its place is nine times '
        'the second placing plus three times the first plus its start '
        'over nine: the units are the start counted in nines, and no '
        'placing touches them. The sweep dealt all nine runs of two and '
        'found the top never reached.$note';
  }
  return 'The runs are counted by the sweep, every run of placings dealt '
      'out counter by counter, and held to a second voice: Gergonne\'s '
      'arithmetic, the placings read as digits in threes with the first '
      'deal the units, which names the place with no dealing at all and '
      'agrees with the dealing for every counter, every run and every '
      'place. ${walk.ways} run${walk.ways == 1 ? '' : 's'} of the 27 '
      'land${walk.ways == 1 ? 's' : ''} this walk.$note';
}

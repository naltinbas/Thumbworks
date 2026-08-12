import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../watch/play.dart';
import '../watch/rules.dart';
import 'palette.dart';

/// Where every watch lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    hour = room.width * 0.88 / Rules.day;
    left = (room.width - hour * Rules.day) / 2;
    final rows = play.starts.length;
    rowHigh = math.min(hour * 1.3, room.height * 0.6 / rows);
    top = (room.height - rowHigh * rows) / 2;
  }

  final Play play;

  late final double hour;
  late final double left;
  late final double rowHigh;
  late final double top;

  /// A watch's bar, on its own row.
  Rect barOf(int watch) => Rect.fromLTWH(
        left + play.starts[watch] * hour,
        top + watch * rowHigh + rowHigh * 0.18,
        play.rules.lengths[watch] * hour,
        rowHigh * 0.64,
      );

  /// The watch under a touch and whether the touch sat in the
  /// bar's left half, or null for the wall.
  (int, bool)? watchUnder(Offset touch) {
    for (var watch = 0; watch < play.starts.length; watch++) {
      final bar = barOf(watch).inflate(rowHigh * 0.12);
      if (bar.contains(touch)) {
        return (watch, touch.dx < bar.center.dx);
      }
    }
    return null;
  }
}

/// The night wall, drawn: hour lines, shared hours washed
/// gold, and every watch on its row.
class WatchView extends CustomPainter {
  WatchView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The slide the show-me points at, or null.
  final (int, bool)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final hour = metrics.hour;
    final rows = play.starts.length;
    final wallTop = metrics.top - metrics.rowHigh * 0.2;
    final wallHigh =
        metrics.rowHigh * rows + metrics.rowHigh * 0.4;

    canvas.drawRect(
      Rect.fromLTWH(metrics.left, wallTop, hour * Rules.day, wallHigh),
      Paint()..color = Palette.wall,
    );

    // The shared hours, washed gold the whole wall down.
    final held = play.common;
    if (held != null) {
      final wash = Rect.fromLTWH(
        metrics.left + held.$1 * hour,
        wallTop,
        (held.$2 - held.$1 + 1) * hour,
        wallHigh,
      );
      canvas.drawRect(wash, Paint()..color = Palette.shared);
      canvas.drawRect(
        wash,
        Paint()
          ..color = Palette.sharedRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // The hour lines and their numbers.
    for (var h = 0; h <= Rules.day; h++) {
      final x = metrics.left + h * hour;
      canvas.drawLine(
        Offset(x, wallTop),
        Offset(x, wallTop + wallHigh),
        Paint()
          ..color = Palette.line
          ..strokeWidth = 1.0,
      );
      if (h < Rules.day) {
        final word = TextPainter(
          text: TextSpan(
            text: '$h',
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: hour * 0.34,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        word.paint(
          canvas,
          Offset(x + hour / 2 - word.width / 2,
              wallTop + wallHigh + hour * 0.14),
        );
      }
    }

    // The watches.
    for (var watch = 0; watch < rows; watch++) {
      final bar = metrics.barOf(watch);
      final round = RRect.fromRectAndRadius(
          bar, Radius.circular(bar.height * 0.4));
      canvas.drawRRect(round, Paint()..color = Palette.watchBar);
      canvas.drawRRect(
        round,
        Paint()
          ..color = Palette.watchRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      canvas.drawCircle(
        Offset(bar.left + bar.height * 0.5, bar.center.dy),
        bar.height * 0.26,
        Paint()..color = Palette.lantern,
      );

      final aim = pointing;
      if (aim != null && aim.$1 == watch) {
        final atRight = aim.$2;
        final x = atRight ? bar.right + hour * 0.3 : bar.left - hour * 0.3;
        final way = atRight ? 1.0 : -1.0;
        canvas.drawPath(
          Path()
            ..moveTo(x + way * hour * 0.22, bar.center.dy)
            ..lineTo(x - way * hour * 0.08, bar.center.dy - hour * 0.22)
            ..lineTo(x - way * hour * 0.08, bar.center.dy + hour * 0.22)
            ..close(),
          Paint()..color = Palette.shown,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bar.inflate(hour * 0.12),
              Radius.circular(bar.height * 0.5)),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(WatchView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the mere at hand.
String whyWords(Play play) {
  final mere = play.mere;
  final note = mere.note == null ? '' : ' ${mere.note}';
  final sweep = mere.lengths.length == 3 ? '729' : withComma(5040);
  if (!mere.winnable) {
    return 'Name two watches before a lantern is slid: the one '
        'that rises latest, and the one that turns in earliest. '
        'They are a pair like any other, so they must overlap, '
        'and every hour they share starts no earlier than every '
        'rise and ends no later than every turning-in: it sits '
        'inside every watch on the wall. The sweep slid all '
        '$sweep diallings and the full ring never once went '
        'without a shared hour.$note';
  }
  return 'The night is read two ways that share nothing: the '
      'pair census checks every two watches for an hour in both, '
      'and the arithmetic takes the latest rise and the earliest '
      'turning-in with no searching at all. The sweep slides all '
      '$sweep diallings of the wall and the two never part. '
      '${withComma(mere.ways)} dialling${mere.ways == 1 ? '' : 's'} '
      'land${mere.ways == 1 ? 's' : ''} this mere.$note';
}

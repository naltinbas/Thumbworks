import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../hoard/play.dart';
import 'palette.dart';

/// Where every nut lies, shared by the painter and the hit-testing, so
/// where the hoard is drawn is exactly where the hoard is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    perRow = 8;
    final rows = ((play.hoard.nuts + perRow - 1) / perRow).ceil();
    nut = math.min(width / (perRow + 1.2), height / (rows + 3.2));
    across = nut * perRow;
    left = (width - across) / 2;
    top = math.max(nut, height * 0.14);
  }

  final Play play;

  late final double width;
  late final double height;
  late final int perRow;
  late final double nut;
  late final double across;
  late final double left;
  late final double top;

  /// Where the so-manyth nut of the standing hoard lies.
  Offset nutAt(int which) {
    final row = which ~/ perRow;
    final column = which % perRow;
    return Offset(
      left + (column + 0.5) * nut,
      top + (row + 0.5) * nut * 1.06,
    );
  }

  /// Whether a touch lands on the hoard at all.
  bool onHoard(Offset touch) {
    final rows = ((play.nuts + perRow - 1) / perRow).ceil();
    return touch.dx >= left - nut &&
        touch.dx <= left + across + nut &&
        touch.dy >= top - nut &&
        touch.dy <= top + rows * nut * 1.06 + nut;
  }
}

/// The hoard, drawn.
class HoardView extends CustomPainter {
  HoardView({
    required this.play,
    required this.pending,
    required this.showClusters,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// Nuts marked for taking, drawn from the end of the hoard.
  final int pending;

  /// Whether to ring the Zeckendorf clusters.
  final bool showClusters;

  /// Whether counts may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    if (showClusters) {
      _clusters(canvas, metrics);
    }
    for (var which = 0; which < play.nuts; which++) {
      _nut(canvas, metrics, which,
          marked: which >= play.nuts - pending);
    }
  }

  void _nut(Canvas canvas, Metrics metrics, int which,
      {required bool marked}) {
    final where = metrics.nutAt(which);
    final size = metrics.nut * 0.42;

    // The shell: a round nut with a pale scar at the base.
    canvas.drawCircle(where, size, Paint()..color = Palette.shell);
    canvas.drawCircle(
      where + Offset(-size * 0.28, -size * 0.3),
      size * 0.42,
      Paint()..color = Palette.sheen,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: where + Offset(0, size * 0.62),
        width: size * 0.8,
        height: size * 0.5,
      ),
      Paint()..color = Palette.scar,
    );

    if (marked) {
      canvas.drawCircle(
        where,
        size * 1.28,
        Paint()
          ..color = Palette.marked
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }
  }

  static const _ringColours = [Palette.cluster, Palette.marked];

  void _clusters(Canvas canvas, Metrics metrics) {
    // The split, ringed over the hoard from its start: the biggest
    // cluster first, matching how the nuts lie, neighbours told apart
    // by colour.
    var from = 0;
    var which = 0;
    for (final cluster in play.clusters) {
      final colour = _ringColours[which % _ringColours.length];
      which++;
      // The ring: a rounded sweep over the rows this cluster covers.
      final firstRow = from ~/ metrics.perRow;
      final lastRow = (from + cluster - 1) ~/ metrics.perRow;
      for (var row = firstRow; row <= lastRow; row++) {
        final rowStart = row == firstRow ? from % metrics.perRow : 0;
        final rowEnd = row == lastRow
            ? (from + cluster - 1) % metrics.perRow
            : metrics.perRow - 1;
        final a = metrics.nutAt(row * metrics.perRow + rowStart);
        final b = metrics.nutAt(row * metrics.perRow + rowEnd);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              a - Offset(metrics.nut * 0.46, metrics.nut * 0.46),
              b + Offset(metrics.nut * 0.46, metrics.nut * 0.46),
            ),
            Radius.circular(metrics.nut * 0.46),
          ),
          Paint()
            ..color = colour
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2,
        );
      }
      if (showWords) {
        final tag = metrics.nutAt(from);
        final words = TextPainter(
          text: TextSpan(
            text: '$cluster',
            style: labels.copyWith(
              color: colour,
              fontSize: metrics.nut * 0.48,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        // On a chip, above the cluster's first nut, so no nut hides it.
        final at = tag + Offset(-words.width / 2, -metrics.nut * 1.06);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(at.dx - 4, at.dy - 1, words.width + 8,
                words.height + 2),
            const Radius.circular(5),
          ),
          Paint()..color = Palette.wood,
        );
        words.paint(canvas, at);
      }
      from += cluster;
    }
  }

  @override
  bool shouldRepaint(HoardView old) =>
      old.play != play ||
      old.pending != pending ||
      old.showClusters != showClusters;
}

/// The words the why speaks, from the hoard at hand.
String whyWords(Play play) {
  final clusters = play.clusters;
  final said = clusters.join(' and ');
  final smallest = clusters.last;
  final start = 'Every count of nuts splits one way into Fibonacci '
      'clusters, no two of them neighbours in the run. What stands here '
      'splits into $said.';
  final verdict = smallest <= play.cap
      ? ' The smallest cluster is $smallest and the cap allows it: take '
          'exactly that, and whatever the grey squirrel does, your next '
          'smallest cluster is always in reach and its never is.'
      : ' The smallest cluster is $smallest and the cap is ${play.cap}: '
          'out of reach, and every take you do have hands the grey '
          'squirrel a split it can work.';
  final note = play.hoard.note;
  return '$start$verdict${note == null ? '' : ' $note'}';
}

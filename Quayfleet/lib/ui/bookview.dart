import 'package:flutter/material.dart';

import '../berth/play.dart';
import 'palette.dart';

/// Where everything in the book is.
///
/// The painter and the finger both use this, which is the point of it: a ship
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    final quay = play.quay;
    scale = 26;
    across = (room.width - _margin * 2) / (quay.shuts - quay.opens);
    row = ((room.height - scale) / quay.count).clamp(0.0, 54.0);
    top = scale + (room.height - scale - row * quay.count) / 2;
  }

  static const _margin = 6.0;

  final Play play;

  /// How tall the row of hours along the top is.
  late final double scale;

  /// How wide one hour is drawn.
  late final double across;

  /// How tall one ship's line in the book is.
  late final double row;

  late final double top;

  double xOf(int hour) => _margin + (hour - play.quay.opens) * across;

  /// The ships in the order they are drawn, earliest alongside first, which is
  /// the order the book would be written in.
  late final List<int> order = () {
    final ships = [for (var ship = 0; ship < play.quay.count; ship++) ship];
    ships.sort((one, other) {
      final by = play.quay[one].from.compareTo(play.quay[other].from);
      if (by != 0) return by;
      final then = play.quay[one].to.compareTo(play.quay[other].to);
      return then != 0 ? then : one.compareTo(other);
    });
    return ships;
  }();

  Rect barOf(int ship) {
    final line = order.indexOf(ship);
    return Rect.fromLTRB(
      xOf(play.quay[ship].from) + 1.5,
      top + line * row + row * 0.14,
      xOf(play.quay[ship].to) - 1.5,
      top + (line + 1) * row - row * 0.14,
    );
  }

  /// The ship under a point, or -1. Anywhere along a ship's line counts, so a
  /// short stay is no harder to hit than a long one.
  int shipAt(Offset touch) {
    final line = ((touch.dy - top) / row).floor();
    if (line < 0 || line >= order.length) return -1;
    return order[line];
  }
}

/// The book: the day across the top, and a line for every ship in it.
class BookView extends CustomPainter {
  const BookView({
    required this.play,
    required this.pointing,
    required this.showMarks,
    required this.labels,
    this.showNames = true,
  });

  final Play play;

  /// A ship the game is pointing at, or -1.
  final int pointing;

  /// Whether to draw the hours that prove the day cannot be better, which is
  /// what the game shows when it is asked why.
  final bool showMarks;

  /// The style the names are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the ships.
  final bool showNames;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final quay = play.quay;

    if (showMarks) {
      for (final hour in play.answer.marks) {
        canvas.drawRect(
          Rect.fromLTRB(
            metrics.xOf(hour),
            metrics.top - metrics.scale * 0.5,
            metrics.xOf(hour + 1),
            metrics.top + metrics.row * quay.count,
          ),
          Paint()..color = Palette.tide.withValues(alpha: 0.17),
        );
      }
    }

    if (showNames) {
      for (var hour = quay.opens; hour <= quay.shuts; hour++) {
        canvas.drawLine(
          Offset(metrics.xOf(hour), metrics.top - metrics.scale * 0.42),
          Offset(metrics.xOf(hour), metrics.top + metrics.row * quay.count),
          Paint()
            ..color = Palette.line
            ..strokeWidth = 1,
        );
        if (hour == quay.shuts) continue;
        final number = TextPainter(
          text: TextSpan(
            text: '$hour',
            style: labels.copyWith(
              color: showMarks && play.answer.marks.contains(hour)
                  ? Palette.tide
                  : Palette.inkDim,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        number.paint(
          canvas,
          Offset(
            (metrics.xOf(hour) + metrics.xOf(hour + 1)) / 2 - number.width / 2,
            metrics.top - metrics.scale * 0.94,
          ),
        );
      }
    }

    for (final ship in metrics.order) {
      final bar = metrics.barOf(ship);
      final has = play.has(ship);
      final blocked = !has && !play.canTake(ship);

      canvas.drawRRect(
        RRect.fromRectAndRadius(bar, Radius.circular(metrics.row * 0.2)),
        Paint()
          ..color = has
              ? Palette.berthed
              : blocked
                  ? Palette.turned
                  : Palette.waiting,
      );
      if (blocked || ship == pointing) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(bar, Radius.circular(metrics.row * 0.2)),
          Paint()
            ..color = ship == pointing ? Palette.ink : Palette.bad
            ..style = PaintingStyle.stroke
            ..strokeWidth = ship == pointing ? 2.4 : 1.3,
        );
      }

      if (!showNames) continue;
      final name = TextPainter(
        text: TextSpan(
          text: quay[ship].name,
          style: labels.copyWith(
            color: has
                ? Palette.night
                : blocked
                    ? Palette.inkDim
                    : Palette.ink,
            fontWeight: has ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Inside the bar when it fits, and just off the end of it when it does
      // not, so a one hour stay is still readable.
      final inside = name.width < bar.width - 10;
      name.paint(
        canvas,
        Offset(
          inside ? bar.left + 7 : bar.right + 7,
          bar.center.dy - name.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(BookView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showMarks != showMarks;
}

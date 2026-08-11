import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../row/play.dart';
import 'palette.dart';

/// Where every seat lies, shared by the painter and the hit-testing, so
/// where a seat is drawn is exactly where a seat is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    seat = math.min((width - 16) / play.level.seats, height * 0.16);
    across = seat * play.level.seats;
    left = (width - across) / 2;
    shelfY = height * 0.62;
    trayY = height * 0.26;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double seat;
  late final double across;
  late final double left;

  /// Where the shelf row sits, and where the pair in hand floats.
  late final double shelfY;
  late final double trayY;

  Rect seatRect(int number) => Rect.fromLTWH(
        left + number * seat,
        shelfY - seat * 1.35,
        seat,
        seat * 1.35,
      );

  /// The seat under a touch, or -1 for nowhere.
  int seatAt(Offset touch) {
    if (touch.dy < shelfY - seat * 2.2 || touch.dy > shelfY + seat) {
      return -1;
    }
    final number = ((touch.dx - left) / seat).floor();
    if (number < 0 || number >= play.level.seats) return -1;
    return number;
  }
}

/// The shelf, drawn.
class RowView extends CustomPainter {
  RowView({
    required this.play,
    required this.pointing,
    required this.showSums,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The seat being pointed at, or -1.
  final int pointing;

  /// Whether to number the seats large, for the arithmetic.
  final bool showSums;

  /// Whether numbers may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    _shelf(canvas, metrics);
    for (var seat = 0; seat < play.level.seats; seat++) {
      _seat(canvas, metrics, seat);
    }
    if (!play.isSet) _tray(canvas, metrics);
    if (pointing >= 0) _point(canvas, metrics);
  }

  void _shelf(Canvas canvas, Metrics metrics) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          metrics.left - 6,
          metrics.shelfY,
          metrics.across + 12,
          math.max(4.0, metrics.seat * 0.18),
        ),
        const Radius.circular(3),
      ),
      Paint()..color = Palette.shelf,
    );
  }

  void _block(Canvas canvas, Rect rect, int pair, {double alpha = 1}) {
    final round = RRect.fromRectAndRadius(
      rect.deflate(rect.width * 0.06),
      Radius.circular(rect.width * 0.18),
    );
    canvas.drawRRect(
      round,
      Paint()
        ..color = Palette.blocks[(pair - 1) % Palette.blocks.length]
            .withValues(alpha: alpha),
    );
    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '$pair',
        style: labels.copyWith(
          color: Palette.floor.withValues(alpha: alpha),
          fontSize: rect.width * 0.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      rect.center - Offset(words.width / 2, words.height / 2),
    );
  }

  void _seat(Canvas canvas, Metrics metrics, int number) {
    final rect = metrics.seatRect(number);
    final pair = play.row[number];

    if (pair == 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(rect.width * 0.08),
          Radius.circular(rect.width * 0.16),
        ),
        Paint()
          ..color = Palette.seat
          ..style = PaintingStyle.fill,
      );
    } else {
      _block(canvas, rect, pair);
    }

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '${number + 1}',
        style: labels.copyWith(
          color: showSums ? Palette.ink : Palette.inkDim,
          fontSize: metrics.seat * (showSums ? 0.44 : 0.34),
          fontWeight: showSums ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      Offset(
        rect.center.dx - words.width / 2,
        metrics.shelfY + metrics.seat * 0.3,
      ),
    );
  }

  void _tray(Canvas canvas, Metrics metrics) {
    // The pair in hand: its two blocks with the span it demands between
    // them, floating over the shelf.
    final pair = play.placing;
    final wide = metrics.seat;
    final span = pair + 1;
    final acrossAll = wide * (span + 1);
    final left = (metrics.width - acrossAll) / 2;
    final top = metrics.trayY;

    _block(canvas, Rect.fromLTWH(left, top, wide, wide * 1.35), pair);
    _block(
      canvas,
      Rect.fromLTWH(left + wide * span, top, wide, wide * 1.35),
      pair,
    );

    // The span, said as a brace between them.
    final brace = Paint()
      ..color = Palette.inkDim
      ..strokeWidth = 1.6;
    final y = top + wide * 1.5;
    canvas.drawLine(
      Offset(left + wide * 1.1, y),
      Offset(left + wide * (span - 0.1), y),
      brace,
    );
    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '$pair between',
        style: labels.copyWith(
          color: Palette.inkDim,
          fontSize: wide * 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      Offset(metrics.width / 2 - words.width / 2, y + 4),
    );
  }

  void _point(Canvas canvas, Metrics metrics) {
    final rect = metrics.seatRect(pointing);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(3),
        Radius.circular(rect.width * 0.2),
      ),
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(RowView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showSums != showSums;
}

/// The words the why speaks, from the shelf at hand.
String whyWords(Play play) {
  final pairs = play.level.pairs;
  final seats = play.level.seats;
  final seatSum = seats * (seats + 1) ~/ 2;
  final spanSum = pairs * (pairs + 1) ~/ 2 + pairs;
  final start = 'Number the seats one to $seats and add them: $seatSum. '
      'Each pair of k sits at two seats adding to twice-something plus k '
      'plus one, so the whole shelf adds to an even number plus the k '
      'plus ones, which come to $spanSum. So $seatSum minus $spanSum must '
      'be even.';
  final verdict = (seatSum - spanSum).isEven
      ? ' Here it is ${seatSum - spanSum}: even, and the shelf can be '
          'set, which the search confirms by setting it.'
      : ' Here it is ${seatSum - spanSum}: odd. No setting exists, and no '
          'search was needed to know it.';
  final note = play.level.note;
  return '$start$verdict${note == null ? '' : ' $note'}';
}

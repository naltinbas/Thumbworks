import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shelf/play.dart';
import 'palette.dart';

/// Where every book stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    slot = math.min(
      room.width * 0.84 / play.shelf.books,
      room.height * 0.22,
    );
    left = (room.width - slot * play.shelf.books) / 2;
    shelfLine = room.height * 0.58;
  }

  final Play play;

  late final double slot;
  late final double left;
  late final double shelfLine;

  /// The rectangle of the book at [place], its height by its own.
  Rect bookAt(int place) {
    final height = play.order[place] + 1;
    final tall = slot * (0.9 + 0.55 * height);
    return Rect.fromLTWH(
      left + place * slot + slot * 0.12,
      shelfLine - tall,
      slot * 0.76,
      tall,
    );
  }

  /// The place under a touch, or -1.
  int placeUnder(Offset touch) {
    for (var at = 0; at < play.shelf.books; at++) {
      final book = bookAt(at);
      if (book.inflate(slot * 0.1).contains(touch)) return at;
    }
    return -1;
  }
}

/// The shelf, drawn.
class ShelfView extends CustomPainter {
  ShelfView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The place and book the show-me points at, or null.
  final (int, int)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The shelf plank.
    canvas.drawRect(
      Rect.fromLTWH(
        metrics.left - metrics.slot * 0.2,
        metrics.shelfLine,
        metrics.slot * play.shelf.books + metrics.slot * 0.4,
        metrics.slot * 0.16,
      ),
      Paint()..color = Palette.wood,
    );

    // The books.
    for (var place = 0; place < play.shelf.books; place++) {
      final book = metrics.bookAt(place);
      final height = play.order[place];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            book, Radius.circular(metrics.slot * 0.06)),
        Paint()..color = Palette.spines[height],
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            book, Radius.circular(metrics.slot * 0.06)),
        Paint()
          ..color = play.picked == place
              ? Palette.shown
              : Palette.night.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = play.picked == place ? 3.0 : 1.4,
      );
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: '${height + 1}',
            style: labels.copyWith(
              color: Palette.night,
              fontSize: metrics.slot * 0.24,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(
          canvas,
          Offset(book.center.dx - words.width / 2,
              book.top + metrics.slot * 0.1),
        );
      }
    }

    // Every step down, called out between the spines.
    for (final at in play.stepsDown) {
      final from = metrics.bookAt(at);
      final to = metrics.bookAt(at + 1);
      final drop = Path()
        ..moveTo(from.right - metrics.slot * 0.06, from.top)
        ..lineTo(to.left + metrics.slot * 0.5, from.top)
        ..lineTo(to.left + metrics.slot * 0.5,
            to.top - metrics.slot * 0.1);
      canvas.drawPath(
        drop,
        Paint()
          ..color = Palette.step
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round,
      );
      // The arrowhead.
      final tip =
          Offset(to.left + metrics.slot * 0.5, to.top - metrics.slot * 0.06);
      canvas.drawPath(
        Path()
          ..moveTo(tip.dx - metrics.slot * 0.08, tip.dy - metrics.slot * 0.12)
          ..lineTo(tip.dx, tip.dy)
          ..lineTo(tip.dx + metrics.slot * 0.08,
              tip.dy - metrics.slot * 0.12),
        Paint()
          ..color = Palette.step
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointed place.
    final aim = pointing;
    if (aim != null) {
      final book = metrics.bookAt(aim.$1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          book.inflate(metrics.slot * 0.12),
          Radius.circular(metrics.slot * 0.1),
        ),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }
  }

  @override
  bool shouldRepaint(ShelfView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the shelf at hand.
String whyWords(Play play) {
  final shelf = play.shelf;
  var everyOrder = 1;
  for (var at = 2; at <= shelf.books; at++) {
    everyOrder *= at;
  }
  final note = shelf.note == null ? '' : ' ${shelf.note}';
  if (!shelf.winnable) {
    return 'Four books stand over three gaps, and every step '
        'down lives in a gap of its own: ${shelf.asked} steps '
        'have nowhere to stand. The sweep shelved all '
        '$everyOrder orderings and read the steps off each, and '
        'the count never passed ${shelf.books - 1}.$note';
  }
  return 'The step counts are checked three ways that share '
      'nothing: the sweep shelves all $everyOrder orderings and '
      'reads each one, Euler\'s recurrence builds the row from '
      'the shelf one book shorter, and reversing any ordering '
      'swaps its steps for the gaps left over. '
      '${shelf.ways} ordering${shelf.ways == 1 ? '' : 's'} '
      'land${shelf.ways == 1 ? 's' : ''} this asking.$note';
}

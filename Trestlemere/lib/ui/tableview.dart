import 'dart:math';

import 'package:flutter/material.dart';

import '../table/play.dart';
import '../table/rules.dart';
import 'palette.dart';

/// Where the trestles stand in a board of a given size.
///
/// Six trestles in two rows of three, each a board on legs with its
/// guests seated along it. A trestle nobody sits at is drawn bare, since
/// an empty table is no table at all.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 20.0;
    final room = Size(
      max(size.width - 16, 8),
      max(size.height - words - 16, 8),
    );
    cellWidth = room.width / 3;
    cellHeight = max(min(room.height / 2, cellWidth * 1.05), 8);
    left = 8;
    top = 8 + max((room.height - cellHeight * 2) / 2, 0);
    boardWidth = cellWidth * 0.84;
    boardHeight = max(cellHeight * 0.20, 3);
    seat = max(min(boardWidth * 0.13, bare ? 20.0 : 13.0), 2);
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double cellWidth, cellHeight, left, top;
  late final double boardWidth, boardHeight, seat;

  /// Whether there is room for words under the hall.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  /// The middle of a trestle.
  Offset trestle(int t) => Offset(
        left + (t % 3 + 0.5) * cellWidth,
        top + (t ~/ 3 + 0.5) * cellHeight,
      );

  /// The board of a trestle, which is the thing a guest is dropped onto.
  Rect boardOf(int t) => Rect.fromCenter(
        center: trestle(t) + Offset(0, boardHeight),
        width: boardWidth,
        height: boardHeight,
      );

  /// Where a guest sits: along the trestle they are at, in the order
  /// they were given.
  Offset seatOf(int guest) {
    final t = play.seats[guest];
    final here = [
      for (var g = 0; g < Rules.guests; g++)
        if (play.seats[g] == t) g,
    ];
    final which = here.indexOf(guest);
    final board = boardOf(t);
    final step = boardWidth / (here.length + 1);
    return Offset(board.left + step * (which + 1),
        board.top - seat * 1.15);
  }

  /// The guest a tap means, or null when it lands on none.
  int? guestNear(Offset touch) {
    int? best;
    var away = seat * 1.6;
    for (var g = 0; g < Rules.guests; g++) {
      final d = (seatOf(g) - touch).distance;
      if (d < away) {
        away = d;
        best = g;
      }
    }
    return best;
  }

  /// The trestle a tap means, or null when it lands on none.
  int? trestleNear(Offset touch) {
    for (var t = 0; t < Play.trestles; t++) {
      if (boardOf(t).inflate(seat * 1.3).contains(touch)) return t;
    }
    return null;
  }
}

/// The hall, its trestles and the guests seated along them.
class TableView extends CustomPainter {
  const TableView({
    required this.play,
    this.holding,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The guest the hand has hold of, or null.
  final int? holding;

  /// The guest and trestle the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the hall alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final counts = List.filled(Play.trestles, 0);
    for (final t in play.seats) {
      counts[t]++;
    }

    for (var t = 0; t < Play.trestles; t++) {
      final board = m.boardOf(t);
      final here = counts[t];
      // The board itself, and two legs under it.
      canvas.drawRect(
        board,
        Paint()..color = here == 0 ? Palette.bare : Palette.trestle,
      );
      final legPaint = Paint()
        ..color = here == 0 ? Palette.bare : Palette.trestle
        ..strokeWidth = max(m.boardHeight * 0.35, 1.5);
      for (final x in [board.left + board.width * 0.18,
        board.right - board.width * 0.18]) {
        canvas.drawLine(Offset(x, board.bottom),
            Offset(x, board.bottom + m.cellHeight * 0.16), legPaint);
      }
      if (!bare && pointing != null && pointing!.$2 == t) {
        canvas.drawRect(
          board.inflate(m.seat * 0.7),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      if (!bare && m.roomy) {
        _word(canvas, here == 0 ? 'bare' : '$here',
            Offset(board.center.dx, board.bottom + m.cellHeight * 0.26),
            here == 0 ? Palette.inkDim : Palette.trestle, size, 10);
      }
    }

    // The guests, coloured by whether they are sitting on their own.
    for (var g = 0; g < Rules.guests; g++) {
      final at = m.seatOf(g);
      final lonely = counts[play.seats[g]] == 1;
      canvas.drawCircle(at, m.seat,
          Paint()..color = lonely ? Palette.alone : Palette.guest);
      if (!bare) {
        _word(canvas, Rules.name(g), at, Palette.night, size, m.seat * 1.1);
      }
      if (!bare && (holding == g || pointing?.$1 == g)) {
        canvas.drawCircle(
          at,
          m.seat * 1.5,
          Paint()
            ..color = holding == g ? Palette.ink : Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    if (bare || !m.roomy) return;
    final sizes = play.sizes;
    _word(
      canvas,
      '${play.laid} ${play.laid == 1 ? 'table' : 'tables'}: '
          '${sizes.join(', ')}',
      Offset(size.width / 2, size.height - 8),
      Palette.inkDim,
      size,
      10,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(TableView old) =>
      old.play.seats.toString() != play.seats.toString() ||
      old.play.level != play.level ||
      old.holding != holding ||
      old.pointing != pointing ||
      old.bare != bare;
}

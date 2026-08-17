import 'dart:math';

import 'package:flutter/material.dart';

import '../beat/play.dart';
import '../beat/rules.dart';
import 'palette.dart';

/// Where the flight chart sits in a board of a given size.
///
/// The chart runs two periods across, ten columns, so that a flight can
/// be drawn straight out from the beat it left to the beat it comes
/// down on without wrapping round. The first five columns are the ring
/// itself and take taps; the five after are the same pattern coming
/// round again, drawn dim.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 20.0;
    // An icon is drawn at whatever size a launcher asks for, down to a
    // few points across, so every measure is kept above nothing.
    final room = Size(
      max(size.width - 16, 8),
      max(size.height - words - 16, 8),
    );
    columns = Rules.beats * 2;
    column = room.width / columns;
    left = 8;
    hand = max(min(column * 0.78, bare ? 40.0 : 26.0), 2);
    flights = _flights();
    rows = _rowsFor(flights);
    final piled = rows.isEmpty ? 1 : rows.reduce(max) + 1;
    if (bare) {
      // The mark carries nothing but the chart and the beats, so the two
      // are set in the middle of the frame with the bars drawn boldly.
      rowHeight = max(min(column * 1.4, room.height / (piled + 2)), 2);
      final block = (piled + 0.6) * rowHeight + 10 + hand;
      final top = 8 + max((room.height - block) / 2, 0);
      floor = top + (piled + 0.6) * rowHeight;
      handTop = floor + 10;
    } else {
      handTop = max(8 + room.height - hand - 16, 10);
      floor = max(handTop - 6, 8);
      // The pile is drawn to fill the chart, so that its height reads as
      // the balls in the air rather than as whatever room was left over.
      rowHeight = max(min((floor - 12) / piled, column * 1.1), 2);
    }
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final int columns;
  late final double column, left, hand, handTop, rowHeight, floor;

  /// The flights to draw and the row each is stacked on.
  late final List<(int, int, int)> flights;
  late final List<int> rows;

  /// Whether there is room for words under the chart.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  double middleOf(int column) => left + (column + 0.5) * this.column;

  /// Where a beat's own tile sits, for the five beats of the ring.
  Rect handAt(int beat) => Rect.fromCenter(
        center: Offset(middleOf(beat), handTop + hand / 2),
        width: hand,
        height: hand,
      );

  /// The flights to draw: the column thrown from, the column come down
  /// on, and which beat of the ring threw it. A flight that would run
  /// off the right of the chart is cut there.
  List<(int, int, int)> _flights() {
    final out = <(int, int, int)>[];
    for (var j = 0; j < columns; j++) {
      final beat = j % Rules.beats;
      final h = play.laid[beat];
      if (h <= 0) continue;
      if (j + h > columns) {
        out.add((j, columns, beat));
      } else {
        out.add((j, j + h, beat));
      }
    }
    return out;
  }

  /// Which row each flight is drawn on, so that flights in the air at
  /// the same time are stacked rather than laid over one another. The
  /// height of the stack at any moment is the balls in the air.
  List<int> _rowsFor(List<(int, int, int)> flights) {
    final ends = <double>[];
    final rows = <int>[];
    for (final f in flights) {
      var row = 0;
      while (row < ends.length && ends[row] > f.$1) {
        row++;
      }
      if (row == ends.length) ends.add(0);
      ends[row] = f.$2.toDouble();
      rows.add(row);
    }
    return rows;
  }

  /// The beat a tap means, or null when it lands on no tile of the ring.
  int? beatNear(Offset touch) {
    for (var b = 0; b < Rules.beats; b++) {
      if (handAt(b).inflate(4).contains(touch)) return b;
    }
    return null;
  }
}

/// The ring of beats, the throws laid on them, and the flights they make.
class BeatView extends CustomPainter {
  const BeatView({
    required this.play,
    this.pointing,
    this.showWhyNot = false,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The beat the show-me points at, or null.
  final int? pointing;

  /// Whether to say out loud that the throws will not go round evenly.
  final bool showWhyNot;

  final TextStyle labels;

  /// Whether to draw the chart alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final flights = m.flights;
    final rows = m.rows;
    final arrivals = play.arrivals;

    // The columns: the ring, then the same pattern coming round again.
    // The box is only as tall as the pile of flights needs, so that the
    // height of the pile reads as the balls in the air.
    final piled = rows.isEmpty ? 1 : rows.reduce(max) + 1;
    final ceiling = max(m.floor - (piled + 0.6) * m.rowHeight, 6.0);
    for (var j = 0; j < m.columns; j++) {
      final own = j < Rules.beats;
      canvas.drawRect(
        Rect.fromLTRB(m.left + j * m.column + 1, ceiling,
            m.left + (j + 1) * m.column - 1, m.floor),
        Paint()..color = own ? Palette.beat : Palette.repeat,
      );
    }

    // The flights, each a bar from the beat it left to the beat it comes
    // down on, stacked so that the height of the pile at any moment is
    // the balls in the air.
    for (var k = 0; k < flights.length; k++) {
      final (from, to, beat) = flights[k];
      final y = m.floor - (rows[k] + 1) * m.rowHeight + m.rowHeight * 0.25;
      final clash = arrivals[Rules.lands(beat, play.laid[beat])] > 1;
      final bar = RRect.fromRectAndRadius(
        Rect.fromLTRB(m.middleOf(from), y,
            to >= m.columns ? m.left + m.columns * m.column : m.middleOf(to),
            y + m.rowHeight * 0.5),
        Radius.circular(m.rowHeight * 0.25),
      );
      canvas.drawRRect(
        bar,
        Paint()
          ..color = (clash ? Palette.drop : Palette.flight)
              .withValues(alpha: from < Rules.beats ? 0.9 : 0.4),
      );
      // The ball coming down, drawn at the far end of its flight.
      if (to < m.columns) {
        canvas.drawCircle(
          Offset(m.middleOf(to), y + m.rowHeight * 0.25),
          m.rowHeight * 0.22,
          Paint()
            ..color = clash ? Palette.drop : Palette.tile
            ..style = from < Rules.beats
                ? PaintingStyle.fill
                : PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
      }
    }

    // The ring's own beats, each with the throw laid on it.
    for (var b = 0; b < Rules.beats; b++) {
      final at = m.handAt(b);
      final h = play.laid[b];
      final clash = h >= 0 && arrivals[Rules.lands(b, h)] > 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(at, Radius.circular(m.hand * 0.22)),
        Paint()
          ..color = h < 0
              ? Palette.beat
              : h == 0
                  ? Palette.rest
                  : Palette.tile,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(at, Radius.circular(m.hand * 0.22)),
        Paint()
          ..color = clash
              ? Palette.drop
              : h < 0
                  ? Palette.line
                  : Palette.tile
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 2.4 : 1.4,
      );
      if (!bare) {
        _word(canvas, h < 0 ? '' : '$h', at.center,
            h > 0 ? Palette.night : Palette.ink, size, m.hand * 0.5);
        _word(canvas, '$b', Offset(at.center.dx, m.handTop + m.hand + 8),
            Palette.inkDim, size, 9);
      }
      if (!bare && pointing == b) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(at.inflate(4), Radius.circular(m.hand * 0.3)),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    if (bare || !m.roomy) return;
    final up = play.full ? play.aloft : const <int>[];
    final steady = up.isNotEmpty && up.every((n) => n == up.first);
    _word(
      canvas,
      showWhyNot
          ? 'four throws down, and the fifth fits on no beat left'
          : play.full
              ? (steady
                  ? '${up.first} balls in the air, beat after beat'
                  : 'balls in the air: ${up.join(', ')}')
              : 'the pile at any moment is the balls in the air',
      Offset(size.width / 2, size.height - 8),
      Palette.inkDim,
      size,
      10,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    if (words.isEmpty) return;
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
  bool shouldRepaint(BeatView old) =>
      old.play.mark != play.mark ||
      old.play.held != play.held ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showWhyNot != showWhyNot ||
      old.bare != bare;
}

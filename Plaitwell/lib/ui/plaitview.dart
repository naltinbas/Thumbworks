import 'dart:math';

import 'package:flutter/material.dart';

import '../plait/play.dart';
import '../plait/rules.dart';
import 'palette.dart';

/// Where the plait sits in a board of a given size.
///
/// The ropes run down in lanes, one crossing to a row, and the bottom of
/// each lane loops round the right side and back to its own top. The
/// leftmost lane takes the outermost loop, so no loop ever cuts another.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final level = play.level;
    rows = level.word.length;
    strands = level.strands;
    final words = bare ? 0.0 : 16.0;
    final room = Size(
      max(size.width - 12, 20),
      max(size.height - words - 12, 20),
    );
    // Worked out in one go: a late final may only be written once, and
    // writing it twice throws while painting rather than while compiling.
    step = max(
      min(
        room.height / (rows + 0.44 * strands + 0.8),
        room.width / (strands - 1 + 0.55 * strands + 1.0),
      ),
      4,
    );
    loopStep = step * 0.55;
    dipStep = step * 0.22;
    final wide = (strands - 1) * step + strands * loopStep;
    left = 6 + max((room.width - wide) / 2, 0) + step * 0.1;
    final tall = rows * step + 2 * strands * dipStep;
    top = 6 + max((room.height - tall) / 2, 0) + strands * dipStep;
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final int rows, strands;
  late final double step, loopStep, dipStep, left, top;

  /// Whether there is room for words under the plait.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  double laneX(int lane) => left + lane * step;

  double rowY(int row) => top + row * step;

  double get foot => rowY(rows);

  /// How far right a lane's loop runs. The leftmost lane runs furthest, so
  /// the loops nest instead of crossing.
  double loopX(int lane) =>
      laneX(strands - 1) + strands * loopStep - lane * loopStep;

  /// How far above the top and below the foot a lane's loop runs.
  double loopDip(int lane) => (strands - lane) * dipStep;

  /// How thick the rope is drawn.
  double get thick => max(step * 0.16, bare ? 3.0 : 2.4);

  /// Where a crossing sits.
  Offset crossingAt(int row) {
    final i = play.level.word[row].abs() - 1;
    return Offset((laneX(i) + laneX(i + 1)) / 2, rowY(row) + step / 2);
  }

  /// A point on the bend a diving or passing rope takes across a row.
  Offset onBend(double fromX, double toX, double yUp, double yDown, double t) {
    final p1 = Offset(fromX, yUp + step * 0.45);
    final p2 = Offset(toX, yDown - step * 0.45);
    final u = 1 - t;
    return Offset(
      u * u * u * fromX + 3 * u * u * t * p1.dx + 3 * u * t * t * p2.dx +
          t * t * t * toX,
      u * u * u * yUp + 3 * u * u * t * p1.dy + 3 * u * t * t * p2.dy +
          t * t * t * yDown,
    );
  }

  /// Where a thumb may land, arc by arc. Every piece of rope the plait
  /// draws puts a point here, so a tap anywhere along an arc finds it.
  List<(int, Offset)> holds() {
    final level = play.level;
    final lanes = Rules.lanes(level.strands, level.word);
    final out = <(int, Offset)>[];
    for (var j = 0; j < strands; j++) {
      final arc = lanes[rows][j];
      // Set at different heights lane by lane, so the beads on the loops do
      // not line up across the right side of the board.
      out.add((arc,
          Offset(loopX(j), top + (foot - top) * (0.34 + 0.16 * j))));
      out.add((arc, Offset((laneX(j) + loopX(j)) / 2, foot + loopDip(j))));
      out.add((arc, Offset((laneX(j) + loopX(j)) / 2, top - loopDip(j))));
    }
    for (var r = 0; r < rows; r++) {
      final turn = level.word[r];
      final i = turn.abs() - 1;
      final yUp = rowY(r), yDown = rowY(r + 1);
      for (var j = 0; j < strands; j++) {
        if (j == i || j == i + 1) continue;
        out.add((lanes[r][j], Offset(laneX(j), (yUp + yDown) / 2)));
      }
      final overFrom = turn > 0 ? i : i + 1;
      final overTo = turn > 0 ? i + 1 : i;
      out.add((lanes[r][overFrom], crossingAt(r)));
      out.add((lanes[r][overTo],
          onBend(laneX(overTo), laneX(overFrom), yUp, yDown, 0.2)));
      out.add((lanes[r + 1][overFrom],
          onBend(laneX(overTo), laneX(overFrom), yUp, yDown, 0.8)));
    }
    return out;
  }

  /// The arc a tap means, or null when it lands on no rope.
  int? arcUnder(Offset touch) {
    var best = -1;
    var near = step * 0.8;
    for (final (arc, at) in holds()) {
      final gap = (at - touch).distance;
      if (gap < near) {
        near = gap;
        best = arc;
      }
    }
    return best < 0 ? null : best;
  }
}

/// The plait: its ropes, its crossings and the paint on them.
class PlaitView extends CustomPainter {
  PlaitView({
    required this.play,
    this.pointing,
    this.showWrong = true,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The arc the show-me wants tapped, or null.
  final int? pointing;

  /// Whether to ring the crossings that do not sit right.
  final bool showWrong;

  final TextStyle labels;

  /// Whether to draw the plait alone, for the mark.
  final bool bare;

  Color _dye(int arc) => Palette.ropes[play.paint[arc]];

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final level = play.level;
    final lanes = Rules.lanes(level.strands, level.word);

    Paint rope(int arc) => Paint()
      ..color = _dye(arc)
      ..strokeWidth = m.thick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // The loops that close the plait, drawn first so the braid sits over
    // them.
    for (var j = 0; j < m.strands; j++) {
      final arc = lanes[m.rows][j];
      final x = m.laneX(j);
      final out = m.loopX(j);
      final dip = m.loopDip(j);
      final bend = min(m.step * 0.4, dip);
      final path = Path()
        ..moveTo(x, m.foot)
        ..lineTo(x, m.foot + dip - bend)
        ..quadraticBezierTo(x, m.foot + dip, x + bend, m.foot + dip)
        ..lineTo(out - bend, m.foot + dip)
        ..quadraticBezierTo(out, m.foot + dip, out, m.foot + dip - bend)
        ..lineTo(out, m.top - dip + bend)
        ..quadraticBezierTo(out, m.top - dip, out - bend, m.top - dip)
        ..lineTo(x + bend, m.top - dip)
        ..quadraticBezierTo(x, m.top - dip, x, m.top - dip + bend)
        ..lineTo(x, m.top);
      canvas.drawPath(path, rope(arc));
    }

    // The braid itself, row by row.
    for (var r = 0; r < m.rows; r++) {
      final turn = level.word[r];
      final i = turn.abs() - 1;
      final yUp = m.rowY(r), yDown = m.rowY(r + 1);

      for (var j = 0; j < m.strands; j++) {
        if (j == i || j == i + 1) continue;
        final arc = lanes[r][j];
        canvas.drawLine(
            Offset(m.laneX(j), yUp), Offset(m.laneX(j), yDown), rope(arc));
      }

      // Which side goes over, and which dives under and comes out anew.
      final overFrom = turn > 0 ? i : i + 1;
      final overTo = turn > 0 ? i + 1 : i;
      final overArc = lanes[r][overFrom];
      final underArc = lanes[r][overTo];
      final freshArc = lanes[r + 1][overFrom];

      Path bendTo(double fromX, double toX) => Path()
        ..moveTo(fromX, yUp)
        ..cubicTo(fromX, yUp + m.step * 0.45, toX, yDown - m.step * 0.45, toX,
            yDown);

      // The rope that dives, drawn in two halves with the crossing left
      // clear between them, because that is where its arc ends and the next
      // one starts.
      final dive = bendTo(m.laneX(overTo), m.laneX(overFrom));
      final metric = dive.computeMetrics().first;
      final gap = min(m.thick * 2.4, metric.length * 0.2);
      canvas.drawPath(
          metric.extractPath(0, metric.length / 2 - gap), rope(underArc));
      canvas.drawPath(
          metric.extractPath(metric.length / 2 + gap, metric.length),
          rope(freshArc));

      // The rope that passes over, drawn whole and last so it reads as
      // lying on top.
      canvas.drawPath(
          bendTo(m.laneX(overFrom), m.laneX(overTo)), rope(overArc));
    }

    if (bare) return;

    // The crossings that do not sit right.
    if (showWrong) {
      for (final r in play.wrong) {
        canvas.drawCircle(
          m.crossingAt(r),
          m.step * 0.42,
          Paint()
            ..color = Palette.bad
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }

    final holds = m.holds();

    // The arc the pointer wants, ringed wherever it runs.
    final want = pointing;
    if (want != null) {
      for (final (arc, at) in holds) {
        if (arc != want) continue;
        canvas.drawCircle(
          at,
          m.step * 0.3,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }

    // A bead on each arc with its letter, so the words can name one. The
    // bead takes the rope's own dye and the letter is cut out of it dark,
    // which reads at any size the board comes out.
    final done = <int>{};
    final bead = max(m.step * 0.17, 7.5);
    for (final (arc, at) in holds) {
      if (!done.add(arc)) continue;
      canvas.drawCircle(at, bead, Paint()..color = _dye(arc));
      _word(canvas, Play.letter(arc), at, size, bead * 1.25);
    }

    if (!m.roomy) return;
    _word(
      canvas,
      play.allSound
          ? 'every crossing sits right'
          : 'a crossing wants one colour or three, never two',
      Offset(size.width / 2, size.height - 8),
      size,
      11,
      colour: play.allSound ? Palette.good : Palette.inkDim,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Size size, double points,
      {Color? colour}) {
    final text = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(
          color: colour ?? Palette.night,
          fontSize: points,
          fontWeight: colour == null ? FontWeight.w800 : FontWeight.w400,
        ),
      ),
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
  bool shouldRepaint(PlaitView old) =>
      old.play.mark != play.mark ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showWrong != showWrong ||
      old.bare != bare;
}

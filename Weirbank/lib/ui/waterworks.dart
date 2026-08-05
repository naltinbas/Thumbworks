import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../flow/play.dart';
import '../flow/works.dart';
import 'palette.dart';

/// Where everything on the works is.
///
/// The painter and the finger both use this, which is the point of it: a pipe
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.works, Size room) {
    final side = math.min(room.width, room.height);
    spot = side * 0.062;
    across = room.width - spot * 3.2;
    down = room.height - spot * 3.4;
    corner = Offset(spot * 1.6, spot * 1.7);
  }

  final Works works;

  late final double spot;
  late final double across;
  late final double down;
  late final Offset corner;

  Offset middleOf(int pond) =>
      corner +
      Offset(works.ponds[pond].x * across, works.ponds[pond].y * down);

  Offset middleOfPipe(int pipe) =>
      (middleOf(works.pipes[pipe].from) + middleOf(works.pipes[pipe].to)) / 2;

  /// The pipe under a point, or -1. A finger is allowed to be a good way off,
  /// because a pipe is a line and a thumb is not a pencil.
  int pipeAt(Offset touch) {
    var nearest = -1;
    var best = spot * 1.1;
    for (var pipe = 0; pipe < works.pipes.length; pipe++) {
      final away = _awayFrom(
        touch,
        middleOf(works.pipes[pipe].from),
        middleOf(works.pipes[pipe].to),
      );
      if (away < best) {
        best = away;
        nearest = pipe;
      }
    }
    return nearest;
  }

  static double _awayFrom(Offset point, Offset from, Offset to) {
    final along = to - from;
    final length = along.distanceSquared;
    if (length == 0) return (point - from).distance;
    var how = ((point - from).dx * along.dx + (point - from).dy * along.dy) /
        length;
    how = how.clamp(0.0, 1.0);
    return (point - (from + along * how)).distance;
  }
}

/// The works: the ponds, the pipes, and what is running through them.
///
/// A leat is the channel that carries water to a mill, and it is called that
/// here because Waterworks is already the list of puzzles: two things with
/// one name is how a file ends up importing itself out of a corner.
class Leat extends CustomPainter {
  const Leat({
    required this.play,
    required this.pointing,
    required this.showCut,
    required this.cut,
    required this.labels,
  });

  final Play play;

  /// A pipe the game is pointing at, or -1.
  final int pointing;

  /// Whether to draw the cut that says nothing more can get through.
  final bool showCut;
  final List<int> cut;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final works = play.works;
    final metrics = Metrics(works, size);
    final spot = metrics.spot;

    for (var pipe = 0; pipe < works.pipes.length; pipe++) {
      final from = metrics.middleOf(works.pipes[pipe].from);
      final to = metrics.middleOf(works.pipes[pipe].to);
      final holds = works.pipes[pipe].holds;
      final down = play.downPipe(pipe);
      final wide = spot * (0.22 + 0.1 * holds);

      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = Palette.cut
          ..strokeWidth = wide
          ..strokeCap = StrokeCap.round,
      );
      if (down > 0) {
        canvas.drawLine(
          from,
          to,
          Paint()
            ..color = down >= holds ? Palette.full : Palette.water
            ..strokeWidth = wide * (down / holds)
            ..strokeCap = StrokeCap.round,
        );
      }
      if (showCut && cut.contains(pipe)) {
        canvas.drawLine(
          from,
          to,
          Paint()
            ..color = Palette.bad
            ..strokeWidth = wide + spot * 0.2
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
      }
      if (pipe == pointing) {
        canvas.drawCircle(
          metrics.middleOfPipe(pipe),
          spot * 0.9,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = spot * 0.1,
        );
      }

      // What is going down it, over what it holds. The arrow says which way.
      _write(
        canvas,
        '$down/$holds',
        metrics.middleOfPipe(pipe),
        down >= holds ? Palette.full : Palette.ink,
      );
      _arrow(canvas, from, to, spot);
    }

    for (var pond = 0; pond < works.count; pond++) {
      final middle = metrics.middleOf(pond);
      final colour = pond == works.spring
          ? Palette.spring
          : pond == works.mill
              ? Palette.mill
              : Palette.edge;

      canvas.drawCircle(middle, spot, Paint()..color = Palette.stone);
      canvas.drawCircle(
        middle,
        spot,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = spot * 0.14,
      );

      final over = play.spills.where((one) => one.pond == pond);
      if (over.isNotEmpty) {
        canvas.drawCircle(
          middle,
          spot * 1.3,
          Paint()
            ..color = Palette.bad
            ..style = PaintingStyle.stroke
            ..strokeWidth = spot * 0.1,
        );
      }

      _write(canvas, works.ponds[pond].name, middle + Offset(0, spot * 1.5),
          Palette.inkDim);
    }
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

  /// A small arrow along a pipe, because a pipe that runs one way has to look
  /// like it.
  void _arrow(Canvas canvas, Offset from, Offset to, double spot) {
    final along = to - from;
    final length = along.distance;
    if (length < 1) return;
    final way = along / length;
    final at = from + way * (length * 0.72);
    final side = Offset(-way.dy, way.dx);

    final head = Path()
      ..moveTo(at.dx + way.dx * spot * 0.34, at.dy + way.dy * spot * 0.34)
      ..lineTo(
        at.dx - way.dx * spot * 0.1 + side.dx * spot * 0.22,
        at.dy - way.dy * spot * 0.1 + side.dy * spot * 0.22,
      )
      ..lineTo(
        at.dx - way.dx * spot * 0.1 - side.dx * spot * 0.22,
        at.dy - way.dy * spot * 0.1 - side.dy * spot * 0.22,
      )
      ..close();
    canvas.drawPath(head, Paint()..color = Palette.edge);
  }

  @override
  bool shouldRepaint(Leat old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showCut != showCut ||
      old.cut.length != cut.length;
}

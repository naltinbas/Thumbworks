import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../weave/play.dart';
import 'palette.dart';

/// Where every strand and comb lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final strands = play.mesh.strands;
    gap = math.min(height / (strands + 1.6), 96.0);
    top = (height - (strands - 1) * gap) / 2;
    left = width * 0.12;
    right = width * 0.86;
    colWide = (right - left) / play.mesh.combs;
  }

  final Play play;

  late final double width;
  late final double height;

  /// The space between strands, and where they hang.
  late final double gap;
  late final double top;
  late final double left;
  late final double right;
  late final double colWide;

  double strandY(int strand) => top + strand * gap;

  double combX(int column) => left + (column + 0.5) * colWide;

  /// The bead columns: before the first comb and after each.
  double boundaryX(int boundary) => left + boundary * colWide;

  /// The strand under a touch, or -1.
  int strandAt(Offset touch) {
    for (var strand = 0; strand < play.mesh.strands; strand++) {
      if ((touch.dy - strandY(strand)).abs() <= gap * 0.42) {
        return strand;
      }
    }
    return -1;
  }
}

/// The frame, drawn.
class WeaveView extends CustomPainter {
  WeaveView({
    required this.play,
    required this.armed,
    this.ghost,
    this.showFoul = false,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The strand armed for a comb, or -1.
  final int armed;

  /// The comb being pointed at, or null.
  final (int, int)? ghost;

  /// Whether to run the first foul grist down the weave in beads.
  final bool showFoul;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var strand = 0; strand < play.mesh.strands; strand++) {
      final y = metrics.strandY(strand);
      canvas.drawLine(
        Offset(metrics.left - metrics.gap * 0.3, y),
        Offset(metrics.right + metrics.gap * 0.3, y),
        Paint()
          ..color = strand == armed ? Palette.armed : Palette.strand
          ..strokeWidth = strand == armed ? 3.0 : 2.0
          ..strokeCap = StrokeCap.round,
      );
    }

    for (var column = 0; column < play.placed; column++) {
      _comb(canvas, metrics, column, play.weave[column]);
    }
    final pointed = ghost;
    if (pointed != null && play.room > 0) {
      _ghost(canvas, metrics, play.placed, pointed);
    }

    if (showFoul) _fouls(canvas, metrics);
  }

  void _comb(Canvas canvas, Metrics metrics, int column, (int, int) comb) {
    final x = metrics.combX(column);
    final (upper, lower) = comb;
    final knob = math.min(metrics.gap * 0.14, 7.0);
    canvas.drawLine(
      Offset(x, metrics.strandY(upper)),
      Offset(x, metrics.strandY(lower)),
      Paint()
        ..color = Palette.comb
        ..strokeWidth = knob * 0.9
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(x, metrics.strandY(upper)), knob,
        Paint()..color = Palette.combKnob);
    canvas.drawCircle(Offset(x, metrics.strandY(lower)), knob,
        Paint()..color = Palette.combKnob);
    // The heavy end wears the arrow: grain drops to the lower strand.
    final tip = Path()
      ..moveTo(x - knob, metrics.strandY(lower) - knob * 2.2)
      ..lineTo(x + knob, metrics.strandY(lower) - knob * 2.2)
      ..lineTo(x, metrics.strandY(lower) - knob * 0.8)
      ..close();
    canvas.drawPath(tip, Paint()..color = Palette.comb);
  }

  void _ghost(Canvas canvas, Metrics metrics, int column, (int, int) comb) {
    final x = metrics.combX(column);
    final (upper, lower) = comb;
    final knob = math.min(metrics.gap * 0.14, 7.0);
    final dash = metrics.gap * 0.18;
    var y = metrics.strandY(upper);
    final endY = metrics.strandY(lower);
    final paint = Paint()
      ..color = Palette.shown
      ..strokeWidth = knob * 0.7
      ..strokeCap = StrokeCap.round;
    while (y < endY) {
      final next = math.min(y + dash, endY);
      canvas.drawLine(Offset(x, y), Offset(x, next), paint);
      y = next + dash * 0.7;
    }
    canvas.drawCircle(Offset(x, metrics.strandY(upper)), knob,
        Paint()..color = Palette.shown);
    canvas.drawCircle(Offset(x, endY), knob, Paint()..color = Palette.shown);
  }

  void _fouls(Canvas canvas, Metrics metrics) {
    final grist = play.foul;
    if (grist == null) return;
    final steps = play.rules.trace(grist, play.weave);
    final bead = math.min(metrics.gap * 0.17, 9.0);

    for (var boundary = 0; boundary < steps.length; boundary++) {
      final x = metrics.boundaryX(boundary);
      for (var strand = 0; strand < play.mesh.strands; strand++) {
        final heavy = steps[boundary] & (1 << strand) != 0;
        canvas.drawCircle(
          Offset(x, metrics.strandY(strand)),
          bead,
          Paint()..color = heavy ? Palette.bead : Palette.beadHollow,
        );
        canvas.drawCircle(
          Offset(x, metrics.strandY(strand)),
          bead,
          Paint()
            ..color = Palette.strand
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }

    // Where each bead should end, rimmed fair or foul at the far edge.
    final ends = steps.last;
    final wants = play.rules.settled(grist);
    final x = metrics.right + metrics.gap * 0.3;
    for (var strand = 0; strand < play.mesh.strands; strand++) {
      final heavy = ends & (1 << strand) != 0;
      final wanted = wants & (1 << strand) != 0;
      canvas.drawCircle(
        Offset(x, metrics.strandY(strand)),
        bead,
        Paint()..color = heavy ? Palette.bead : Palette.beadHollow,
      );
      canvas.drawCircle(
        Offset(x, metrics.strandY(strand)),
        bead + 1.5,
        Paint()
          ..color = heavy == wanted ? Palette.fair : Palette.foul
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(WeaveView old) =>
      old.play != play ||
      old.armed != armed ||
      old.ghost != ghost ||
      old.showFoul != showFoul;
}

/// The words the why speaks, from the weave at hand.
String whyWords(Play play) {
  final mesh = play.mesh;
  final note = mesh.note == null ? '' : ' ${mesh.note}';
  if (play.isClean) {
    return 'Every grist of noughts and ones runs clean, and by the old '
        'nought-one principle that settles every ordering too. The '
        'suite takes neither on trust: it runs both sweeps on the '
        'shipped meshes, and both on every short weave there is.$note';
  }
  final foul = play.foul!;
  final word = [
    for (var strand = 0; strand < mesh.strands; strand++)
      foul & (1 << strand) != 0 ? '1' : '0',
  ].join();
  return 'A weave riddles clean when every grist of noughts and ones '
      'comes out heavy-side down; the nought-one principle then '
      'settles every ordering, and the suite checks both. The beads '
      'are grist $word running your weave, and its far end shows '
      'where it lands foul, red against where it belongs.$note';
}

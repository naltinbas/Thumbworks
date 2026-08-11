import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../code/play.dart';
import '../code/rules.dart';
import 'palette.dart';

/// Where the rows and the candidate lie, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    peg = math.min(width * 0.055, 26.0);
    rowHigh = math.min(
        height * 0.6 / (play.riddle.rows.length + 1), peg * 4.2);
    rowsTop = height * 0.08;
    candidateY = rowsTop +
        (play.riddle.rows.length + 0.9) * rowHigh +
        peg * 3.2;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double peg;
  late final double rowHigh;
  late final double rowsTop;
  late final double candidateY;

  Offset guessPeg(int row, int slot) => Offset(
        width * 0.16 + slot * peg * 3.0,
        rowsTop + row * rowHigh + rowHigh / 2,
      );

  Offset markDot(int row, int at) => Offset(
        width * 0.62 + at * peg * 1.5,
        rowsTop + row * rowHigh + rowHigh / 2,
      );

  Offset candidateSlot(int slot) => Offset(
        width / 2 + (slot - 1.5) * peg * 3.6,
        candidateY,
      );

  /// The candidate slot under a touch, or -1.
  int slotAt(Offset touch) {
    for (var slot = 0; slot < Rules.pegs; slot++) {
      if ((candidateSlot(slot) - touch).distance <= peg * 2.0) {
        return slot;
      }
    }
    return -1;
  }
}

/// The table, drawn.
class CodeView extends CustomPainter {
  CodeView({
    required this.play,
    required this.pointing,
    this.other,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The mend being pointed at: a slot and its colour, or null.
  final (int, int)? pointing;

  /// Another agreeing code, shown as ghost rims, or null.
  final int? other;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var row = 0; row < play.riddle.rows.length; row++) {
      _row(canvas, metrics, row);
    }

    for (var slot = 0; slot < Rules.pegs; slot++) {
      _slot(canvas, metrics, slot);
    }
  }

  void _row(Canvas canvas, Metrics metrics, int row) {
    final (guess, black, white) = play.riddle.rows[row];
    final stands = play.rowStands(row);
    final rim = stands == null
        ? Palette.line
        : stands
            ? Palette.kept
            : Palette.brokenRow;

    final frame = Rect.fromLTRB(
      metrics.width * 0.06,
      metrics.rowsTop + row * metrics.rowHigh + metrics.rowHigh * 0.08,
      metrics.width * 0.94,
      metrics.rowsTop + (row + 1) * metrics.rowHigh -
          metrics.rowHigh * 0.08,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(metrics.peg)),
      Paint()..color = Palette.panel,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(metrics.peg)),
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = stands == null ? 1.2 : 2.2,
    );

    for (var slot = 0; slot < Rules.pegs; slot++) {
      final middle = metrics.guessPeg(row, slot);
      canvas.drawCircle(
        middle,
        metrics.peg,
        Paint()..color = Palette.pegColours[Rules.pegAt(guess, slot)],
      );
    }

    // The written marks: blacks then whites.
    var at = 0;
    for (var dot = 0; dot < black; dot++) {
      canvas.drawCircle(metrics.markDot(row, at++), metrics.peg * 0.5,
          Paint()..color = Palette.black);
      canvas.drawCircle(
        metrics.markDot(row, at - 1),
        metrics.peg * 0.5,
        Paint()
          ..color = Palette.inkDim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
    for (var dot = 0; dot < white; dot++) {
      canvas.drawCircle(metrics.markDot(row, at++), metrics.peg * 0.5,
          Paint()..color = Palette.white);
    }
  }

  void _slot(Canvas canvas, Metrics metrics, int slot) {
    final middle = metrics.candidateSlot(slot);
    final colour = play.slots[slot];
    canvas.drawCircle(
        middle, metrics.peg * 1.6, Paint()..color = Palette.slot);
    canvas.drawCircle(
      middle,
      metrics.peg * 1.6,
      Paint()
        ..color = Palette.slotRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    if (colour >= 0) {
      canvas.drawCircle(middle, metrics.peg * 1.25,
          Paint()..color = Palette.pegColours[colour]);
    }
    final pointed = pointing;
    if (pointed != null && pointed.$1 == slot) {
      canvas.drawCircle(
        middle,
        metrics.peg * 1.9,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
    final ghost = other;
    if (ghost != null) {
      canvas.drawCircle(
        middle + Offset(0, metrics.peg * 2.7),
        metrics.peg * 0.7,
        Paint()..color = Palette.pegColours[Rules.pegAt(ghost, slot)],
      );
      canvas.drawCircle(
        middle + Offset(0, metrics.peg * 2.7),
        metrics.peg * 0.85,
        Paint()
          ..color = Palette.other
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
  }

  @override
  bool shouldRepaint(CodeView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.other != other;
}

/// The words the why speaks, from the riddle at hand.
String whyWords(Play play) {
  final riddle = play.riddle;
  final note = riddle.note == null ? '' : ' ${riddle.note}';
  if (!riddle.winnable) {
    return 'The sweep set all 256 codes against every row: none '
        'earns them all their written marks.$note';
  }
  if (riddle.ways > 1) {
    return 'The sweep set all 256 codes against every row and found '
        '${riddle.ways} that agree, shown in gold below the slots '
        'one at a time.$note';
  }
  return 'The sweep set all 256 codes against every row: exactly one '
      'earns every row its written marks. A finished wrong guess '
      'shows its broken rows red, with the marks it would really '
      'earn.$note';
}

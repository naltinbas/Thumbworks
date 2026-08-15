import 'dart:math';

import 'package:flutter/material.dart';

import '../coil/play.dart';
import '../coil/rules.dart';
import 'palette.dart';

/// Where the coil sits in a board of a given size, and where a pitch
/// falls on it: one turn of the coil an octave, the start at the top,
/// rising pitch running clockwise and outward.
class Metrics {
  Metrics(this.play, this.size) {
    final side = min(size.width, size.height);
    centre = Offset(size.width / 2, size.height / 2);
    rOut = side / 2 - 10;
    rIn = rOut * 0.14;
    // The band of turns in view: the note and the stack of fifths that
    // reached it, and at least a turn below the start and two above.
    var lo = -1.0, hi = 2.0;
    for (final t in [turnsOf(play.fifths, play.octaves), ...stack.map((p) => p.$2)]) {
      lo = min(lo, t.floorToDouble());
      hi = max(hi, t.ceilToDouble());
    }
    low = lo;
    high = hi;
  }

  final Play play;
  final Size size;
  late final Offset centre;
  late final double rIn, rOut, low, high;

  static final _log2of3 = log(3) / log(2);

  /// A setting as turns of the coil above the start.
  static double turnsOf(int f, int o) => f * _log2of3 + o - f;

  /// The stack of fifths that reaches the note before the octaves shift
  /// it: (fifths so far, turns), one fifth at a time.
  List<(int, double)> get stack => [
        for (var k = 1; k <= play.fifths.abs(); k++) (k, turnsOf(play.fifths.sign * k, 0)),
      ];

  double radius(double turns) => rIn + (turns - low) / (high - low) * (rOut - rIn);

  /// The point of the coil [turns] above the start.
  Offset at(double turns) {
    final a = 2 * pi * (turns - turns.floorToDouble());
    return centre + Offset(sin(a), -cos(a)) * radius(turns);
  }

  /// Where the note stands.
  Offset get note => at(turnsOf(play.fifths, play.octaves));

  /// Whether there is room for words on the coil.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The coil, the stack of fifths on it, and the note.
class CoilView extends CustomPainter {
  const CoilView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the coil only, for the mark: no words.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    // The rays of the twelve, faint.
    final ray = Paint()
      ..color = Palette.ray
      ..strokeWidth = 1;
    for (var k = 0; k < 12; k++) {
      final a = 2 * pi * k / 12;
      canvas.drawLine(m.centre, m.centre + Offset(sin(a), -cos(a)) * m.rOut, ray);
    }
    // The coil, a turn an octave.
    final coil = Path()..moveTo(m.at(m.low).dx, m.at(m.low).dy);
    for (var t = m.low; t <= m.high + 1e-9; t += 1 / 72) {
      final p = m.at(min(t, m.high));
      coil.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      coil,
      Paint()
        ..color = Palette.coil
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 3 : 2,
    );
    // The octave marks up the home ray.
    for (var t = m.low; t <= m.high; t++) {
      canvas.drawCircle(m.at(t), bare ? 4 : 3, Paint()..color = t == 0 ? Palette.home : Palette.coilDim);
    }
    // The stack of fifths: the coil climbed so far, drawn over, a dot a
    // fifth, then the octaves' shift straight in or out to the note.
    final stack = m.stack;
    var last = m.at(0);
    if (stack.isNotEmpty) {
      final end = stack.last.$2;
      final climbed = Path()..moveTo(last.dx, last.dy);
      final step = end > 0 ? 1 / 72 : -1 / 72;
      for (var t = step; end > 0 ? t < end : t > end; t += step) {
        final p = m.at(t);
        climbed.lineTo(p.dx, p.dy);
      }
      last = m.at(end);
      climbed.lineTo(last.dx, last.dy);
      canvas.drawPath(
        climbed,
        Paint()
          ..color = Palette.stack
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3.5 : 3,
      );
      for (final (k, t) in stack) {
        final p = m.at(t);
        canvas.drawCircle(p, bare ? 5 : 3.5, Paint()..color = Palette.stack);
        if (!bare && m.roomy && stack.length <= 12) {
          final out = (p - m.centre) / (p - m.centre).distance;
          _word(canvas, '$k', p + out * 10, Palette.stack, size);
        }
      }
    }
    final note = m.note;
    if (play.octaves != 0) {
      canvas.drawLine(
        last,
        note,
        Paint()
          ..color = Palette.stack.withValues(alpha: 0.7)
          ..strokeWidth = 1.5,
      );
    }
    // The start, in gold, and the note.
    canvas.drawCircle(
      m.at(0),
      bare ? 9 : 7,
      Paint()
        ..color = Palette.home
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final r = play.note;
    final tint = Rules.home(r) ? Palette.home : Rules.sharp(r) ? Palette.sharp : Palette.flat;
    canvas.drawCircle(note, bare ? 10 : 8, Paint()..color = tint);
    canvas.drawCircle(note, bare ? 4 : 3, Paint()..color = Palette.noteInk);
    if (bare || !m.roomy) return;
    // The words: 'start' left of the gold ring, the cents right of the
    // note, so the two stay apart when the note comes home.
    _word(canvas, 'start', m.at(0) + const Offset(-24, 0), Palette.home, size);
    if (!Rules.home(r)) {
      final c = play.cents;
      final told = '${c < 0 ? '' : '+'}${c.toStringAsFixed(2)}';
      _word(canvas, told, note + Offset(12 + told.length * 3.2, 0), tint, size);
    }
    _word(canvas, 'a turn an octave, clockwise up', Offset(size.width / 2, size.height - 12), Palette.inkDim, size);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(CoilView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

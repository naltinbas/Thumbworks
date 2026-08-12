import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../chain/play.dart';
import '../chain/rules.dart';
import 'palette.dart';

/// Where every crossing lies, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(Size room) {
    final span = math.min(room.width, room.height) * 0.86;
    cell = span / (Rules.side - 1);
    left = (room.width - span) / 2;
    top = (room.height - span) / 2;
  }

  late final double cell;
  late final double left;
  late final double top;

  /// The point of the crossing at (x, y), y rising from the bottom.
  Offset crossAt(int x, int y) =>
      Offset(left + x * cell, top + (Rules.side - 1 - y) * cell);

  /// The crossing under a touch, or null for the surrounds.
  (int, int)? crossUnder(Offset touch) {
    for (var x = 0; x < Rules.side; x++) {
      for (var y = 0; y < Rules.side; y++) {
        if ((crossAt(x, y) - touch).distance <= cell * 0.36) {
          return (x, y);
        }
      }
    }
    return null;
  }
}

/// The field, drawn.
class ChainView extends CustomPainter {
  ChainView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The crossing being pointed at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(size);

    // The mowing lines of the field.
    for (var at = 0; at < Rules.side; at++) {
      canvas.drawLine(
        metrics.crossAt(at, 0),
        metrics.crossAt(at, Rules.side - 1),
        Paint()
          ..color = Palette.grass
          ..strokeWidth = 1.2,
      );
      canvas.drawLine(
        metrics.crossAt(0, at),
        metrics.crossAt(Rules.side - 1, at),
        Paint()
          ..color = Palette.grass
          ..strokeWidth = 1.2,
      );
    }

    // The crossings.
    for (var x = 0; x < Rules.side; x++) {
      for (var y = 0; y < Rules.side; y++) {
        canvas.drawCircle(
          metrics.crossAt(x, y),
          metrics.cell * 0.05,
          Paint()..color = Palette.cross,
        );
      }
    }

    // The chains, stretched a little past their end stones; bare
    // ones gold, laden ones moss.
    for (final chain in play.chainsNow) {
      final bare = chain.length == 2;
      Offset a = metrics.crossAt(chain.first.$1, chain.first.$2);
      Offset b = a;
      var far = -1.0;
      for (final s in chain) {
        for (final t in chain) {
          final p = metrics.crossAt(s.$1, s.$2);
          final q = metrics.crossAt(t.$1, t.$2);
          if ((p - q).distance > far) {
            far = (p - q).distance;
            a = p;
            b = q;
          }
        }
      }
      canvas.drawLine(
        a,
        b,
        Paint()
          ..color = bare ? Palette.bare : Palette.laden
          ..strokeWidth = bare ? 3.0 : math.max(metrics.cell * 0.11, 4.0)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointed crossing.
    final pointed = pointing;
    if (pointed != null) {
      canvas.drawCircle(
        metrics.crossAt(pointed.$1, pointed.$2),
        metrics.cell * 0.3,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }

    // The stones, stood on top.
    for (final (x, y) in play.stones) {
      final middle = metrics.crossAt(x, y);
      final stone = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: middle - Offset(0, metrics.cell * 0.06),
          width: metrics.cell * 0.34,
          height: metrics.cell * 0.46,
        ),
        Radius.circular(metrics.cell * 0.14),
      );
      canvas.drawRRect(stone, Paint()..color = Palette.stone);
      canvas.drawRRect(
        stone,
        Paint()
          ..color = Palette.stoneRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(ChainView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the field at hand.
String whyWords(Play play) {
  final field = play.field;
  final note = field.note == null ? '' : ' ${field.note}';
  if (!field.winnable) {
    return 'Sylvester and Gallai\'s law: stones not all in one row '
        'always show a bare chain, a chain through exactly two. '
        'The sweep laid every placing of five stones on this '
        'field, all ${withComma(53130)} of them, counting chains '
        'two ways that share nothing, strung lines against '
        'thirds-on-the-pair, and the only placings with no bare '
        'chain were the twelve rows of five the asking bars.$note';
  }
  return 'Chains are counted two ways that share nothing: strung '
      'lines gather every stone on a line, and thirds-on-the-pair '
      'calls a pair bare when no third stone sits with it. The '
      'sweep of every placing of three, four and five stones, all '
      '${withComma(68080)}, finds the two agreeing on every one. '
      '${withComma(field.ways)} placings land this field\'s '
      'asking.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pebble/play.dart';
import '../pebble/rules.dart';
import 'palette.dart';

/// Where the board's numbers lie, so the screen and the tests can
/// find every one.
class Metrics {
  Metrics(this.play, Size room) {
    cols = 10;
    rows = 10;
    cell = math.min(room.width * 0.94 / cols, room.height * 0.56 / rows);
    boardLeft = (room.width - cell * cols) / 2;
    boardTop = room.height * 0.02;
    rowsTop = boardTop + cell * rows + room.height * 0.03;
    rowsHeight = room.height - rowsTop - room.height * 0.02;
  }

  final Play play;

  late final int cols;
  late final int rows;
  late final double cell;
  late final double boardLeft;
  late final double boardTop;

  /// Where the divisor grid is drawn below the board.
  late final double rowsTop;
  late final double rowsHeight;

  /// The middle of number [n]'s cell, 1 to 100.
  Offset cellAt(int n) {
    final index = n - 1;
    return Offset(
      boardLeft + (index % cols + 0.5) * cell,
      boardTop + (index ~/ cols + 0.5) * cell,
    );
  }

  /// The number under a touch, or null.
  int? under(Offset touch) {
    final c = ((touch.dx - boardLeft) / cell).floor();
    final r = ((touch.dy - boardTop) / cell).floor();
    if (c < 0 || c >= cols || r < 0 || r >= rows) return null;
    return r * cols + c + 1;
  }
}

/// The board itself: the hundred numbers, the picked one gold, and
/// beneath it the divisor grid of the picked heap, primes to powers
/// along its edges.
class RowsView extends CustomPainter {
  RowsView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// The number the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final cell = metrics.cell;

    // The board of numbers.
    for (var n = 1; n <= 100; n++) {
      final at = metrics.cellAt(n);
      final rect = Rect.fromCenter(center: at, width: cell, height: cell).deflate(cell * 0.06);
      final picked = play.heap == n;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.15)),
        Paint()..color = picked ? Palette.picked : Palette.cell,
      );
      if (pointing == n) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect.inflate(cell * 0.03), Radius.circular(cell * 0.18)),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, cell * 0.08),
        );
      }
      _write(
        canvas,
        '$n',
        at,
        labels.copyWith(
          color: picked ? Palette.pickedInk : Palette.cellInk,
          fontSize: cell * 0.36,
          fontWeight: picked ? FontWeight.w800 : FontWeight.w500,
        ),
      );
    }

    // The divisor grid of the picked heap.
    final heap = play.heap;
    if (heap == null) {
      _write(
        canvas,
        'pick a heap',
        Offset(size.width / 2, metrics.rowsTop + metrics.rowsHeight / 2),
        labels.copyWith(color: Palette.inkDim, fontSize: math.max(11, cell * 0.4)),
      );
      return;
    }
    final factors = Rules.factors(heap);
    final told = factors.isEmpty
        ? '1 alone'
        : factors.map((f) => f.$2 == 1 ? '${f.$1}' : '${f.$1}^${f.$2}').join(' x ');
    final counted = factors.isEmpty
        ? '1 even row'
        : '${factors.map((f) => '(${f.$2} + 1)').join(' x ')} = ${play.rows} even rows';
    _write(
      canvas,
      '$heap = $told',
      Offset(size.width / 2, metrics.rowsTop + metrics.rowsHeight * 0.08),
      labels.copyWith(color: Palette.factor, fontSize: math.max(11, cell * 0.36), fontWeight: FontWeight.w700),
    );
    _write(
      canvas,
      counted,
      Offset(size.width / 2, metrics.rowsTop + metrics.rowsHeight * 0.2),
      labels.copyWith(color: Palette.inkDim, fontSize: math.max(10, cell * 0.3)),
    );

    // The grid: the first prime's powers across, the second's down,
    // and a third prime's powers as blocks side by side.
    final across = factors.isNotEmpty ? factors[0].$2 + 1 : 1;
    final down = factors.length > 1 ? factors[1].$2 + 1 : 1;
    final blocks = factors.length > 2 ? factors[2].$2 + 1 : 1;
    final gridTop = metrics.rowsTop + metrics.rowsHeight * 0.3;
    final gridHeight = metrics.rowsHeight * 0.66;
    final gridWidth = size.width * 0.9;
    final unit = math.min(gridWidth / (blocks * across + (blocks - 1) * 0.5), gridHeight / down);
    final totalWidth = unit * (blocks * across + (blocks - 1) * 0.5);
    final left = (size.width - totalWidth) / 2;
    for (var b = 0; b < blocks; b++) {
      for (var j = 0; j < down; j++) {
        for (var i = 0; i < across; i++) {
          var d = 1;
          for (var k = 0; k < i; k++) {
            d *= factors[0].$1;
          }
          for (var k = 0; k < j; k++) {
            d *= factors[1].$1;
          }
          for (var k = 0; k < b; k++) {
            d *= factors[2].$1;
          }
          final x = left + b * (across + 0.5) * unit + i * unit;
          final y = gridTop + j * unit;
          final rect = Rect.fromLTWH(x, y, unit, unit).deflate(unit * 0.06);
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(unit * 0.12)),
            Paint()..color = Palette.answer,
          );
          _write(
            canvas,
            '$d',
            rect.center,
            labels.copyWith(color: Palette.pebble, fontSize: math.max(8, unit * 0.34), fontWeight: FontWeight.w600),
          );
        }
      }
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(RowsView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for an asking as it stands.
String whyWords(Play play) {
  final asking = play.asking;
  final note = asking.note == null ? '' : ' ${asking.note}';
  if (!asking.winnable) {
    return 'Write a heap as primes raised to powers, and its even rows '
        'are the powers each raised by one, multiplied: a divisor takes '
        'each prime to any power from nought up to the top. Thirteen is '
        'prime, so it can only be one power plus one, and that heap is a '
        'single prime to the twelfth. The smallest such is two to the '
        'twelfth, four thousand and ninety-six, and the sweep of the '
        'hundred finds no heap with thirteen rows.$note';
  }
  return 'The heaps are found by the sweep, every heap of the hundred '
      'laid out by trial, row length by row length, and held to a second '
      'voice: the powers, each raised by one and multiplied, which name '
      'the count with no trial and agree with it on every heap to a '
      'thousand. ${asking.ways} heap${asking.ways == 1 ? '' : 's'} of the '
      'hundred meet${asking.ways == 1 ? 's' : ''} this asking.$note';
}

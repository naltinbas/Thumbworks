import 'dart:math';

import 'package:flutter/material.dart';

import '../heap/play.dart';
import 'palette.dart';

/// Where the shelf and the slots sit in a board of a given size.
class Metrics {
  Metrics(this.play, this.size) {
    final shelf = play.level.shelf;
    columns = shelf.length <= 8 ? shelf.length : (shelf.length + 1) ~/ 2;
    rows = (shelf.length + columns - 1) ~/ columns;
    cell = min((size.width - 16) / columns, 64.0);
    shelfTop = 8;
    slotWidth = min(84.0, (size.width - 40) / (play.slots.length + 0.6));
    slotTop = shelfTop + rows * cell + 28;
    slotHeight = min(64.0, size.height - slotTop - (roomy ? 30 : 8));
  }

  final Play play;
  final Size size;
  late final int columns, rows;
  late final double cell, shelfTop, slotWidth, slotTop, slotHeight;

  /// The rectangle of shelf item [i].
  Rect shelfRect(int i) {
    final w = columns * cell;
    final x0 = (size.width - w) / 2;
    return Rect.fromLTWH(x0 + (i % columns) * cell, shelfTop + (i ~/ columns) * cell, cell, cell);
  }

  /// The rectangle of slot [i].
  Rect slotRect(int i) {
    final n = play.slots.length;
    final w = n * slotWidth + (n - 1) * 24;
    final x0 = (size.width - w) / 2;
    return Rect.fromLTWH(x0 + i * (slotWidth + 24), slotTop, slotWidth, slotHeight);
  }

  /// What is under a point: ('shelf', number) or ('slot', index), or
  /// null.
  (String, int)? under(Offset p) {
    final shelf = play.level.shelf;
    for (var i = 0; i < shelf.length; i++) {
      if (shelfRect(i).contains(p)) return ('shelf', shelf[i]);
    }
    for (var i = 0; i < play.slots.length; i++) {
      if (slotRect(i).contains(p)) return ('slot', i);
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The shelf of heaps, the slots, and the sum.
class HeapView extends CustomPainter {
  const HeapView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the slots only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    if (bare) {
      _bareMark(canvas, size);
      return;
    }
    final m = Metrics(play, size);
    final shelf = play.level.shelf;
    for (var i = 0; i < shelf.length; i++) {
      final r = m.shelfRect(i).deflate(3);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(6));
      canvas.drawRRect(rr, Paint()..color = Palette.heap);
      canvas.drawRRect(rr, Paint()..color = Palette.heapRim..style = PaintingStyle.stroke..strokeWidth = 1);
      _heap(canvas, r, i, m.cell);
      _word(canvas, '${shelf[i]}', Offset(r.center.dx, r.bottom - 9), Palette.chalk, size, 11);
    }
    for (var i = 0; i < play.slots.length; i++) {
      final r = m.slotRect(i);
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(8));
      canvas.drawRRect(rr, Paint()..color = Palette.slot);
      canvas.drawRRect(rr, Paint()..color = Palette.slotRim..style = PaintingStyle.stroke..strokeWidth = 2);
      final s = play.slots[i];
      _word(canvas, s == null ? '?' : '$s', r.center, s == null ? Palette.inkDim : Palette.chalk, size, 22);
      if (i < play.slots.length - 1) {
        _word(canvas, '+', Offset(r.right + 12, r.center.dy), Palette.inkDim, size, 20);
      }
    }
    final aim = pointing;
    if (aim != null) {
      final r = aim.$1 == Aim.slot ? m.slotRect(aim.$2) : m.shelfRect(shelf.indexOf(aim.$2)).deflate(3);
      canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(2), const Radius.circular(8)), Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 3);
    }
    if (!m.roomy) return;
    final landed = play.isFull && play.sum == play.level.number;
    _word(canvas, play.isFull ? '= ${play.sum}${landed ? ', as asked' : ', not ${play.level.number}'}' : '= ${play.sum} so far, ${play.level.number} wanted', Offset(size.width / 2, min(size.height - 12, m.slotTop + m.slotHeight + 20)), landed ? Palette.gold : play.isFull ? Palette.short : Palette.inkDim, size, 12);
  }

  /// A little triangle of stones for the k-th triangular number.
  void _heap(Canvas canvas, Rect r, int k, double cell) {
    if (k == 0) return;
    // At most four rows are drawn, the heap standing for the number.
    final rows = min(k, cell < 50 ? 3 : 4);
    final d = min(cell * 0.07, 3.6);
    final top = r.top + 7;
    for (var row = 0; row < rows; row++) {
      for (var i = 0; i <= row; i++) {
        final x = r.center.dx + (i - row / 2) * d * 2.3;
        final y = top + row * d * 2.0;
        canvas.drawCircle(Offset(x, y), d, Paint()..color = Palette.stone);
      }
    }
  }

  void _bareMark(Canvas canvas, Size size) {
    // Three heaps of stones, 3, 1 and 1, the five's three.
    final d = size.width * 0.045;
    void heap(Offset base, int rows) {
      for (var row = 0; row < rows; row++) {
        for (var i = 0; i <= row; i++) {
          canvas.drawCircle(base + Offset((i - row / 2) * d * 2.4, -(rows - 1 - row) * d * 2.1), d, Paint()..color = Palette.stone);
        }
      }
    }

    heap(Offset(size.width * 0.28, size.height * 0.62), 3);
    heap(Offset(size.width * 0.58, size.height * 0.62), 1);
    heap(Offset(size.width * 0.78, size.height * 0.62), 1);
    final plus = Paint()..color = Palette.gold..strokeWidth = size.width * 0.03;
    for (final x in [size.width * 0.44, size.width * 0.68]) {
      canvas.drawLine(Offset(x - d * 1.6, size.height * 0.5), Offset(x + d * 1.6, size.height * 0.5), plus);
      canvas.drawLine(Offset(x, size.height * 0.5 - d * 1.6), Offset(x, size.height * 0.5 + d * 1.6), plus);
    }
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: fontSize, fontWeight: fontSize > 16 ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(HeapView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

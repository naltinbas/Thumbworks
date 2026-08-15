import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tray/play.dart';
import '../tray/rules.dart';
import 'palette.dart';

/// Where things lie on the board: the tray in the top part, cell by
/// cell, and the bag of fours along the bottom, one slot a kind with its
/// count.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    final w = play.width, h = play.height;
    final whole = bare || play.isOver;
    final trayRoomH = whole ? room.height : room.height * 0.7;
    cell = math.min(room.width * (bare ? 1 : 0.92) / w, trayRoomH * (bare ? 1 : 0.9) / h);
    final tw = cell * w, th = cell * h;
    tray = Rect.fromLTWH((room.width - tw) / 2, whole ? (room.height - th) / 2 : math.max(room.height * 0.03, (trayRoomH - th) / 2), tw, th);
    bagTop = room.height * 0.72;
    bagHeight = room.height * 0.28;
    final slotW = room.width / Rules.kinds.length;
    for (var k = 0; k < Rules.kinds.length; k++) {
      slots[k] = Rect.fromLTWH(k * slotW, bagTop, slotW, bagHeight);
    }
    // A four in the bag is drawn at a small cell.
    bagCell = math.min(slotW / 5, bagHeight / 6);
  }

  final Play play;

  late final double width;
  late final double height;

  /// One cell of the tray, in pixels.
  late final double cell;

  /// The tray, as laid out.
  late final Rect tray;
  late final double bagTop;
  late final double bagHeight;
  late final double bagCell;

  /// Each kind's slot in the bag.
  final slots = <int, Rect>{};

  /// The middle of tray cell (x, y).
  Offset cellAt(int x, int y) => Offset(tray.left + (x + 0.5) * cell, tray.top + (y + 0.5) * cell);

  /// The middle of kind [k]'s slot in the bag.
  Offset bagAt(int k) => slots[k]!.center;

  /// What is under a touch: (0, x, y) a tray cell, (1, kind, 0) a slot in
  /// the bag, or null.
  (int, int, int)? under(Offset touch) {
    for (final e in slots.entries) {
      if (e.value.contains(touch)) return (1, e.key, 0);
    }
    if (tray.contains(touch)) {
      final x = ((touch.dx - tray.left) / cell).floor().clamp(0, play.width - 1);
      final y = ((touch.dy - tray.top) / cell).floor().clamp(0, play.height - 1);
      return (0, x, y);
    }
    return null;
  }
}

/// The tray and the bag: laid fours as iced gingerbread, the tin bare
/// where nothing lies, the bag's kinds waiting with counts, the held
/// four drawn the way it faces.
class TrayView extends CustomPainter {
  TrayView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words and the bag off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.kitchen);
    // The tray.
    canvas.drawRRect(RRect.fromRectAndRadius(m.tray.inflate(m.cell * 0.12), Radius.circular(m.cell * 0.15)), Paint()..color = Palette.rim);
    canvas.drawRect(m.tray, Paint()..color = Palette.tin);
    final grid = Paint()
      ..color = Palette.tinLine
      ..strokeWidth = 1;
    for (var x = 0; x <= play.width; x++) {
      canvas.drawLine(Offset(m.tray.left + x * m.cell, m.tray.top), Offset(m.tray.left + x * m.cell, m.tray.bottom), grid);
    }
    for (var y = 0; y <= play.height; y++) {
      canvas.drawLine(Offset(m.tray.left, m.tray.top + y * m.cell), Offset(m.tray.right, m.tray.top + y * m.cell), grid);
    }
    // The fours laid, each its own shade of icing so alike fours read apart.
    for (var i = 0; i < play.laid.length; i++) {
      final (k, o, x0, y0) = play.laid[i];
      _four(canvas, k, Rules.orientations(k)[o], Offset(m.tray.left + x0 * m.cell, m.tray.top + y0 * m.cell), m.cell, tint: i);
    }
    // The pointer on the tray.
    if (pointing != null && pointing!.$1 == Aim.cell && play.held != null) {
      final shape = Rules.orientations(play.held!)[play.facing];
      for (final c in shape) {
        canvas.drawRect(Rect.fromLTWH(m.tray.left + (pointing!.$2 + c.$1) * m.cell, m.tray.top + (pointing!.$3 + c.$2) * m.cell, m.cell, m.cell).deflate(1), Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
    if (pointing != null && pointing!.$1 == Aim.lift) {
      final i = play.fourAt(pointing!.$2, pointing!.$3);
      if (i != null) {
        final (k, o, x0, y0) = play.laid[i];
        for (final c in Rules.orientations(k)[o]) {
          canvas.drawRect(Rect.fromLTWH(m.tray.left + (x0 + c.$1) * m.cell, m.tray.top + (y0 + c.$2) * m.cell, m.cell, m.cell).deflate(1), Paint()
            ..color = Palette.lift
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
        }
      }
    }
    if (bare || play.isOver) return;

    // The bag.
    canvas.drawLine(Offset(size.width * 0.03, m.bagTop), Offset(size.width * 0.97, m.bagTop), Paint()
      ..color = Palette.line
      ..strokeWidth = 2);
    for (var k = 0; k < Rules.kinds.length; k++) {
      final slot = m.slots[k]!;
      final leftOver = play.left(k);
      final shape = play.held == k ? Rules.orientations(k)[play.facing] : Rules.orientations(k)[0];
      final sw = (shape.map((c) => c.$1).reduce(math.max) + 1) * m.bagCell;
      final sh = (shape.map((c) => c.$2).reduce(math.max) + 1) * m.bagCell;
      final origin = Offset(slot.center.dx - sw / 2, slot.top + (slot.height * 0.72 - sh) / 2);
      if (leftOver == 0) {
        for (final c in shape) {
          canvas.drawRect(Rect.fromLTWH(origin.dx + c.$1 * m.bagCell, origin.dy + c.$2 * m.bagCell, m.bagCell, m.bagCell).deflate(1), Paint()
            ..color = Palette.tinLine
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
        }
      } else {
        _four(canvas, k, shape, origin, m.bagCell);
      }
      _write(canvas, '${Rules.kindNames[k]} x$leftOver', Offset(slot.center.dx, slot.bottom - 10), labels.copyWith(color: leftOver == 0 ? Palette.inkDim : Palette.ink, fontSize: 10));
      if (play.held == k) {
        canvas.drawRRect(RRect.fromRectAndRadius(slot.deflate(3), const Radius.circular(6)), Paint()
          ..color = Palette.held
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
      if (pointing != null && pointing!.$1 == Aim.tray && pointing!.$2 == k) {
        canvas.drawRRect(RRect.fromRectAndRadius(slot.deflate(1), const Radius.circular(7)), Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
  }

  /// A four of kind [k] in shape [shape], its top left cell at [origin],
  /// each cell [cell] wide: one piece of gingerbread, its cells joined,
  /// with icing on each cell; [tint] picks the icing for a laid four.
  void _four(Canvas canvas, int k, List<(int, int)> shape, Offset origin, double cell, {int? tint}) {
    final colour = Palette.fours[tint == null ? k : (k + tint) % Palette.fours.length];
    final gap = (cell * 0.07).clamp(1.0, 4.0);
    final crumb = Paint()..color = Palette.crumb;
    for (final c in shape) {
      final r = Rect.fromLTWH(origin.dx + c.$1 * cell, origin.dy + c.$2 * cell, cell, cell);
      canvas.drawRect(r.deflate(gap), crumb);
      // Bridge to the cell on the right and the cell below when the
      // piece has them, so the four reads as one biscuit.
      if (shape.contains((c.$1 + 1, c.$2))) {
        canvas.drawRect(Rect.fromLTWH(r.right - gap - 1, r.top + gap, 2 * gap + 2, cell - 2 * gap), crumb);
      }
      if (shape.contains((c.$1, c.$2 + 1))) {
        canvas.drawRect(Rect.fromLTWH(r.left + gap, r.bottom - gap - 1, cell - 2 * gap, 2 * gap + 2), crumb);
      }
      if (shape.contains((c.$1 + 1, c.$2)) && shape.contains((c.$1, c.$2 + 1)) && shape.contains((c.$1 + 1, c.$2 + 1))) {
        canvas.drawRect(Rect.fromLTWH(r.right - gap - 1, r.bottom - gap - 1, 2 * gap + 2, 2 * gap + 2), crumb);
      }
    }
    for (final c in shape) {
      final r = Rect.fromLTWH(origin.dx + c.$1 * cell, origin.dy + c.$2 * cell, cell, cell);
      canvas.drawRRect(RRect.fromRectAndRadius(r.deflate(cell * 0.24), Radius.circular(cell * 0.12)), Paint()..color = colour);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(TrayView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'Gingerbread fours, the five tetrominoes: the bar, the square, the tee, '
      'the skew and the elbow, turned and flipped as you like, laid on a tray to '
      'fill it exactly. Every filling is found by laying a four over the first bare '
      'cell, top row first, since whatever covers that cell has its earliest cell '
      'there, and found again column by column. Chequer the tray, and every four '
      'but the tee covers two dark and two light cells whichever way it lies, while '
      'the tee covers three of one shade and one of the other: so a tray of equal '
      'dark and light needs an even count of tees, and the colouring is checked on '
      'every bag; six tees on the six-by-four and four skews on the four-by-four '
      'pass the colouring and still fill nothing, which only the search can say.';
  return '$law ${level.note}';
}

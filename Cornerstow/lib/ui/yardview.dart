import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../yard/play.dart';
import 'palette.dart';

/// Where things lie on the board: the yard in the top part, cell by
/// cell, and the tray of flag kinds along the bottom, each with its
/// count.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    final side = play.side;
    final whole = bare || play.isOver;
    final yardRoomH = whole ? room.height : room.height * 0.72;
    cell = math.min(room.width * (bare ? 1 : 0.94) / side, yardRoomH * (bare ? 1 : 0.96) / side);
    final size = cell * side;
    yard = Rect.fromLTWH((room.width - size) / 2, whole ? (room.height - size) / 2 : math.max(room.height * 0.02, (yardRoomH - size) / 2), size, size);
    trayTop = room.height * 0.75;
    trayHeight = room.height * 0.25;
    // The tray: one slot a kind, at the yard's scale but never too small
    // to tap, shrunk together if they crowd.
    final kinds = play.kinds;
    var sizes = kinds.map((k) => (math.max(math.max(k.$1, k.$2) * cell, 26.0)).clamp(0.0, trayHeight * 0.7)).toList();
    const gap = 10.0;
    final total = sizes.fold(0.0, (sum, s) => sum + s) + gap * (kinds.length + 1);
    if (total > room.width) {
      final shrink = (room.width - gap * (kinds.length + 1)) / (total - gap * (kinds.length + 1));
      sizes = sizes.map((s) => s * shrink).toList();
    }
    var x = (room.width - (sizes.fold(0.0, (sum, s) => sum + s) + gap * (kinds.length - 1))) / 2;
    for (var i = 0; i < kinds.length; i++) {
      final s = sizes[i];
      final (w, h, _, _) = kinds[i];
      final longest = math.max(w, h);
      final drawnW = s * w / longest, drawnH = s * h / longest;
      trayRects[i] = Rect.fromLTWH(x + (s - drawnW) / 2, trayTop + (trayHeight * 0.85 - drawnH) / 2, drawnW, drawnH);
      traySlots[i] = Rect.fromLTWH(x, trayTop, s, trayHeight);
      x += s + gap;
    }
  }

  final Play play;

  late final double width;
  late final double height;

  /// One cell of the yard, in pixels.
  late final double cell;

  /// The yard, as laid out.
  late final Rect yard;
  late final double trayTop;
  late final double trayHeight;

  /// Each tray kind's drawn flag, and its whole slot, by kind.
  final trayRects = <int, Rect>{};
  final traySlots = <int, Rect>{};

  /// The rectangle of a flag [w] by [h] laid at (x, y).
  Rect flagRect(int w, int h, int x, int y) => Rect.fromLTWH(yard.left + x * cell, yard.top + y * cell, w * cell, h * cell);

  /// The middle of yard cell (x, y).
  Offset cellAt(int x, int y) => Offset(yard.left + (x + 0.5) * cell, yard.top + (y + 0.5) * cell);

  /// The middle of tray kind [i].
  Offset trayAt(int i) => traySlots[i]!.center;

  /// What is under a touch: (0, x, y) a yard cell, (1, kind, 0) a tray
  /// kind, or null.
  (int, int, int)? under(Offset touch) {
    for (final e in traySlots.entries) {
      if (e.value.contains(touch)) return (1, e.key, 0);
    }
    if (yard.contains(touch)) {
      final x = ((touch.dx - yard.left) / cell).floor().clamp(0, play.side - 1);
      final y = ((touch.dy - yard.top) / cell).floor().clamp(0, play.side - 1);
      return (0, x, y);
    }
    return null;
  }
}

/// The yard and the tray: laid flags as stone squares and halves, the
/// earth bare where nothing lies, the tray's kinds waiting with counts.
class YardView extends CustomPainter {
  YardView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words and the tray off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.dusk);
    // The yard.
    canvas.drawRect(m.yard, Paint()..color = Palette.earth);
    final every = m.cell >= 7 ? 1 : 5;
    final grid = Paint()
      ..color = Palette.earthLine
      ..strokeWidth = 1;
    for (var x = 0; x <= play.side; x += every) {
      canvas.drawLine(Offset(m.yard.left + x * m.cell, m.yard.top), Offset(m.yard.left + x * m.cell, m.yard.bottom), grid);
    }
    for (var y = 0; y <= play.side; y += every) {
      canvas.drawLine(Offset(m.yard.left, m.yard.top + y * m.cell), Offset(m.yard.right, m.yard.top + y * m.cell), grid);
    }
    // The flags laid.
    for (final (kind, w, h, x, y) in play.laid) {
      _flag(canvas, m.flagRect(w, h, x, y), play.kinds[kind].$3, half: w != h);
    }
    // The pointer on the yard: the cell the held flag goes to, or the
    // flag to lift.
    if (pointing != null && pointing!.$1 == Aim.cell && play.heldShape != null) {
      final (w, h) = play.heldShape!;
      canvas.drawRect(m.flagRect(w, h, pointing!.$2, pointing!.$3).deflate(1), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    if (pointing != null && pointing!.$1 == Aim.lift) {
      final i = play.flagAt(pointing!.$2, pointing!.$3);
      if (i != null) {
        final (_, w, h, x, y) = play.laid[i];
        canvas.drawRect(m.flagRect(w, h, x, y).deflate(1), Paint()
          ..color = Palette.lift
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
    canvas.drawRect(m.yard, Paint()
      ..color = Palette.grout
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    if (bare || play.isOver) return;

    // The tray.
    canvas.drawLine(Offset(size.width * 0.03, m.trayTop), Offset(size.width * 0.97, m.trayTop), Paint()
      ..color = Palette.rail
      ..strokeWidth = 2);
    for (final e in m.trayRects.entries) {
      final kind = e.key;
      final (w, h, k, _) = play.kinds[kind];
      final rect = e.value;
      final leftOver = play.left(kind);
      // A held half is drawn the way up it would lie.
      final drawn = play.held == kind && w != h && play.upright ? Rect.fromCenter(center: rect.center, width: rect.height, height: rect.width) : rect;
      if (leftOver == 0) {
        canvas.drawRect(drawn, Paint()
          ..color = Palette.earthLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
      } else {
        _flag(canvas, drawn, k, half: w != h);
      }
      final slot = m.traySlots[kind]!;
      _write(canvas, 'x$leftOver', Offset(slot.center.dx, slot.bottom - 8), labels.copyWith(color: leftOver == 0 ? Palette.inkDim : Palette.ink, fontSize: 11));
      if (play.held == kind) {
        canvas.drawRect(drawn.inflate(3), Paint()
          ..color = Palette.held
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
      if (pointing != null && pointing!.$1 == Aim.tray && pointing!.$2 == kind) {
        canvas.drawRect(drawn.inflate(6), Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
  }

  void _flag(Canvas canvas, Rect rect, int k, {bool half = false}) {
    final colour = Palette.flags[(k - 1) % Palette.flags.length];
    canvas.drawRect(rect, Paint()..color = Palette.grout);
    final inset = (rect.shortestSide * 0.06).clamp(1.0, 4.0);
    canvas.drawRect(rect.deflate(inset), Paint()..color = half ? colour.withValues(alpha: 0.72) : colour);
    if (!bare && rect.shortestSide >= 16) {
      _write(canvas, '$k', rect.center, labels.copyWith(color: Palette.night.withValues(alpha: 0.7), fontSize: (rect.shortestSide * 0.4).clamp(9.0, 22.0), fontWeight: FontWeight.w800));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(YardView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'One flag of one, two of two, three of three and on to n of n, each k of '
      'them a square k by k, come to the cubes of one to n summed, and that is the '
      'square of one to n summed: Nicomachus\'s theorem, checked to a hundred. The '
      'picture proof paves the square yard band by band round the corner: band k '
      'is k wide and its two arms run k times k/2 plus half a k, so odd k lays k '
      'whole flags and even k lays k - 1 whole and two halves, one at the end of '
      'each arm; and that paving is laid here by formula and paves every yard to '
      'the thirty-six-by-thirty-six. Every paving of every yard is found by laying '
      'a flag at the first bare cell, top row first, and found again column by '
      'column.';
  return '$law ${level.note}';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wall/play.dart';
import 'palette.dart';

/// Where things lie on the board, so the screen and the tests can find
/// them: the wall in the top part, cell by cell, and the tray of frames
/// still to hang along the bottom.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    final w = play.level.width, h = play.level.height;
    // Once the ask is over the tray is gone and the wall has the room.
    final whole = bare || play.isOver;
    final wallRoomH = whole ? room.height : room.height * 0.72;
    cell = math.min(room.width * (bare ? 1 : 0.94) / w, wallRoomH * (bare ? 1 : 0.96) / h);
    final wallW = cell * w, wallH = cell * h;
    wall = Rect.fromLTWH((room.width - wallW) / 2, whole ? (room.height - wallH) / 2 : math.max(room.height * 0.02, (wallRoomH - wallH) / 2), wallW, wallH);
    trayTop = room.height * 0.75;
    trayHeight = room.height * 0.25;
    // The tray: the frames still to hang, largest first, at the wall's
    // scale but never too small to tap, shrunk together if they crowd.
    final tray = play.tray;
    var sides = tray.map((s) => math.max(s * cell, 26.0).clamp(0.0, trayHeight * 0.8)).toList();
    const gap = 8.0;
    final total = sides.fold(0.0, (sum, s) => sum + s) + gap * (tray.length + 1);
    if (total > room.width) {
      final shrink = (room.width - gap * (tray.length + 1)) / (total - gap * (tray.length + 1));
      sides = sides.map((s) => s * shrink).toList();
    }
    var x = (room.width - (sides.fold(0.0, (sum, s) => sum + s) + gap * (tray.length - 1))) / 2;
    for (var i = 0; i < tray.length; i++) {
      final side = sides[i];
      trayRects[tray[i]] = Rect.fromLTWH(x, trayTop + (trayHeight - side) / 2, side, side);
      x += side + gap;
    }
  }

  final Play play;

  late final double width;
  late final double height;

  /// One cell of the wall, in pixels.
  late final double cell;

  /// The wall, as laid out.
  late final Rect wall;
  late final double trayTop;
  late final double trayHeight;

  /// Each tray frame's rectangle, by size.
  final trayRects = <int, Rect>{};

  /// The rectangle of a frame of [s] hung at (x, y).
  Rect frameRect(int s, int x, int y) => Rect.fromLTWH(wall.left + x * cell, wall.top + y * cell, s * cell, s * cell);

  /// The middle of wall cell (x, y).
  Offset cellAt(int x, int y) => Offset(wall.left + (x + 0.5) * cell, wall.top + (y + 0.5) * cell);

  /// The middle of tray frame [s].
  Offset trayAt(int s) => trayRects[s]!.center;

  /// What is under a touch: (0, x, y) a wall cell, (1, s, 0) a tray
  /// frame, or null.
  (int, int, int)? under(Offset touch) {
    for (final e in trayRects.entries) {
      if (e.value.inflate(4).contains(touch)) return (1, e.key, 0);
    }
    if (wall.contains(touch)) {
      final x = ((touch.dx - wall.left) / cell).floor().clamp(0, play.level.width - 1);
      final y = ((touch.dy - wall.top) / cell).floor().clamp(0, play.level.height - 1);
      return (0, x, y);
    }
    return null;
  }
}

/// The wall and the tray: hung frames as wooden squares round pictures,
/// the plaster bare where nothing hangs, the tray's frames waiting.
class WallView extends CustomPainter {
  WallView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words and the tray off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.gallery);
    // The wall.
    canvas.drawRect(m.wall, Paint()..color = Palette.plaster);
    final every = m.cell >= 7 ? 1 : 5;
    final grid = Paint()
      ..color = Palette.plasterLine
      ..strokeWidth = 1;
    for (var x = 0; x <= play.level.width; x += every) {
      canvas.drawLine(Offset(m.wall.left + x * m.cell, m.wall.top), Offset(m.wall.left + x * m.cell, m.wall.bottom), grid);
    }
    for (var y = 0; y <= play.level.height; y += every) {
      canvas.drawLine(Offset(m.wall.left, m.wall.top + y * m.cell), Offset(m.wall.right, m.wall.top + y * m.cell), grid);
    }
    // The frames hung.
    final sorted = play.sizes.toList()..sort();
    for (final e in play.hung.entries) {
      _frame(canvas, m.frameRect(e.key, e.value.$1, e.value.$2), e.key, sorted.indexOf(e.key), fixed: play.level.fixed.containsKey(e.key));
    }
    // The pointer on the wall: the cell the held frame goes to, or the
    // frame to lift.
    if (pointing != null && pointing!.$1 == Aim.cell && play.held != null) {
      canvas.drawRect(m.frameRect(play.held!, pointing!.$2, pointing!.$3).deflate(1), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    if (pointing != null && pointing!.$1 == Aim.lift) {
      final s = play.frameAt(pointing!.$2, pointing!.$3);
      if (s != null) {
        canvas.drawRect(m.frameRect(s, pointing!.$2, pointing!.$3).deflate(1), Paint()
          ..color = Palette.lift
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
    canvas.drawRect(m.wall, Paint()
      ..color = Palette.wood
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
    if (bare || play.isOver) return;

    // The tray.
    canvas.drawLine(Offset(size.width * 0.03, m.trayTop), Offset(size.width * 0.97, m.trayTop), Paint()
      ..color = Palette.rail
      ..strokeWidth = 2);
    for (final e in m.trayRects.entries) {
      _frame(canvas, e.value, e.key, sorted.indexOf(e.key));
      if (play.held == e.key) {
        canvas.drawRect(e.value.inflate(3), Paint()
          ..color = Palette.held
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
      if (pointing != null && pointing!.$1 == Aim.tray && pointing!.$2 == e.key) {
        canvas.drawRect(e.value.inflate(5), Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
    if (m.trayRects.isEmpty) {
      _write(canvas, 'the tray is empty', Offset(size.width / 2, m.trayTop + m.trayHeight / 2), labels.copyWith(color: Palette.inkDim, fontSize: 13));
    }
  }

  void _frame(Canvas canvas, Rect rect, int size, int index, {bool fixed = false}) {
    final border = (rect.width * 0.09).clamp(1.5, 7.0);
    canvas.drawRect(rect, Paint()..color = fixed ? Palette.woodFixed : Palette.wood);
    final inner = rect.deflate(border);
    canvas.drawRect(inner, Paint()..color = Palette.mount);
    final picture = inner.deflate((inner.width * 0.12).clamp(1.0, 8.0));
    canvas.drawRect(picture, Paint()..color = Palette.pictures[index % Palette.pictures.length].withValues(alpha: fixed ? 0.7 : 1));
    if (!bare && picture.width >= 13) {
      _write(canvas, '$size', picture.center, labels.copyWith(color: Palette.night.withValues(alpha: 0.75), fontSize: (picture.width * 0.42).clamp(9.0, 22.0), fontWeight: FontWeight.w800));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(WallView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'Square frames no two alike, hung edge to edge to fill a wall exactly, '
      'make a perfect squared rectangle. Every hanging is found by hanging a frame at '
      'the first bare cell, top row first, since whatever covers that cell must have '
      'its top left corner there, and found again column by column: the thirty-two by '
      'thirty-three wall of nine has 4 hangings, one but for turning and mirroring, '
      'and so have the sixty-one by sixty-nine of nine and the forty-seven by '
      'sixty-five of ten. The smallest frame is never on the rim: there it would have '
      'a taller frame on either side along the edge, or one and the wall\'s corner, '
      'so it would sit at the bottom of a well as wide as itself, and whatever '
      'covered the cell above it would have to fit the well, so be no wider than it, '
      'and every other frame is wider.';
  return '$law ${level.note}';
}

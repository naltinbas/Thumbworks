import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../board/play.dart';
import '../board/rules.dart';
import 'palette.dart';

/// Where the squares lie on the board, so the screen and the tests can
/// find every one.
class Metrics {
  Metrics(this.play, Size room) {
    side = play.level.side;
    pitch = math.min(room.width, room.height) * 0.84 / side;
    origin = Offset(
      (room.width - pitch * side) / 2,
      (room.height - pitch * side) / 2,
    );
  }

  final Play play;

  late final int side;
  late final double pitch;
  late final Offset origin;

  Offset at(Square s) => Offset(
        origin.dx + (s.$2 + 0.5) * pitch,
        origin.dy + (s.$1 + 0.5) * pitch,
      );

  /// The square under a touch, or null off the board.
  Square? under(Offset touch) {
    final c = ((touch.dx - origin.dx) / pitch).floor();
    final r = ((touch.dy - origin.dy) / pitch).floor();
    if (r < 0 || r >= side || c < 0 || c >= side) return null;
    return (r, c);
  }
}

/// The board itself: the squares, the two lonely corners marked, the
/// bishops as mitres, and every clash struck along its diagonal.
class BoardView extends CustomPainter {
  BoardView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Square)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final pitch = m.pitch;
    final side = m.side;
    final board = Rect.fromLTWH(m.origin.dx, m.origin.dy, pitch * side, pitch * side);

    // The frame and the squares.
    canvas.drawRRect(RRect.fromRectAndRadius(board.inflate(pitch * 0.14), Radius.circular(pitch * 0.1)),
        Paint()..color = Palette.frame);
    for (var r = 0; r < side; r++) {
      for (var c = 0; c < side; c++) {
        canvas.drawRect(Rect.fromLTWH(board.left + c * pitch, board.top + r * pitch, pitch, pitch),
            Paint()..color = (r + c).isEven ? Palette.light : Palette.dark);
      }
    }
    // The two lonely corners, the single-square rising diagonals, and
    // the long falling diagonal they share, faint.
    canvas.drawLine(m.at((0, 0)), m.at((side - 1, side - 1)), Paint()
      ..color = Palette.lonely.withValues(alpha: 0.35)
      ..strokeWidth = math.max(2, pitch * 0.05));
    for (final corner in [(0, 0), (side - 1, side - 1)]) {
      canvas.drawCircle(m.at(corner), pitch * 0.1, Paint()..color = Palette.lonely.withValues(alpha: 0.7));
    }

    // The clashes, struck along their diagonals.
    for (final (i, j) in play.clashes) {
      canvas.drawLine(m.at(play.bishops[i]), m.at(play.bishops[j]), Paint()
        ..color = Palette.clash.withValues(alpha: 0.85)
        ..strokeWidth = math.max(3, pitch * 0.09)
        ..strokeCap = StrokeCap.round);
    }

    // The bishops.
    for (var i = 0; i < play.bishops.length; i++) {
      final s = play.bishops[i];
      _mitre(canvas, m.at(s), pitch, play.isGiven(s));
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: m.at(aim.$2), width: pitch * 0.9, height: pitch * 0.9), Radius.circular(pitch * 0.1)),
        Paint()
          ..color = aim.$1 == 'lift' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }
  }

  void _mitre(Canvas canvas, Offset at, double pitch, bool held) {
    final h = pitch * 0.34, w = pitch * 0.2;
    final body = Path()
      ..moveTo(at.dx - w, at.dy + h * 0.75)
      ..lineTo(at.dx + w, at.dy + h * 0.75)
      ..lineTo(at.dx + w * 0.75, at.dy + h * 0.35)
      ..quadraticBezierTo(at.dx + w * 1.05, at.dy - h * 0.25, at.dx, at.dy - h)
      ..quadraticBezierTo(at.dx - w * 1.05, at.dy - h * 0.25, at.dx - w * 0.75, at.dy + h * 0.35)
      ..close();
    canvas.drawPath(body, Paint()..color = held ? Palette.held : Palette.mitre);
    canvas.drawPath(body, Paint()
      ..color = Palette.mitreEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, pitch * 0.03));
    // The slit and the ball.
    canvas.drawLine(at + Offset(w * 0.15, -h * 0.55), at + Offset(w * 0.55, -h * 0.05), Paint()
      ..color = Palette.mitreEdge
      ..strokeWidth = math.max(1, pitch * 0.03));
    canvas.drawCircle(at + Offset(0, -h * 1.12), pitch * 0.05, Paint()..color = held ? Palette.held : Palette.mitre);
    canvas.drawRect(Rect.fromCenter(center: at + Offset(0, h * 0.85), width: w * 2.3, height: h * 0.2),
        Paint()..color = Palette.mitreEdge);
  }

  @override
  bool shouldRepaint(BoardView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a board as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final n = level.side;
  if (!level.winnable) {
    return 'Number the rising diagonals: there are ${2 * n - 1} of them on a board '
        'of $n, and no two bishops can share one, so at most ${2 * n - 1} bishops '
        'stand. But the first and last of those diagonals are single squares, the '
        'two corners marked, and the two corners lie on one falling diagonal, so '
        'they clash and only one of them can be used: ${2 * n - 2} at the most. '
        'The sweep set ${2 * n - 1} bishops every way and found no peace, and the '
        'diagonals counted it nought first.$note';
  }
  return 'The sweep sets the bishops every way and reads each setting for a clash, '
      'and the count is read again with no sweep of squares: one bishop at most to '
      'each rising diagonal, the falling diagonals kept distinct, walked diagonal '
      'by diagonal. The two agree on every board that ships. ${level.ways} of the '
      '${level.settings} land it.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../slate/play.dart';
import '../slate/rules.dart';
import 'palette.dart';

/// Where the cells lie on the slate, so the screen and the tests can
/// find every one.
class Metrics {
  Metrics(this.play, Size room) {
    pitch = math.min(room.width, room.height) * 0.78 / 3;
    origin = Offset(
      (room.width - pitch * 3) / 2,
      (room.height - pitch * 3) / 2,
    );
  }

  final Play play;

  late final double pitch;
  late final Offset origin;

  Offset at(int cell) => Offset(
        origin.dx + (cell % 3 + 0.5) * pitch,
        origin.dy + (cell ~/ 3 + 0.5) * pitch,
      );

  /// The cell under a touch, or null off the slate.
  int? under(Offset touch) {
    final x = ((touch.dx - origin.dx) / pitch).floor();
    final y = ((touch.dy - origin.dy) / pitch).floor();
    if (x < 0 || x > 2 || y < 0 || y > 2) return null;
    return y * 3 + x;
  }
}

/// The slate itself: the frame, the chalk grid, the marks, the book's
/// last mark ringed, and the line of three struck through when made.
class SlateView extends CustomPainter {
  SlateView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// The cell the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;
    final board = Rect.fromLTWH(metrics.origin.dx, metrics.origin.dy, pitch * 3, pitch * 3);

    // The frame and the slate.
    final frame = board.inflate(pitch * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(pitch * 0.12)),
      Paint()..color = Palette.frame,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(pitch * 0.12)),
      Paint()
        ..color = Palette.frameEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, pitch * 0.025),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(board.inflate(pitch * 0.05), Radius.circular(pitch * 0.05)),
      Paint()..color = Palette.slate,
    );

    // The chalk grid, drawn twice a hair apart, the way chalk goes on.
    for (final alpha in [0.55, 0.35]) {
      final chalk = Paint()
        ..color = Palette.chalk.withValues(alpha: alpha)
        ..strokeWidth = math.max(1.5, pitch * 0.035)
        ..strokeCap = StrokeCap.round;
      final nudge = alpha == 0.55 ? 0.0 : pitch * 0.012;
      for (var k = 1; k < 3; k++) {
        final x = board.left + k * pitch + nudge;
        final y = board.top + k * pitch - nudge;
        canvas.drawLine(Offset(x, board.top + pitch * 0.08), Offset(x, board.bottom - pitch * 0.08), chalk);
        canvas.drawLine(Offset(board.left + pitch * 0.08, y), Offset(board.right - pitch * 0.08, y), chalk);
      }
    }

    // The marks.
    final stroke = math.max(3.0, pitch * 0.09);
    for (var cell = 0; cell < 9; cell++) {
      final mark = play.board[cell];
      if (mark == 0) continue;
      final at = metrics.at(cell);
      final r = pitch * 0.27;
      if (mark == Rules.cross) {
        final paint = Paint()
          ..color = Palette.cross
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(at + Offset(-r, -r * 0.94), at + Offset(r, r * 1.02), paint);
        canvas.drawLine(at + Offset(r * 0.98, -r), at + Offset(-r * 1.02, r * 0.96), paint);
      } else {
        canvas.drawArc(
          Rect.fromCircle(center: at, radius: r),
          -math.pi * 0.35,
          math.pi * 1.94,
          false,
          Paint()
            ..color = Palette.nought
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // The book's last mark, ringed faint.
    final bookCell = play.bookCell;
    if (bookCell != null && !play.isOver) {
      canvas.drawCircle(
        metrics.at(bookCell),
        pitch * 0.42,
        Paint()
          ..color = Palette.books.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, pitch * 0.03),
      );
    }

    // The line of three, struck through.
    final line = Rules.winningLine(play.board);
    if (line != null) {
      final a = metrics.at(line.first), b = metrics.at(line.last);
      final dir = (b - a) / (b - a).distance;
      canvas.drawLine(
        a - dir * pitch * 0.34,
        b + dir * pitch * 0.34,
        Paint()
          ..color = (play.won ? Palette.mine : Palette.books).withValues(alpha: 0.85)
          ..strokeWidth = math.max(4, pitch * 0.13)
          ..strokeCap = StrokeCap.round,
      );
    }

    // The pointer.
    if (pointing != null) {
      canvas.drawCircle(
        metrics.at(pointing!),
        pitch * 0.42,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }
  }

  @override
  bool shouldRepaint(SlateView old) => old.play != play || old.pointing != pointing;
}

/// The tree's word, spoken from your side.
String valueWords(int value) => value == 0
    ? 'level'
    : value == 1
        ? 'a win for you'
        : 'a win for the book';

/// The why, spoken for a slate as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'The tree of noughts and crosses is small enough to walk whole: '
        '255,168 games over 5,478 slates, and its word on the open slate is '
        'level, so no first move forces a win. The book plays no search at '
        'all, eight rules tried in order, and every game against it from the '
        'open slate was played out; the book keeps the tree\'s word at every '
        'move, so it never loses. Crosses can never be forced to lose either: '
        'if noughts had a winning way, crosses could take it first, a move '
        'early, since a spare cross on the slate never hurts.$note';
  }
  return 'The tree reads the slate as it stands as ${valueWords(play.value)} '
      'from your side, and every game against the book from the start was '
      'played out: ${level.ways} of the ${level.games} land it. The book '
      'keeps the tree\'s word at every move, so what the tree promises you, '
      'you must take yourself.$note';
}

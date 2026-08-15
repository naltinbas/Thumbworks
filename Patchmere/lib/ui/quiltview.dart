import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../quilt/play.dart';
import '../quilt/rules.dart';
import 'palette.dart';

/// Where the cells lie on the quilt, so the screen and the tests can
/// find every one.
class Metrics {
  Metrics(this.play, Size room) {
    final quilt = play.quilt;
    pitch = math.min(room.width * 0.86 / quilt.cols, room.height * 0.86 / quilt.rows);
    origin = Offset(
      (room.width - pitch * quilt.cols) / 2,
      (room.height - pitch * quilt.rows) / 2,
    );
  }

  final Play play;

  late final double pitch;
  late final Offset origin;

  Offset at(int cell) => Offset(
        origin.dx + (play.quilt.colOf(cell) + 0.5) * pitch,
        origin.dy + (play.quilt.rowOf(cell) + 0.5) * pitch,
      );

  /// The rectangle a patch covers.
  Rect patchRect(Patch patch) {
    final a = at(patch.$1), b = at(patch.$2);
    return Rect.fromPoints(a, b).inflate(pitch / 2);
  }

  /// The cell under a touch, or null off the quilt.
  int? under(Offset touch) {
    final c = ((touch.dx - origin.dx) / pitch).floor();
    final r = ((touch.dy - origin.dy) / pitch).floor();
    if (c < 0 || c >= play.quilt.cols || r < 0 || r >= play.quilt.rows) return null;
    return play.quilt.cell(r, c);
  }
}

/// The quilt itself: the frame, the calico cells, every patch sewn
/// with its number, the house's last patch ringed, the middle pinned,
/// and the held cell marked.
class QuiltView extends CustomPainter {
  QuiltView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// The patch the show-me points at, or null.
  final Patch? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;
    final quilt = play.quilt;
    final board = Rect.fromLTWH(
        metrics.origin.dx, metrics.origin.dy, pitch * quilt.cols, pitch * quilt.rows);

    // The frame and the calico.
    final frame = board.inflate(pitch * 0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(pitch * 0.14)),
      Paint()..color = Palette.frame,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, Radius.circular(pitch * 0.14)),
      Paint()
        ..color = Palette.frameEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, pitch * 0.03),
    );
    for (var cell = 0; cell < quilt.cells; cell++) {
      final r = quilt.rowOf(cell), c = quilt.colOf(cell);
      final rect = Rect.fromLTWH(board.left + c * pitch, board.top + r * pitch, pitch, pitch);
      canvas.drawRect(rect, Paint()..color = (r + c).isEven ? Palette.calico : Palette.calicoDim);
    }
    // The tacking between cells.
    final tack = Paint()
      ..color = Palette.stitch
      ..strokeWidth = math.max(1, pitch * 0.02);
    for (var c = 1; c < quilt.cols; c++) {
      _dashed(canvas, Offset(board.left + c * pitch, board.top), Offset(board.left + c * pitch, board.bottom), tack, pitch * 0.12);
    }
    for (var r = 1; r < quilt.rows; r++) {
      _dashed(canvas, Offset(board.left, board.top + r * pitch), Offset(board.right, board.top + r * pitch), tack, pitch * 0.12);
    }

    // The patches, in the order sewn, each with its number.
    for (var i = 0; i < play.patches.length; i++) {
      final (patch, mine) = play.patches[i];
      final rect = metrics.patchRect(patch).deflate(pitch * 0.07);
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.1));
      canvas.drawRRect(rr, Paint()..color = mine ? Palette.mine : Palette.houses);
      // A lighter square in each cell of the patch, calico-fashion.
      for (final cell in [patch.$1, patch.$2]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: metrics.at(cell), width: pitch * 0.42, height: pitch * 0.42),
              Radius.circular(pitch * 0.06)),
          Paint()..color = (mine ? Palette.mineLight : Palette.housesLight).withValues(alpha: 0.55),
        );
      }
      // The running stitch round the patch.
      _dashedRect(canvas, rect.deflate(pitch * 0.09), Paint()
        ..color = Palette.thread
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, pitch * 0.025), pitch * 0.1);
      _write(canvas, '${i + 1}', metrics.patchRect(patch).center,
          labels.copyWith(color: Palette.thread, fontSize: pitch * 0.3, fontWeight: FontWeight.w800));
    }

    // The house's last patch, ringed faint.
    final last = play.houseLast;
    if (last != null && !play.isOver) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(metrics.patchRect(last).deflate(pitch * 0.02), Radius.circular(pitch * 0.12)),
        Paint()
          ..color = Palette.houses.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.5, pitch * 0.035),
      );
    }

    // The middle of the quilt, pinned.
    canvas.drawCircle(board.center, pitch * 0.07, Paint()..color = Palette.pin);
    canvas.drawCircle(board.center, pitch * 0.11, Paint()
      ..color = Palette.pin.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, pitch * 0.02));

    // The held cell.
    final held = play.held;
    if (held != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: metrics.at(held), width: pitch * 0.86, height: pitch * 0.86),
            Radius.circular(pitch * 0.1)),
        Paint()
          ..color = Palette.pin
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }

    // The pointer.
    if (pointing != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(metrics.patchRect(pointing!).deflate(pitch * 0.05), Radius.circular(pitch * 0.12)),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint, double dash) {
    final length = (b - a).distance;
    final dir = (b - a) / length;
    var t = 0.0;
    while (t < length) {
      final end = math.min(t + dash, length);
      canvas.drawLine(a + dir * t, a + dir * end, paint);
      t += dash * 2;
    }
  }

  void _dashedRect(Canvas canvas, Rect rect, Paint paint, double dash) {
    _dashed(canvas, rect.topLeft, rect.topRight, paint, dash);
    _dashed(canvas, rect.topRight, rect.bottomRight, paint, dash);
    _dashed(canvas, rect.bottomRight, rect.bottomLeft, paint, dash);
    _dashed(canvas, rect.bottomLeft, rect.topLeft, paint, dash);
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(QuiltView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a quilt as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'The middle of the quilt is pinned. Every cell has a cell across the '
        'middle from it, and every patch a patch across; on a quilt even both '
        'ways no patch is its own mirror, because a patch\'s middle sits on a '
        'seam between two cells and the quilt\'s middle sits on a corner where '
        'four meet. So when you sew a patch, its mirror is two free cells, and '
        'the house sews it; the quilt stays a mirror of itself, and the house '
        'is never the one without a patch. Every game against it was sewn '
        'out, and the tree of the quilt agrees.$note';
  }
  return 'The tree of the quilt reads it as ${play.youWin ? 'yours' : 'the house\'s'} '
      'to sew last with best play from here, and every game against the '
      'house from the start was sewn out: ${level.ways} of the ${level.games} '
      'are yours. Where a mirror wins, the show-me points at it.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../plank/play.dart';
import 'palette.dart';

/// Where the pens lie on the board, so the screen and the tests can
/// find every one.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.rules.length;
    pitch = math.min(room.width * 0.92 / n, room.height * 0.3);
    left = (room.width - pitch * n) / 2;
    top = room.height * 0.5 - pitch * 0.5;
  }

  final Play play;

  late final double pitch;
  late final double left;
  late final double top;

  Rect penRect(int pen) => Rect.fromLTWH(left + pen * pitch, top, pitch, pitch);

  Offset at(int pen) => penRect(pen).center;

  /// The pen under a touch, or null off the plank.
  int? under(Offset touch) {
    final i = ((touch.dx - left) / pitch).floor();
    if (i < 0 || i >= play.rules.length) return null;
    if (touch.dy < top - pitch * 0.4 || touch.dy > top + pitch * 1.4) return null;
    return i;
  }
}

/// The plank itself: the pens in a row, sheep and goats facing one
/// another, the empty pen dark, the movers ringed, and the order
/// written beneath.
class PlankView extends CustomPainter {
  PlankView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// The pen the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;
    final n = play.rules.length;

    // The grass and the plank.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.02, size.height * 0.08, size.width * 0.96, size.height * 0.84),
          Radius.circular(pitch * 0.3)),
      Paint()..color = Palette.grass,
    );
    final plank = Rect.fromLTWH(metrics.left, metrics.top, pitch * n, pitch).inflate(pitch * 0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plank, Radius.circular(pitch * 0.12)),
      Paint()..color = Palette.plank,
    );
    for (var pen = 0; pen < n; pen++) {
      final rect = metrics.penRect(pen).deflate(pitch * 0.06);
      final empty = play.plank[pen] == '_';
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.1)),
        Paint()..color = empty ? Palette.penEmpty : Palette.pen,
      );
    }

    // The beasts, facing the way they go.
    for (var pen = 0; pen < n; pen++) {
      final kind = play.plank[pen];
      if (kind == '_') continue;
      final at = metrics.at(pen);
      final sheep = kind == 'S';
      final body = Paint()..color = sheep ? Palette.sheep : Palette.goat;
      canvas.drawOval(
        Rect.fromCenter(center: at, width: pitch * 0.62, height: pitch * 0.46),
        body,
      );
      // The head, on the side it faces.
      final headX = at.dx + (sheep ? 1 : -1) * pitch * 0.3;
      canvas.drawCircle(Offset(headX, at.dy - pitch * 0.06), pitch * 0.14, body);
      canvas.drawCircle(
        Offset(headX + (sheep ? 1 : -1) * pitch * 0.05, at.dy - pitch * 0.08),
        pitch * 0.03,
        Paint()..color = sheep ? Palette.sheepInk : Palette.goatInk,
      );
      _write(
        canvas,
        sheep ? 'S' : 'G',
        at + Offset(-(sheep ? 1 : -1) * pitch * 0.05, pitch * 0.02),
        labels.copyWith(
          color: sheep ? Palette.sheepInk : Palette.goatInk,
          fontSize: pitch * 0.22,
          fontWeight: FontWeight.w800,
        ),
      );
    }

    // The movers, ringed gold.
    for (final pen in play.movers) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(metrics.penRect(pen).deflate(pitch * 0.02), Radius.circular(pitch * 0.12)),
        Paint()
          ..color = Palette.mover
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.04),
      );
    }

    // The pointer.
    if (pointing != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(metrics.penRect(pointing!).inflate(pitch * 0.06), Radius.circular(pitch * 0.14)),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
    }

    // The order along the plank.
    _write(
      canvas,
      'along the plank: ${play.order.split('').join(' ')}',
      Offset(size.width / 2, metrics.top + pitch * 1.6),
      labels.copyWith(color: Palette.inkDim, fontSize: math.max(10, pitch * 0.26)),
    );
    _write(
      canvas,
      'sheep face right, goats face left',
      Offset(size.width / 2, metrics.top - pitch * 0.6),
      labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, pitch * 0.22)),
    );
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(PlankView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a crossing as it stands.
String whyWords(Play play) {
  final crossing = play.crossing;
  final note = crossing.note == null ? '' : ' ${crossing.note}';
  if (!crossing.winnable) {
    return 'A step moves a beast into the empty pen beside it, so nobody '
        'ever gets past anybody: read the beasts along the plank and the '
        'order is the same after every step as before. Sheep, sheep, '
        'goat, goat can never become goat, goat, sheep, sheep. The walk '
        'tried every step from every plank it could reach, five planks in '
        'all, and stuck.$note';
  }
  return 'The crossings are counted by walking every move from every '
      'plank, no beast going back, so the walk is finite and every '
      'crossing is found; and held to a second voice: Lucas\'s arithmetic, '
      'every sheep passing every goat by exactly one jump, sheep times '
      'goats jumps, and the rest of the ground covered by steps, sheep '
      'plus goats of them, so every crossing takes the same count of '
      'moves, and the walk finds every crossing takes exactly that. '
      '${crossing.ways} crossings, ${crossing.moves} moves each.$note';
}

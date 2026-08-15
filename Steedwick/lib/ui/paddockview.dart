import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../paddock/play.dart';
import '../paddock/rules.dart';
import 'palette.dart';

/// Where the stalls lie on the board, so the screen and the tests
/// can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    pitch = math.min(room.width, room.height) * 0.86 / 3;
    origin = Offset(
      (room.width - pitch * 3) / 2,
      (room.height - pitch * 3) / 2,
    );
  }

  final Play play;

  late final double pitch;
  late final Offset origin;

  Rect rectOf(int stall) => Rect.fromLTWH(
        origin.dx + (stall % 3) * pitch,
        origin.dy + (stall ~/ 3) * pitch,
        pitch,
        pitch,
      );

  Offset at(int stall) => rectOf(stall).center;

  /// The stall under a touch, or null off the paddock.
  int? under(Offset touch) {
    final c = ((touch.dx - origin.dx) / pitch).floor();
    final r = ((touch.dy - origin.dy) / pitch).floor();
    if (c < 0 || c >= 3 || r < 0 || r >= 3) return null;
    return r * 3 + c;
  }
}

/// The paddock itself: nine stalls, the knight's ring drawn faint
/// through the outer eight, the steeds, and the rings of a pick or
/// a pointer.
class PaddockView extends CustomPainter {
  PaddockView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// (steed, stall) the show-me points at, or null.
  final (int, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;

    // The paddock.
    final paddock = Rect.fromLTWH(metrics.origin.dx, metrics.origin.dy, pitch * 3, pitch * 3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(paddock.inflate(pitch * 0.1), Radius.circular(pitch * 0.2)),
      Paint()..color = Palette.paddock,
    );
    for (var stall = 0; stall < 9; stall++) {
      final rect = metrics.rectOf(stall).deflate(pitch * 0.05);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.12)),
        Paint()..color = stall == 4 ? Palette.hay : Palette.stall,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.12)),
        Paint()
          ..color = Palette.stallRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, pitch * 0.015),
      );
    }
    _write(canvas, 'hay', metrics.at(4),
        labels.copyWith(color: Palette.paddock, fontSize: pitch * 0.2, fontWeight: FontWeight.w700));

    // The knight's ring through the outer stalls, faint.
    final ringPaint = Paint()
      ..color = Palette.ring.withValues(alpha: 0.35)
      ..strokeWidth = math.max(1.5, pitch * 0.025)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < Rules.ring.length; i++) {
      final a = metrics.at(Rules.ring[i]);
      final b = metrics.at(Rules.ring[(i + 1) % Rules.ring.length]);
      canvas.drawLine(a, b, ringPaint);
    }

    // The stalls the picked steed may move to.
    for (final stall in play.openTo) {
      canvas.drawCircle(metrics.at(stall), pitch * 0.12, Paint()..color = Palette.open.withValues(alpha: 0.8));
    }

    // The steeds.
    for (var i = 0; i < 4; i++) {
      final at = metrics.at(play.standing[i]);
      final pale = i < 2;
      canvas.drawCircle(at, pitch * 0.3, Paint()..color = pale ? Palette.pale : Palette.dark);
      canvas.drawCircle(
        at,
        pitch * 0.3,
        Paint()
          ..color = pale ? Palette.paleInk : Palette.darkInk
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, pitch * 0.02),
      );
      _write(
        canvas,
        '${i + 1}',
        at,
        labels.copyWith(
          color: pale ? Palette.paleInk : Palette.darkInk,
          fontSize: pitch * 0.3,
          fontWeight: FontWeight.w800,
        ),
      );
      if (play.picked == i) {
        canvas.drawCircle(
          at,
          pitch * 0.38,
          Paint()
            ..color = Palette.picked
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, pitch * 0.03),
        );
      }
    }

    // The pointer: the steed and the stall.
    final aim = pointing;
    if (aim != null) {
      final ring = Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, pitch * 0.03);
      canvas.drawCircle(metrics.at(play.standing[aim.$1]), pitch * 0.4, ring);
      canvas.drawCircle(metrics.at(aim.$2), pitch * 0.4, ring);
      canvas.drawLine(metrics.at(play.standing[aim.$1]), metrics.at(aim.$2), ring);
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
  bool shouldRepaint(PaddockView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for an errand as it stands.
String whyWords(Play play) {
  final errand = play.errand;
  final note = errand.note == null ? '' : ' ${errand.note}';
  if (!errand.winnable) {
    return 'Look at the faint line through the outer stalls: it is every '
        'knight\'s move there is, and it runs round in one ring, the '
        'middle stall out of reach. Steeds on a ring cannot pass one '
        'another, so their order round it never changes, whoever moves. '
        'The ride tried every move from every standing it could reach '
        'and found the pale swap nowhere.$note';
  }
  return 'The rides are counted by walking every standing a knight can '
      'reach from home, 280 of them, and taking the fewest moves to the '
      'asking, with every fewest ride counted; and held to a second '
      'voice: the ring, which says exactly which standings can be reached '
      'at all, those keeping home\'s order round it, and the walk reaches '
      'those and no others. ${errand.fewest} moves at the fewest, '
      '${errand.rides} fewest ride${errand.rides == 1 ? '' : 's'}.$note';
}

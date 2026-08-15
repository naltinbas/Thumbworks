import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../rota/play.dart';
import '../rota/rules.dart';
import 'palette.dart';

/// Where the shifts lie on the slate, so the screen and the tests
/// can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    side = play.rules.side;
    // Room for the day and station labels along the top and left.
    pitch = math.min(room.width, room.height) * 0.86 / (side + 0.7);
    origin = Offset(
      (room.width - pitch * (side + 0.7)) / 2 + pitch * 0.7,
      (room.height - pitch * (side + 0.7)) / 2 + pitch * 0.7,
    );
  }

  final Play play;

  late final int side;
  late final double pitch;
  late final Offset origin;

  /// The square of a shift, day down and station across.
  Rect rectOf(Shift shift) => Rect.fromLTWH(
        origin.dx + shift.$2 * pitch,
        origin.dy + shift.$1 * pitch,
        pitch,
        pitch,
      );

  Offset at(Shift shift) => rectOf(shift).center;

  /// The shift under a touch, or null off the slate.
  Shift? under(Offset touch) {
    final station = ((touch.dx - origin.dx) / pitch).floor();
    final day = ((touch.dy - origin.dy) / pitch).floor();
    if (station < 0 || station >= side || day < 0 || day >= side) return null;
    return (day, station);
  }
}

/// The slate itself: the rota's shifts, fixed and free, the hands
/// left for each open shift, clashes in rust, and the pointer.
class RotaView extends CustomPainter {
  RotaView({required this.play, this.pointing, required this.labels});

  final Play play;
  final (Shift, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;
    final side = metrics.side;

    // The slate behind.
    final slate = Rect.fromLTWH(
      metrics.origin.dx - pitch * 0.7,
      metrics.origin.dy - pitch * 0.7,
      pitch * (side + 0.7),
      pitch * (side + 0.7),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(slate.inflate(pitch * 0.1), Radius.circular(pitch * 0.15)),
      Paint()..color = Palette.slate,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(slate.inflate(pitch * 0.1), Radius.circular(pitch * 0.15)),
      Paint()
        ..color = Palette.slateRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, pitch * 0.02),
    );

    // The labels: days down the side, stations along the top.
    for (var k = 0; k < side; k++) {
      _write(
        canvas,
        'day ${k + 1}',
        Offset(metrics.origin.dx - pitch * 0.36, metrics.origin.dy + (k + 0.5) * pitch),
        labels.copyWith(color: Palette.label, fontSize: math.max(8, pitch * 0.17), fontWeight: FontWeight.w600),
      );
      _write(
        canvas,
        'st. ${k + 1}',
        Offset(metrics.origin.dx + (k + 0.5) * pitch, metrics.origin.dy - pitch * 0.36),
        labels.copyWith(color: Palette.label, fontSize: math.max(8, pitch * 0.17), fontWeight: FontWeight.w600),
      );
    }

    final clashes = play.clashes;
    for (final shift in play.rules.shifts) {
      final rect = metrics.rectOf(shift).deflate(pitch * 0.05);
      final fixed = play.isFixed(shift);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.1)),
        Paint()..color = fixed ? Palette.fixedCell : Palette.cell,
      );
      final hand = play.filled[shift];
      if (hand != null) {
        _write(
          canvas,
          '$hand',
          rect.center,
          labels.copyWith(
            color: fixed ? Palette.fixedHand : Palette.hand,
            fontSize: pitch * 0.5,
            fontWeight: FontWeight.w800,
          ),
        );
        if (fixed) {
          // A pin in the corner: this shift was fixed before play.
          canvas.drawCircle(
            rect.topRight + Offset(-pitch * 0.13, pitch * 0.13),
            pitch * 0.05,
            Paint()..color = Palette.fixedHand,
          );
        }
      } else {
        // The hands left for it, small, in a two by two; a rust
        // cross when none is left.
        final left = play.rules.candidates(play.filled, shift);
        if (left.isEmpty) {
          final cross = Paint()
            ..color = Palette.stuck
            ..strokeWidth = math.max(2, pitch * 0.06)
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(rect.center + Offset(-pitch * 0.18, -pitch * 0.18),
              rect.center + Offset(pitch * 0.18, pitch * 0.18), cross);
          canvas.drawLine(rect.center + Offset(pitch * 0.18, -pitch * 0.18),
              rect.center + Offset(-pitch * 0.18, pitch * 0.18), cross);
        } else {
          for (final h in left) {
            final dx = ((h - 1) % 2 == 0 ? -1 : 1) * pitch * 0.2;
            final dy = ((h - 1) ~/ 2 == 0 ? -1 : 1) * pitch * 0.2;
            _write(
              canvas,
              '$h',
              rect.center + Offset(dx, dy),
              labels.copyWith(color: Palette.candidate, fontSize: pitch * 0.2, fontWeight: FontWeight.w600),
            );
          }
        }
      }
      if (clashes.contains(shift)) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.1)),
          Paint()
            ..color = Palette.clash
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, pitch * 0.05),
        );
      }
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final rect = metrics.rectOf(aim.$1).deflate(pitch * 0.02);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(pitch * 0.12)),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.05),
      );
      _write(
        canvas,
        '${aim.$2}',
        rect.bottomRight - Offset(pitch * 0.15, pitch * 0.15),
        labels.copyWith(color: Palette.shown, fontSize: pitch * 0.2, fontWeight: FontWeight.w800),
      );
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
  bool shouldRepaint(RotaView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a rota as it stands.
String whyWords(Play play) {
  final rota = play.rota;
  final note = rota.note == null ? '' : ' ${rota.note}';
  if (!rota.winnable) {
    return 'Look at the last shift of the first day, marked with a '
        'cross: the small figures in every open shift are the hands '
        'still allowed there, and that shift has none. Every rota is '
        'finished shift by shift, and a shift with no hand for it ends '
        'the matter. The sweep tried every finishing and found '
        'none.$note';
  }
  return 'The finishings are counted by the sweep, every way of '
      'giving the open shifts a hand with no clash, the emptiest shift '
      'first, and held to a second voice: renaming the hands turns any '
      'rota into one whose first day reads 1 2 3 4, so the 576 rotas of '
      'four are 24 finishings of a fixed first day times the 24 orders '
      'of that day, and both counts are taken. ${rota.ways} '
      'rota${rota.ways == 1 ? '' : 's'} finish${rota.ways == 1 ? 'es' : ''} '
      'this one.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../show/play.dart';
import 'palette.dart';

/// Where the bench and every stall lie, shared by the painter and
/// the tests.
class Metrics {
  Metrics(this.play, Size room) {
    final stalls = play.show.marrows;
    stallWide = room.width * 0.92 / stalls;
    left = room.width * 0.04;
    benchY = room.height * 0.72;
    tall = room.height * 0.5;
  }

  final Play play;

  late final double stallWide;
  late final double left;
  late final double benchY;

  /// The tallest a marrow can stand.
  late final double tall;

  /// The middle of a stall.
  Offset stallAt(int seat) => Offset(
        left + stallWide * (seat + 0.5),
        benchY,
      );
}

/// The bench, drawn.
class ShowView extends CustomPainter {
  ShowView({required this.play, required this.labels});

  final Play play;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final show = play.show;

    // The bench plank.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          metrics.left * 0.5,
          metrics.benchY,
          size.width - metrics.left,
          size.height * 0.045,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = Palette.bench,
    );

    final judging = play.judging;

    for (var seat = 0; seat < show.marrows; seat++) {
      final stand = metrics.stallAt(seat);

      if (judging && seat >= play.shown) {
        // Not up yet: an empty stall.
        canvas.drawCircle(
          stand.translate(0, -metrics.tall * 0.05),
          metrics.stallWide * 0.06,
          Paint()
            ..color = Palette.stall
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
        continue;
      }

      // How tall this marrow stands: while judging, by rank among
      // the seen only; at the verdict, by its true size.
      final double height;
      if (judging) {
        var rank = 1;
        for (var other = 0; other < play.shown; other++) {
          if (play.deal[other] > play.deal[seat]) rank++;
        }
        height = metrics.tall * (play.shown - rank + 1) / play.shown;
      } else {
        height = metrics.tall * (play.deal[seat] + 1) / show.marrows;
      }

      final isUp = judging && seat == play.upAt;
      final wavedBy = judging && seat < play.upAt;
      _marrow(
        canvas,
        metrics,
        stand,
        height,
        color: wavedBy ? Palette.waved : Palette.marrow,
        bright: isUp,
      );

      if (isUp && play.record) {
        _rosette(canvas, stand.translate(0, -height - metrics.tall * 0.14),
            metrics.stallWide * 0.11,
            outline: true);
      }

      if (!judging) {
        if (play.deal[seat] == show.marrows - 1) {
          _rosette(
              canvas,
              stand.translate(0, -height - metrics.tall * 0.14),
              metrics.stallWide * 0.11,
              outline: false);
        }
        if (seat == play.kept) {
          canvas.drawCircle(
            stand.translate(0, -height * 0.5),
            metrics.stallWide * 0.42,
            Paint()
              ..color =
                  play.sittingWon ? Palette.good : Palette.bad
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.8,
          );
        }
      }
    }

    // Which seat is which, along the bench.
    for (var seat = 0; seat < show.marrows; seat++) {
      final words = TextPainter(
        text: TextSpan(
          text: '${seat + 1}',
          style: labels.copyWith(
            color: Palette.inkDim.withValues(alpha: 0.7),
            fontSize: metrics.stallWide * 0.22,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        metrics
            .stallAt(seat)
            .translate(-words.width / 2, metrics.tall * 0.09),
      );
    }
  }

  void _marrow(
    Canvas canvas,
    Metrics metrics,
    Offset stand,
    double height, {
    required Color color,
    required bool bright,
  }) {
    final wide = math.min(metrics.stallWide * 0.62, height * 0.75);
    final body = Rect.fromCenter(
      center: stand.translate(0, -height / 2),
      width: wide,
      height: height,
    );
    canvas.drawOval(body, Paint()..color = color);
    if (color == Palette.marrow) {
      // The stripes a marrow wears.
      for (final lean in const [-0.45, 0.0, 0.45]) {
        canvas.drawLine(
          Offset(body.center.dx + body.width * lean * 0.5,
              body.top + body.height * 0.12),
          Offset(body.center.dx + body.width * lean * 0.5,
              body.bottom - body.height * 0.12),
          Paint()
            ..color = Palette.stripe
            ..strokeWidth = math.max(body.width * 0.07, 1.4)
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    // The stem.
    canvas.drawLine(
      Offset(body.center.dx, body.top),
      Offset(body.center.dx + wide * 0.14, body.top - height * 0.06),
      Paint()
        ..color = Palette.marrowDark
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    if (bright) {
      canvas.drawOval(
        body.inflate(2.4),
        Paint()
          ..color = Palette.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
    }
  }

  void _rosette(Canvas canvas, Offset middle, double reach,
      {required bool outline}) {
    final paint = Paint()..color = Palette.rosette;
    if (outline) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
    }
    for (var petal = 0; petal < 8; petal++) {
      final turn = petal * math.pi / 4;
      canvas.drawCircle(
        middle + Offset(math.cos(turn), math.sin(turn)) * reach * 0.75,
        reach * 0.42,
        paint,
      );
    }
    canvas.drawCircle(middle, reach * 0.5, paint);
  }

  @override
  bool shouldRepaint(ShowView old) => old.play != play;
}

/// The words the why speaks, from the bench at hand.
String whyWords(Play play) {
  final show = play.show;
  final note = show.note == null ? '' : ' ${show.note}';
  if (show.sure) {
    return 'Two sittings can open with the same best-yet marrow and '
        'hide the true best in different seats: take, and one of '
        'them has you; wave, and the other does. So no rule of any '
        'kind lands the best every sitting, and the sweep of all '
        '${show.swept} rank-based rules puts the ceiling at '
        '${show.wins} of ${show.of}.$note';
  }
  final swept = show.swept == null
      ? ''
      : ' The sweep of all ${show.swept} rank-based rules against '
          'every sitting finds none better, so that count is the '
          'ceiling itself.';
  return 'A judge sees only how each marrow stands against the ones '
      'already seen. The rule waves ${show.skip} by and then takes '
      'the first best-yet: over all ${show.of} sittings of the '
      'bench it lands the true best in ${show.wins}.$swept$note';
}

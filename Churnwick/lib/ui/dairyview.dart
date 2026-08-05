import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../churn/play.dart';
import 'palette.dart';

/// What a tap landed on, when it was not a churn.
class Thing {
  const Thing._();

  static const nothing = -1;
  static const vat = -2;
  static const drain = -3;
}

/// Where everything in the dairy is.
///
/// The painter and the finger both use this, which is the point of it: a churn
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    this.room = room;
    bar = math.min(room.height * 0.09, 54);
    final gap = room.width * 0.04;
    wide = (room.width - gap * (play.dairy.count + 1)) / play.dairy.count;
    left = gap;
    across = wide + gap;

    top = bar + room.height * 0.05;
    // Room under the churns for the two lines written there, so they never
    // land on the drain.
    tall = math.max(room.height - top - bar - underneath - 8, 40);
  }

  final Play play;
  late final Size room;

  /// How much room the two lines under a churn take.
  static const underneath = 52.0;

  /// How deep the vat along the top and the drain along the bottom are.
  late final double bar;

  late final double wide;
  late final double across;
  late final double left;
  late final double top;
  late final double tall;

  Rect get vat => Rect.fromLTWH(0, 0, room.width, bar);
  Rect get drain => Rect.fromLTWH(0, room.height - bar, room.width, bar);

  Rect churnAt(int churn) =>
      Rect.fromLTWH(left + churn * across, top, wide, tall);

  /// How far up a churn a given number of gallons comes.
  double heightOf(int churn, int gallons) =>
      tall * gallons / play.dairy.churns[churn];

  /// The churn under a point, or one of the things in [Thing].
  int whatAt(Offset touch) {
    if (vat.contains(touch)) return Thing.vat;
    if (drain.contains(touch)) return Thing.drain;
    for (var churn = 0; churn < play.dairy.count; churn++) {
      if (churnAt(churn).inflate(across * 0.1).contains(touch)) return churn;
    }
    return Thing.nothing;
  }
}

/// The dairy: the vat, the churns with whatever is in them, and the drain.
class DairyView extends CustomPainter {
  const DairyView({
    required this.play,
    required this.showSteps,
    required this.labels,
    this.showWords = true,
  });

  final Play play;

  /// Whether to draw the lines the milk can stop on, which is what the game
  /// shows when it is asked what can be measured here at all.
  final bool showSteps;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// Off for the mark, where the picture is the milk.
  final bool showWords;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final dairy = play.dairy;

    if (showWords) {
      _bar(canvas, metrics.vat, 'The vat', Palette.milk.withValues(alpha: 0.5));
      _bar(canvas, metrics.drain, 'The drain', Palette.edge);
    }

    for (var churn = 0; churn < dairy.count; churn++) {
      final body = metrics.churnAt(churn);
      final held = play.holding == churn;
      final round = Radius.circular(metrics.wide * 0.16);

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          body,
          bottomLeft: round,
          bottomRight: round,
        ),
        Paint()..color = Palette.churn,
      );

      final milk = metrics.heightOf(churn, play.inChurn(churn));
      if (milk > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTRB(body.left, body.bottom - milk, body.right,
                body.bottom),
            bottomLeft: round,
            bottomRight: round,
          ),
          Paint()..color = Palette.milk,
        );
      }

      // The lines the milk can stop on, when they are asked for.
      if (showSteps) {
        final step = play.stepOfDairy;
        for (var mark = step;
            mark < dairy.churns[churn];
            mark += step) {
          final up = body.bottom - metrics.heightOf(churn, mark);
          canvas.drawLine(
            Offset(body.left + metrics.wide * 0.12, up),
            Offset(body.right - metrics.wide * 0.12, up),
            Paint()
              ..color = Palette.step
              ..strokeWidth = 1.4,
          );
        }
      }

      // What the morning is after, drawn where it would come to.
      if (dairy.want <= dairy.churns[churn]) {
        final up = body.bottom - metrics.heightOf(churn, dairy.want);
        canvas.drawLine(
          Offset(body.left, up),
          Offset(body.right, up),
          Paint()
            ..color = play.inChurn(churn) == dairy.want
                ? Palette.good
                : Palette.good.withValues(alpha: 0.45)
            ..strokeWidth = play.inChurn(churn) == dairy.want ? 3.4 : 2,
        );
      }

      canvas.drawRRect(
        RRect.fromRectAndCorners(body, bottomLeft: round, bottomRight: round),
        Paint()
          ..color = held ? Palette.ink : Palette.brass
          ..style = PaintingStyle.stroke
          ..strokeWidth = held ? 3.4 : 2,
      );

      if (!showWords) continue;
      _words(
        canvas,
        '${play.inChurn(churn)}',
        Offset(body.center.dx, body.bottom + 16),
        labels.copyWith(
          color: play.inChurn(churn) == dairy.want
              ? Palette.good
              : Palette.ink,
          fontSize: (labels.fontSize ?? 13) * 1.5,
          fontWeight: FontWeight.w700,
        ),
      );
      _words(
        canvas,
        'holds ${dairy.churns[churn]}',
        Offset(body.center.dx, body.bottom + 40),
        labels.copyWith(color: Palette.inkDim),
      );
    }
  }

  void _bar(Canvas canvas, Rect where, String words, Color colour) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(where.deflate(2), Radius.circular(where.height * 0.3)),
      Paint()..color = Palette.verge,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(where.deflate(2), Radius.circular(where.height * 0.3)),
      Paint()
        ..color = colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    _words(canvas, words, where.center,
        labels.copyWith(color: Palette.inkDim, fontWeight: FontWeight.w600));
  }

  void _words(Canvas canvas, String words, Offset middle, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      middle - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(DairyView old) =>
      old.play != play || old.showSteps != showSteps;
}

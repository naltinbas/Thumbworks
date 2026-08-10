import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../till/play.dart';
import 'palette.dart';

/// Where everything on the counter is.
///
/// The painter and the finger both use this, which is the point of it: a coin
/// is where it is drawn, and there is no second sum that could disagree with
/// the first.
class Metrics {
  Metrics(this.play, Size room) {
    this.room = room;
    final till = play.till;

    // The till row along the bottom: every kind, sized by worth.
    tillSpot = math.min(room.width / (till.kinds * 2.3), 34);
    tillY = room.height - tillSpot * 2.6;

    // The tray above it, where the coins put down sit in rows.
    traySpot = math.min(tillSpot * 1.15, 36);
    trayAcross = (room.width * 0.86) ~/ (traySpot * 2.3);
    trayTop = room.height * 0.34;
  }

  final Play play;
  late final Size room;

  late final double tillSpot;
  late final double tillY;
  late final double traySpot;
  late final int trayAcross;
  late final double trayTop;

  /// A coin's radius, grown a little with its worth.
  double radiusOf(int kind, double base) =>
      base * (0.72 + 0.08 * kind);

  Offset tillAt(int kind) => Offset(
        room.width * (kind + 0.5) / play.till.kinds,
        tillY,
      );

  Offset trayAt(int place) {
    final row = place ~/ trayAcross;
    final column = place % trayAcross;
    final inRow = math.min(play.used - row * trayAcross, trayAcross);
    final width = inRow * traySpot * 2.3;
    return Offset(
      (room.width - width) / 2 + (column + 0.5) * traySpot * 2.3,
      trayTop + row * traySpot * 2.5,
    );
  }

  /// The till coin under a point, or -1.
  int tillKindAt(Offset touch) {
    for (var kind = 0; kind < play.till.kinds; kind++) {
      if ((tillAt(kind) - touch).distance < tillSpot * 1.35) return kind;
    }
    return -1;
  }

  /// The tray coin under a point, or -1, as a place in the tray.
  int trayPlaceAt(Offset touch) {
    for (var place = 0; place < play.used; place++) {
      if ((trayAt(place) - touch).distance < traySpot * 1.2) return place;
    }
    return -1;
  }
}

/// The counter: the amount owed, the tray, and the till row.
class CounterView extends CustomPainter {
  const CounterView({
    required this.play,
    required this.pointing,
    required this.labels,
    this.justTray = false,
  });

  final Play play;

  /// A till coin the game is pointing at, or -1.
  final int pointing;

  /// The style the words are set in. A painter has no theme to ask.
  final TextStyle labels;

  /// For the mark: draw only the coins on the tray, large and centred.
  final bool justTray;

  @override
  void paint(Canvas canvas, Size size) {
    if (justTray) {
      _mark(canvas, size);
      return;
    }

    final metrics = Metrics(play, size);
    final till = play.till;

    // What is owed, big in the middle above the tray.
    _words(
      canvas,
      play.isDone ? till.spoken(play.round.amount) : till.spoken(play.owed),
      Offset(size.width / 2, size.height * 0.13),
      labels.copyWith(
        color: play.isDone ? Palette.good : Palette.ink,
        fontSize: size.height * 0.09,
        fontWeight: FontWeight.w200,
      ),
    );
    _words(
      canvas,
      play.isDone ? 'counted out' : 'still owed',
      Offset(size.width / 2, size.height * 0.225),
      labels.copyWith(color: Palette.inkDim, fontSize: 13),
    );

    // The tray.
    for (var place = 0; place < play.used; place++) {
      _coin(
        canvas,
        metrics.trayAt(place),
        metrics.radiusOf(play.tray[place], metrics.traySpot),
        play.tray[place],
        till.coins[play.tray[place]].face,
        metrics.traySpot,
      );
    }

    // The till row, every kind with its name under it.
    for (var kind = 0; kind < till.kinds; kind++) {
      final middle = metrics.tillAt(kind);
      final dead = play.wouldOverpay(kind) && !play.isDone;

      _coin(
        canvas,
        middle,
        metrics.radiusOf(kind, metrics.tillSpot),
        kind,
        till.coins[kind].face,
        metrics.tillSpot,
        dim: dead,
      );
      if (kind == pointing) {
        canvas.drawCircle(
          middle,
          metrics.radiusOf(kind, metrics.tillSpot) + 5,
          Paint()
            ..color = Palette.ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
      _words(
        canvas,
        till.coins[kind].name,
        middle + Offset(0, metrics.tillSpot * 1.6),
        labels.copyWith(
          color: dead ? Palette.line : Palette.inkDim,
          fontSize: 10.5,
        ),
      );
    }
  }

  void _mark(Canvas canvas, Size size) {
    final spot = size.shortestSide * 0.23;
    for (var place = 0; place < play.used; place++) {
      final across = play.used * spot * 2.2;
      _coin(
        canvas,
        Offset(
          (size.width - across) / 2 + (place + 0.5) * spot * 2.2,
          size.height / 2,
        ),
        spot,
        play.tray[place],
        play.till.coins[play.tray[place]].face,
        spot,
      );
    }
  }

  void _coin(
    Canvas canvas,
    Offset middle,
    double radius,
    int kind,
    String face,
    double base, {
    bool dim = false,
  }) {
    final copper = kind < 2;
    final body = copper ? Palette.copper : Palette.silver;
    final rim = copper ? Palette.copperRim : Palette.silverRim;

    canvas.drawCircle(
      middle,
      radius,
      Paint()..color = dim ? Palette.verge : body,
    );
    canvas.drawCircle(
      middle,
      radius,
      Paint()
        ..color = dim ? Palette.line : rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.14,
    );
    canvas.drawCircle(
      middle,
      radius * 0.78,
      Paint()
        ..color = dim ? Palette.line : rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.05,
    );
    _words(
      canvas,
      face,
      middle,
      labels.copyWith(
        color: dim ? Palette.inkDim : Palette.night,
        fontSize: radius * 0.62,
        fontWeight: FontWeight.w800,
      ),
    );
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
  bool shouldRepaint(CounterView old) =>
      old.play != play || old.pointing != pointing;
}

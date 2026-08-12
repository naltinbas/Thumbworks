import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../purse/play.dart';
import '../purse/rules.dart';
import 'palette.dart';

/// Where every coin sits, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    // Coins up to 21 sit on the counter in one row; bigger ones
    // in a second row beneath.
    slot = math.min(room.width * 0.9 / 7, room.height * 0.16);
    left = (room.width - slot * 7) / 2;
    counterTop = room.height * 0.12;
    trayTop = room.height * 0.62;
  }

  final Play play;

  late final double slot;
  late final double left;
  late final double counterTop;
  late final double trayTop;

  /// The middle of a coin's counter seat; the three big coins
  /// take the second row at a wider stride.
  Offset coinAt(int coin) {
    final at = Rules.coins.indexOf(coin);
    final row = at < 7 ? 0 : 1;
    final place = at < 7 ? at : at - 7;
    return Offset(
      row == 0
          ? left + (place + 0.5) * slot
          : left + slot * 0.75 + place * slot * 1.5,
      counterTop + slot * (0.5 + row * 1.25),
    );
  }

  /// The size a coin draws at, gently with its worth and capped
  /// so neighbours never touch.
  double sizeOf(int coin) =>
      slot * math.min(0.44, 0.26 + 0.004 * coin);

  /// The coin under a touch, or -1.
  int coinUnder(Offset touch) {
    for (final coin in Rules.coins) {
      if ((coinAt(coin) - touch).distance <= slot * 0.48) {
        return coin;
      }
    }
    return -1;
  }
}

/// The well's counter and tray, drawn.
class PurseView extends CustomPainter {
  PurseView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The coin the show-me points at, or null, with whether it
  /// goes in.
  final (int, bool)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  void _coin(Canvas canvas, Offset middle, double size, int coin,
      {required Color rim, double rimWidth = 1.6}) {
    canvas.drawCircle(middle, size, Paint()..color = Palette.coin);
    canvas.drawCircle(
      middle,
      size,
      Paint()
        ..color = rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = rimWidth,
    );
    canvas.drawCircle(
      middle,
      size * 0.72,
      Paint()
        ..color = Palette.coinRim.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    if (showWords) {
      final words = TextPainter(
        text: TextSpan(
          text: '$coin',
          style: labels.copyWith(
            color: Palette.coinInk,
            fontSize: size * 0.62,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(canvas,
          middle - Offset(words.width / 2, words.height / 2));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The tray.
    final tray = Rect.fromLTWH(
      metrics.left - metrics.slot * 0.1,
      metrics.trayTop,
      metrics.slot * 7 + metrics.slot * 0.2,
      metrics.slot * 1.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tray, Radius.circular(metrics.slot * 0.2)),
      Paint()..color = Palette.tray,
    );

    // The counter coins, those not in the tray.
    for (final coin in Rules.coins) {
      if (play.tray.contains(coin)) continue;
      final ghost = play.shown.contains(coin);
      _coin(
        canvas,
        metrics.coinAt(coin),
        metrics.sizeOf(coin),
        coin,
        rim: pointing?.$1 == coin
            ? Palette.shown
            : ghost
                ? Palette.shownWay
                : Palette.coinRim,
        rimWidth: pointing?.$1 == coin || ghost ? 2.8 : 1.6,
      );
    }

    // The tray coins, neighbours ringed rust.
    final bad = <int>{};
    for (final (a, b) in play.neighbours) {
      bad.addAll([a, b]);
    }
    final held = List.of(play.tray)..sort();
    for (var at = 0; at < held.length; at++) {
      final coin = held[at];
      final middle = Offset(
        tray.left +
            metrics.slot * 0.8 +
            at * metrics.slot * 1.05,
        tray.center.dy,
      );
      _coin(
        canvas,
        middle,
        metrics.sizeOf(coin),
        coin,
        rim: bad.contains(coin)
            ? Palette.neighbour
            : Palette.coinRim,
        rimWidth: bad.contains(coin) ? 3.0 : 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(PurseView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the purse at hand.
String whyWords(Play play) {
  final purse = play.purse;
  final note = purse.note == null ? '' : ' ${purse.note}';
  if (!purse.winnable) {
    return 'Zeckendorf\'s theorem holds the well: every price '
        'pays in exactly one lawful handful of coins, no two of '
        'them neighbours in the coinage. The sweep tried every '
        'handful for every purse from one to a hundred and never '
        'found a second, and the greedy walk, largest coin '
        'first, lands on the one payment every time.$note';
  }
  return 'The one payment is checked two ways that share '
      'nothing: the sweep tries every lawful handful and finds '
      'exactly one for this price, as it does for every purse '
      'to a hundred, and the greedy walk lands on the same '
      'coins largest first.$note';
}

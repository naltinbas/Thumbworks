import 'package:flutter/material.dart';

import '../reel/play.dart';
import 'palette.dart';

/// Where everybody stands.
///
/// The painter and the finger both use this, which is the point of it: a
/// name is where it is drawn, and there is no second sum that could disagree
/// with the first.
class Metrics {
  Metrics(this.count, Size room) {
    chip = Size(room.width * 0.34, room.height / (count + 0.6) * 0.72);
    _room = room;
  }

  final int count;
  late final Size _room;

  /// How big a name is drawn.
  late final Size chip;

  double get _pitch => _room.height / (count + 0.6);

  Rect chipAt(int who, {required bool caller}) => Rect.fromCenter(
        center: Offset(
          caller ? _room.width * 0.22 : _room.width * 0.78,
          _pitch * (who + 0.8),
        ),
        width: chip.width,
        height: chip.height,
      );

  /// Who was touched: the side, and which of them, or null.
  (bool, int)? whoIs(Offset touch) {
    for (final caller in [true, false]) {
      for (var who = 0; who < count; who++) {
        if (chipAt(who, caller: caller).inflate(4).contains(touch)) {
          return (caller, who);
        }
      }
    }
    return null;
  }
}

/// The hall: two sides, their lists, the couples, and who would rather swap.
class Floor extends CustomPainter {
  const Floor({
    required this.play,
    required this.holding,
    required this.showSwaps,
    required this.names,
    required this.lists,
  });

  final Play play;

  /// The caller waiting for a partner, or -1.
  final int holding;

  /// Whether to draw the pairs who would rather have each other. They are
  /// only worth drawing once everybody is paired: before that every pair is
  /// one, because anybody would rather have somebody than nobody.
  final bool showSwaps;

  /// The styles the names and the lists are set in. A painter has no theme to
  /// ask.
  final TextStyle names;
  final TextStyle lists;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play.count, size);
    final round = play.round;

    if (showSwaps) {
      final swap = Paint()
        ..color = Palette.swap
        ..strokeWidth = 1.4;
      for (final one in play.blocking) {
        _dashed(
          canvas,
          metrics.chipAt(one.caller, caller: true).centerRight,
          metrics.chipAt(one.dancer, caller: false).centerLeft,
          swap,
        );
      }
    }

    final tie = Paint()
      ..color = Palette.tie
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var caller = 0; caller < play.count; caller++) {
      final dancer = play.dancerOf(caller);
      if (dancer < 0) continue;
      canvas.drawLine(
        metrics.chipAt(caller, caller: true).centerRight,
        metrics.chipAt(dancer, caller: false).centerLeft,
        tie,
      );
    }

    for (var who = 0; who < play.count; who++) {
      _one(
        canvas,
        metrics.chipAt(who, caller: true),
        round.callerName(who),
        [for (final other in round.callers[who]) round.dancerName(other)],
        Palette.caller,
        held: who == holding,
        paired: play.dancerOf(who) >= 0,
      );
      _one(
        canvas,
        metrics.chipAt(who, caller: false),
        round.dancerName(who),
        [for (final other in round.dancers[who]) round.callerName(other)],
        Palette.dancer,
        held: false,
        paired: play.callerOf(who) >= 0,
      );
    }
  }

  void _one(
    Canvas canvas,
    Rect where,
    String name,
    List<String> wants,
    Color colour, {
    required bool held,
    required bool paired,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(where, Radius.circular(where.height * 0.28)),
      Paint()..color = paired ? Palette.board : Palette.floor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(where, Radius.circular(where.height * 0.28)),
      Paint()
        ..color = held ? Palette.ink : colour.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = held ? 2.4 : 1.2,
    );

    final label = TextPainter(
      text: TextSpan(text: name, style: names.copyWith(color: colour)),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(
      canvas,
      Offset(where.left + where.height * 0.3, where.top + where.height * 0.14),
    );

    // The list, first choice first. It is the whole of what anybody knows
    // about anybody here.
    final order = TextPainter(
      text: TextSpan(
        text: wants.map((one) => one.substring(0, 1)).join(' '),
        style: lists,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    order.paint(
      canvas,
      Offset(
        where.left + where.height * 0.3,
        where.bottom - where.height * 0.14 - order.height,
      ),
    );
  }

  /// A line in dashes, for a pair who are not a couple but would rather be.
  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 6.0;
    final away = to - from;
    final length = away.distance;
    if (length < 1) return;
    final step = away / length * dash;

    var at = from;
    var gone = 0.0;
    var on = true;
    while (gone < length) {
      final next = at + step;
      if (on) canvas.drawLine(at, next, paint);
      at = next;
      gone += dash;
      on = !on;
    }
  }

  @override
  bool shouldRepaint(Floor old) =>
      old.play != play ||
      old.holding != holding ||
      old.showSwaps != showSwaps;
}

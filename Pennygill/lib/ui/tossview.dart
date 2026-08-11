import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../toss/call.dart';
import '../toss/play.dart';
import 'palette.dart';

/// Where everything lies, shared by the painter and the hit-testing, so
/// where a call is drawn is exactly where a call is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    coin = math.min(width / 9.2, height / 14);
  }

  final Play play;

  late final double width;
  late final double height;
  late final double coin;

  /// The calling grid: eight plaques, two rows of four, shown before your
  /// call is made.
  Rect callRect(int flips) {
    final column = flips % 4;
    final row = flips ~/ 4;
    final wide = width / 4.6;
    final high = coin * 2.2;
    final acrossAll = wide * 4 + 12 * 3;
    final left = (width - acrossAll) / 2 + column * (wide + 12);
    final top = height * 0.32 + row * (high + 14);
    return Rect.fromLTWH(left, top, wide, high);
  }

  /// The call under a touch while calling, or null.
  Call? callAt(Offset touch) {
    if (play.yours != null) return null;
    for (var flips = 0; flips < 8; flips++) {
      if (callRect(flips).contains(touch)) return Call(flips);
    }
    return null;
  }

  /// Where a flip's coin lies in the run, wrapping in rows under the
  /// plaques.
  Offset flipAt(int flip) {
    const perRow = 8;
    final row = flip ~/ perRow;
    final column = flip % perRow;
    return Offset(
      width / 2 + (column - (perRow - 1) / 2) * coin * 1.12,
      height * 0.34 + row * coin * 1.16,
    );
  }
}

/// The table, drawn.
class TossView extends CustomPainter {
  TossView({
    required this.play,
    required this.pointing,
    required this.showRing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The call being pointed at, or null.
  final Call? pointing;

  /// Whether to draw the ring of eight calls and their beatings.
  final bool showRing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    if (showRing) {
      _ring(canvas, metrics);
      return;
    }

    _plaques(canvas, metrics);
    if (play.yours == null) {
      _calling(canvas, metrics);
    } else {
      _run(canvas, metrics);
    }
  }

  void _plaque(
    Canvas canvas,
    Metrics metrics,
    Rect rect,
    String owner,
    Call? call,
    int rounds,
    Color colour, {
    bool ringed = false,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.2)),
      Paint()..color = Palette.board,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.2)),
      Paint()
        ..color = ringed ? Palette.shown : colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringed ? 2.6 : 1.6,
    );
    if (!showWords) return;

    final words = TextPainter(
      text: TextSpan(children: [
        TextSpan(
          text: '$owner  ',
          style: labels.copyWith(
            color: colour,
            fontSize: rect.height * 0.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextSpan(
          text: call?.said ?? '?',
          style: labels.copyWith(
            color: Palette.ink,
            fontSize: rect.height * 0.42,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        TextSpan(
          text: '   ${'●' * rounds}',
          style: labels.copyWith(
            color: colour,
            fontSize: rect.height * 0.3,
          ),
        ),
      ]),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      rect.centerLeft + Offset(rect.height * 0.3, -words.height / 2),
    );
  }

  void _plaques(Canvas canvas, Metrics metrics) {
    final wide = metrics.width * 0.86;
    final high = metrics.coin * 1.7;
    final left = (metrics.width - wide) / 2;
    _plaque(
      canvas,
      metrics,
      Rect.fromLTWH(left, metrics.coin * 0.6, wide, high),
      'YOU',
      play.yours,
      play.yourRounds,
      Palette.you,
      ringed: pointing != null && pointing == play.yours,
    );
    _plaque(
      canvas,
      metrics,
      Rect.fromLTWH(left, metrics.coin * 0.6 + high + 8, wide, high),
      'HOUSE',
      play.theirs,
      play.theirRounds,
      Palette.house,
    );
  }

  void _calling(Canvas canvas, Metrics metrics) {
    for (var flips = 0; flips < 8; flips++) {
      final call = Call(flips);
      final rect = metrics.callRect(flips);
      final isPointed = pointing == call;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.22)),
        Paint()..color = Palette.board,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(rect.height * 0.22)),
        Paint()
          ..color = isPointed ? Palette.shown : Palette.edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = isPointed ? 2.6 : 1.2,
      );
      if (!showWords) continue;
      final words = TextPainter(
        text: TextSpan(
          text: call.said,
          style: labels.copyWith(
            color: Palette.ink,
            fontSize: rect.height * 0.42,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        rect.center - Offset(words.width / 2, words.height / 2),
      );
    }
  }

  void _run(Canvas canvas, Metrics metrics) {
    final shown = play.shownBy;
    for (var flip = 0; flip < play.flips.length; flip++) {
      final where = metrics.flipAt(flip);
      final heads = play.flips[flip];
      final inShow =
          shown != null && flip >= play.flips.length - 3;
      canvas.drawCircle(
        where,
        metrics.coin * 0.48,
        Paint()..color = heads ? Palette.head : Palette.tail,
      );
      canvas.drawCircle(
        where,
        metrics.coin * 0.48,
        Paint()
          ..color = inShow
              ? (shown == play.yours ? Palette.you : Palette.house)
              : Palette.rim
          ..style = PaintingStyle.stroke
          ..strokeWidth = inShow ? 3.0 : 1.4,
      );
      if (!showWords) continue;
      final words = TextPainter(
        text: TextSpan(
          text: heads ? 'H' : 'T',
          style: labels.copyWith(
            color: Palette.taproom,
            fontSize: metrics.coin * 0.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(canvas, where - Offset(words.width / 2, words.height / 2));
    }
  }

  void _ring(Canvas canvas, Metrics metrics) {
    // The eight calls round a circle, an arrow from each to its beater:
    // the picture of there being no best call.
    final middle = Offset(metrics.width / 2, metrics.height * 0.46);
    final around = math.min(metrics.width, metrics.height) * 0.34;

    Offset at(Call call) {
      final turn = -math.pi / 2 + call.flips * math.pi / 4;
      return middle + Offset(math.cos(turn), math.sin(turn)) * around;
    }

    for (final call in Call.all) {
      final winner = call.beatenBy;
      final from = at(call);
      final to = at(winner);
      final way = (to - from) / (to - from).distance;
      final start = from + way * metrics.coin * 1.1;
      final end = to - way * metrics.coin * 1.3;
      final arrow = Paint()
        ..color = Palette.ring.withValues(alpha: 0.7)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(start, end, arrow);
      final side = Offset(-way.dy, way.dx);
      canvas.drawLine(end, end - way * 7 + side * 4.5, arrow);
      canvas.drawLine(end, end - way * 7 - side * 4.5, arrow);
    }

    for (final call in Call.all) {
      final where = at(call);
      final mine = call == play.yours;
      final theirs = call == play.theirs;
      canvas.drawCircle(
        where,
        metrics.coin * 1.05,
        Paint()..color = Palette.board,
      );
      canvas.drawCircle(
        where,
        metrics.coin * 1.05,
        Paint()
          ..color = mine
              ? Palette.you
              : theirs
                  ? Palette.house
                  : Palette.edge
          ..style = PaintingStyle.stroke
          ..strokeWidth = mine || theirs ? 2.6 : 1.2,
      );
      if (!showWords) continue;
      final words = TextPainter(
        text: TextSpan(
          text: call.said,
          style: labels.copyWith(
            color: Palette.ink,
            fontSize: metrics.coin * 0.52,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(canvas, where - Offset(words.width / 2, words.height / 2));
    }

    if (showWords && play.called) {
      final odds = play.theirChance!;
      final tidy = odds.eased;
      final words = TextPainter(
        text: TextSpan(
          text: 'the house shows first\n$tidy',
          style: labels.copyWith(
            color: Palette.inkDim,
            fontSize: metrics.coin * 0.55,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      // Under the ring, clear of the crossing arrows.
      words.paint(
        canvas,
        Offset(
          middle.dx - words.width / 2,
          middle.dy + around + metrics.coin * 1.6,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(TossView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showRing != showRing;
}

/// The words the why speaks, from the table at hand.
String whyWords(Play play) {
  final start = 'Better-than runs in a ring here: every call has another '
      'that beats it, so there is no best call to make.';
  final called = !play.called
      ? ''
      : ' The house holds ${play.theirChance!} odds of showing first '
          'this match.';
  final note = play.wager.note;
  return '$start$called${note == null ? '' : ' $note'}';
}

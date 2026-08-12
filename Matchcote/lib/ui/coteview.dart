import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../round/play.dart';
import 'palette.dart';

/// Where every player stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height * 0.5);
    ring = math.min(room.width, room.height) * 0.38;
  }

  final Play play;

  late final Offset middle;
  late final double ring;

  /// The point of a player, counted clockwise from the top.
  Offset playerAt(int player) {
    final turn =
        -math.pi / 2 + 2 * math.pi * player / play.cote.players;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// The player under a touch, or -1.
  int playerUnder(Offset touch) {
    for (var at = 0; at < play.cote.players; at++) {
      if ((playerAt(at) - touch).distance <= ring * 0.24) {
        return at;
      }
    }
    return -1;
  }
}

/// The cote, drawn.
class CoteView extends CustomPainter {
  CoteView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The pair the show-me points at, or null.
  final (int, int)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The cote's grass.
    canvas.drawCircle(
      metrics.middle,
      metrics.ring * 1.26,
      Paint()..color = Palette.cote,
    );

    // The rounds, each in its coat, given ones worn dim.
    final givenRounds = play.cote.given.length;
    final rounds = play.rounds;
    for (var at = 0; at < rounds.length; at++) {
      final coat =
          Palette.roundCoats[at % Palette.roundCoats.length];
      final dim = at < givenRounds;
      for (final (a, b) in rounds[at]) {
        canvas.drawLine(
          metrics.playerAt(a),
          metrics.playerAt(b),
          Paint()
            ..color = dim ? coat.withValues(alpha: 0.4) : coat
            ..strokeWidth = math.max(metrics.ring * 0.04, 3.2)
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // The pointed pair, dashed blue.
    final aim = pointing;
    if (aim != null) {
      final from = metrics.playerAt(aim.$1);
      final to = metrics.playerAt(aim.$2);
      final way = (to - from) / (to - from).distance;
      var far = 0.0;
      final whole = (to - from).distance;
      while (far < whole) {
        final step = math.min(metrics.ring * 0.07, whole - far);
        canvas.drawLine(
          from + way * far,
          from + way * (far + step),
          Paint()
            ..color = Palette.shown
            ..strokeWidth = 2.8
            ..strokeCap = StrokeCap.round,
        );
        far += metrics.ring * 0.13;
      }
    }

    // The players.
    for (var at = 0; at < play.cote.players; at++) {
      final middle = metrics.playerAt(at);
      final picked = play.picked == at;
      canvas.drawCircle(middle, metrics.ring * 0.1,
          Paint()..color = Palette.player);
      canvas.drawCircle(
        middle,
        metrics.ring * 0.1,
        Paint()
          ..color = picked ? Palette.shown : Palette.playerRim
          ..style = PaintingStyle.stroke
          ..strokeWidth = picked ? 3.0 : 1.5,
      );
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: '${at + 1}',
            style: labels.copyWith(
              color: Palette.night,
              fontSize: metrics.ring * 0.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(canvas,
            middle - Offset(words.width / 2, words.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(CoteView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the cote at hand.
String whyWords(Play play) {
  final cote = play.cote;
  final rules = play.rules;
  final note = cote.note == null ? '' : ' ${cote.note}';
  if (!cote.winnable) {
    return 'A round pairs everyone at once, and '
        '${cote.players} is odd: whoever pairs, someone is left '
        'standing, so no round ever fills, let alone '
        '${cote.players - 1} of them. The sweep asked for a '
        'single full round among ${cote.players} players and '
        'found none.$note';
  }
  return 'A full fixture is checked by its cover, every pair of '
      'players met exactly once across ${rules.rounds} rounds, '
      'and the sweep builds every fixture there is from what is '
      'given: ${cote.ways} land this asking.$note';
}

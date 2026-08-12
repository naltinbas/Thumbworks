import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../post/play.dart';
import 'palette.dart';

/// Where every hole and letter lies, shared by the painter and
/// the hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    slot = math.min(
      room.width * 0.86 / play.round.letters,
      room.height * 0.26,
    );
    left = (room.width - slot * play.round.letters) / 2;
    rackTop = room.height * 0.16;
    bagTop = room.height * 0.66;
  }

  final Play play;

  late final double slot;
  late final double left;
  late final double rackTop;
  late final double bagTop;

  /// The middle of a hole.
  Offset holeAt(int hole) => Offset(
      left + (hole + 0.5) * slot, rackTop + slot * 0.55);

  /// The middle of a letter's bag seat.
  Offset seatAt(int letter) => Offset(
      left + (letter + 0.5) * slot, bagTop + slot * 0.4);

  /// The hole under a touch, or -1.
  int holeUnder(Offset touch) {
    for (var at = 0; at < play.round.letters; at++) {
      if ((holeAt(at) - touch).distance <= slot * 0.42) return at;
    }
    return -1;
  }

  /// The bagged letter under a touch, or -1.
  int letterUnder(Offset touch) {
    for (var at = 0; at < play.round.letters; at++) {
      if (play.posting[at] >= 0) continue;
      if ((seatAt(at) - touch).distance <= slot * 0.42) return at;
    }
    return -1;
  }
}

/// The round, drawn.
class PostView extends CustomPainter {
  PostView({
    required this.play,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The letter and hole the show-me points at, or null.
  final (int, int)? pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  void _letter(Canvas canvas, Offset middle, double slot, int letter,
      {required bool home, required bool held}) {
    final paper = Rect.fromCenter(
      center: middle,
      width: slot * 0.68,
      height: slot * 0.48,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(slot * 0.05)),
      Paint()..color = Palette.paper,
    );
    // The flap and the seal.
    final flap = Path()
      ..moveTo(paper.left, paper.top)
      ..lineTo(paper.center.dx, paper.center.dy + slot * 0.02)
      ..lineTo(paper.right, paper.top);
    canvas.drawPath(
      flap,
      Paint()
        ..color = Palette.address
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      paper.center + Offset(0, slot * 0.07),
      slot * 0.065,
      Paint()..color = Palette.seal,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(paper, Radius.circular(slot * 0.05)),
      Paint()
        ..color = home
            ? Palette.home
            : held
                ? Palette.shown
                : Palette.address
        ..style = PaintingStyle.stroke
        ..strokeWidth = home || held ? 3.0 : 1.4,
    );
    if (showWords) {
      final words = TextPainter(
        text: TextSpan(
          text: '${letter + 1}',
          style: labels.copyWith(
            color: Palette.address,
            fontSize: slot * 0.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
          canvas,
          paper.topLeft +
              Offset(slot * 0.05, slot * 0.03));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final slot = metrics.slot;

    // The rack.
    final rack = Rect.fromLTWH(
      metrics.left - slot * 0.12,
      metrics.rackTop,
      slot * play.round.letters + slot * 0.24,
      slot * 1.1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rack, Radius.circular(slot * 0.08)),
      Paint()..color = Palette.rack,
    );
    for (var hole = 0; hole < play.round.letters; hole++) {
      final middle = metrics.holeAt(hole);
      final arch = Rect.fromCenter(
        center: middle,
        width: slot * 0.78,
        height: slot * 0.8,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(arch, Radius.circular(slot * 0.16)),
        Paint()..color = Palette.hole,
      );
      if (showWords) {
        final words = TextPainter(
          text: TextSpan(
            text: '${hole + 1}',
            style: labels.copyWith(
              color: Palette.inkDim,
              fontSize: slot * 0.2,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        words.paint(
          canvas,
          Offset(middle.dx - words.width / 2,
              metrics.rackTop - slot * 0.28),
        );
      }
      final sitting = play.letterIn(hole);
      if (sitting >= 0) {
        _letter(canvas, middle, slot, sitting,
            home: sitting == hole, held: false);
      }
      if (pointing != null && pointing!.$2 == hole) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              arch.inflate(slot * 0.06),
              Radius.circular(slot * 0.18)),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The bag row: letters not yet posted.
    for (var letter = 0; letter < play.round.letters; letter++) {
      if (play.posting[letter] >= 0) continue;
      _letter(canvas, metrics.seatAt(letter), slot, letter,
          home: false, held: play.held == letter);
    }
  }

  @override
  bool shouldRepaint(PostView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the round at hand.
String whyWords(Play play) {
  final round = play.round;
  var everyRound = 1;
  for (var at = 2; at <= round.letters; at++) {
    everyRound *= at;
  }
  final note = round.note == null ? '' : ' ${round.note}';
  if (!round.winnable) {
    return 'Post three of four letters home and the fourth holds '
        'the only hole left, its own: exactly three home is four '
        'home, so the asking asks for nothing. The sweep posted '
        'all $everyRound rounds and read the homes off each, and '
        'the count of exactly-three came to none.$note';
  }
  return 'The deranged rounds are counted three ways that share '
      'nothing: the sweep posts all $everyRound rounds and reads '
      'the homes off each, the recurrence builds the count from '
      'the two sizes before, and the figure of '
      '${round.letters}! over e lands on the same number. '
      '${round.ways} round${round.ways == 1 ? '' : 's'} '
      'land${round.ways == 1 ? 's' : ''} this asking.$note';
}

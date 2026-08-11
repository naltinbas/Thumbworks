import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../banns/play.dart';
import 'palette.dart';

/// Where every chip stands, shared by the painter and the hit-testing,
/// so where a person is drawn is exactly where a person is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    final people = play.party.people;
    if (play.party.sided) {
      final half = people ~/ 2;
      chip = math.min(
        math.min(width / (half + 0.8) / 2, height * 0.11),
        56.0,
      );
      for (var who = 0; who < people; who++) {
        final side = who < half ? 0 : 1;
        final at = side == 0 ? who : who - half;
        centers.add(Offset(
          width * (at + 1) / (half + 1),
          height * (side == 0 ? 0.20 : 0.72),
        ));
      }
    } else {
      chip = math.min(math.min(width, height) * 0.105, 56.0);
      final round = math.min(width, height) * 0.335;
      final middle = Offset(width / 2, height * 0.46);
      for (var who = 0; who < people; who++) {
        final turn = -math.pi / 2 + who * 2 * math.pi / people;
        centers
            .add(middle + Offset(math.cos(turn), math.sin(turn)) * round);
      }
    }
  }

  final Play play;

  late final double width;
  late final double height;

  /// A chip's radius.
  late final double chip;

  final List<Offset> centers = [];

  Offset chipCenter(int who) => centers[who];

  /// The person under a touch, or -1 for nobody.
  int chipAt(Offset touch) {
    for (var who = 0; who < centers.length; who++) {
      if ((centers[who] - touch).distance <= chip * 1.45) return who;
    }
    return -1;
  }
}

/// The hall, drawn.
class BannsView extends CustomPainter {
  BannsView({
    required this.play,
    required this.armed,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The person armed for a wedding, or -1.
  final int armed;

  /// The couple being pointed at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // Cords under chips: the standing couples, then the elopers over
    // them, then the pointed couple over everything.
    for (var who = 0; who < play.party.people; who++) {
      final partner = play.wedded[who];
      if (partner == null || partner < who) continue;
      _cord(canvas, metrics, who, partner, Palette.cord, 2.4);
    }
    for (final (one, other) in play.eloping) {
      _elopeCord(canvas, metrics, one, other);
    }
    final pointed = pointing;
    if (pointed != null) {
      _cord(canvas, metrics, pointed.$1, pointed.$2, Palette.shown, 2.8);
    }

    for (var who = 0; who < play.party.people; who++) {
      _chip(canvas, metrics, who);
    }
  }

  void _cord(Canvas canvas, Metrics metrics, int one, int other,
      Color colour, double weight) {
    canvas.drawLine(
      metrics.chipCenter(one),
      metrics.chipCenter(other),
      Paint()
        ..color = colour
        ..strokeWidth = weight
        ..strokeCap = StrokeCap.round,
    );
  }

  void _elopeCord(Canvas canvas, Metrics metrics, int one, int other) {
    // Dashed, so a red fancy reads apart from a standing cord.
    final from = metrics.chipCenter(one);
    final to = metrics.chipCenter(other);
    final way = to - from;
    final length = way.distance;
    final step = way / length;
    final dash = metrics.chip * 0.42;
    var at = 0.0;
    final paint = Paint()
      ..color = Palette.elope
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    while (at < length) {
      final end = math.min(at + dash, length);
      canvas.drawLine(from + step * at, from + step * end, paint);
      at = end + dash * 0.7;
    }
  }

  void _chip(Canvas canvas, Metrics metrics, int who) {
    final middle = metrics.chipCenter(who);
    final chip = metrics.chip;
    final eloping = {
      for (final (one, other) in play.eloping) ...[one, other],
    };

    canvas.drawCircle(middle, chip, Paint()..color = Palette.chip);
    canvas.drawCircle(
      middle,
      chip,
      Paint()
        ..color = who == armed
            ? Palette.armed
            : eloping.contains(who)
                ? Palette.elope
                : Palette.chipRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = who == armed ? 2.8 : 1.6,
    );

    final name = play.party.names[who];
    final letter = TextPainter(
      text: TextSpan(
        text: name[0],
        style: labels.copyWith(
          color: Palette.face,
          fontSize: chip * 0.82,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    letter.paint(
        canvas, middle - Offset(letter.width / 2, letter.height / 2));

    // Askers' words go above their chips, so the cords between the
    // rows keep a clear channel.
    final above =
        play.party.sided && who < play.party.people ~/ 2;

    final under = TextPainter(
      text: TextSpan(
        text: name,
        style: labels.copyWith(
          color: Palette.inkDim,
          fontSize: chip * 0.34,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // The fancy list: who they would have, best first.
    final fancies = play.party.prefs[who]
        .map((other) => play.party.names[other][0])
        .join(' ');
    final list = TextPainter(
      text: TextSpan(
        text: fancies,
        style: labels.copyWith(
          color: Palette.inkDim.withValues(alpha: 0.75),
          fontSize: chip * 0.3,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final nameTop = above
        ? middle.dy - chip * 1.1 - under.height - list.height - 1
        : middle.dy + chip * 1.1;
    under.paint(
      canvas,
      Offset(
        (middle.dx - under.width / 2)
            .clamp(2.0, metrics.width - under.width - 2.0),
        nameTop,
      ),
    );
    list.paint(
      canvas,
      Offset(
        (middle.dx - list.width / 2)
            .clamp(2.0, metrics.width - list.width - 2.0),
        nameTop + under.height + 1,
      ),
    );
  }

  @override
  bool shouldRepaint(BannsView old) =>
      old.play != play || old.armed != armed || old.pointing != pointing;
}

/// The words the why speaks, from the party at hand.
String whyWords(Play play) {
  final party = play.party;
  final note = party.note == null ? '' : ' ${party.note}';
  var pairings = 0;
  for (final _ in play.rules.allPairings()) {
    pairings++;
  }
  if (!party.winnable) {
    return 'A pairing settles when everyone is wed and no two people '
        'would both rather have each other: a red cord is such a pair. '
        'This party has $pairings pairings and the sweep judged every '
        'one: each breaks.$note';
  }
  final round = party.sided
      ? ' The old asking-round, run fresh in the suite, ends on a '
          'settled pairing every time.'
      : '';
  return 'A pairing settles when everyone is wed and no two people '
      'would both rather have each other: a red cord is such a pair, '
      'and settling is exactly making every red cord go. Of the '
      '$pairings pairings of these ${party.people}, '
      '${party.settles} settle${party.settles == 1 ? 's' : ''}, judged '
      'one by one in the sweep.$round$note';
}

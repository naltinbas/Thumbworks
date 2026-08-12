import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../herd/play.dart';
import 'palette.dart';

/// Where the three patches and their herds lie, shared by the painter
/// and the hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    patch = math.min(width, height) * 0.27;
    final middle = Offset(width / 2, height * 0.48);
    final spread = math.min(width, height) * 0.30;
    for (var herd = 0; herd < 3; herd++) {
      final turn = -math.pi / 2 + herd * 2 * math.pi / 3;
      centers.add(
          middle + Offset(math.cos(turn), math.sin(turn)) * spread);
    }
  }

  final Play play;

  late final double width;
  late final double height;
  late final double patch;
  final List<Offset> centers = [];

  Offset patchCenter(int herd) => centers[herd];

  /// The patch under a touch, or -1.
  int patchAt(Offset touch) {
    for (var herd = 0; herd < 3; herd++) {
      if ((centers[herd] - touch).distance <= patch * 1.15) return herd;
    }
    return -1;
  }
}

/// The moor, drawn.
class HerdView extends CustomPainter {
  HerdView({
    required this.play,
    required this.armed,
    this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The patch armed for a meeting, or -1.
  final int armed;

  /// The meeting being pointed at, or null.
  final (int, int)? pointing;

  /// Whether counts may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  static const coats = [Palette.russet, Palette.olive, Palette.slate];

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    for (var herd = 0; herd < 3; herd++) {
      _patch(canvas, metrics, herd);
    }
  }

  void _patch(Canvas canvas, Metrics metrics, int herd) {
    final middle = metrics.patchCenter(herd);
    final patch = metrics.patch;
    final count = play.countOf(herd);
    final pointed = pointing != null &&
        (pointing!.$1 == herd || pointing!.$2 == herd);

    canvas.drawCircle(middle, patch, Paint()..color = Palette.patch);
    canvas.drawCircle(
      middle,
      patch,
      Paint()
        ..color = herd == armed
            ? Palette.armed
            : pointed
                ? Palette.shown
                : Palette.patchRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = herd == armed || pointed ? 2.8 : 1.6,
    );

    // The chameleons, little ovals ringed about the middle.
    final shown = math.min(count, 20);
    for (var beast = 0; beast < shown; beast++) {
      final ring = beast < 8 ? 0 : (beast < 14 ? 1 : 2);
      final ringCount = ring == 0
          ? math.min(shown, 8)
          : ring == 1
              ? math.min(shown - 8, 6)
              : shown - 14;
      final at = ring == 0 ? beast : (ring == 1 ? beast - 8 : beast - 14);
      final turn = at * 2 * math.pi / math.max(ringCount, 1) +
          ring * 0.5;
      final away = patch * (0.34 + ring * 0.26);
      final spot = middle +
          Offset(math.cos(turn), math.sin(turn)) * away;
      canvas.save();
      canvas.translate(spot.dx, spot.dy);
      canvas.rotate(turn + math.pi / 2);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset.zero,
            width: patch * 0.16,
            height: patch * 0.28),
        Paint()..color = coats[herd],
      );
      canvas.restore();
    }

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '$count',
        style: labels.copyWith(
          color: coats[herd],
          fontSize: patch * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
        canvas, middle - Offset(words.width / 2, words.height / 2));
  }

  @override
  bool shouldRepaint(HerdView old) =>
      old.play != play ||
      old.armed != armed ||
      old.pointing != pointing;
}

/// The words the why speaks, from the moor at hand.
String whyWords(Play play) {
  final moor = play.moor;
  final note = moor.note == null ? '' : ' ${moor.note}';
  final (a, b, c) = play.herds;
  if (!moor.winnable) {
    return 'A meeting takes one from two herds and gives the third '
        'two, so every difference between herds moves by nought or '
        'three: the remainders never change. The herds stand at '
        '$a, $b and $c, no two sharing a remainder by three, and a '
        'settled moor needs two herds level at nought.$note';
  }
  return 'A meeting moves every difference by nought or three, so a '
      'moor settles only where two herds share a remainder by '
      'three, and this one does. The walk stood on every herding of '
      '${moor.total} and read the fewest from each: '
      '${play.fewestFromHere} from here.$note';
}

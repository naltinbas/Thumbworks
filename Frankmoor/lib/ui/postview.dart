import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../post/play.dart';
import '../post/rules.dart';
import 'palette.dart';

/// Where everything lies, shared by the painter and the hit-testing, so
/// where a pile is drawn is exactly where a pile is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    stamp = math.min(width * 0.16, height * 0.14);
    pileY = stamp * 0.86;
    envelope = Rect.fromCenter(
      center: Offset(width / 2, height * 0.56),
      width: math.min(width * 0.86, height * 0.9),
      height: math.min(width * 0.86, height * 0.9) * 0.62,
    );
  }

  final Play play;

  late final double width;
  late final double height;
  late final double stamp;
  late final double pileY;
  late final Rect envelope;

  Rect cheapPile() => Rect.fromCenter(
        center: Offset(width * 0.3, pileY),
        width: stamp,
        height: stamp * 1.2,
      );

  Rect dearPile() => Rect.fromCenter(
        center: Offset(width * 0.7, pileY),
        width: stamp,
        height: stamp * 1.2,
      );

  /// Which pile a touch lands on: true cheap, false dear, null neither.
  bool? pileAt(Offset touch) {
    if (cheapPile().inflate(10).contains(touch)) return true;
    if (dearPile().inflate(10).contains(touch)) return false;
    return null;
  }

  /// Where the so-manyth affixed stamp sits on the envelope.
  Rect affixedRect(int which) {
    const perRow = 4;
    final small = stamp * 0.72;
    final row = which ~/ perRow;
    final column = which % perRow;
    return Rect.fromLTWH(
      envelope.right - (column + 1) * (small + 6) - 8,
      envelope.top + 8 + row * (small * 1.2 + 6),
      small,
      small * 1.2,
    );
  }
}

/// The counter, drawn.
class PostView extends CustomPainter {
  PostView({
    required this.play,
    required this.showWalk,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// Whether to lay the remainder walk out in chips.
  final bool showWalk;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    _envelope(canvas, metrics);
    _stamp(canvas, metrics.cheapPile(), play.letter.cheap, true);
    _stamp(canvas, metrics.dearPile(), play.letter.dear, false);

    var which = 0;
    for (var c = 0; c < play.cheaps; c++) {
      _stamp(canvas, metrics.affixedRect(which++), play.letter.cheap, true);
    }
    for (var d = 0; d < play.dears; d++) {
      _stamp(canvas, metrics.affixedRect(which++), play.letter.dear, false);
    }

    if (showWalk && showWords) _walk(canvas, metrics);
  }

  void _envelope(Canvas canvas, Metrics metrics) {
    final rect = metrics.envelope;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = Palette.envelope,
    );
    // Address lines, low left.
    final address = Paint()
      ..color = Palette.address
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var lineAt = 0; lineAt < 3; lineAt++) {
      canvas.drawLine(
        Offset(rect.left + rect.width * 0.1,
            rect.bottom - rect.height * (0.34 - 0.11 * lineAt)),
        Offset(rect.left + rect.width * (0.52 - 0.08 * lineAt),
            rect.bottom - rect.height * (0.34 - 0.11 * lineAt)),
        address,
      );
    }
  }

  void _stamp(Canvas canvas, Rect rect, int value, bool cheap) {
    final colour = cheap ? Palette.cheap : Palette.dear;
    final deep = cheap ? Palette.cheapDeep : Palette.dearDeep;

    // Perforated edge: a rounded rect with nicks.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.08)),
      Paint()..color = colour,
    );
    final nick = Paint()..color = Palette.office;
    final step = rect.width / 5;
    for (var at = 1; at < 5; at++) {
      canvas.drawCircle(
          Offset(rect.left + at * step, rect.top), rect.width * 0.045, nick);
      canvas.drawCircle(Offset(rect.left + at * step, rect.bottom),
          rect.width * 0.045, nick);
    }
    final tall = rect.height / 5;
    for (var at = 1; at < 5; at++) {
      canvas.drawCircle(
          Offset(rect.left, rect.top + at * tall), rect.width * 0.045, nick);
      canvas.drawCircle(Offset(rect.right, rect.top + at * tall),
          rect.width * 0.045, nick);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(rect.width * 0.12),
        Radius.circular(rect.width * 0.05),
      ),
      Paint()
        ..color = deep
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '$value',
        style: labels.copyWith(
          color: Palette.envelope,
          fontSize: rect.height * 0.4,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      rect.center - Offset(words.width / 2, words.height / 2),
    );
  }

  void _walk(Canvas canvas, Metrics metrics) {
    // The remainder walk under the envelope: what is owed after nought,
    // one, two ... dear stamps, the divisible one lit when it exists.
    final owed = play.owed;
    if (owed <= 0) return;
    final steps = Rules.walk(owed, play.letter.cheap, play.letter.dear);
    final wide = math.min(
      metrics.stamp * 0.9,
      (metrics.width - 24) / steps.length - 8,
    );
    final top = metrics.envelope.bottom + metrics.stamp * 0.4;
    final acrossAll = steps.length * (wide + 8) - 8;
    var left = (metrics.width - acrossAll) / 2;
    for (final step in steps) {
      final hit = step % play.letter.cheap == 0;
      final rect = Rect.fromLTWH(left, top, wide, wide * 0.62);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(wide * 0.14)),
        Paint()
          ..color = hit ? Palette.chipHit : Palette.chip
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final words = TextPainter(
        text: TextSpan(
          text: '$step',
          style: labels.copyWith(
            color: hit ? Palette.chipHit : Palette.chip,
            fontSize: wide * 0.34,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      words.paint(
        canvas,
        rect.center - Offset(words.width / 2, words.height / 2),
      );
      left += wide + 8;
    }
  }

  @override
  bool shouldRepaint(PostView old) =>
      old.play != play || old.showWalk != showWalk;
}

/// The words the why speaks, from the letter at hand.
String whyWords(Play play) {
  final owed = play.owed;
  if (owed <= 0) {
    return 'The letter is paid to the penny.';
  }
  final cheap = play.letter.cheap;
  final dear = play.letter.dear;
  final steps = Rules.walk(owed, cheap, dear);
  final said = steps.join(', ');
  final hit = steps.indexWhere((step) => step % cheap == 0);
  final start = 'Only remainders matter: take off nought, one, two '
      '${dear}s while the money lasts, and see what is left: $said. ';
  final verdict = hit >= 0
      ? 'The ${steps[hit]} divides by $cheap, and that is the whole '
          'answer: $hit dear stamp${hit == 1 ? '' : 's'} and the rest in '
          '${cheap}s.'
      : 'None of them divides by $cheap, and no further count of '
          '${dear}s fits the money: the amount cannot be paid, and the '
          'checking took ${steps.length} lines.';
  final note = play.letter.note;
  return '$start$verdict${note == null ? '' : ' $note'}';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../string/play.dart';
import 'palette.dart';

/// Where the sweets and the gaps lie on the counter, so the screen
/// and the tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    length = play.rules.length;
    rows = length > 8 ? 2 : 1;
    perRow = (length + rows - 1) ~/ rows;
    pitch = math.min(room.width * 0.9 / (perRow + 0.4), room.height * 0.36);
    sweet = pitch * 0.34;
    left = (room.width - pitch * perRow) / 2;
    top = rows == 1
        ? room.height / 2
        : room.height / 2 - pitch * 0.9;
  }

  final Play play;

  late final int length;
  late final int rows;
  late final int perRow;
  late final double pitch;
  late final double sweet;
  late final double left;
  late final double top;

  /// The middle of a sweet: the string runs left to right on the
  /// first row and back right to left on the second.
  Offset sweetAt(int index) {
    final row = index ~/ perRow;
    final along = index % perRow;
    final col = row.isEven ? along : perRow - 1 - along;
    return Offset(left + (col + 0.5) * pitch, top + row * pitch * 1.8);
  }

  /// The middle of a gap: between sweet gap - 1 and sweet gap.
  Offset gapAt(int gap) {
    final a = sweetAt(gap - 1);
    final b = sweetAt(gap);
    return Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  }

  /// The gap under a touch, or null.
  int? under(Offset touch) {
    for (var gap = 1; gap < length; gap++) {
      if ((gapAt(gap) - touch).distance <= pitch * 0.5) return gap;
    }
    return null;
  }
}

/// The counter itself: the string, the sweets, each piece tinted
/// for the child who takes it, the cuts, and the pointer's ring.
class StringView extends CustomPainter {
  StringView({required this.play, this.pointing, required this.labels});

  final Play play;
  final (String, int)? pointing;
  final TextStyle labels;

  static Color tint(String kind) => switch (kind) {
        'R' => Palette.red,
        'B' => Palette.blue,
        _ => Palette.green,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final pitch = metrics.pitch;

    // The pieces, banded in the taker's tint.
    var index = 0;
    final pieces = play.pieces;
    for (var p = 0; p < pieces.length; p++) {
      final piece = pieces[p];
      final band = Paint()
        ..color = (p.isEven ? Palette.first : Palette.second).withValues(alpha: 0.45)
        ..strokeWidth = metrics.sweet * 2.6
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < piece.length; i++) {
        final here = metrics.sweetAt(index + i);
        final next = i + 1 < piece.length ? metrics.sweetAt(index + i + 1) : here;
        canvas.drawLine(here, next, band);
      }
      index += piece.length;
    }

    // The string.
    final string = Paint()
      ..color = Palette.string
      ..strokeWidth = math.max(1.5, pitch * 0.05);
    for (var i = 0; i + 1 < metrics.length; i++) {
      if (play.cuts.contains(i + 1)) continue;
      canvas.drawLine(metrics.sweetAt(i), metrics.sweetAt(i + 1), string);
    }

    // The sweets.
    for (var i = 0; i < metrics.length; i++) {
      final at = metrics.sweetAt(i);
      final kind = play.rules.sweets[i];
      canvas.drawCircle(at, metrics.sweet, Paint()..color = tint(kind));
      canvas.drawCircle(
        at + Offset(-metrics.sweet * 0.3, -metrics.sweet * 0.3),
        metrics.sweet * 0.25,
        Paint()..color = Palette.shine.withValues(alpha: 0.45),
      );
    }

    // The gaps: a faint mark where a cut may go, a rust blade
    // where one is.
    for (var gap = 1; gap < metrics.length; gap++) {
      final at = metrics.gapAt(gap);
      if (play.cuts.contains(gap)) {
        // The blade lies across the string, whichever way the
        // string runs there.
        final along = metrics.sweetAt(gap) - metrics.sweetAt(gap - 1);
        final across = Offset(-along.dy, along.dx) / along.distance;
        canvas.drawLine(
          at - across * metrics.sweet * 1.5,
          at + across * metrics.sweet * 1.5,
          Paint()
            ..color = Palette.cut
            ..strokeWidth = math.max(2, pitch * 0.09)
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawCircle(at, math.max(1.5, pitch * 0.05), Paint()..color = Palette.gap);
      }
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        metrics.gapAt(aim.$2),
        pitch * 0.34,
        Paint()
          ..color = aim.$1 == 'mend' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, pitch * 0.06),
      );
    }

    // The children's names under the counter.
    _write(
      canvas,
      'first child',
      Offset(size.width * 0.28, size.height - pitch * 0.35),
      labels.copyWith(color: Palette.first.withValues(alpha: 1), fontSize: math.max(10, pitch * 0.32), fontWeight: FontWeight.w700),
    );
    _write(
      canvas,
      'second child',
      Offset(size.width * 0.72, size.height - pitch * 0.35),
      labels.copyWith(color: Palette.second.withValues(alpha: 1), fontSize: math.max(10, pitch * 0.32), fontWeight: FontWeight.w700),
    );
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(StringView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a share as it stands.
String whyWords(Play play) {
  final share = play.share;
  final note = share.note == null ? '' : ' ${share.note}';
  if (!share.winnable) {
    return 'One cut leaves a first piece and a second. Read the first '
        'pieces off the string: every one with two blues in it has all '
        'four reds in front of them, since the reds all come first, and '
        'no piece holds two of each. The sweep tried the seven cuts and '
        'found no fair share.$note';
  }
  final second = share.sweets.contains('G')
      ? 'three kinds may need three cuts, and the sweep of every string '
          'of two of each finds three always enough'
      : 'the window: slide a piece half the string long from one end to '
          'the other and count the reds in it, and since the count moves '
          'by one at most each step and ends where the other half began, '
          'somewhere it is exactly half, and the two cuts round it share '
          'the string, built for every string of these counts';
  return 'The shares are counted by the sweep, every set of cuts allowed '
      'and every piece handed out in turn, and held to a second voice: '
      '$second. ${share.ways} set${share.ways == 1 ? '' : 's'} of cuts '
      'land${share.ways == 1 ? 's' : ''} this share.$note';
}

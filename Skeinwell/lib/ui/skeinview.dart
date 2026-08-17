import 'dart:math';

import 'package:flutter/material.dart';

import '../skein/play.dart';
import '../skein/rules.dart';
import 'palette.dart';

/// Where the five greens sit in a board of a given size, and where each
/// lane's middle falls, which is where the share is written and where a
/// tap lands.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 24.0;
    final room = Size(size.width, size.height - words);
    final reach = min(room.width, room.height) / 2 - (bare ? 14.0 : 30.0);
    ring = max(20.0, reach);
    middle = Offset(room.width / 2, room.height / 2);
    green = List.filled(Rules.greens + 1, Offset.zero);
    for (var g = 1; g <= Rules.greens; g++) {
      final turn = -pi / 2 + (g - 1) * 2 * pi / Rules.greens;
      green[g] = middle + Offset(cos(turn) * ring, sin(turn) * ring);
    }
    radius = min(bare ? 20.0 : 15.0, ring * 0.24);
    lane = [
      for (var i = 0; i < Rules.howManyLanes; i++)
        (green[Rules.lanes[i].$1] + green[Rules.lanes[i].$2]) / 2,
    ];
  }

  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final Offset middle;
  late final List<Offset> green;

  /// Where each lane's middle falls, in the order the lanes are listed.
  late final List<Offset> lane;
  late final double ring, radius;

  /// The lane a tap at [at] means, or null when it lands nowhere near
  /// one.
  int? laneAt(Offset at) {
    var best = -1;
    var away = radius * 1.5;
    for (var i = 0; i < lane.length; i++) {
      final d = (lane[i] - at).distance;
      if (d < away) {
        away = d;
        best = i;
      }
    }
    return best < 0 ? null : best;
  }

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 200 && size.width >= 250;
}

/// The village: greens, the lanes laid between them with their shares
/// written along them, and the lanes not laid drawn as dashes.
class SkeinView extends CustomPainter {
  const SkeinView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, bool)? pointing;

  final TextStyle labels;

  /// Whether to draw the village alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);
    final shares = play.shares;
    for (var i = 0; i < Rules.howManyLanes; i++) {
      final (a, b) = Rules.lanes[i];
      final from = m.green[a], to = m.green[b];
      final lit = pointing?.$1 == i;
      if (!play.has(i)) {
        // A lane not laid is drawn as dashes, so a thumb can see where
        // it would go and tap it there.
        _dashed(canvas, from, to, lit ? Palette.shown : Palette.ghost,
            bare ? 3.5 : 1.6);
        continue;
      }
      final share = shares[i];
      final whole = share != null && share.n == share.d;
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = lit
              ? Palette.shown
              : (whole ? Palette.whole : Palette.lane)
          ..strokeWidth = bare ? 6 : (whole ? 3.6 : 2.6)
          ..strokeCap = StrokeCap.round,
      );
    }
    for (var g = 1; g <= Rules.greens; g++) {
      canvas.drawCircle(m.green[g], m.radius, Paint()..color = Palette.green);
      canvas.drawCircle(
        m.green[g],
        m.radius,
        Paint()
          ..color = Palette.night
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : 1.6,
      );
      if (!bare) {
        _word(canvas, '$g', m.green[g], Palette.night, size, m.radius);
      }
    }
    if (bare) return;
    // The share, written at the middle of each lane, nudged away from
    // the centre of the village so the diagonals do not write over one
    // another.
    for (var i = 0; i < Rules.howManyLanes; i++) {
      final share = shares[i];
      if (share == null) continue;
      final at = m.lane[i];
      final out = at - m.middle;
      final nudge =
          out.distance < 1 ? const Offset(0, -12) : out / out.distance * 11;
      _pill(canvas, '$share', at + nudge,
          share.n == share.d ? Palette.whole : Palette.ink, size);
    }
    if (!m.roomy) return;
    _word(
        canvas,
        '${play.lanes} lanes, ${play.stringings} '
        '${play.stringings == 1 ? 'stringing' : 'stringings'}, and the shares '
        'add to ${play.total}',
        Offset(size.width / 2, size.height - 10),
        Palette.inkDim,
        size,
        11);
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Color colour,
      double width) {
    final along = to - from;
    final steps = (along.distance / 9).floor();
    final paint = Paint()
      ..color = colour
      ..strokeWidth = width;
    for (var i = 0; i < steps; i += 2) {
      canvas.drawLine(from + along * (i / steps),
          from + along * ((i + 1) / steps), paint);
    }
  }

  void _pill(Canvas canvas, String words, Offset at, Color colour, Size size) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final box = Rect.fromCenter(
        center: at, width: text.width + 6, height: text.height + 2);
    canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(4)),
        Paint()..color = Palette.night.withValues(alpha: 0.82));
    text.paint(canvas, box.topLeft + const Offset(3, 1));
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(SkeinView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}

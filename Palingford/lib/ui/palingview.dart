import 'dart:math';

import 'package:flutter/material.dart';

import '../paling/play.dart';
import '../paling/rules.dart';
import 'palette.dart';

/// Where the fence stands in a board of a given size.
///
/// Ten columns across, the palings standing on a ground line near the foot,
/// their tags written underneath, and room kept above for the one in hand.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 18.0;
    final tagRow = bare ? 0.0 : 15.0;
    final room = Size(
      max(size.width - 12, 8),
      max(size.height - words - 12, 8),
    );
    left = 6;
    place = room.width / Rules.palings;
    hold = bare ? 0.0 : min(room.height * 0.18, 46.0);
    ground = 6 + room.height - tagRow;
    tall = max(ground - 6 - hold, 12);
    width = max(place * (bare ? 0.52 : 0.46), 2);
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double place, left, ground, tall, hold, width;

  /// Whether there is room for words under the fence.
  bool get roomy => !bare && size.height >= 200 && size.width >= 240;

  double middleOf(int at) => left + (at + 0.5) * place;

  /// The top of a paling of a given height, standing on the ground.
  double topOf(int height) => ground - tall * height / Rules.palings;

  Rect standingAt(int at, int height) => Rect.fromLTRB(
        middleOf(at) - width / 2,
        topOf(height),
        middleOf(at) + width / 2,
        ground,
      );

  /// Where a gap sits: the near edge of the column it comes before.
  double gapLine(int gap) => left + gap * place;

  /// The standing paling a tap means, or null when it lands in the air above
  /// the fence or past the last paling.
  int? palingUnder(Offset touch) {
    if (touch.dy < hold) return null;
    final at = ((touch.dx - left) / place).floor();
    if (at < 0 || at >= play.standing.length) return null;
    return at;
  }

  /// The gap a tap means, which is the nearest, or null when the tap lands
  /// in the air above the fence.
  int? gapUnder(Offset touch) {
    if (touch.dy < hold) return null;
    return ((touch.dx - left) / place).round().clamp(0, Rules.palings - 1);
  }
}

/// The fence, its palings, its tags and the runs marked along it.
class PalingView extends CustomPainter {
  const PalingView({
    required this.play,
    this.pointing,
    this.showRuns = true,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The paling the show-me wants lifted and the gap it wants it in, or null.
  final (int, int)? pointing;

  /// Whether to mark the longest climb and the longest drop.
  final bool showRuns;

  final TextStyle labels;

  /// Whether to draw the fence alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final standing = play.standing;

    canvas.drawLine(
      Offset(m.left, m.ground),
      Offset(m.left + m.place * Rules.palings, m.ground),
      Paint()
        ..color = Palette.ground
        ..strokeWidth = bare ? 4 : 2,
    );

    // The gaps, shown only while a paling is in hand and there is somewhere
    // to put it.
    if (!bare && play.held != null) {
      for (var gap = 0; gap < Rules.palings; gap++) {
        final x = m.gapLine(gap);
        final lit = pointing != null && pointing!.$2 == gap;
        canvas.drawLine(
          Offset(x, m.ground - 5),
          Offset(x, m.ground + 5),
          Paint()
            ..color = lit ? Palette.shown : Palette.line
            ..strokeWidth = lit ? 3 : 1.6,
        );
      }
    }

    final climbing = showRuns ? play.climbLine : const <int>[];
    final dropping = showRuns && !bare ? play.dropLine : const <int>[];

    for (var at = 0; at < standing.length; at++) {
      final height = standing[at];
      final post = m.standingAt(at, height);
      final onClimb = climbing.contains(at);
      final onDrop = dropping.contains(at);
      canvas.drawRRect(
        RRect.fromRectAndRadius(post, Radius.circular(m.width * 0.3)),
        Paint()..color = Palette.paling,
      );
      if (onClimb || onDrop) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(post, Radius.circular(m.width * 0.3)),
          Paint()
            ..color = onClimb ? Palette.climb : Palette.drop
            ..style = PaintingStyle.stroke
            ..strokeWidth = bare ? 3 : 1.8,
        );
      }
    }

    // The runs themselves, drawn along the tops of the palings they use.
    void run(List<int> places, Color colour) {
      if (places.length < 2) return;
      final path = Path();
      for (var i = 0; i < places.length; i++) {
        final at = places[i];
        final point = Offset(m.middleOf(at), m.topOf(standing[at]) - 3);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colour
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : 1.6,
      );
    }

    run(dropping, Palette.drop);
    run(climbing, Palette.climb);

    if (bare) return;

    // The tag under each paling: the longest climb ending there written in
    // the climb's colour, the longest drop ending there in the drop's. No
    // two tags on a fence are the same, and that is the whole proof.
    final tags = play.tags;
    final points = min(m.place * 0.30, 10.0);
    for (var at = 0; at < standing.length; at++) {
      _tag(canvas, tags[at], Offset(m.middleOf(at), m.ground + 8), size,
          points);
    }

    // The paling in hand, floating over the gap it came from.
    final hand = play.inHand;
    if (hand != null) {
      final x = m.middleOf(min(play.held!, standing.length));
      // Drawn to the height of the band it floats in rather than the
      // fence's own scale, so a tall paling in hand is not cut off at the
      // top of the board.
      final foot = m.hold - 4;
      final band = max(m.hold - 6, 6);
      final post = Rect.fromLTRB(
        x - m.width / 2,
        max(foot - band * hand / Rules.palings, 1),
        x + m.width / 2,
        foot,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(post, Radius.circular(m.width * 0.3)),
        Paint()..color = Palette.held,
      );
    }

    if (!m.roomy) return;
    _word(
      canvas,
      'each tag reads the climb ending there, then the drop',
      Offset(size.width / 2, size.height - 8),
      Palette.inkDim,
      size,
      11,
    );
  }

  /// One paling's tag, its two numbers set side by side in the colours of
  /// the runs they count.
  void _tag(
    Canvas canvas,
    (int, int) tag,
    Offset at,
    Size size,
    double points,
  ) {
    TextPainter face(String words, Color colour) => TextPainter(
          text: TextSpan(
            text: words,
            style: labels.copyWith(color: colour, fontSize: points),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
    final climbing = face('${tag.$1}', Palette.climb);
    final dropping = face('${tag.$2}', Palette.drop);
    final gap = points * 0.5;
    final whole = climbing.width + gap + dropping.width;
    final x = (at.dx - whole / 2)
        .clamp(1.0, max(1.0, size.width - whole - 1))
        .toDouble();
    final y = (at.dy - climbing.height / 2)
        .clamp(0.0, max(0.0, size.height - climbing.height))
        .toDouble();
    climbing.paint(canvas, Offset(x, y));
    dropping.paint(canvas, Offset(x + climbing.width + gap, y));
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
  bool shouldRepaint(PalingView old) =>
      old.play.mark != play.mark ||
      old.play.level != play.level ||
      old.pointing != pointing ||
      old.showRuns != showRuns ||
      old.bare != bare;
}

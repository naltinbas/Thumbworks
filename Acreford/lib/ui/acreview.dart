import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../acre/play.dart';
import '../acre/rules.dart';
import 'palette.dart';

/// Where every post stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    gap = math.min(
      room.width * 0.74 / (Rules.side - 1),
      room.height * 0.74 / (Rules.side - 1),
    );
    left = (room.width - gap * (Rules.side - 1)) / 2;
    top = (room.height - gap * (Rules.side - 1)) / 2;
  }

  final Play play;

  late final double gap;
  late final double left;
  late final double top;

  /// The middle of a post, rows read from the top.
  Offset postAt((int, int) post) => Offset(
        left + post.$1 * gap,
        top + post.$2 * gap,
      );

  /// The post under a touch, or null for the verge.
  (int, int)? postUnder(Offset touch) {
    for (final post in Rules.field) {
      if ((postAt(post) - touch).distance <= gap * 0.34) {
        return post;
      }
    }
    return null;
  }
}

/// The field, drawn: posts, rails, and what the paddock holds.
class AcreView extends CustomPainter {
  AcreView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The post the show-me points at, close or walk, or null.
  final ((int, int), bool)? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final gap = metrics.gap;
    final walk = play.walk;

    // The rails standing so far, the closing rail included.
    final rails = <((int, int), (int, int))>[
      for (var i = 0; i + 1 < walk.length; i++) (walk[i], walk[i + 1]),
      if (play.closed) (walk.last, walk.first),
    ];

    // The paddock, washed, once the fence is closed.
    if (play.closed) {
      final ground = Path()
        ..addPolygon([for (final post in walk) metrics.postAt(post)], true);
      canvas.drawPath(ground, Paint()..color = Palette.wash);
    }

    // The rails.
    final wood = Paint()
      ..color = Palette.rail
      ..strokeWidth = math.max(gap * 0.09, 3.4)
      ..strokeCap = StrokeCap.round;
    for (final (a, b) in rails) {
      canvas.drawLine(metrics.postAt(a), metrics.postAt(b), wood);
    }

    // Every post of the field; the walked ones as fence posts,
    // the ones a rail runs over ringed rust, and the ones the
    // closed paddock holds shown gold.
    for (final post in Rules.field) {
      final at = metrics.postAt(post);
      final isWalked = walk.contains(post);
      var onRail = false;
      for (final (a, b) in rails) {
        if (!isWalked && Rules.onRail(post, a, b)) onRail = true;
      }
      final held = play.closed && !isWalked && !onRail && _inside(post);

      if (held) {
        canvas.drawCircle(
          at,
          gap * 0.16,
          Paint()..color = Palette.held.withValues(alpha: 0.25),
        );
      }
      canvas.drawCircle(
        at,
        isWalked ? gap * 0.11 : gap * 0.07,
        Paint()
          ..color = held
              ? Palette.held
              : isWalked
                  ? Palette.walked
                  : Palette.post,
      );
      if (isWalked) {
        canvas.drawCircle(
          at,
          gap * 0.11,
          Paint()
            ..color = Palette.night
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
      if (onRail) {
        canvas.drawCircle(
          at,
          gap * 0.15,
          Paint()
            ..color = Palette.caught
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      }
    }

    // The first post ringed once the walk is long enough to
    // close on it.
    if (!play.closed &&
        walk.length == play.field.posts &&
        play.takes(walk.first)) {
      canvas.drawCircle(
        metrics.postAt(walk.first),
        gap * 0.18,
        Paint()
          ..color = Palette.walked
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    }

    // The pointed post.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(
        metrics.postAt(aim.$1),
        gap * 0.21,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.8,
      );
    }
  }

  bool _inside((int, int) post) =>
      play.closed && Rules.insidePosts(play.walk) > 0 && _rayIn(post);

  bool _rayIn((int, int) post) {
    final walk = play.walk;
    for (var i = 0; i < walk.length; i++) {
      if (Rules.onRail(post, walk[i], walk[(i + 1) % walk.length])) {
        return false;
      }
    }
    var crossings = 0;
    for (var i = 0; i < walk.length; i++) {
      final a = walk[i], b = walk[(i + 1) % walk.length];
      if ((a.$2 > post.$2) != (b.$2 > post.$2)) {
        final num = (a.$1 - post.$1) * (b.$2 - a.$2) +
            (post.$2 - a.$2) * (b.$1 - a.$1);
        if (b.$2 > a.$2 ? num > 0 : num < 0) crossings++;
      }
    }
    return crossings.isOdd;
  }

  @override
  bool shouldRepaint(AcreView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the field at hand.
String whyWords(Play play) {
  final field = play.field;
  final note = field.note == null ? '' : ' ${field.note}';
  if (!field.winnable) {
    return 'Twice the acres is twice the posts within plus the rim '
        'less two: Pick\'s count, held to the rails\' crossing sum '
        'across every paddock there is. A bare rim keeps all four '
        'walked posts as its whole count, so twice the acres comes '
        'out twice the inside plus two, even every time; two acres '
        'and a half is five halves, odd. The sweep walked all '
        '${withComma(1758)} four-post paddocks, and the 212 that '
        'pay five all let a post onto a rail.$note';
  }
  return 'The acres are counted two ways that share nothing: the '
      'rails\' own crossing sum, walked rail by rail, and Pick\'s '
      'count, twice the posts within plus the rim less two. The '
      'sweep walks all 516 three-post and ${withComma(1758)} '
      'four-post paddocks and the two agree on every one. '
      '${field.ways} paddocks land this field\'s asking.$note';
}

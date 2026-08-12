import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../wish/play.dart';
import 'palette.dart';

/// Where every farm stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    middle = Offset(room.width / 2, room.height / 2);
    ring = math.min(room.width, room.height) * 0.36;
    house = ring * 0.19;
  }

  final Play play;

  late final Offset middle;
  late final double ring;
  late final double house;

  /// The middle of a farm, the first at the top.
  Offset farmAt(int farm) {
    final turn =
        -math.pi / 2 + 2 * math.pi * farm / play.wish.farms;
    return middle + Offset(math.cos(turn), math.sin(turn)) * ring;
  }

  /// Both ends of a pair's path, trimmed clear of the farms.
  (Offset, Offset) pathOf(int pair) {
    final (a, b) = play.rules.pairs[pair];
    final from = farmAt(a);
    final to = farmAt(b);
    final way = (to - from) / (to - from).distance;
    return (from + way * house * 1.5, to - way * house * 1.5);
  }

  /// Where a pair's ring and hit-centre sit, staggered along
  /// the path so no two paths meet at anyone's centre: crossing
  /// pairs would otherwise share the exact midpoint.
  Offset midOf(int pair) {
    final (from, to) = pathOf(pair);
    return from + (to - from) * (0.34 + (pair % 4) * 0.11);
  }

  /// The pair whose path lies under a touch, or null.
  int? pairUnder(Offset touch) {
    int? found;
    var nearest = house * 1.15;
    for (var pair = 0; pair < play.rules.pairs.length; pair++) {
      final (from, to) = pathOf(pair);
      final span = to - from;
      final length = span.distance;
      var along = ((touch - from).dx * span.dx +
              (touch - from).dy * span.dy) /
          (length * length);
      along = along.clamp(0.0, 1.0);
      final off = (from + span * along - touch).distance;
      if (off < nearest) {
        nearest = off;
        found = pair;
      }
    }
    return found;
  }
}

/// The green, drawn: farms, wishes, and the paths trodden.
class WishView extends CustomPainter {
  WishView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The pair the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final house = metrics.house;
    final counts = play.counts;

    // Every path, faint until trodden.
    for (var pair = 0; pair < play.rules.pairs.length; pair++) {
      final (from, to) = metrics.pathOf(pair);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color =
              play.trodden[pair] ? Palette.path : Palette.faint
          ..strokeWidth = play.trodden[pair]
              ? math.max(house * 0.22, 3.6)
              : math.max(house * 0.09, 1.8)
          ..strokeCap = StrokeCap.round,
      );
      if (pointing == pair) {
        canvas.drawCircle(
          metrics.midOf(pair),
          house * 0.7,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }

    // The farms, each wearing its wish.
    for (var farm = 0; farm < play.wish.farms; farm++) {
      final at = metrics.farmAt(farm);
      final wished = play.wish.wishes[farm];
      final walked = counts[farm];
      final met = walked == wished;
      final body = Rect.fromCenter(
        center: at + Offset(0, house * 0.22),
        width: house * 1.5,
        height: house * 1.18,
      );
      canvas.drawRect(body, Paint()..color = Palette.farm);
      canvas.drawPath(
        Path()
          ..moveTo(body.left - house * 0.14, body.top)
          ..lineTo(at.dx, body.top - house * 0.82)
          ..lineTo(body.right + house * 0.14, body.top)
          ..close(),
        Paint()..color = Palette.roof,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: body.center + Offset(0, house * 0.12),
          width: house * 0.34,
          height: house * 0.56,
        ),
        Paint()..color = Palette.line,
      );
      canvas.drawRect(
        body.inflate(house * 0.09),
        Paint()
          ..color = met
              ? Palette.met
              : walked > wished
                  ? Palette.over
                  : Palette.faint
          ..style = PaintingStyle.stroke
          ..strokeWidth = met || walked > wished ? 2.8 : 1.6,
      );

      // The tally: walked of wished.
      final tally = TextPainter(
        text: TextSpan(
          text: '$walked of $wished',
          style: labels.copyWith(
            color: met
                ? Palette.met
                : walked > wished
                    ? Palette.over
                    : Palette.inkDim,
            fontSize: house * 0.52,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tally.paint(
        canvas,
        at + Offset(-tally.width / 2, house * 1.05),
      );
    }
  }

  @override
  bool shouldRepaint(WishView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the wish list at hand.
String whyWords(Play play) {
  final wish = play.wish;
  final note = wish.note == null ? '' : ' ${wish.note}';
  final sweeps = {4: '64', 5: withComma(1024)};
  if (!wish.winnable) {
    return 'The wish sum here is even, and evenness is not '
        'enough. Hold the top three wishes to Erdos and Gallai\'s '
        'arithmetic: nine asked, against three farms treading at '
        'most six among themselves and the one-wish farm sparing '
        'one, seven for nine. The sweep trod all 64 yards of the '
        'green and none lands the list.$note';
  }
  return 'A wish list lands three ways that share nothing: the '
      'sweep treads every yard of the green, ${sweeps[wish.farms]} '
      'of them, and counts the landings; Erdos and Gallai\'s '
      'arithmetic holds the top k wishes under k times k less one '
      'plus what the rest can spare, at every k; and Havel and '
      'Hakimi\'s build wires the biggest wish first and lands or '
      'dies. All three agree on every wish list of four and five '
      'farms. ${wish.ways} treading${wish.ways == 1 ? '' : 's'} '
      'land${wish.ways == 1 ? 's' : ''} this list.$note';
}

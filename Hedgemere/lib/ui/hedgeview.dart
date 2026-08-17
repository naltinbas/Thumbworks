import 'dart:math';

import 'package:flutter/material.dart';

import '../hedge/play.dart';
import '../hedge/rules.dart';
import 'palette.dart';

/// Where the posts of a hedge sit in a board of a given size. Post 1 is
/// put at the top and every post hangs below the one it is joined back
/// to, leaves spread evenly along the bottom of their row.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final hangs = <int, List<int>>{};
    final deep = List.filled(Rules.posts + 1, 0);
    for (final (a, b) in play.paths) {
      hangs.putIfAbsent(b, () => []).add(a);
    }
    for (var p = 2; p <= Rules.posts; p++) {
      final over = p == 2 ? 1 : play.hanging[p - 3];
      deep[p] = deep[over] + 1;
    }
    depth = deep;
    var slot = 0.0;
    final across = List.filled(Rules.posts + 1, 0.0);
    void walk(int p) {
      final under = hangs[p] ?? const <int>[];
      if (under.isEmpty) {
        across[p] = slot;
        slot += 1;
        return;
      }
      for (final q in under..sort()) {
        walk(q);
      }
      across[p] = (across[under.first] + across[under.last]) / 2;
    }

    walk(1);
    final rows = deep.reduce(max) + 1;
    final wide = max(1.0, slot - 1);
    final pad = bare ? size.shortestSide * 0.12 : 30.0;
    final words = bare ? 0.0 : 32.0;
    final room = Rect.fromLTRB(
        pad, pad * 0.6, size.width - pad, size.height - pad * 0.6 - words);
    post = List.filled(Rules.posts + 1, Offset.zero);
    for (var p = 1; p <= Rules.posts; p++) {
      post[p] = Offset(
        room.left + (wide == 0 ? 0.5 : across[p] / wide) * room.width,
        room.top + (rows == 1 ? 0.5 : deep[p] / (rows - 1)) * room.height,
      );
    }
    radius = min(bare ? 22.0 : 15.0,
        min(room.width / (slot * 1.6), room.height / (rows * 1.9)));
    this.rows = rows;
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final List<Offset> post;
  late final List<int> depth;
  late final double radius;
  late final int rows;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 170 && size.width >= 240;
}

/// The hedge: posts, paths, one longest walk drawn behind them, the
/// middle lit and the fallen posts marked with the round they fell in.
class HedgeView extends CustomPainter {
  const HedgeView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the hedge alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final middle = play.middle;
    final fell = play.fell;
    // One longest walk, drawn wide and faint behind everything, with
    // the middle sitting at its halfway mark.
    final walk = _longestWalk();
    if (walk.length > 1) {
      final path = Path()..moveTo(m.post[walk.first].dx, m.post[walk.first].dy);
      for (final p in walk.skip(1)) {
        path.lineTo(m.post[p].dx, m.post[p].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.walk
          ..style = PaintingStyle.stroke
          ..strokeWidth = m.radius * (bare ? 1.1 : 0.9)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    for (final (a, b) in play.paths) {
      canvas.drawLine(
        m.post[a],
        m.post[b],
        Paint()
          ..color = Palette.twig
          ..strokeWidth = bare ? 5 : 2.4,
      );
    }
    for (var p = 1; p <= Rules.posts; p++) {
      final standing = fell[p] == 0;
      canvas.drawCircle(
        m.post[p],
        m.radius,
        Paint()
          ..color = standing
              ? Palette.middle
              : Color.lerp(Palette.post, Palette.line,
                  (fell[p] - 1) / max(1, play.rounds))!,
      );
      canvas.drawCircle(
        m.post[p],
        m.radius,
        Paint()
          ..color = standing ? Palette.ink : Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 3 : (standing ? 2.2 : 1.2),
      );
      if (bare) continue;
      _word(canvas, '$p', m.post[p], Palette.night, size, m.radius * 0.95);
      if (!standing && m.radius > 8) {
        // The round the post falls in, tucked against its shoulder so
        // that a crowded hedge does not write over itself.
        _word(canvas, '${fell[p]}',
            m.post[p] + Offset(m.radius * 0.95, m.radius * 0.95),
            Palette.inkDim, size, 10);
      }
    }
    if (bare || !m.roomy) return;
    _word(
        canvas,
        'the number by a post is the round it falls in',
        Offset(size.width / 2, size.height - 22),
        Palette.inkDim,
        size,
        11);
    _word(
        canvas,
        'longest walk ${play.longest} steps; the middle is '
        '${Rules.tellMiddle(middle)}, halfway along it',
        Offset(size.width / 2, size.height - 8),
        Palette.inkDim,
        size,
        11);
  }

  /// A longest walk through the hedge, end to end.
  List<int> _longestWalk() {
    final joined = Rules.joined(play.hanging);
    var from = 1, far = 0;
    for (var p = 1; p <= Rules.posts; p++) {
      final away = Rules.stepsFrom(joined, p);
      for (var q = 1; q <= Rules.posts; q++) {
        if (away[q] > far) {
          far = away[q];
          from = p;
        }
      }
    }
    final away = Rules.stepsFrom(joined, from);
    var to = from;
    for (var p = 1; p <= Rules.posts; p++) {
      if (away[p] == far) {
        to = p;
        break;
      }
    }
    // Walk back down the steps, one at a time.
    final out = <int>[to];
    while (out.last != from) {
      final at = out.last;
      out.add(joined[at].firstWhere((q) => away[q] == away[at] - 1));
    }
    return out;
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
  bool shouldRepaint(HedgeView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}

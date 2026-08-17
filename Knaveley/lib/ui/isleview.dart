import 'dart:math';

import 'package:flutter/material.dart';

import '../isle/play.dart';
import '../isle/rules.dart';
import 'palette.dart';

/// Where the villagers stand in a board of a given size: in a column,
/// each with the telling they make beside them.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final many = play.level.villagers;
    final pad = min(bare ? 10.0 : 16.0, size.height * 0.05);
    row = max(6.0, (size.height - 2 * pad) / many);
    top = (size.height - row * many) / 2;
    head = max(3.0, min(row * 0.34, bare ? 44.0 : 26.0));
    left = min(size.width * 0.16, head * 2.2);
  }

  final Play play;
  final Size size;
  final bool bare;

  /// How tall a villager's row is, and how big a head is drawn.
  late final double row;
  late final double top;
  late final double head;
  late final double left;

  Offset at(int who) => Offset(left, top + (who + 0.5) * row);

  Rect bubbleAt(int who) => Rect.fromLTWH(
        left + head * 1.5,
        top + (who + 0.5) * row - head * 0.85,
        size.width - left - head * 1.5 - 12,
        head * 1.7,
      );

  /// Which villager lies under [where], or null when none does.
  int? under(Offset where) {
    for (var who = 0; who < play.level.villagers; who++) {
      if ((at(who) - where).distance <= head * 1.4) return who;
    }
    return null;
  }

  bool get roomy => head >= 16;
}

/// The villagers, their kinds and the tellings they make.
class IsleView extends CustomPainter {
  const IsleView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The villager the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the villagers alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final kinds = play.kinds;
    final caught = play.caught;

    for (var who = 0; who < play.level.villagers; who++) {
      final at = m.at(who);
      final isKnight = kinds[who] == Rules.knight;
      // The villager: a head and a cloak.
      canvas.drawCircle(
        at.translate(0, -m.head * 0.35),
        m.head * 0.5,
        Paint()..color = isKnight ? Palette.knight : Palette.knave,
      );
      canvas.drawPath(
        Path()
          ..moveTo(at.dx - m.head * 0.8, at.dy + m.head * 0.9)
          ..lineTo(at.dx, at.dy - m.head * 0.1)
          ..lineTo(at.dx + m.head * 0.8, at.dy + m.head * 0.9)
          ..close(),
        Paint()..color = isKnight ? Palette.knight : Palette.knave,
      );
      if (who == pointing) {
        canvas.drawCircle(
          at,
          m.head * 1.25,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.6, m.head * 0.12),
        );
      }
      final wrong = caught.contains(who);
      canvas.drawCircle(
        at,
        m.head * 1.25,
        Paint()
          ..color = wrong ? Palette.bad : Palette.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.2, m.head * 0.08),
      );

      if (bare) continue;

      final bubble = m.bubbleAt(who);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bubble, Radius.circular(m.head * 0.4)),
        Paint()..color = Palette.bubble,
      );
      _word(
        canvas,
        '${Rules.tellName(who)}: '
        '${Rules.tellTelling(play.level.tellings[who], who)}',
        bubble.centerLeft.translate(10, -m.head * 0.18),
        min(m.head * 0.5, 13.0),
        Palette.ink,
        left: true,
        wide: bubble.width - 20,
      );
      _word(
        canvas,
        wrong
            ? 'caught out'
            : play.tellsTrue(who)
                ? 'true, and a knight tells it'
                : 'false, and a knave tells it',
        bubble.centerLeft.translate(10, m.head * 0.45),
        min(m.head * 0.42, 11.0),
        wrong ? Palette.bad : Palette.gold,
        left: true,
        wide: bubble.width - 20,
      );
    }
  }

  void _word(
    Canvas canvas,
    String words,
    Offset at,
    double size,
    Color colour, {
    bool left = false,
    double? wide,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(color: colour, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    )..layout(maxWidth: wide ?? double.infinity);
    painter.paint(
      canvas,
      at - Offset(left ? 0 : painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(IsleView old) =>
      old.play != play || old.pointing != pointing;
}

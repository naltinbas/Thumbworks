import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../coins/play.dart';
import '../coins/rules.dart';
import 'palette.dart';

/// Where the spots lie on the board, so the screen and the tests can
/// find every one: the table's rows nest as a triangular lattice, the
/// upright triangle's middle line down the middle of the board.
class Metrics {
  Metrics(this.play, Size room) {
    final rows = play.rules.rows;
    // The widest row, at the bottom, has rows + 4 spots; the rows stand
    // rows + 3 deep, root three over two apart.
    spacing = math.min(room.width * 0.92 / (rows + 4), room.height * 0.9 / ((rows + 2) * 0.866 + 1));
    final height = (rows + 2) * 0.866 * spacing + spacing;
    top = (room.height - height) / 2 + spacing / 2;
    middle = room.width / 2;
    coinRadius = spacing * 0.42;
  }

  final Play play;

  late final double spacing;
  late final double top;
  late final double middle;
  late final double coinRadius;

  /// Spot [s]'s place on the board.
  Offset at(Spot s) {
    final (x, y) = s;
    return Offset(middle + (x - y / 2) * spacing, top + (y + 1) * 0.866 * spacing);
  }

  /// The spot under a touch, or null.
  Spot? under(Offset touch) {
    for (final s in play.rules.table) {
      if ((touch - at(s)).distance <= spacing * 0.5) return s;
    }
    return null;
  }
}

/// The table: dimples for every spot, the ghost of where the upright
/// lay, pennies in copper, the one in hand ringed gold, and the turned
/// triangle outlined green when it is made.
class TableView extends CustomPainter {
  TableView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Spot)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final rules = play.rules;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.tableEdge);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.02, size.height * 0.02, size.width * 0.96, size.height * 0.96), Radius.circular(m.spacing * 0.5)),
        Paint()..color = Palette.table);
    // The dimples, and the ghost of the upright.
    for (final s in rules.table) {
      canvas.drawCircle(m.at(s), m.spacing * 0.14, Paint()..color = Palette.dimple);
    }
    for (final s in rules.upright) {
      canvas.drawCircle(m.at(s), m.coinRadius * 0.95, Paint()
        ..color = Palette.ghost.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, m.spacing * 0.03));
    }
    // The turned triangle, outlined when made: the corners pushed out
    // past the pennies so the line runs round them.
    final point = rules.pointOf(play.lying);
    if (point != null) {
      final (a, b) = point;
      final corners = [m.at(point), m.at((a - rules.rows + 1, b - rules.rows + 1)), m.at((a, b - rules.rows + 1))];
      final centre = (corners[0] + corners[1] + corners[2]) / 3;
      final pushed = [
        for (final c in corners) c + (c - centre) / (c - centre).distance * m.coinRadius * 1.9,
      ];
      final path = Path()
        ..moveTo(pushed[0].dx, pushed[0].dy)
        ..lineTo(pushed[1].dx, pushed[1].dy)
        ..lineTo(pushed[2].dx, pushed[2].dy)
        ..close();
      canvas.drawPath(path, Paint()
        ..color = Palette.good.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(2, m.spacing * 0.06)
        ..strokeJoin = StrokeJoin.round);
    }
    // The pennies.
    for (final s in play.lying) {
      final at = m.at(s);
      final held = play.held == s;
      final r = held ? m.coinRadius * 1.12 : m.coinRadius;
      canvas.drawCircle(at + Offset(r * 0.08, r * 0.1), r, Paint()..color = Palette.copperShade);
      canvas.drawCircle(at, r, Paint()..color = Palette.copper);
      canvas.drawCircle(at, r, Paint()
        ..color = Palette.copperRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, r * 0.12));
      canvas.drawCircle(at - Offset(r * 0.3, r * 0.3), r * 0.22, Paint()..color = Palette.copperRim.withValues(alpha: 0.5));
      if (held) {
        canvas.drawCircle(at, r * 1.25, Paint()
          ..color = Palette.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, r * 0.15));
      }
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.at(aim.$2), m.coinRadius * 1.4, Paint()
        ..color = aim.$1 == 'take' ? Palette.gold : Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    if (!bare) {
      _write(canvas, '${play.moves} of ${play.level.moves} move${play.level.moves == 1 ? '' : 's'}', Offset(size.width * 0.5, size.height * 0.06),
          labels.copyWith(color: play.spent && !play.turned ? Palette.clash : Palette.inkDim, fontSize: 12));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(TableView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a triangle as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  if (!level.winnable) {
    return 'However the turned triangle lies over the pennies, each of its rows '
        'shares at most the shorter of its own length and the coin row under it, '
        'so it takes in at most ${rules.rowsBound} of the ${rules.coins} as they '
        'lie, and the sweep of every placement, ${level.placements} of them, finds '
        'no more: ${rules.fewest} pennies must move, and ${level.moves} moves never '
        'turn it, every sequence of ${level.moves} moves on the table swept to be '
        'sure. On every triangle up to twelve rows the sweep takes in exactly what '
        'the rows allow, and the fewest moves is a third of the pennies rounded '
        'down.$note';
  }
  return 'The sweep tries every placement of the turned triangle over the pennies '
      'as they lie, ${level.placements} of them, and the most any takes in is '
      '${rules.bestShare} of the ${rules.coins}, so ${rules.fewest} must move and '
      '${rules.fewest} move${rules.fewest == 1 ? '' : 's'} are enough; the rows allow no more, the '
      'shorter of each turned row and the coin row under it, and the fewest is a '
      'third of the pennies rounded down, on every triangle up to twelve rows. '
      '${level.ways} placement${level.ways == 1 ? '' : 's'} of the ${level.placements} '
      '${level.ways == 1 ? 'is' : 'are'} within ${level.moves} move${level.moves == 1 ? '' : 's'}.$note';
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../ford/play.dart';
import '../ford/rules.dart';
import 'palette.dart';

/// Where the ford's stones sit in a board of a given size. The stones
/// run in rows of [across], turning at each end the way a ford laid
/// across a river does, so stone 12 and stone 13 sit one above the
/// other.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    rows = (Rules.stones / across).ceil();
    final pad = bare ? 2.0 : 8.0;
    // A strip along the top for the rope's word, when there is room.
    strip = bare || size.height < 200 ? 0.0 : 16.0;
    wide = (size.width - 2 * pad) / across;
    // The rows may stand further apart than the stones do along them,
    // so a tall board fills with water rather than with margin.
    tall = min(wide * 1.5, (size.height - 2 * pad - strip) / rows);
    cell = min(wide, tall);
    left = (size.width - wide * across) / 2;
    top = strip + (size.height - strip - tall * rows) / 2;
  }

  /// Stones to a row.
  static const across = 12;

  final Size size;
  final bool bare;
  late final int rows;

  /// How far apart the stones stand along a row and down the ford, and
  /// the smaller of the two, which sets how big a stone is drawn.
  late final double wide;
  late final double tall;
  late final double cell;
  late final double left;
  late final double top;
  late final double strip;

  /// The row and column [stone] falls in, counting from the top left.
  (int, int) place(int stone) {
    final row = (stone - 1) ~/ across;
    final along = (stone - 1) % across;
    return (row, row.isEven ? along : across - 1 - along);
  }

  /// The middle of [stone]'s cell.
  Offset centre(int stone) {
    final (row, col) = place(stone);
    return Offset(left + (col + 0.5) * wide, top + (row + 0.5) * tall);
  }

  Rect cellOf(int stone) {
    final (row, col) = place(stone);
    return Rect.fromLTWH(left + col * wide, top + row * tall, wide, tall);
  }

  /// Which stone lies under [where], or null when nothing does.
  int? under(Offset where) {
    final col = ((where.dx - left) / wide).floor();
    final row = ((where.dy - top) / tall).floor();
    if (col < 0 || col >= across || row < 0 || row >= rows) return null;
    final along = row.isEven ? col : across - 1 - col;
    final stone = row * across + along + 1;
    return Rules.onFord(stone) ? stone : null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => cell >= 22;
}

/// The ford: the water, the stones dry and mossy, the rope from the
/// stone under your feet and the crossing so far.
class FordView extends CustomPainter {
  const FordView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The stone the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the ford and the rope only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);
    final water = Rect.fromLTWH(
      m.left - m.cell * 0.1,
      m.top - m.cell * 0.1,
      m.wide * Metrics.across + m.cell * 0.2,
      m.tall * m.rows + m.cell * 0.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(water, Radius.circular(m.cell * 0.3)),
      Paint()..color = Palette.water,
    );
    for (var row = 0; row < m.rows; row++) {
      final y = m.top + (row + 0.5) * m.tall;
      canvas.drawLine(
        Offset(water.left + m.cell * 0.2, y),
        Offset(water.right - m.cell * 0.2, y),
        Paint()
          ..color = Palette.ripple
          ..strokeWidth = m.cell * 0.5,
      );
    }

    // Where the ask can end, washed over.
    if (!bare) {
      final washed = play.level.winnable
          ? [for (var k = 1; k <= Rules.stones; k++) if (play.level.meets(k)) k]
          : [for (var k = Rules.shallowsFrom; k <= Rules.shallowsTo; k++) k];
      final wash = Paint()
        ..color = play.level.winnable ? Palette.goldFill : Palette.redFill;
      for (final stone in washed) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            m.cellOf(stone).deflate(m.cell * 0.06),
            Radius.circular(m.cell * 0.18),
          ),
          wash,
        );
      }
    }

    // The crossing so far, one leap to a stone from the one before it.
    final leaps = Paint()
      ..color = Palette.copper
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.5, m.cell * 0.08)
      ..strokeJoin = StrokeJoin.round;
    for (var i = 1; i < play.stones.length; i++) {
      final from = m.centre(play.stones[i - 1]);
      final to = m.centre(play.stones[i]);
      final lift = max(m.cell * 0.6, (to - from).distance * 0.16);
      canvas.drawPath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(
            (from.dx + to.dx) / 2,
            (from.dy + to.dy) / 2 - lift,
            to.dx,
            to.dy,
          ),
        leaps,
      );
    }

    // The rope, from the stone under your feet to twice its number.
    final end = min(play.rope, Rules.stones);
    if (end > play.at) {
      final rope = Path()..moveTo(m.centre(play.at).dx, m.centre(play.at).dy);
      _along(rope, m, play.at, end);
      canvas.drawPath(
        rope,
        Paint()
          ..color = Palette.gold.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(3.0, m.cell * 0.34)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // The stones themselves.
    for (var k = 1; k <= Rules.stones; k++) {
      final at = m.centre(k);
      final dry = Rules.dry(k);
      final here = k == play.at;
      final pebble = m.cell * (dry ? 0.36 : 0.30);
      if (!dry) {
        canvas.drawCircle(at.translate(0, m.cell * 0.04), pebble,
            Paint()..color = Palette.water);
      }
      canvas.drawCircle(
        at,
        pebble,
        Paint()..color = dry ? Palette.stone : Palette.moss,
      );
      if (here) {
        canvas.drawCircle(at, pebble, Paint()..color = Palette.gold);
        canvas.drawCircle(
          at,
          pebble + m.cell * 0.09,
          Paint()
            ..color = Palette.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.5, m.cell * 0.07),
        );
      } else if (k == pointing) {
        canvas.drawCircle(
          at,
          pebble + m.cell * 0.08,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.5, m.cell * 0.07),
        );
      } else if (play.stones.contains(k)) {
        canvas.drawCircle(
          at,
          pebble + m.cell * 0.08,
          Paint()
            ..color = Palette.copper
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.0, m.cell * 0.05),
        );
      } else if (dry && Rules.canHop(play.at, k) && !play.isOver) {
        canvas.drawCircle(
          at,
          pebble + m.cell * 0.08,
          Paint()
            ..color = Palette.copper
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.0, m.cell * 0.05),
        );
      }
      if (m.roomy) {
        _word(
          canvas,
          '$k',
          at,
          m.cell * 0.30,
          here || dry ? Palette.night : Palette.mossInk,
        );
      }
    }

    // Where the rope ends, when it ends on the ford at all.
    if (play.rope <= Rules.stones && play.rope > play.at) {
      canvas.drawCircle(
        m.centre(play.rope),
        m.cell * 0.44,
        Paint()
          ..color = Palette.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.0, m.cell * 0.06),
      );
    }

    if (bare || m.strip == 0) return;
    _word(
      canvas,
      play.rope > Rules.stones
          ? 'the rope reaches ${play.rope}, past the far bank'
          : 'the rope from ${play.at} reaches ${play.rope}',
      Offset(size.width / 2, max(m.strip / 2, m.top - m.cell * 0.4)),
      12,
      Palette.gold,
    );
  }

  /// Runs [path] from stone [from] to stone [to] along the ford, turning
  /// at the end of each row the way the stones do.
  void _along(Path path, Metrics m, int from, int to) {
    for (var k = from + 1; k <= to; k++) {
      final at = m.centre(k);
      path.lineTo(at.dx, at.dy);
    }
  }

  void _word(Canvas canvas, String words, Offset at, double size, Color colour) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(color: colour, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(FordView old) =>
      old.play != play || old.pointing != pointing;
}

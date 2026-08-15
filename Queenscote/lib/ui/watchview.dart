import 'dart:math';

import 'package:flutter/material.dart';

import '../watch/play.dart';
import 'palette.dart';

/// Where the board sits in a board of a given size: squares to pixels.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 22.0 : 0.0;
    final side = play.level.side;
    cell = min((size.width - 16) / side, (size.height - strip - 16) / side);
    origin = Offset(size.width / 2 - side * cell / 2, (size.height - strip) / 2 - side * cell / 2);
  }

  final Play play;
  final Size size;
  late final double cell;
  late final Offset origin;

  /// The rectangle of square [i].
  Rect rect(int i) {
    final side = play.level.side;
    return Rect.fromLTWH(origin.dx + (i % side) * cell, origin.dy + (i ~/ side) * cell, cell, cell);
  }

  /// The square under a point, or null.
  int? under(Offset p) {
    final side = play.level.side;
    final c = ((p.dx - origin.dx) / cell).floor(), r = ((p.dy - origin.dy) / cell).floor();
    if (c < 0 || c >= side || r < 0 || r >= side) return null;
    return r * side + c;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The board, the squares seen and unseen, and the queens.
class WatchView extends CustomPainter {
  const WatchView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (Aim, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the board only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final side = play.level.side;
    for (var i = 0; i < side * side; i++) {
      final r = m.rect(i);
      final light = ((i ~/ side) + (i % side)).isEven;
      final seen = play.isSeen(i);
      canvas.drawRect(r, Paint()..color = seen ? (light ? Palette.seenLight : Palette.seenDark) : (light ? Palette.light : Palette.dark));
      if (!seen && play.placed.isNotEmpty) {
        canvas.drawRect(
          r.deflate(bare ? 3 : 2),
          Paint()
            ..color = Palette.unseenRim
            ..style = PaintingStyle.stroke
            ..strokeWidth = bare ? 3 : 1.5,
        );
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(m.origin.dx, m.origin.dy, side * m.cell, side * m.cell),
      Paint()
        ..color = Palette.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    for (final q in play.placed) {
      _queen(canvas, m.rect(q));
    }
    if (bare) return;
    final aim = pointing;
    if (aim != null) {
      canvas.drawRect(
        m.rect(aim.$2).deflate(3),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
    if (!m.roomy) return;
    final u = play.unseen;
    _word(canvas, '${play.placed.length} of ${play.level.queens} queen${play.level.queens == 1 ? '' : 's'} set, $u square${u == 1 ? '' : 's'} unseen', Offset(size.width / 2, size.height - 11), Palette.inkDim, size);
  }

  void _queen(Canvas canvas, Rect r) {
    final c = r.center;
    final w = r.width;
    // A crowned piece: a base, a body, and five points of a crown.
    final body = Path()
      ..moveTo(c.dx - w * 0.28, c.dy + w * 0.34)
      ..lineTo(c.dx + w * 0.28, c.dy + w * 0.34)
      ..lineTo(c.dx + w * 0.2, c.dy + w * 0.05)
      ..lineTo(c.dx - w * 0.2, c.dy + w * 0.05)
      ..close();
    canvas.drawPath(body, Paint()..color = Palette.queen);
    final crown = Path()..moveTo(c.dx - w * 0.3, c.dy + w * 0.05);
    for (var k = 0; k < 5; k++) {
      final x = c.dx - w * 0.3 + k * w * 0.15;
      crown.lineTo(x, c.dy - w * (k.isEven ? 0.3 : 0.1));
      crown.lineTo(x + w * 0.075, c.dy - w * (k.isEven ? 0.05 : 0.1));
    }
    crown
      ..lineTo(c.dx + w * 0.3, c.dy + w * 0.05)
      ..close();
    canvas.drawPath(crown, Paint()..color = Palette.crown);
    canvas.drawPath(
      Path.combine(PathOperation.union, body, crown),
      Paint()
        ..color = Palette.queenRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(WatchView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

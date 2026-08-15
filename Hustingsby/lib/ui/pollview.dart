import 'dart:math';

import 'package:flutter/material.dart';

import '../poll/play.dart';
import 'palette.dart';

/// Where the count's path sits in a board of a given size: ballots left
/// to right, the lead up and down.
class Metrics {
  Metrics(this.play, this.size) {
    final strip = roomy ? 22.0 : 0.0;
    left = 28;
    right = size.width - 16;
    final ballots = play.level.ballots;
    step = (right - left) / max(1, ballots);
    // The lead runs from -birch to +ash at the widest.
    final span = play.level.ash + play.level.birch;
    rise = (size.height - strip - 32) / max(1, span);
    zero = 16 + play.level.ash * rise;
  }

  final Play play;
  final Size size;
  late final double left, right, step, rise, zero;

  /// The point after [i] ballots at lead [lead].
  Offset at(int i, int lead) => Offset(left + i * step, zero - lead * rise);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// The count's path: the level line, the ballots as steps, the lead.
class PollView extends CustomPainter {
  const PollView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the path only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final level = play.level;
    // The grid: a faint line per ballot and per lead.
    final grid = Paint()..color = Palette.grid..strokeWidth = 1;
    for (var i = 0; i <= level.ballots; i++) {
      canvas.drawLine(m.at(i, level.ash), m.at(i, -level.birch), grid);
    }
    for (var l = -level.birch; l <= level.ash; l++) {
      canvas.drawLine(m.at(0, l), m.at(level.ballots, l), l == 0 ? (Paint()..color = Palette.levelLine..strokeWidth = bare ? 3 : 1.5) : grid);
    }
    // The path.
    final leads = play.leads;
    var from = m.at(0, 0);
    for (var i = 0; i < leads.length; i++) {
      final to = m.at(i + 1, leads[i]);
      final ash = play.drawn[i];
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = ash ? Palette.ash : Palette.birch
          ..strokeWidth = bare ? 6 : 3
          ..strokeCap = StrokeCap.round,
      );
      from = to;
    }
    // Dots where the count stands level, and the head.
    for (var i = 0; i < leads.length; i++) {
      if (leads[i] == 0) canvas.drawCircle(m.at(i + 1, 0), bare ? 7 : 4, Paint()..color = Palette.levelDot);
    }
    if (leads.isNotEmpty) {
      final head = m.at(leads.length, leads.last);
      canvas.drawCircle(head, bare ? 9 : 6, Paint()..color = leads.last > 0 ? Palette.ahead : leads.last < 0 ? Palette.behind : Palette.levelDot);
    } else {
      canvas.drawCircle(m.at(0, 0), bare ? 9 : 6, Paint()..color = Palette.levelDot);
    }
    if (bare || !m.roomy) return;
    _word(canvas, 'Ash ahead', Offset(m.left, m.at(0, level.ash).dy - 8), Palette.ahead, size, left: true);
    _word(canvas, 'Birch ahead', Offset(m.left, m.at(0, -level.birch).dy + 10), Palette.behind, size, left: true);
    _word(canvas, 'level', Offset(m.left - 26, m.zero), Palette.levelLine, size);
    _word(canvas, '${play.drawn.length} of ${level.ballots} drawn, lead ${play.lead > 0 ? '+' : ''}${play.lead}, level ${play.levelsSoFar} time${play.levelsSoFar == 1 ? '' : 's'}, changed hands ${play.changesSoFar}', Offset(size.width / 2, size.height - 11), Palette.inkDim, size);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, {bool left = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: 11)),
      textDirection: TextDirection.ltr,
    )..layout();
    final ax = left ? at.dx : at.dx - text.width / 2;
    final x = ax.clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(PollView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

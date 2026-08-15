import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../cellar/play.dart';
import '../cellar/rules.dart';
import 'palette.dart';

/// Where the casks stand on the board, so the screen and the tests can
/// find every one: in rows of up to ten, left to right and top to
/// bottom, numbered from one.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.level.casks;
    cols = math.min(n, 10);
    rows = (n + cols - 1) ~/ cols;
    cell = math.min(room.width * 0.94 / cols, room.height * 0.9 / rows);
    origin = Offset((room.width - cell * cols) / 2, (room.height - cell * rows) / 2);
  }

  final Play play;

  late final int cols;
  late final int rows;
  late final double cell;
  late final Offset origin;

  /// The middle of cask [i], counting from nought.
  Offset at(int i) => origin + Offset((i % cols + 0.5) * cell, (i ~/ cols + 0.5) * cell);

  Rect rectOf(int i) => Rect.fromCenter(center: at(i), width: cell, height: cell);

  /// The cask under a touch, or null.
  int? under(Offset touch) {
    final x = touch.dx - origin.dx, y = touch.dy - origin.dy;
    if (x < 0 || y < 0 || x >= cell * cols || y >= cell * rows) return null;
    final i = (y / cell).floor() * cols + (x / cell).floor();
    return i < play.level.casks ? i : null;
  }
}

/// The cellar: casks in oak with iron hoops, the ones ruled out gone
/// dark, the found cask in green with the coin on it.
class CellarView extends CustomPainter {
  CellarView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The cask the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.cellar);
    // Shelves.
    for (var r = 0; r < m.rows; r++) {
      final y = m.origin.dy + (r + 1) * m.cell - m.cell * 0.06;
      canvas.drawRect(Rect.fromLTWH(m.origin.dx - 4, y, m.cell * m.cols + 8, m.cell * 0.06), Paint()..color = Palette.stone);
    }
    for (var i = 0; i < play.level.casks; i++) {
      final box = m.rectOf(i).deflate(m.cell * 0.12);
      final might = play.mightHold(i);
      final foundHere = play.found && might;
      final body = RRect.fromRectAndRadius(box, Radius.circular(box.width * 0.3));
      canvas.drawRRect(body, Paint()..color = might ? Palette.oak : Palette.out);
      canvas.drawRRect(body, Paint()
        ..color = might ? Palette.oakDark : Palette.stone
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, box.width * 0.06));
      for (final t in [0.3, 0.7]) {
        final y = box.top + box.height * t;
        canvas.drawLine(Offset(box.left, y), Offset(box.right, y), Paint()
          ..color = might ? Palette.hoop : Palette.stone
          ..strokeWidth = math.max(1, box.height * 0.07));
      }
      if (foundHere) {
        canvas.drawRRect(body, Paint()
          ..color = Palette.good
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
        canvas.drawCircle(box.center, box.width * 0.22, Paint()..color = Palette.gold);
      }
      if (!bare && m.cell >= 26) {
        _write(canvas, '${i + 1}', box.center, labels.copyWith(color: might ? Palette.night : Palette.inkDim, fontSize: math.max(9, m.cell * 0.28), fontWeight: FontWeight.w800));
      }
    }
    // The pointer: the cask to cut after.
    final aim = pointing;
    if (aim != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(m.rectOf(aim).deflate(m.cell * 0.06), Radius.circular(m.cell * 0.2)), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(CellarView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a cellar as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final reach = 1 << level.questions;
  final counting = 'Every question is answered yes or no, so ${level.questions} questions have '
      '$reach answers between them, and $reach answers tell apart $reach casks at most: '
      'the coin among ${level.casks} casks wants ${Rules.questions(level.casks)} '
      'questions whatever the cellarman answers, since he keeps the bigger part '
      'every time and the game tree says no cut does better than the middle.';
  if (!level.winnable) {
    return '$counting ${level.casks} is more than $reach, so ${level.questions} never '
        'serve, and every first cut of the ${level.cuts} was swept: after each the '
        'cellarman keeps a part that ${level.questions - 1} questions never search. '
        'The tree is walked for every row up to two hundred, and its fewest is '
        'the bound on every one.$note';
  }
  return '$counting Every first cut of the ${level.cuts} was swept, and ${level.ways} '
      'leave a part that ${level.questions - 1} questions still search; the tree is '
      'walked for every row up to two hundred, and its fewest is the bound on '
      'every one.$note';
}

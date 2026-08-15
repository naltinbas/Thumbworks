import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../miu/play.dart';
import '../miu/rules.dart';
import 'palette.dart';

/// Where the letters lie on the board, so the screen and the tests can
/// find every one: the target in outline near the top of the sheet,
/// the string being derived as tiles across the middle, wrapped when it
/// runs long.
class Metrics {
  Metrics(this.play, Size room) {
    sheet = Rect.fromLTWH(room.width * 0.05, room.height * 0.05, room.width * 0.9, room.height * 0.9);
    perRow = 12;
    tile = math.min(sheet.width / (perRow + 0.5), room.height * 0.11);
    stringTop = sheet.top + sheet.height * 0.34;
    targetTop = sheet.top + sheet.height * 0.1;
  }

  final Play play;

  late final Rect sheet;
  late final int perRow;
  late final double tile;
  late final double stringTop;
  late final double targetTop;

  /// The rectangle of letter [p] of a string [length] long, its rows
  /// centred, from [top].
  Rect tileRect(int p, int length, double top) {
    final row = p ~/ perRow, col = p % perRow;
    final inRow = math.min(perRow, length - row * perRow);
    final left = sheet.center.dx - inRow * tile / 2 + col * tile;
    return Rect.fromLTWH(left, top + row * tile * 1.15, tile, tile).deflate(tile * 0.06);
  }

  /// The middle of letter [p] of the string.
  Offset at(int p) => tileRect(p, play.string.length, stringTop).center;

  /// The letter under a touch, or null.
  int? under(Offset touch) {
    for (var p = 0; p < play.string.length; p++) {
      if (tileRect(p, play.string.length, stringTop).inflate(2).contains(touch)) return p;
    }
    return null;
  }
}

/// The sheet: the target in outline, the string as tiles, M blue, I
/// gold and U plum, a marker under every letter where rule three or four
/// may act, and the count of I written below.
class SheetView extends CustomPainter {
  SheetView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The move the show-me points at, or null.
  final (int, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.desk);
    canvas.drawRect(m.sheet.translate(3, 4), Paint()..color = Palette.night.withValues(alpha: 0.4));
    canvas.drawRect(m.sheet, Paint()..color = Palette.sheet);
    final letterSize = math.max(10.0, m.tile * 0.55);
    // The target, in outline.
    final target = play.level.target;
    for (var p = 0; p < target.length; p++) {
      final rect = m.tileRect(p, target.length, m.targetTop);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(m.tile * 0.15)), Paint()
        ..color = play.isDone ? Palette.mark : Palette.faint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      _write(canvas, target[p], rect.center, labels.copyWith(color: play.isDone ? Palette.mark : Palette.faint, fontSize: letterSize, fontWeight: FontWeight.w800));
    }
    if (!bare) {
      _write(canvas, play.isDone ? 'derived' : 'to derive', Offset(m.sheet.center.dx, m.targetTop - m.tile * 0.45), labels.copyWith(color: Palette.faint, fontSize: 11, fontStyle: FontStyle.italic));
    }
    // The string.
    final s = play.string;
    final moves = play.moves;
    for (var p = 0; p < s.length; p++) {
      final rect = m.tileRect(p, s.length, m.stringTop);
      final colour = s[p] == 'M' ? Palette.tileM : s[p] == 'I' ? Palette.tileI : Palette.tileU;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(m.tile * 0.15)), Paint()..color = colour);
      _write(canvas, s[p], rect.center, labels.copyWith(color: Palette.night, fontSize: letterSize, fontWeight: FontWeight.w800));
      final acts = moves.contains((3, p)) || moves.contains((4, p));
      if (acts) {
        canvas.drawLine(Offset(rect.left + rect.width * 0.2, rect.bottom + 3), Offset(rect.right - rect.width * 0.2, rect.bottom + 3), Paint()
          ..color = Palette.pen
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
      }
    }
    // The pointer: the letters the move acts on, or the whole string for
    // rule one and two.
    final aim = pointing;
    if (aim != null) {
      final (rule, p) = aim;
      final first = rule == 3 || rule == 4 ? p : 0;
      final span = rule == 3 ? 3 : rule == 4 ? 2 : s.length;
      var box = m.tileRect(first, s.length, m.stringTop);
      for (var q = first; q < first + span && q < s.length; q++) {
        box = box.expandToInclude(m.tileRect(q, s.length, m.stringTop));
      }
      canvas.drawRRect(RRect.fromRectAndRadius(box.inflate(4), Radius.circular(m.tile * 0.2)), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    if (!bare) {
      final rows = (s.length + m.perRow - 1) ~/ m.perRow;
      final below = m.stringTop + rows * m.tile * 1.15 + m.tile * 0.4;
      final count = play.iCount;
      _write(canvas, '${s.length} letters, $count I, leaving ${count % 3} by three', Offset(m.sheet.center.dx, below),
          labels.copyWith(color: count % 3 == 0 ? Palette.clash : Palette.pen, fontSize: 12));
      _write(canvas, 'I: end I with U   II: double after M   III: III to U   IV: drop UU', Offset(m.sheet.center.dx, m.sheet.bottom - 14),
          labels.copyWith(color: Palette.faint, fontSize: 10));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(SheetView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a string as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final law = 'The count of I is what the rules cannot shake: rule one and rule four leave '
      'it, rule two doubles it and rule three takes three away, and from one, doubling '
      'and taking three never make a multiple of three, since a multiple of three '
      'doubled or less three is a multiple of three and nothing else is. Every string '
      'reachable on a sheet of ${Rules.longest} letters was walked, ${_commas(Rules.walk().length)} '
      'strings, and the count of I is a multiple of three in none of them.';
  if (!level.winnable) {
    return '$law MU has no I at all, nought I, and nought is a multiple of three, so MU is '
        'never derived; every derivation of ${level.steps} steps was swept as well, '
        '${level.derivations} of them.$note';
  }
  return 'The sweep makes every derivation of ${level.steps} steps from MI, ${level.derivations} '
      'of them, and ${level.ways} end${level.ways == 1 ? 's' : ''} at ${level.target}. $law$note';
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}

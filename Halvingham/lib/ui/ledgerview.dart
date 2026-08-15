import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ledger/play.dart';
import 'palette.dart';

/// Where the rows lie on the board, so the screen and the tests can
/// find every one: a sheet of ledger paper on the desk, the halves down
/// the left column and the doubles down the right, a row a line.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.rows.length;
    sheet = Rect.fromLTWH(room.width * 0.06, room.height * 0.04, room.width * 0.88, room.height * 0.92);
    rowHeight = math.min(sheet.height * 0.78 / (n + 1), 44);
    firstRow = sheet.top + rowHeight * 1.2;
    halvesAt = sheet.left + sheet.width * 0.3;
    doublesAt = sheet.left + sheet.width * 0.66;
    tickAt = sheet.left + sheet.width * 0.9;
  }

  final Play play;

  late final Rect sheet;
  late final double rowHeight;
  late final double firstRow;
  late final double halvesAt;
  late final double doublesAt;
  late final double tickAt;

  /// The middle of row [i]'s line.
  Offset at(int i) => Offset(sheet.center.dx, firstRow + (i + 0.5) * rowHeight);

  Rect rowRect(int i) => Rect.fromLTWH(sheet.left, firstRow + i * rowHeight, sheet.width, rowHeight);

  /// The row under a touch, or null.
  int? under(Offset touch) {
    for (var i = 0; i < play.rows.length; i++) {
      if (rowRect(i).contains(touch)) return i;
    }
    return null;
  }
}

/// The ledger: cream paper ruled in blue, the halves down the left, the
/// doubles down the right, a tick by every row kept and the sum of the
/// doubles kept at the foot against the product wanted.
class LedgerView extends CustomPainter {
  LedgerView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.desk);
    canvas.drawRect(m.sheet.translate(4, 5), Paint()..color = Palette.night.withValues(alpha: 0.4));
    canvas.drawRect(m.sheet, Paint()..color = Palette.paper);
    // The rules and the margin.
    for (var y = m.firstRow; y < m.sheet.bottom - 4; y += m.rowHeight) {
      canvas.drawLine(Offset(m.sheet.left, y), Offset(m.sheet.right, y), Paint()
        ..color = Palette.rule
        ..strokeWidth = 1);
    }
    canvas.drawLine(Offset(m.sheet.left + m.sheet.width * 0.5, m.sheet.top), Offset(m.sheet.left + m.sheet.width * 0.5, m.sheet.bottom), Paint()
      ..color = Palette.margin
      ..strokeWidth = 1.5);
    final size0 = math.max(11.0, math.min(m.rowHeight * 0.55, 20.0));
    if (!bare) {
      _write(canvas, 'halve', Offset(m.halvesAt, m.sheet.top + m.rowHeight * 0.55), labels.copyWith(color: Palette.faint, fontSize: size0 * 0.8, fontStyle: FontStyle.italic));
      _write(canvas, 'double', Offset(m.doublesAt, m.sheet.top + m.rowHeight * 0.55), labels.copyWith(color: Palette.faint, fontSize: size0 * 0.8, fontStyle: FontStyle.italic));
    }
    for (var i = 0; i < play.rows.length; i++) {
      final (half, dbl) = play.rows[i];
      final kept = play.isKept(i);
      final rect = m.rowRect(i);
      if (kept) canvas.drawRect(rect.deflate(1), Paint()..color = Palette.keptRow);
      final y = m.at(i).dy;
      _write(canvas, '$half', Offset(m.halvesAt, y), labels.copyWith(color: Palette.pen, fontSize: size0, fontWeight: FontWeight.w700));
      _write(canvas, '$dbl', Offset(m.doublesAt, y), labels.copyWith(color: kept ? Palette.pen : Palette.faint, fontSize: size0, fontWeight: kept ? FontWeight.w800 : FontWeight.w400));
      if (kept) {
        // A tick.
        final t = Offset(m.tickAt, y);
        canvas.drawLine(t + Offset(-size0 * 0.35, 0), t + Offset(-size0 * 0.1, size0 * 0.3), Paint()
          ..color = Palette.tick
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
        canvas.drawLine(t + Offset(-size0 * 0.1, size0 * 0.3), t + Offset(size0 * 0.4, -size0 * 0.35), Paint()
          ..color = Palette.tick
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
      } else {
        canvas.drawRect(Rect.fromCenter(center: Offset(m.tickAt, y), width: size0 * 0.7, height: size0 * 0.7), Paint()
          ..color = Palette.faint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
      }
    }
    // The foot: the sum against the product.
    final footY = m.firstRow + (play.rows.length + 0.6) * m.rowHeight;
    canvas.drawLine(Offset(m.sheet.left + m.sheet.width * 0.5, footY - m.rowHeight * 0.45), Offset(m.sheet.right - 6, footY - m.rowHeight * 0.45), Paint()
      ..color = Palette.pen
      ..strokeWidth = 1.5);
    final sum = play.sum;
    if (!bare) {
      _write(canvas, 'kept', Offset(m.halvesAt, footY), labels.copyWith(color: Palette.faint, fontSize: size0 * 0.8, fontStyle: FontStyle.italic));
      _write(canvas, '$sum', Offset(m.doublesAt, footY), labels.copyWith(color: play.isDone ? Palette.tick : sum > play.level.first * play.level.second ? Palette.clash : Palette.pen, fontSize: size0, fontWeight: FontWeight.w800));
      _write(canvas, 'want ${play.level.first * play.level.second}', Offset(m.doublesAt, footY + m.rowHeight * 0.7), labels.copyWith(color: Palette.faint, fontSize: size0 * 0.75));
    } else {
      _write(canvas, '$sum', Offset(m.doublesAt, footY), labels.copyWith(color: Palette.tick, fontSize: size0, fontWeight: FontWeight.w800));
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawRect(m.rowRect(aim.$2).deflate(1.5), Paint()
        ..color = aim.$1 == 'keep' ? Palette.shown : Palette.bad
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(LedgerView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a ledger as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = play.rules;
  final odd = rules.oddRows.map((i) => rules.rows[i].$1).join(', ');
  final doubles = rules.oddRows.map((i) => rules.rows[i].$2).join(' + ');
  final law = 'Halve the first number row by row, dropping the remainder, and double '
      'the second beside it; a half is odd exactly when the two of that row is '
      'in the first number, so the doubles beside the odd halves add to the '
      'product: here the odd halves are $odd, and $doubles is ${rules.product}. '
      'The sweep tries every keeping of the rows, and that one alone lands, since '
      'a number is its twos one way only; on every pair up to sixty by sixty, '
      '3,600 ledgers, the same.';
  if (!level.winnable) {
    return '$law Every keeping of exactly ${level.exactly} rows was swept as well, '
        '${level.keepings} of them, and none lands.$note';
  }
  return '$law ${level.keepings} keepings of the ${rules.rows.length} rows, and '
      '${level.ways} land${level.ways == 1 ? 's' : ''}.$note';
}

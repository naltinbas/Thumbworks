import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../stook/play.dart';
import 'palette.dart';

/// Where the stooks and the pool lie on the board, so the screen and
/// the tests can find them: stooks in rows down the field, the pool
/// lying along the bottom.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.level.sheaves;
    field = Rect.fromLTRB(room.width * 0.04, room.height * 0.02, room.width * 0.96, room.height * 0.78);
    pool = Rect.fromLTRB(room.width * 0.04, room.height * 0.82, room.width * 0.96, room.height * 0.98);
    rowHeight = field.height / n;
    sheafWidth = math.min(rowHeight * 0.85, (field.width - 60) / (n + 1));
  }

  final Play play;

  late final Rect field;
  late final Rect pool;
  late final double rowHeight;
  late final double sheafWidth;

  /// The middle of stook row [i].
  Offset rowAt(int i) => Offset(field.center.dx, field.top + (i + 0.5) * rowHeight);

  /// The middle of sheaf [k] of stook row [i].
  Offset sheafAt(int i, int k) => Offset(field.left + 44 + (k + 0.5) * sheafWidth, field.top + (i + 0.5) * rowHeight);

  Offset get poolAt => pool.center;

  /// What a touch means: a stook row's index, [Play.newStook] for the
  /// pool or an empty row, or null off the board.
  int? under(Offset touch) {
    if (pool.contains(touch)) return Play.newStook;
    if (!field.contains(touch)) return null;
    final row = ((touch.dy - field.top) / rowHeight).floor();
    if (row < play.stooks.length) return row;
    return Play.newStook;
  }
}

/// The field: stooks in rows, each sheaf drawn, each stook counted and
/// judged, and the pool of sheaves still lying flat.
class StookView extends CustomPainter {
  StookView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final level = play.level;

    // The stubble field, in rows.
    canvas.drawRRect(RRect.fromRectAndRadius(m.field, const Radius.circular(10)), Paint()..color = Palette.stubble);
    for (var i = 0; i < level.sheaves; i++) {
      if (i.isOdd) {
        canvas.drawRect(Rect.fromLTWH(m.field.left, m.field.top + i * m.rowHeight, m.field.width, m.rowHeight),
            Paint()..color = Palette.stubbleDim);
      }
    }
    // The stooks.
    final sizes = play.stooks;
    for (var i = 0; i < sizes.length; i++) {
      final size = sizes[i];
      final alike = sizes.where((s) => s == size).length > 1;
      final wrong = level.kind == 'apart' ? alike : size.isEven;
      for (var k = 0; k < size; k++) {
        _sheaf(canvas, m.sheafAt(i, k), m.sheafWidth, m.rowHeight);
      }
      // The count, and the judgement.
      _write(canvas, '$size', Offset(m.field.left + 20, m.rowAt(i).dy),
          labels.copyWith(color: wrong ? Palette.clash : Palette.ear, fontSize: math.max(11, m.rowHeight * 0.4), fontWeight: FontWeight.w800));
      if (wrong) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(m.field.left + 40, m.field.top + i * m.rowHeight + 2, size * m.sheafWidth + 8, m.rowHeight - 4),
              const Radius.circular(6)),
          Paint()
            ..color = Palette.clash.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }
    }
    // The pool.
    canvas.drawRRect(RRect.fromRectAndRadius(m.pool, const Radius.circular(8)), Paint()..color = Palette.pool);
    final poolWidth = math.min(m.pool.height * 1.4, (m.pool.width - 90) / math.max(1, level.sheaves));
    for (var k = 0; k < play.pool; k++) {
      final at = Offset(m.pool.left + 60 + (k + 0.5) * poolWidth, m.pool.center.dy);
      // Lying flat: a short straw bar with a band.
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: at, width: poolWidth * 0.8, height: m.pool.height * 0.28), const Radius.circular(3)),
          Paint()..color = Palette.strawDark);
      canvas.drawRect(Rect.fromCenter(center: at, width: poolWidth * 0.14, height: m.pool.height * 0.34), Paint()..color = Palette.band);
    }
    _write(canvas, play.pool == 0 ? 'none left' : '${play.pool} to stand', Offset(m.pool.left + 30, m.pool.center.dy),
        labels.copyWith(color: Palette.inkDim, fontSize: 11));

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final Rect where = aim.$1 == 'add'
          ? Rect.fromLTWH(m.field.left + 40, m.field.top + aim.$2 * m.rowHeight + 2, m.field.width - 44, m.rowHeight - 4)
          : aim.$1 == 'new'
              ? m.pool.deflate(2)
              : Rect.fromLTWH(m.field.left + 40, m.field.top + (sizes.length - 1) * m.rowHeight + 2, m.field.width - 44, m.rowHeight - 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(where, const Radius.circular(6)),
        Paint()
          ..color = aim.$1 == 'back' ? Palette.bad : Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  void _sheaf(Canvas canvas, Offset at, double w, double h) {
    final half = math.min(h * 0.42, w * 1.2);
    final body = Path()
      ..moveTo(at.dx - w * 0.22, at.dy + half)
      ..lineTo(at.dx + w * 0.22, at.dy + half)
      ..lineTo(at.dx + w * 0.16, at.dy - half * 0.4)
      ..lineTo(at.dx + w * 0.3, at.dy - half)
      ..lineTo(at.dx - w * 0.3, at.dy - half)
      ..lineTo(at.dx - w * 0.16, at.dy - half * 0.4)
      ..close();
    canvas.drawPath(body, Paint()..color = Palette.straw);
    canvas.drawPath(body, Paint()
      ..color = Palette.strawDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    canvas.drawRect(Rect.fromCenter(center: at + Offset(0, half * 0.1), width: w * 0.4, height: half * 0.22), Paint()..color = Palette.band);
    canvas.drawCircle(at + Offset(0, -half * 0.85), w * 0.16, Paint()..color = Palette.ear);
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(StookView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a harvest as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'Stooks of different sizes hold at the least 1, 2, 3 and 4 sheaves '
        'when there are four of them, ten in all; nine sheaves are one short, '
        'and no standing of them makes four stooks all apart. Every partition '
        'of nine was walked to be sure, and k stooks apart need k(k + 1)/2 '
        'sheaves at the least for every k to seven, standing exactly one way '
        'at that count.$note';
  }
  return 'Every partition of the harvest is walked and every one that meets '
      'the ask is counted; the count is read again with no walk, by '
      'multiplying out (1 + x^k) over every k for stooks all apart, or 1 over '
      '(1 - x^k) over odd k for stooks all odd, and the two products come out '
      'the same at every harvest, which is Euler\'s identity. Glaisher\'s turn '
      'shows why: pair off equal stooks into double ones until none match, and '
      'a standing all odd becomes one all apart, and back again. ${level.ways} '
      'of the ${level.partitions} land it.$note';
}

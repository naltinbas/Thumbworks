import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../stack/play.dart';
import '../stack/rules.dart';
import 'palette.dart';

/// Where the books lie on the board, so the screen and the tests can
/// find every one and either half of it.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.level.books;
    edgeX = room.width * 0.44;
    bookWidth = room.width * 0.4;
    bookHeight = math.min(room.height * 0.6 / (n + 0.5), 46);
    deskTop = room.height * 0.76;
  }

  final Play play;

  late final double edgeX;
  late final double bookWidth;
  late final double bookHeight;
  late final double deskTop;

  /// A twenty-fourth of a book, in pixels.
  double get grainWidth => bookWidth / Rules.grain;

  /// Book [i]'s rectangle, top first.
  Rect bookRect(int i) {
    final n = play.level.books;
    final right = edgeX + play.edges[i] * grainWidth;
    final top = deskTop - (n - i) * bookHeight;
    return Rect.fromLTWH(right - bookWidth, top, bookWidth, bookHeight);
  }

  /// A point on the left or right half of book [i], for a nudge.
  Offset half(int i, int by) {
    final r = bookRect(i);
    return Offset(by < 0 ? r.left + r.width * 0.25 : r.left + r.width * 0.75, r.center.dy);
  }

  /// The book and the nudge under a touch: left half nudges left, right
  /// half nudges right; null off the books.
  (int, int)? under(Offset touch) {
    for (var i = 0; i < play.level.books; i++) {
      final r = bookRect(i);
      if (r.contains(touch)) return (i, touch.dx < r.center.dx ? -1 : 1);
    }
    return null;
  }
}

/// The desk, the stack of books over its edge, the balance of every
/// level marked, and a ruler for the overhang.
class StackView extends CustomPainter {
  StackView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.level.books;

    // The floor and the desk.
    canvas.drawRect(Rect.fromLTWH(0, m.deskTop, size.width, size.height - m.deskTop), Paint()..color = Palette.floor);
    canvas.drawRect(Rect.fromLTWH(0, m.deskTop, m.edgeX, size.height * 0.05), Paint()..color = Palette.desk);
    canvas.drawRect(Rect.fromLTWH(0, m.deskTop, m.edgeX, 3), Paint()..color = Palette.deskEdge);
    canvas.drawRect(Rect.fromLTWH(m.edgeX * 0.15, m.deskTop + size.height * 0.05, m.edgeX * 0.08, size.height * 0.16),
        Paint()..color = Palette.deskEdge);
    // The desk's edge, dashed up through the stack.
    _dashed(canvas, Offset(m.edgeX, m.deskTop - (n + 0.6) * m.bookHeight), Offset(m.edgeX, m.deskTop),
        Paint()
          ..color = Palette.ruler.withValues(alpha: 0.6)
          ..strokeWidth = 1.5);

    // The ruler above the stack.
    final rulerY = m.deskTop - (n + 0.9) * m.bookHeight;
    canvas.drawLine(Offset(m.edgeX, rulerY), Offset(m.edgeX + m.bookWidth * 1.2, rulerY),
        Paint()
          ..color = Palette.ruler
          ..strokeWidth = 1.5);
    for (final (frac, name) in [(0.25, '¼'), (0.5, '½'), (0.75, '¾'), (1.0, '1'), (1.125, '1⅛')]) {
      final x = m.edgeX + m.bookWidth * frac;
      canvas.drawLine(Offset(x, rulerY - 5), Offset(x, rulerY + 5), Paint()
        ..color = Palette.ruler
        ..strokeWidth = 1.5);
      _write(canvas, name, Offset(x, rulerY - 13), labels.copyWith(color: Palette.ruler, fontSize: 10));
    }
    // The asked mark, and the overhang reached.
    final askedX = m.edgeX + play.level.asked * m.grainWidth;
    canvas.drawLine(Offset(askedX, rulerY - 8), Offset(askedX, m.deskTop), Paint()
      ..color = Palette.shown.withValues(alpha: 0.5)
      ..strokeWidth = 1.5);
    final reachX = m.edgeX + play.overhang * m.grainWidth;
    final tri = Path()
      ..moveTo(reachX, rulerY + 4)
      ..lineTo(reachX - 5, rulerY + 12)
      ..lineTo(reachX + 5, rulerY + 12)
      ..close();
    canvas.drawPath(tri, Paint()..color = play.stands ? Palette.stands : Palette.topples);

    // The books, bottom first so the top book paints last.
    for (var i = n - 1; i >= 0; i--) {
      final r = m.bookRect(i);
      canvas.drawRRect(RRect.fromRectAndRadius(r.deflate(1), const Radius.circular(3)),
          Paint()..color = Palette.cloth[i % Palette.cloth.length]);
      // The pages along the right end, and a spine band on the left.
      canvas.drawRect(Rect.fromLTWH(r.right - r.width * 0.06, r.top + 3, r.width * 0.05, r.height - 6),
          Paint()..color = Palette.pages);
      canvas.drawRect(Rect.fromLTWH(r.left + r.width * 0.05, r.top + 3, r.width * 0.02, r.height - 6),
          Paint()..color = Palette.spine.withValues(alpha: 0.7));
      _write(canvas, '${i + 1}', Offset(r.left + r.width * 0.16, r.center.dy),
          labels.copyWith(color: Palette.pages, fontSize: math.max(10, r.height * 0.4), fontWeight: FontWeight.w800));
    }

    // The balance at every level: the weight of the books above,
    // marked on the edge they rest on.
    final e = play.edges;
    var centres = 0;
    final toppleAt = play.topples;
    for (var k = 1; k <= n; k++) {
      centres += e[k - 1] - Rules.grain ~/ 2;
      final x = m.edgeX + (centres / k) * m.grainWidth;
      final y = k < n ? m.bookRect(k).top : m.deskTop;
      final bad = toppleAt != null && k >= toppleAt;
      final marker = Path()
        ..moveTo(x, y - 1)
        ..lineTo(x - 5, y - 9)
        ..lineTo(x + 5, y - 9)
        ..close();
      canvas.drawPath(marker, Paint()..color = bad ? Palette.topples : Palette.stands);
    }

    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final r = m.bookRect(aim.$2);
      final side = aim.$1 == 'right'
          ? Rect.fromLTWH(r.center.dx, r.top, r.width / 2, r.height)
          : Rect.fromLTWH(r.left, r.top, r.width / 2, r.height);
      canvas.drawRRect(RRect.fromRectAndRadius(side.deflate(2), const Radius.circular(4)), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5);
    }
  }

  void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    final length = (b - a).distance;
    final dir = (b - a) / length;
    var t = 0.0;
    while (t < length) {
      canvas.drawLine(a + dir * t, a + dir * math.min(t + 6, length), paint);
      t += 12;
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(StackView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a stack as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'The top book can hang half over the one below, since its middle '
        'must stay over that book. The top two together weigh from a point a '
        'quarter behind the second book\'s edge, so the second can hang a '
        'quarter over the third; the top three weigh from a sixth behind, and so '
        'on: half, a quarter, a sixth, the harmonic numbers halved. Three books '
        'reach 1/2 + 1/4 + 1/6, eleven twelfths, and no further with each '
        'resting on the one below; the sweep of every stack on the '
        'twenty-fourths finds 22 at the most, and a whole book is 24.$note';
  }
  return 'Every stack on the twenty-fourths is swept, each book nought to a '
      'whole book past the one below, and read for standing level by level, the '
      'weight of the books above against the edge they rest on; ${level.ways} of '
      'the ${level.stacks} stand with the reach asked. The harmonic stack, half '
      'then a quarter then a sixth and on, is worked out with no sweep and reaches '
      'the sweep\'s best on the grid every time.$note';
}

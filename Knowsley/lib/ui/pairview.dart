import 'dart:math';

import 'package:flutter/material.dart';

import '../pair/play.dart';
import '../pair/rules.dart';
import 'palette.dart';

/// Where the two cards and the four things said sit in a board of a
/// given size.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    if (bare) {
      final room = min(size.width, size.height);
      final left = (size.width - room) / 2, top = (size.height - room) / 2;
      cardS = Rect.fromLTWH(left + room * 0.04, top + room * 0.1, room * 0.44, room * 0.46);
      cardP = Rect.fromLTWH(left + room * 0.52, top + room * 0.1, room * 0.44, room * 0.46);
      rowsTop = top + room * 0.62;
      rowHeight = room * 0.3;
      return;
    }
    final strip = roomy ? 26.0 : 0.0;
    final cardHeight = min(58.0, size.height * 0.2);
    final cardWidth = (size.width - 36) / 2;
    cardS = Rect.fromLTWH(12, 6, cardWidth, cardHeight);
    cardP = Rect.fromLTWH(24 + cardWidth, 6, cardWidth, cardHeight);
    rowsTop = cardHeight + 18;
    rowHeight = min(64.0, (size.height - strip - rowsTop - 4) / 4);
  }

  final Play play;
  final Size size;
  late final Rect cardS, cardP;
  late final double rowsTop, rowHeight;

  /// The row of the [i]th thing said, 0 to 3.
  Rect row(int i) => Rect.fromLTWH(10, rowsTop + i * rowHeight, size.width - 20, rowHeight);

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 200 && size.width >= 260;
}

/// S's card, P's card, and the four things said with a tick, a cross
/// or nothing yet beside each, and why.
class PairView extends CustomPainter {
  const PairView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: ('x' or 'y', by).
  final (String, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the cards and the pair only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    _card(canvas, m.cardS, 'S is told', '${play.sum}', size);
    _card(canvas, m.cardP, 'P is told', '${play.product}', size);
    if (bare) {
      _word(canvas, '${play.x} and ${play.y}', Offset(size.width / 2, m.rowsTop + m.rowHeight / 2), Palette.gold, size, m.rowHeight * 0.55, bold: true);
      return;
    }
    final (one, two, three, four) = play.said;
    final splits = play.splitsOfProduct;
    final sums = Rules.speakingSums;
    String times(List<(int, int)> q) => q.take(3).map((s) => '${s.$1} × ${s.$2}').join(' or ') + (q.length > 3 ? ' and more' : '');
    final reasons = <String>[
      one ? '${play.product} is ${times(splits)}' : '${play.product} is ${times(splits)} alone',
      two
          ? 'every split of ${play.sum} leaves P in the dark'
          : play.tellingSplit == null
              ? ''
              : '${play.sum} is ${play.tellingSplit!.$1} + ${play.tellingSplit!.$2}, and ${play.tellingSplit!.$1 * play.tellingSplit!.$2} tells P',
      !two
          ? ''
          : (() {
              final kept = splits.where((q) => sums.contains(q.$1 + q.$2)).toList();
              return kept.length == 1 ? 'of the splits of ${play.product}, ${kept.single.$1} and ${kept.single.$2} alone add to a sum of S\'s' : '${kept.length} splits of ${play.product} add to a sum of S\'s';
            })(),
      !three
          ? ''
          : (() {
              final kept = play.splitsOfSum.where((q) => Rules.pInDark(q.$1 * q.$2) && Rules.pNowKnows(q.$1 * q.$2)).toList();
              return kept.length == 1 ? '${play.sum} keeps ${kept.single.$1} and ${kept.single.$2} alone' : '${play.sum} keeps ${kept.length} splits P could know from';
            })(),
    ];
    final said = ['P: I do not know the numbers.', 'S: I knew you did not.', 'P: Now I know them.', 'S: Now I know them too.'];
    final holds = [one, two, three, four];
    final reached = [true, one, two, three];
    for (var i = 0; i < 4; i++) {
      final r = m.row(i);
      final at = Offset(r.left + 10, r.top + r.height * 0.32);
      if (!reached[i]) {
        canvas.drawCircle(at, 6, Paint()..color = Palette.line..style = PaintingStyle.stroke..strokeWidth = 1.5);
      } else if (holds[i]) {
        _tick(canvas, at, 7, Palette.good);
      } else {
        _cross(canvas, at, 6, Palette.bad);
      }
      _wordLeft(canvas, said[i], Offset(r.left + 24, at.dy), reached[i] ? Palette.ink : Palette.inkDim, size, 13, bold: reached[i]);
      if (reasons[i].isNotEmpty && r.height >= 34) {
        _wordLeft(canvas, reasons[i], Offset(r.left + 24, r.top + r.height * 0.72), holds[i] ? Palette.inkDim : Palette.bad, size, 11);
      }
    }
    if (!m.roomy) return;
    _word(canvas, 'S\'s sums: ${sums.join(' ')}', Offset(size.width / 2, size.height - 11), sums.contains(play.sum) ? Palette.gold : Palette.inkDim, size, 11);
  }

  void _card(Canvas canvas, Rect r, String head, String number, Size size) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(r.height * 0.15));
    canvas.drawRRect(rr, Paint()..color = Palette.card);
    canvas.drawRRect(rr, Paint()..color = Palette.cardRim..style = PaintingStyle.stroke..strokeWidth = max(1, r.height * 0.03));
    if (bare) {
      _word(canvas, head[0], Offset(r.left + r.width * 0.16, r.top + r.height * 0.2), Palette.inkDim, size, r.height * 0.22, bold: true);
      _word(canvas, number, r.center + Offset(0, r.height * 0.1), Palette.chalk, size, r.height * 0.5, bold: true);
      return;
    }
    _word(canvas, head, Offset(r.center.dx, r.top + r.height * 0.26), Palette.inkDim, size, 11);
    _word(canvas, number, Offset(r.center.dx, r.top + r.height * 0.66), Palette.chalk, size, r.height * 0.42, bold: true);
  }

  void _tick(Canvas canvas, Offset at, double r, Color colour) {
    final path = Path()
      ..moveTo(at.dx - r, at.dy)
      ..lineTo(at.dx - r * 0.3, at.dy + r * 0.7)
      ..lineTo(at.dx + r, at.dy - r * 0.7);
    canvas.drawPath(path, Paint()..color = colour..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }

  void _cross(Canvas canvas, Offset at, double r, Color colour) {
    final paint = Paint()..color = colour..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawLine(at + Offset(-r, -r), at + Offset(r, r), paint);
    canvas.drawLine(at + Offset(-r, r), at + Offset(r, -r), paint);
  }

  void _wordLeft(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool bold = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize), fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: max(10, size.width - at.dx - 4));
    text.paint(canvas, Offset(at.dx, at.dy - text.height / 2));
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool bold = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize), fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(PairView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

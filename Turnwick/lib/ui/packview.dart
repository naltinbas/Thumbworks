import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../pack/play.dart';
import '../pack/rules.dart';
import 'palette.dart';

/// Where the cards lie on the board, so the screen and the tests can
/// find every one: in a row across the baize, the top of the pack at
/// the left, the pattern asked in outline above them.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.pack.length;
    cardWidth = math.min(room.width * 0.86 / n, room.height * 0.28 / 1.4);
    cardHeight = cardWidth * 1.4;
    rowAt = room.height * 0.58;
    askAt = room.height * 0.2;
    left = (room.width - cardWidth * n - (n - 1) * cardWidth * 0.12) / 2;
    width = room.width;
  }

  final Play play;

  late final double cardWidth;
  late final double cardHeight;
  late final double rowAt;
  late final double askAt;
  late final double left;
  late final double width;

  /// The rectangle of the card at place [i].
  Rect cardRect(int i) => Rect.fromCenter(center: Offset(left + i * cardWidth * 1.12 + cardWidth / 2, rowAt), width: cardWidth, height: cardHeight);

  /// The middle of the card at place [i].
  Offset at(int i) => cardRect(i).center;
}

/// The baize: the pack in a row, the top card at the left, faces up
/// in cream with their letters and faces down in patterned blue, the
/// pattern asked in outline above.
class PackView extends CustomPainter {
  PackView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The move the show-me points at: true for a turn, false for a cut.
  final bool? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  static const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.baize);
    for (var y = 0.0; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()
        ..color = Palette.baizeDark.withValues(alpha: 0.5)
        ..strokeWidth = 1);
    }
    // The pattern asked, in outline.
    final n = play.pack.length;
    for (var i = 0; i < n; i++) {
      final rect = m.cardRect(i);
      final small = Rect.fromCenter(center: Offset(rect.center.dx, m.askAt), width: m.cardWidth * 0.5, height: m.cardHeight * 0.5);
      final up = play.level.pattern[i];
      canvas.drawRRect(RRect.fromRectAndRadius(small, Radius.circular(m.cardWidth * 0.06)), Paint()..color = up ? Palette.face.withValues(alpha: 0.9) : Palette.back.withValues(alpha: 0.6));
      canvas.drawRRect(RRect.fromRectAndRadius(small, Radius.circular(m.cardWidth * 0.06)), Paint()
        ..color = play.isDone ? Palette.good : Palette.chalk.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = play.isDone ? 2.5 : 1.2);
      if (!bare) _write(canvas, up ? 'up' : 'down', Offset(small.center.dx, small.bottom + 10), labels.copyWith(color: Palette.chalk.withValues(alpha: 0.8), fontSize: 10));
    }
    if (!bare) _write(canvas, play.isDone ? 'as asked' : 'asked', Offset(size.width / 2, m.askAt - m.cardHeight * 0.4), labels.copyWith(color: Palette.chalk.withValues(alpha: 0.8), fontSize: 11, fontStyle: FontStyle.italic));
    // The cards.
    for (var i = 0; i < n; i++) {
      final rect = m.cardRect(i);
      final (card, up) = play.pack[i];
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(m.cardWidth * 0.1));
      canvas.drawRRect(rr.shift(const Offset(2, 3)), Paint()..color = Palette.night.withValues(alpha: 0.4));
      canvas.drawRRect(rr, Paint()..color = up ? Palette.face : Palette.back);
      canvas.drawRRect(rr, Paint()
        ..color = Palette.edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      if (up) {
        _write(canvas, letters[card], rect.center, labels.copyWith(color: Palette.pen, fontSize: m.cardWidth * 0.55, fontWeight: FontWeight.w800));
        _write(canvas, letters[card], rect.topLeft + Offset(m.cardWidth * 0.16, m.cardHeight * 0.12), labels.copyWith(color: Palette.pen, fontSize: m.cardWidth * 0.2, fontWeight: FontWeight.w700));
      } else {
        // The back: a lattice.
        canvas.save();
        canvas.clipRRect(rr.deflate(m.cardWidth * 0.1));
        for (var d = -rect.height; d < rect.width + rect.height; d += m.cardWidth * 0.18) {
          canvas.drawLine(Offset(rect.left + d, rect.top), Offset(rect.left + d - rect.height, rect.bottom), Paint()
            ..color = Palette.backLine
            ..strokeWidth = 1);
          canvas.drawLine(Offset(rect.left + d, rect.top), Offset(rect.left + d + rect.height, rect.bottom), Paint()
            ..color = Palette.backLine
            ..strokeWidth = 1);
        }
        canvas.restore();
      }
      if (!bare) {
        _write(canvas, i == 0 ? 'top' : '${i + 1}', Offset(rect.center.dx, rect.bottom + 12), labels.copyWith(color: Palette.chalk.withValues(alpha: 0.8), fontSize: 11));
        _write(canvas, i.isEven ? 'even' : 'odd', Offset(rect.center.dx, rect.bottom + 25), labels.copyWith(color: Palette.chalk.withValues(alpha: 0.5), fontSize: 9));
      }
    }
    // The pointer: the top two ringed for a turn, an arrow round for a cut.
    final aim = pointing;
    if (aim != null) {
      if (aim) {
        final box = m.cardRect(0).expandToInclude(m.cardRect(1)).inflate(5);
        canvas.drawRRect(RRect.fromRectAndRadius(box, Radius.circular(m.cardWidth * 0.12)), Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      } else {
        final from = m.cardRect(0), to = m.cardRect(n - 1);
        final y = from.bottom + m.cardHeight * 0.34;
        canvas.drawLine(Offset(from.center.dx, y), Offset(to.center.dx, y), Paint()
          ..color = Palette.shown
          ..strokeWidth = 3);
        canvas.drawLine(Offset(from.center.dx, from.bottom + 4), Offset(from.center.dx, y), Paint()
          ..color = Palette.shown
          ..strokeWidth = 3);
        canvas.drawLine(Offset(to.center.dx, y), Offset(to.center.dx, to.bottom + 4), Paint()
          ..color = Palette.shown
          ..strokeWidth = 3);
      }
    }
    if (!bare) {
      _write(canvas, 'up at even places ${play.upAtEven}, at odd ${play.upAtOdd}', Offset(size.width / 2, size.height * 0.92),
          labels.copyWith(color: play.upAtEven == play.upAtOdd ? Palette.chalk : Palette.clash, fontSize: 12));
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(PackView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a pattern as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final rules = level.rules;
  final law = 'The top two cards lie at an even place and an odd one, and turned over '
      'as one they swap places, so the count of cards face up at even places and '
      'the count at odd places move together; a cut sends every card to a place of '
      'the other kind and swaps the two counts. They start nought and nought and '
      'stay equal for ever, which is Hummer\'s principle. Every pack of four, six '
      'and eight cards is walked from all face down, ${_commas(rules.walk().length)} '
      'packs of ${level.cards}, and the count holds on every one; the patterns of '
      'faces reached are exactly those that keep it.';
  final evens = Rules.upAtEven(level.pattern), odds = Rules.upAtOdd(level.pattern);
  if (!level.winnable) {
    return '$law The pattern asked has $evens up at even places and $odds at odd, so it '
        'never comes, and every sequence of ${level.moves} moves was swept as well, '
        '${level.sequences} of them.$note';
  }
  return '$law The pattern asked has $evens up at even places and $odds at odd, and the '
      'walk reaches it in ${level.moves} move${level.moves == 1 ? '' : 's'} at the fewest, '
      '${level.ways} of the ${level.sequences} sequences of that many.$note';
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

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../deck/play.dart';
import '../deck/rules.dart';
import 'palette.dart';

/// Where the cards lie on the table, so the screen and the tests can
/// find every one: the row of four for the partner across the top, the
/// hidden card's place at the left of it, the hand along the bottom.
class Metrics {
  Metrics(this.play, Size room) {
    cardWidth = math.min(room.width * 0.16, room.height * 0.16);
    cardHeight = cardWidth * 1.4;
    rowY = room.height * 0.3;
    handY = room.height * 0.76;
    final rowSpan = room.width * 0.78;
    rowLeft = room.width * 0.11 + cardWidth / 2;
    rowGap = (rowSpan - cardWidth) / 3;
    hiddenAt = Offset(room.width * 0.5, room.height * 0.6);
    handLeft = room.width * 0.05 + cardWidth / 2;
    handGap = (room.width * 0.9 - cardWidth) / 4;
  }

  final Play play;

  late final double cardWidth;
  late final double cardHeight;
  late final double rowY;
  late final double handY;
  late final double rowLeft;
  late final double rowGap;
  late final Offset hiddenAt;
  late final double handLeft;
  late final double handGap;

  /// Slot [i] of the partner's row.
  Offset rowAt(int i) => Offset(rowLeft + i * rowGap, rowY);

  /// Where card [k] of the hand rests on the table.
  Offset handAt(int k) => Offset(handLeft + k * handGap, handY);

  /// Where a card is drawn as things stand.
  Offset at(Playcard c) {
    if (c == play.hidden) return hiddenAt;
    final i = play.row.indexOf(c);
    if (i >= 0) return rowAt(i);
    return handAt(play.level.hand.indexOf(c));
  }

  /// The card under a touch, or null.
  Playcard? under(Offset touch) {
    for (final c in play.level.hand) {
      final r = Rect.fromCenter(center: at(c), width: cardWidth, height: cardHeight);
      if (r.contains(touch)) return c;
    }
    return null;
  }
}

/// The table: the row for the partner with its four slots, the hidden
/// card face down, the hand along the bottom, and the partner's word.
class DeckView extends CustomPainter {
  DeckView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, Playcard)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.baize);
    // The row's slots and the hidden card's place.
    for (var i = 0; i < 4; i++) {
      _slot(canvas, m.rowAt(i), m, i == 0 ? 'suit' : '$i');
    }
    _write(canvas, 'laid for the partner', Offset(size.width / 2, m.rowY - m.cardHeight * 0.75),
        labels.copyWith(color: Palette.inkDim, fontSize: 11));
    _slot(canvas, m.hiddenAt, m, 'hidden');
    _write(canvas, 'the hand', Offset(size.width / 2, m.handY - m.cardHeight * 0.75),
        labels.copyWith(color: Palette.inkDim, fontSize: 11));

    // The cards, hand first, then row, hidden last.
    for (final c in play.level.hand) {
      if (c == play.hidden || play.row.contains(c)) continue;
      _card(canvas, m, c, faceUp: true);
    }
    for (final c in play.row) {
      _card(canvas, m, c, faceUp: true);
    }
    if (play.hidden != null) {
      _card(canvas, m, play.hidden!, faceUp: false);
    }
    // The partner's word.
    final named = play.named;
    if (named != null) {
      final ok = named == play.hidden;
      _write(canvas, 'the partner names ${Rules.name(named)}', Offset(size.width / 2, m.rowY + m.cardHeight * 0.68),
          labels.copyWith(color: ok ? Palette.right : Palette.wrong, fontSize: 13, fontWeight: FontWeight.w800));
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      final at = aim.$1 == 'lay' && !play.row.contains(aim.$2) ? m.at(aim.$2) : m.at(aim.$2);
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: at, width: m.cardWidth + 10, height: m.cardHeight + 10), const Radius.circular(8)),
          Paint()
            ..color = aim.$1 == 'unlay' || aim.$1 == 'unhide' ? Palette.bad : Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
    }
  }

  void _slot(Canvas canvas, Offset at, Metrics m, String label) {
    final r = Rect.fromCenter(center: at, width: m.cardWidth, height: m.cardHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), Paint()..color = Palette.baizeDark);
    canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)), Paint()
      ..color = Palette.slot
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    _write(canvas, label, at, labels.copyWith(color: Palette.slot, fontSize: 10));
  }

  void _card(Canvas canvas, Metrics m, Playcard c, {required bool faceUp}) {
    final at = m.at(c);
    final r = Rect.fromCenter(center: at, width: m.cardWidth, height: m.cardHeight);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(6));
    if (!faceUp) {
      canvas.drawRRect(rr, Paint()..color = Palette.back);
      canvas.drawRRect(rr.deflate(4), Paint()
        ..color = Palette.backLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      for (var y = r.top + 10; y < r.bottom - 6; y += 8) {
        canvas.drawLine(Offset(r.left + 8, y), Offset(r.right - 8, y), Paint()
          ..color = Palette.backLine.withValues(alpha: 0.35)
          ..strokeWidth = 1);
      }
      return;
    }
    canvas.drawRRect(rr, Paint()..color = Palette.card);
    canvas.drawRRect(rr, Paint()
      ..color = Palette.cardEdge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    final suit = Rules.suitOf(c);
    final colour = suit == 1 || suit == 2 ? Palette.red : Palette.black;
    _write(canvas, Rules.rankNames[Rules.rankOf(c) - 1], Offset(r.left + m.cardWidth * 0.24, r.top + m.cardHeight * 0.16),
        labels.copyWith(color: colour, fontSize: m.cardWidth * 0.3, fontWeight: FontWeight.w800));
    _pip(canvas, suit, at + Offset(0, m.cardHeight * 0.1), m.cardWidth * 0.34, colour);
    _pip(canvas, suit, Offset(r.left + m.cardWidth * 0.24, r.top + m.cardHeight * 0.34), m.cardWidth * 0.14, colour);
  }

  void _pip(Canvas canvas, int suit, Offset at, double s, Color colour) {
    final paint = Paint()..color = colour;
    switch (suit) {
      case 0: // clubs
        canvas.drawCircle(at + Offset(0, -s * 0.28), s * 0.28, paint);
        canvas.drawCircle(at + Offset(-s * 0.28, s * 0.08), s * 0.28, paint);
        canvas.drawCircle(at + Offset(s * 0.28, s * 0.08), s * 0.28, paint);
        canvas.drawRect(Rect.fromCenter(center: at + Offset(0, s * 0.35), width: s * 0.16, height: s * 0.5), paint);
      case 1: // diamonds
        canvas.drawPath(
            Path()
              ..moveTo(at.dx, at.dy - s * 0.55)
              ..lineTo(at.dx + s * 0.4, at.dy)
              ..lineTo(at.dx, at.dy + s * 0.55)
              ..lineTo(at.dx - s * 0.4, at.dy)
              ..close(),
            paint);
      case 2: // hearts
        canvas.drawCircle(at + Offset(-s * 0.24, -s * 0.15), s * 0.28, paint);
        canvas.drawCircle(at + Offset(s * 0.24, -s * 0.15), s * 0.28, paint);
        canvas.drawPath(
            Path()
              ..moveTo(at.dx - s * 0.5, at.dy - s * 0.05)
              ..lineTo(at.dx, at.dy + s * 0.55)
              ..lineTo(at.dx + s * 0.5, at.dy - s * 0.05)
              ..close(),
            paint);
      default: // spades
        canvas.drawPath(
            Path()
              ..moveTo(at.dx, at.dy - s * 0.55)
              ..lineTo(at.dx + s * 0.5, at.dy + s * 0.05)
              ..lineTo(at.dx - s * 0.5, at.dy + s * 0.05)
              ..close(),
            paint);
        canvas.drawCircle(at + Offset(-s * 0.24, at.dy * 0 + s * 0.12), s * 0.26, paint);
        canvas.drawCircle(at + Offset(s * 0.24, s * 0.12), s * 0.26, paint);
        canvas.drawRect(Rect.fromCenter(center: at + Offset(0, s * 0.4), width: s * 0.16, height: s * 0.45), paint);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(DeckView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a hand as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'The partner reads the row this way: the first card names the suit, '
        'and the other three, laid low, middle and high in one of six orders, '
        'tell how many steps round the ranks from the first card to the hidden '
        'one, one to six. So the first card must share the hidden card\'s suit, '
        'and here nothing does: every one of the ${level.layouts} orders names '
        'a card of another suit.$note';
  }
  return 'The assistant\'s rule: two of five cards share a suit, and of any two '
      'ranks one is within six steps round of the other; hide that one, show its '
      'mate first, and lay the other three in the order that tells the steps. '
      'Every layout of the hand is swept, ${level.layouts} of them, and the '
      'partner is read on each; ${level.ways} land it. On every one of the '
      '2,598,960 hands of the whole deck the rule finds a layout the partner '
      'reads right.$note';
}

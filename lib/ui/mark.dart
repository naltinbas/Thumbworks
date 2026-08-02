import 'dart:math';

import 'package:flutter/material.dart' hide Card;

import '../game/cards.dart';
import 'palette.dart';

/// The mark: three cards fanned, the ace of spades in front.
///
/// A card game's logo has to be a card, and one card is a rectangle. Three
/// fanned is the smallest picture that says cards rather than paper, and it is
/// still legible at forty eight points, which is the size that decides these
/// things.
class Mark extends StatelessWidget {
  const Mark({super.key, this.onFelt = true});

  /// Whether to draw the table under it. Off for the Android adaptive icon,
  /// where the background is a layer of its own.
  final bool onFelt;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => CustomPaint(
          size: Size(box.maxWidth, box.maxHeight),
          painter: _MarkPainter(
            onFelt: onFelt,
            text: Theme.of(context).textTheme.bodyMedium!,
          ),
        ),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.onFelt, required this.text});

  final bool onFelt;
  final TextStyle text;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final middle = Offset(size.width / 2, size.height / 2);

    if (onFelt) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: middle, width: side, height: side),
          Radius.circular(side * 0.14),
        ),
        Paint()..color = Palette.feltDark,
      );
    }

    final width = side * 0.42;
    final height = width * 1.42;

    // Back to front, so the ace ends up on top.
    const fan = [
      (turn: -0.30, shift: -0.30, card: 'KH'),
      (turn: -0.02, shift: 0.02, card: 'QC'),
      (turn: 0.26, shift: 0.34, card: 'AS'),
    ];

    for (final one in fan) {
      canvas.save();
      canvas.translate(
        middle.dx + width * one.shift,
        middle.dy + side * 0.04,
      );
      canvas.rotate(one.turn);
      _card(canvas, Card.from(one.card), width, height);
      canvas.restore();
    }
  }

  void _card(Canvas canvas, Card card, double width, double height) {
    final box = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    final rounded = RRect.fromRectAndRadius(
      box,
      Radius.circular(width * 0.12),
    );

    canvas.drawRRect(
      rounded.shift(Offset(0, width * 0.03)),
      Paint()..color = Palette.shadow,
    );
    canvas.drawRRect(rounded, Paint()..color = Palette.card);
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = Palette.cardEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1, width * 0.02),
    );

    final ink = card.red ? Palette.red : Palette.black;
    final letter = TextPainter(
      text: TextSpan(
        text: Card.ranks[card.rank - 1],
        style: text.copyWith(
          color: ink,
          fontSize: width * 0.42,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    letter.paint(
      canvas,
      Offset(box.left + width * 0.13, box.top + height * 0.08),
    );

    _pip(canvas, card.suit, Offset(0, height * 0.12), width * 0.24, ink);
  }

  /// The four suits, drawn rather than written. Whether a font has the glyphs
  /// is not something to find out on somebody's phone.
  void _pip(Canvas canvas, Suit suit, Offset middle, double size, Color ink) {
    final paint = Paint()..color = ink;
    switch (suit) {
      case Suit.diamonds:
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx, middle.dy - size * 1.25)
            ..lineTo(middle.dx + size, middle.dy)
            ..lineTo(middle.dx, middle.dy + size * 1.25)
            ..lineTo(middle.dx - size, middle.dy)
            ..close(),
          paint,
        );
      case Suit.hearts:
        final top = middle.dy - size * 0.75;
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx, middle.dy + size * 1.15)
            ..cubicTo(middle.dx - size * 2.1, top - size * 0.35,
                middle.dx - size * 0.45, top - size * 1.1, middle.dx,
                top + size * 0.3)
            ..cubicTo(middle.dx + size * 0.45, top - size * 1.1,
                middle.dx + size * 2.1, top - size * 0.35, middle.dx,
                middle.dy + size * 1.15)
            ..close(),
          paint,
        );
      case Suit.spades:
        final tip = middle.dy - size * 1.25;
        canvas
          ..drawPath(
            Path()
              ..moveTo(middle.dx, tip)
              ..cubicTo(middle.dx + size * 0.45, tip + size * 1.1,
                  middle.dx + size * 2.1, tip + size * 1.5, middle.dx,
                  middle.dy + size * 0.65)
              ..cubicTo(middle.dx - size * 2.1, tip + size * 1.5,
                  middle.dx - size * 0.45, tip + size * 1.1, middle.dx, tip)
              ..close(),
            paint,
          )
          ..drawPath(
            Path()
              ..moveTo(middle.dx - size * 0.42, middle.dy + size * 1.3)
              ..quadraticBezierTo(middle.dx, middle.dy + size * 0.6,
                  middle.dx + size * 0.42, middle.dy + size * 1.3)
              ..close(),
            paint,
          );
      case Suit.clubs:
        final leaf = size * 0.62;
        canvas
          ..drawCircle(Offset(middle.dx, middle.dy - size * 0.6), leaf, paint)
          ..drawCircle(
              Offset(middle.dx - size * 0.68, middle.dy + size * 0.34),
              leaf,
              paint)
          ..drawCircle(
              Offset(middle.dx + size * 0.68, middle.dy + size * 0.34),
              leaf,
              paint)
          ..drawPath(
            Path()
              ..moveTo(middle.dx - size * 0.42, middle.dy + size * 1.35)
              ..quadraticBezierTo(middle.dx, middle.dy + size * 0.5,
                  middle.dx + size * 0.42, middle.dy + size * 1.35)
              ..close(),
            paint,
          );
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.onFelt != onFelt;
}

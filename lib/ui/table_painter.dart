import 'dart:math';

import 'package:flutter/rendering.dart';

import '../game/cards.dart';
import '../game/table.dart';
import 'palette.dart';

/// Something a finger can land on.
class Spot {
  const Spot({required this.where, required this.at, this.card});

  final Where where;

  /// Which cell, home or column.
  final int at;

  /// Which card down the column, counting from the top of the pile. Null for
  /// a cell, a home, or an empty column.
  final int? card;

  @override
  bool operator ==(Object other) =>
      other is Spot &&
      other.where == where &&
      other.at == at &&
      other.card == card;

  @override
  int get hashCode => Object.hash(where, at, card);
}

/// Where everything is on the screen.
///
/// One object works it out and the painter, the finger and the tests all ask
/// it. On a board of fifty two overlapping cards, working it out twice is how
/// a tap picks up the card above the one under the thumb.
class Metrics {
  factory Metrics(Size space, {int longest = 7}) {
    // Eight columns across, with a gap either side and between. Everything
    // else is measured from the card that gives.
    const gap = 4.0;
    final width = (space.width - gap * (Table.columnCount + 1)) /
        Table.columnCount;
    final height = width * 1.42;

    // How far down each card sits from the one before, worked out from the
    // longest column there is so that it just fits — one step for the whole
    // table, because columns fanned at different rates read as a mistake.
    //
    // A fixed step of a third of a card was the first version and it left the
    // bottom half of the screen empty at the start of a deal, when the
    // longest column is seven. Spreading to fit shows most of every card
    // early on and closes up later, which is what a hand of cards does on a
    // real table.
    final top = gap + height + gap * 3;
    final room = space.height - top - height;
    final step = (room / (longest < 2 ? 1 : longest - 1))
        .clamp(height * 0.24, height * 0.78);

    return Metrics._(
      cardWidth: width,
      cardHeight: height,
      gap: gap,
      step: step,
      space: space,
    );
  }

  const Metrics._({
    required this.cardWidth,
    required this.cardHeight,
    required this.gap,
    required this.step,
    required this.space,
  });

  final double cardWidth;
  final double cardHeight;
  final double gap;
  final double step;
  final Size space;

  /// The top strip: four cells on the left, four homes on the right.
  double get topRow => gap;

  double get columnsTop => topRow + cardHeight + gap * 3;

  Rect cellAt(int at) => Rect.fromLTWH(
        gap + at * (cardWidth + gap),
        topRow,
        cardWidth,
        cardHeight,
      );

  Rect homeAt(int at) => Rect.fromLTWH(
        gap + (at + 4) * (cardWidth + gap),
        topRow,
        cardWidth,
        cardHeight,
      );

  Rect columnAt(int at, int card) => Rect.fromLTWH(
        gap + at * (cardWidth + gap),
        columnsTop + card * step,
        cardWidth,
        cardHeight,
      );

  /// How much room a column has before it runs off the bottom.
  double get columnRoom => space.height - columnsTop - cardHeight;

  /// The step a column of [length] cards uses.
  ///
  /// The same for every column, unless one has grown past what the table was
  /// laid out for, in which case that one closes up rather than running off
  /// the bottom.
  double stepFor(int length) {
    if (length < 2) return step;
    final needed = step * (length - 1);
    if (needed <= columnRoom) return step;
    return columnRoom / (length - 1);
  }

  /// What is under a point, or null if it is nothing.
  ///
  /// Columns are asked from the bottom card up, because the bottom card is the
  /// one drawn on top and so the one the finger is actually touching.
  Spot? under(Offset point, Table table) {
    for (var at = 0; at < Table.cellCount; at++) {
      if (cellAt(at).contains(point)) {
        return Spot(where: Where.cell, at: at);
      }
      if (homeAt(at).contains(point)) {
        return Spot(where: Where.home, at: at);
      }
    }

    for (var at = 0; at < Table.columnCount; at++) {
      final column = table.column(at);
      final down = stepFor(column.length);
      for (var card = column.length - 1; card >= 0; card--) {
        final box = Rect.fromLTWH(
          gap + at * (cardWidth + gap),
          columnsTop + card * down,
          cardWidth,
          cardHeight,
        );
        if (box.contains(point)) {
          return Spot(where: Where.column, at: at, card: card);
        }
      }
      // The empty slot itself, so a card can be sent to an empty column.
      if (column.isEmpty && columnAt(at, 0).contains(point)) {
        return Spot(where: Where.column, at: at);
      }
    }
    return null;
  }
}

/// Draws the table.
///
/// The cards are drawn rather than loaded. Fifty two images at three
/// resolutions is a megabyte of app and a licence to keep track of; a
/// rectangle, a rank and a pip is neither, and it is sharp at whatever size a
/// phone gives it.
class TablePainter extends CustomPainter {
  TablePainter({
    required this.table,
    required this.metrics,
    required this.text,
    this.lit = const [],
  });

  final Table table;
  final Metrics metrics;

  /// The face the ranks are written in. Passed in because a TextPainter
  /// inside a painter is outside the widget tree and inherits nothing.
  final TextStyle text;

  /// Cards to point at, which is what a hint does.
  final List<Spot> lit;

  static final _letters = <String, TextPainter>{};

  @override
  void paint(Canvas canvas, Size size) {
    for (var at = 0; at < Table.cellCount; at++) {
      _paintSlot(canvas, metrics.cellAt(at));
      final card = table.cell(at);
      if (card != null) {
        _paintCard(canvas, metrics.cellAt(at), card,
            lit: _isLit(Where.cell, at));
      }
    }

    for (final suit in Suit.values) {
      final box = metrics.homeAt(suit.index);
      _paintSlot(canvas, box, pip: suit);
      final rank = table.home(suit);
      if (rank > 0) {
        _paintCard(canvas, box, Card.of(suit, rank));
      }
    }

    for (var at = 0; at < Table.columnCount; at++) {
      final column = table.column(at);
      if (column.isEmpty) {
        _paintSlot(canvas, metrics.columnAt(at, 0));
        continue;
      }
      final step = metrics.stepFor(column.length);
      for (var card = 0; card < column.length; card++) {
        final box = Rect.fromLTWH(
          metrics.gap + at * (metrics.cardWidth + metrics.gap),
          metrics.columnsTop + card * step,
          metrics.cardWidth,
          metrics.cardHeight,
        );
        _paintCard(
          canvas,
          box,
          column[card],
          lit: _isLit(Where.column, at, card),
          buried: card < column.length - 1,
        );
      }
    }
  }

  bool _isLit(Where where, int at, [int? card]) => lit.any(
        (spot) =>
            spot.where == where &&
            spot.at == at &&
            (spot.card == null || spot.card == card),
      );

  void _paintSlot(Canvas canvas, Rect box, {Suit? pip}) {
    final rounded = RRect.fromRectAndRadius(
      box.deflate(0.5),
      Radius.circular(metrics.cardWidth * 0.12),
    );
    canvas.drawRRect(rounded, Paint()..color = Palette.slot);
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = Palette.slotEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    if (pip == null) return;
    _pip(canvas, pip, box.center, metrics.cardWidth * 0.30, Palette.slotEdge);
  }

  /// Draws a card. [buried] means another card is lying over the bottom of
  /// it, so only its corner is worth drawing — the big pip in the middle would
  /// otherwise poke out from under whatever is on top and dot the table with
  /// little half-pips.
  void _paintCard(
    Canvas canvas,
    Rect box,
    Card card, {
    bool lit = false,
    bool buried = false,
  }) {
    final rounded = RRect.fromRectAndRadius(
      box.deflate(0.5),
      Radius.circular(metrics.cardWidth * 0.12),
    );

    canvas.drawRRect(
      rounded.shift(const Offset(0, 1)),
      Paint()..color = Palette.shadow,
    );
    canvas.drawRRect(rounded, Paint()..color = Palette.card);
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = lit ? Palette.pointed : Palette.cardEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = lit ? 2.4 : 1,
    );

    final ink = card.red ? Palette.red : Palette.black;
    final size = metrics.cardWidth * 0.36;

    // The rank and the pip in the top corner, which is the only part of a
    // card that is ever visible in a column.
    _write(
      canvas,
      Card.ranks[card.rank - 1],
      Offset(box.left + metrics.cardWidth * 0.28, box.top + size * 0.72),
      size,
      ink,
    );
    _pip(
      canvas,
      card.suit,
      Offset(box.left + metrics.cardWidth * 0.68, box.top + size * 0.72),
      size * 0.34,
      ink,
    );

    // And a big one further down, for the card on the end of a column, which
    // is the one being looked at.
    if (buried) return;
    _pip(
      canvas,
      card.suit,
      Offset(box.center.dx, box.bottom - metrics.cardHeight * 0.26),
      metrics.cardWidth * 0.19,
      ink,
    );
  }

  /// Draws a suit, rather than writing one.
  ///
  /// The four pips are glyphs, and whether a font has them is not something to
  /// find out on somebody's phone: the first version wrote them as text and
  /// every card in every picture came out with a hollow rectangle on it. Four
  /// shapes drawn with lines and arcs are always there, always the same, and
  /// sharp at any size — and a card game where the suits are unreadable is not
  /// a card game.
  ///
  /// [size] is the half-width of the pip.
  void _pip(Canvas canvas, Suit suit, Offset middle, double size, Color ink) {
    final paint = Paint()..color = ink;
    final path = Path();

    switch (suit) {
      case Suit.diamonds:
        path
          ..moveTo(middle.dx, middle.dy - size * 1.25)
          ..lineTo(middle.dx + size, middle.dy)
          ..lineTo(middle.dx, middle.dy + size * 1.25)
          ..lineTo(middle.dx - size, middle.dy)
          ..close();

      case Suit.hearts:
        final top = middle.dy - size * 0.75;
        path
          ..moveTo(middle.dx, middle.dy + size * 1.15)
          ..cubicTo(
            middle.dx - size * 2.1, top - size * 0.35,
            middle.dx - size * 0.45, top - size * 1.1,
            middle.dx, top + size * 0.3,
          )
          ..cubicTo(
            middle.dx + size * 0.45, top - size * 1.1,
            middle.dx + size * 2.1, top - size * 0.35,
            middle.dx, middle.dy + size * 1.15,
          )
          ..close();

      case Suit.spades:
        final tip = middle.dy - size * 1.25;
        path
          ..moveTo(middle.dx, tip)
          ..cubicTo(
            middle.dx + size * 0.45, tip + size * 1.1,
            middle.dx + size * 2.1, tip + size * 1.5,
            middle.dx, middle.dy + size * 0.65,
          )
          ..cubicTo(
            middle.dx - size * 2.1, tip + size * 1.5,
            middle.dx - size * 0.45, tip + size * 1.1,
            middle.dx, tip,
          )
          ..close();
        canvas.drawPath(path, paint);
        // The stem.
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx - size * 0.42, middle.dy + size * 1.3)
            ..quadraticBezierTo(
              middle.dx, middle.dy + size * 0.6,
              middle.dx + size * 0.42, middle.dy + size * 1.3,
            )
            ..close(),
          paint,
        );
        return;

      case Suit.clubs:
        final leaf = size * 0.62;
        canvas.drawCircle(
          Offset(middle.dx, middle.dy - size * 0.6), leaf, paint,
        );
        canvas.drawCircle(
          Offset(middle.dx - size * 0.68, middle.dy + size * 0.34), leaf, paint,
        );
        canvas.drawCircle(
          Offset(middle.dx + size * 0.68, middle.dy + size * 0.34), leaf, paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(middle.dx - size * 0.42, middle.dy + size * 1.35)
            ..quadraticBezierTo(
              middle.dx, middle.dy + size * 0.5,
              middle.dx + size * 0.42, middle.dy + size * 1.35,
            )
            ..close(),
          paint,
        );
        return;
    }

    canvas.drawPath(path, paint);
  }

  void _write(Canvas canvas, String glyph, Offset middle, double size,
      Color colour) {
    final key = '$glyph|${size.toStringAsFixed(1)}|${colour.toARGB32()}';
    final painter = _letters.putIfAbsent(key, () {
      final made = TextPainter(
        text: TextSpan(
          text: glyph,
          style: text.copyWith(
            color: colour,
            fontSize: size,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      return made;
    });
    painter.paint(
      canvas,
      Offset(middle.dx - painter.width / 2, middle.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(TablePainter old) =>
      old.table != table ||
      old.lit != lit ||
      old.metrics.cardWidth != metrics.cardWidth;

  /// The most cards a column can hold before they are squashed together.
  static int roomFor(Metrics metrics) =>
      max(1, (metrics.columnRoom / metrics.step).floor() + 1);
}

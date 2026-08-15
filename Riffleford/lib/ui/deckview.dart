import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../deck/play.dart';
import 'palette.dart';

/// Where the piles and the dealt row lie on the table, so the
/// screen and the tests can find every one.
class Metrics {
  Metrics(this.play, Size room) {
    card = math.min(room.width * 0.16, room.height * 0.2);
    final y = room.height * 0.06;
    pileA = Rect.fromLTWH(room.width * 0.22 - card * 0.5, y, card, card * 1.4);
    pileB = Rect.fromLTWH(room.width * 0.78 - card * 0.5, y, card, card * 1.4);
    dealtTop = y + card * 1.4 + room.height * 0.24;
    final n = play.rules.length;
    dealtCard = math.min((room.width * 0.9) / (n + (n ~/ play.rules.kinds) * 0.35), card * 0.8);
    dealtLeft = (room.width - dealtWidth) / 2;
  }

  final Play play;

  late final double card;
  late final Rect pileA;
  late final Rect pileB;

  /// The dealt row: cards laid left to right, a gap after every
  /// block.
  late final double dealtTop;
  late final double dealtCard;
  late final double dealtLeft;

  double get dealtWidth {
    final n = play.rules.length;
    final blocks = (n + play.rules.kinds - 1) ~/ play.rules.kinds;
    return n * dealtCard + (blocks - 1) * dealtCard * 0.35;
  }

  /// The place of the [i]th dealt card.
  Rect dealtAt(int i) {
    final block = i ~/ play.rules.kinds;
    return Rect.fromLTWH(
      dealtLeft + i * dealtCard + block * dealtCard * 0.35,
      dealtTop,
      dealtCard,
      dealtCard * 1.4,
    );
  }

  /// The pile under a touch, 'A' or 'B', or null.
  String? under(Offset touch) {
    if (pileA.inflate(card * 0.3).contains(touch)) return 'A';
    if (pileB.inflate(card * 0.3).contains(touch)) return 'B';
    return null;
  }
}

/// The table itself: two piles, the top card of each showing, and
/// the riffled row below, block by block.
class DeckView extends CustomPainter {
  DeckView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// The pile the show-me points at, or null.
  final String? pointing;
  final TextStyle labels;

  static Color tint(String kind) => switch (kind) {
        'R' => Palette.red,
        'B' => Palette.black,
        _ => Palette.green,
      };

  static String word(String kind) => switch (kind) {
        'R' => 'red',
        'B' => 'black',
        _ => 'green',
      };

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The baize.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.02, 0, size.width * 0.96, size.height), Radius.circular(metrics.card * 0.3)),
      Paint()..color = Palette.baize,
    );

    // The piles.
    _pile(canvas, metrics, metrics.pileA, play.rules.first, play.droppedA, 'A');
    _pile(canvas, metrics, metrics.pileB, play.rules.second, play.droppedB, 'B');
    _write(canvas, 'first pile${play.riffle.turned ? ', turned' : ''}',
        Offset(metrics.pileA.center.dx, metrics.pileA.bottom + metrics.card * 0.32),
        labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, metrics.card * 0.2)));
    _write(canvas, 'second pile',
        Offset(metrics.pileB.center.dx, metrics.pileB.bottom + metrics.card * 0.32),
        labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, metrics.card * 0.2)));

    // The dealt row.
    final dealt = play.dealt;
    final blocks = play.blocks;
    for (var i = 0; i < play.rules.length; i++) {
      final rect = metrics.dealtAt(i);
      if (i < dealt.length) {
        _card(canvas, rect, dealt[i], metrics.dealtCard);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(metrics.dealtCard * 0.15)),
          Paint()
            ..color = Palette.empty
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
    }
    // Brackets under every full block, gold when mixed and rust
    // when not.
    for (var b = 0; b < blocks.length; b++) {
      final left = metrics.dealtAt(b * play.rules.kinds).left;
      final right = metrics.dealtAt(b * play.rules.kinds + play.rules.kinds - 1).right;
      final y = metrics.dealtTop + metrics.dealtCard * 1.4 + metrics.dealtCard * 0.2;
      final paint = Paint()
        ..color = blocks[b] ? Palette.mixed : Palette.unmixed
        ..strokeWidth = math.max(2, metrics.dealtCard * 0.08)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
      canvas.drawLine(Offset(left, y), Offset(left, y - metrics.dealtCard * 0.15), paint);
      canvas.drawLine(Offset(right, y), Offset(right, y - metrics.dealtCard * 0.15), paint);
    }
    _write(canvas, 'the riffled deck, top to bottom',
        Offset(size.width / 2, metrics.dealtTop - metrics.dealtCard * 0.55),
        labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, metrics.card * 0.2)));

    // The pointer.
    if (pointing != null) {
      final rect = pointing == 'A' ? metrics.pileA : metrics.pileB;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(metrics.card * 0.14), Radius.circular(metrics.card * 0.2)),
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(2, metrics.card * 0.05),
      );
    }
  }

  void _pile(Canvas canvas, Metrics metrics, Rect rect, String cards, int dropped, String which) {
    final left = cards.length - dropped;
    if (left == 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(metrics.card * 0.12)),
        Paint()
          ..color = Palette.empty
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      _write(canvas, 'empty', rect.center,
          labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, metrics.card * 0.2)));
      return;
    }
    // The stack, a sliver per card left, then the top card.
    for (var i = math.min(left, 6) - 1; i >= 1; i--) {
      final r = rect.shift(Offset(-i * metrics.card * 0.04, -i * metrics.card * 0.04));
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(metrics.card * 0.12)),
        Paint()..color = Palette.cardEdge,
      );
    }
    _card(canvas, rect, cards[dropped], metrics.card);
    _write(canvas, '$left left', Offset(rect.center.dx, rect.top - metrics.card * 0.3),
        labels.copyWith(color: Palette.inkDim, fontSize: math.max(9, metrics.card * 0.2)));
  }

  void _card(Canvas canvas, Rect rect, String kind, double side) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(side * 0.12)),
      Paint()..color = Palette.cardFace,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(side * 0.12)),
      Paint()
        ..color = Palette.cardEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(side * 0.16), Radius.circular(side * 0.08)),
      Paint()..color = tint(kind),
    );
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: words, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(DeckView old) =>
      old.play != play || old.pointing != pointing;
}

/// The why, spoken for a riffle as it stands.
String whyWords(Play play) {
  final riffle = play.riffle;
  final note = riffle.note == null ? '' : ' ${riffle.note}';
  if (!riffle.winnable) {
    return 'The cut packet is turned, so the first pile reads the '
        'deck upward from the cut and the second reads it downward: '
        'their top cards differ. Drop either; the pair is finished by '
        'the next card of either pile, and both of those are the '
        'other colour, since each pile alternates. So the pair is '
        'mixed, and the two tops differ again. Round it goes to the '
        'last card. The sweep dealt all 56 riffles and found no pair '
        'of two reds.$note';
  }
  final second = riffle.turned
      ? 'the two piles read the pattern in opposite directions from '
          'the cut, so at the start of every block their tops differ, '
          'whichever card dropped last, and the walk of that invariant '
          'along every riffle agrees with the sweep'
      : 'with the packet not turned the two piles read the pattern the '
          'same way and both begin red, the invariant fails at the first '
          'pair, and only the riffles that happen to alternate land, as '
          'the sweep counts';
  return 'The riffles are counted by the sweep, every way of dropping '
      'the two piles together, ${riffle.riffles} of them, which is the '
      'cut chosen from the deck\'s places by arithmetic, and held to a '
      'second voice: $second. ${riffle.ways} riffle${riffle.ways == 1 ? '' : 's'} '
      'land${riffle.ways == 1 ? 's' : ''} this deck.$note';
}

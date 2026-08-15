import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../show/play.dart';
import '../show/rules.dart';
import 'palette.dart';

/// Where things lie on the board, so the screen and the tests can find
/// them: three judges' cards across the top, each a column of pies first
/// to last, and the ring of pies with the majority's arrows below.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    cardsTop = room.height * 0.02;
    cardsHeight = room.height * 0.5;
    cardWidth = room.width * 0.3;
    cardGap = room.width * 0.025;
    slotHeight = math.min((cardsHeight - 30) / play.pies, room.height * 0.13);
    ringCentre = Offset(room.width / 2, room.height * 0.79);
    ringRadius = math.min(room.width * 0.28, room.height * 0.14);
  }

  final Play play;

  late final double width;
  late final double height;
  late final double cardsTop;
  late final double cardsHeight;
  late final double cardWidth;
  late final double cardGap;
  late final double slotHeight;
  late final Offset ringCentre;
  late final double ringRadius;

  /// Judge [j]'s card.
  Rect card(int j) => Rect.fromLTWH(cardGap + j * (cardWidth + cardGap), cardsTop, cardWidth, cardsHeight);

  /// The slot for rank [i] on judge [j]'s card.
  Rect slot(int j, int i) {
    final c = card(j);
    return Rect.fromLTWH(c.left, c.top + 30 + i * slotHeight, c.width, slotHeight);
  }

  /// The middle of the slot holding [pie] on judge [j]'s card.
  Offset at(int j, int pie) => slot(j, play.profile[j].indexOf(pie)).center;

  /// The pie's place on the ring below.
  Offset ringAt(int pie) {
    final angle = -math.pi / 2 + pie * 2 * math.pi / play.pies;
    return ringCentre + Offset(math.cos(angle), math.sin(angle)) * ringRadius;
  }

  /// The (judge, pie) under a touch, or null.
  (int, int)? under(Offset touch) {
    for (var j = 0; j < Rules.judges; j++) {
      for (var i = 0; i < play.pies; i++) {
        if (slot(j, i).contains(touch)) return (j, play.profile[j][i]);
      }
    }
    return null;
  }
}

/// The judges' cards, each a column of pies first to last, and below
/// them the pies round a ring with the majority's arrows, winner to
/// loser, the count on each; a ring lights green, a pie beating every
/// other wears the rosette.
class ShowView extends CustomPainter {
  ShowView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The (judge, pie) the show-me points at, or null.
  final (int, int)? pointing;
  final TextStyle labels;

  /// Whether to draw the ring alone, for the mark.
  final bool bare;

  static const judgeNames = ['the vicar', 'the miller', 'the smith'];

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.tent);
    if (bare) {
      _ring(canvas, m, Offset(size.width / 2, size.height / 2), math.min(size.width, size.height) * 0.36, bare: true);
      return;
    }
    // Once the ask is over the cards are put away and the ring has the room.
    if (play.isOver) {
      _ring(canvas, m, Offset(size.width / 2, size.height / 2), math.min(size.width * 0.3, size.height * 0.36));
      return;
    }
    // The cards.
    for (var j = 0; j < Rules.judges; j++) {
      final c = m.card(j);
      canvas.drawRRect(RRect.fromRectAndRadius(c, const Radius.circular(8)), Paint()..color = Palette.card);
      _write(canvas, judgeNames[j], Offset(c.center.dx, c.top + 15), labels.copyWith(color: Palette.cardInk, fontSize: 13, fontWeight: FontWeight.w800));
      for (var i = 0; i < play.pies; i++) {
        final s = m.slot(j, i);
        canvas.drawLine(Offset(s.left + 6, s.top), Offset(s.right - 6, s.top), Paint()
          ..color = Palette.cardLine
          ..strokeWidth = 1);
        final pie = play.profile[j][i];
        final r = (s.height * 0.32).clamp(6.0, 16.0);
        _write(canvas, '${i + 1}', Offset(s.left + 12, s.center.dy), labels.copyWith(color: Palette.inkDim, fontSize: 11));
        _pie(canvas, Offset(s.left + 30 + r, s.center.dy), r, pie);
        _write(canvas, Rules.pieNames[pie], Offset(s.left + 30 + 2 * r + 6, s.center.dy), labels.copyWith(color: Palette.cardInk, fontSize: (s.height * 0.28).clamp(9.0, 13.0)), left: true);
        if (pointing != null && pointing!.$1 == j && pointing!.$2 == pie) {
          canvas.drawRRect(RRect.fromRectAndRadius(s.deflate(2), const Radius.circular(6)), Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
        }
      }
    }
    _ring(canvas, m, m.ringCentre, m.ringRadius);
  }

  void _ring(Canvas canvas, Metrics m, Offset centre, double radius, {bool bare = false}) {
    final n = play.pies;
    Offset at(int pie) {
      final angle = -math.pi / 2 + pie * 2 * math.pi / n;
      return centre + Offset(math.cos(angle), math.sin(angle)) * radius;
    }

    final ringOrder = play.ringOrder;
    final ringPairs = <String>{};
    if (ringOrder != null) {
      for (var i = 0; i < n; i++) {
        ringPairs.add('${ringOrder[i]}>${ringOrder[(i + 1) % n]}');
      }
    }
    final pieR = bare ? radius * 0.26 : (radius * 0.22).clamp(6.0, 26.0);
    final headLength = (radius * 0.09).clamp(8.0, 30.0), headHalf = headLength / 2;
    // Too small a ring carries no words.
    final words = !bare && radius >= 45;
    // The arrows, winner to loser, with the count.
    for (var a = 0; a < n; a++) {
      for (var b = a + 1; b < n; b++) {
        final aWins = Rules.beats(play.profile, a, b);
        final from = aWins ? a : b, to = aWins ? b : a;
        final inRing = ringPairs.contains('$from>$to');
        final colour = inRing ? Palette.ring : Palette.arrow;
        final p = at(from), q = at(to);
        final dir = (q - p) / (q - p).distance;
        final start = p + dir * (pieR + 3), end = q - dir * (pieR + 3);
        final stroke = (radius * 0.03).clamp(1.5, bare ? 8.0 : 4.0);
        canvas.drawLine(start, end, Paint()
          ..color = colour
          ..strokeWidth = stroke * (inRing ? 1.6 : 1));
        final head = Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(end.dx - dir.dx * headLength + dir.dy * headHalf, end.dy - dir.dy * headLength - dir.dx * headHalf)
          ..lineTo(end.dx - dir.dx * headLength - dir.dy * headHalf, end.dy - dir.dy * headLength + dir.dx * headHalf)
          ..close();
        canvas.drawPath(head, Paint()..color = colour);
        if (words) {
          final mid = (start + end) / 2;
          final count = Rules.count(play.profile, from, to);
          _write(canvas, '$count-${Rules.judges - count}', mid + Offset(-dir.dy, dir.dx) * 13, labels.copyWith(color: colour, fontSize: 10, fontWeight: FontWeight.w800));
        }
      }
    }
    // The pies.
    final winner = play.winner;
    final points = play.points;
    for (var pie = 0; pie < n; pie++) {
      final c = at(pie);
      if (winner == pie) {
        canvas.drawCircle(c, pieR + 5, Paint()
          ..color = Palette.winner
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
      _pie(canvas, c, pieR, pie);
      if (words) {
        final out = (c - centre) / (c - centre).distance;
        _writeOut(canvas, '${Rules.pieNames[pie]} ${points[pie]}', c, out, pieR + 8, labels.copyWith(color: Palette.ink, fontSize: 11));
      }
    }
  }

  void _pie(Canvas canvas, Offset c, double r, int pie) {
    canvas.drawCircle(c, r, Paint()..color = Palette.crust);
    canvas.drawCircle(c, r * 0.72, Paint()..color = Palette.fillings[pie]);
    final lattice = Paint()
      ..color = Palette.crustDark.withValues(alpha: 0.7)
      ..strokeWidth = (r * 0.12).clamp(1.0, 3.0);
    canvas.drawLine(c + Offset(-r * 0.5, -r * 0.5), c + Offset(r * 0.5, r * 0.5), lattice);
    canvas.drawLine(c + Offset(-r * 0.5, r * 0.5), c + Offset(r * 0.5, -r * 0.5), lattice);
    canvas.drawCircle(c, r, Paint()
      ..color = Palette.crustDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = (r * 0.1).clamp(1.0, 3.0));
  }

  /// Writes [words] just outside a disc at [c], out along [out].
  void _writeOut(Canvas canvas, String words, Offset c, Offset out, double gap, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    final at = c + out * gap + Offset(out.dx * painter.width / 2, out.dy * painter.height / 2);
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style, {bool left = false}) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, left ? at - Offset(0, painter.height / 2) : at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(ShowView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'Three judges each rank the pies, and one pie beats another when more '
      'judges rank it above; with three judges every pair is decided. Each judge\'s '
      'ranking runs straight, and still the majority can run in a ring, apple over '
      'bramble, bramble over cherry, cherry over apple, which is Condorcet\'s '
      'paradox: with three pies it happens in 12 of the 216 shows, exactly when the '
      'three ballots are the three turnings of one ranking. A pie that beats every '
      'other is a Condorcet winner, and with three pies it is always somebody\'s '
      'first choice: first on no ballot, it lies under one of the other two on '
      'each, so the ballots ranking it over one and those ranking it over the other '
      'come to three at most between them, and beating both takes two of each. '
      'Every show of three ballots is swept, 216 over three pies and 13,824 over '
      'four, and every count is read twice.';
  return '$law ${level.note}';
}

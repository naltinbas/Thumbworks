import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../deck/play.dart';
import 'palette.dart';

/// Where the pirates stand on the board, so the screen and the tests
/// can find every one: in a row across the deck, the captain at the
/// left, each with his coins stacked at his feet.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.pirates;
    slot = room.width / n;
    figure = math.min(slot * 0.7, room.height * 0.2);
    standAt = room.height * 0.46;
    coinsAt = room.height * 0.7;
    width = room.width;
    height = room.height;
  }

  final Play play;

  late final double slot;
  late final double figure;
  late final double standAt;
  late final double coinsAt;
  late final double width;
  late final double height;

  /// Where pirate [i] stands: his middle.
  Offset at(int i) => Offset(slot * (i + 0.5), standAt);

  /// The pirate under a touch, or null off the deck.
  int? under(Offset touch) {
    if (touch.dy < height * 0.1 || touch.dy > height * 0.95) return null;
    final i = (touch.dx / slot).floor();
    return i < 0 || i >= play.pirates ? null : i;
  }
}

/// The deck: sky, sea and planks, the pirates in a row with their coins
/// at their feet, the votes in bubbles once taken and what each expects
/// with the captain gone written under him.
class DeckView extends CustomPainter {
  DeckView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  /// Whether to leave the words off, for the mark.
  final bool bare;

  static const ranks = ['captain', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh'];

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.sky);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.22, size.width, size.height * 0.12), Paint()..color = Palette.sea);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.32, size.width, size.height * 0.68), Paint()..color = Palette.deck);
    for (var y = size.height * 0.32; y < size.height; y += size.height * 0.08) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()
        ..color = Palette.plank
        ..strokeWidth = 2);
    }
    for (var i = 0; i < play.pirates; i++) {
      final at = m.at(i);
      final f = m.figure;
      final aye = play.voted ? play.votes[i] : null;
      // The figure: coat, head, hat, sash.
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: at + Offset(0, f * 0.15), width: f * 0.55, height: f * 0.7), Radius.circular(f * 0.12)), Paint()..color = Palette.coat);
      canvas.drawRect(Rect.fromCenter(center: at + Offset(0, f * 0.05), width: f * 0.55, height: f * 0.08), Paint()..color = Palette.sash);
      canvas.drawCircle(at + Offset(0, -f * 0.38), f * 0.2, Paint()..color = Palette.skin);
      canvas.drawRect(Rect.fromCenter(center: at + Offset(0, -f * 0.55), width: f * 0.6, height: f * 0.08), Paint()..color = Palette.hat);
      canvas.drawRect(Rect.fromCenter(center: at + Offset(0, -f * 0.66), width: f * 0.34, height: f * 0.18), Paint()..color = Palette.hat);
      if (i == 0) {
        // The captain's badge.
        canvas.drawCircle(at + Offset(0, -f * 0.55), f * 0.06, Paint()..color = Palette.gold);
      }
      // The coins at his feet, a stack of discs.
      final coins = play.shares[i];
      final coinW = math.min(m.slot * 0.5, f * 0.5), coinH = math.max(3.0, f * 0.09);
      for (var k = 0; k < coins; k++) {
        final y = m.coinsAt - k * coinH * 1.15;
        canvas.drawOval(Rect.fromCenter(center: Offset(at.dx, y), width: coinW, height: coinH * 1.6), Paint()..color = Palette.goldDark);
        canvas.drawOval(Rect.fromCenter(center: Offset(at.dx, y - coinH * 0.4), width: coinW, height: coinH * 1.6), Paint()..color = Palette.gold);
      }
      if (!bare) {
        _write(canvas, ranks[i], Offset(at.dx, m.coinsAt + f * 0.55), labels.copyWith(color: Palette.ink, fontSize: 11));
        _write(canvas, '$coins coin${coins == 1 ? '' : 's'}', Offset(at.dx, m.coinsAt + f * 0.55 + 14), labels.copyWith(color: Palette.gold, fontSize: 11, fontWeight: FontWeight.w800));
        if (play.voted && i > 0) {
          _write(canvas, 'expects ${play.expects[i]}', Offset(at.dx, m.coinsAt + f * 0.55 + 28), labels.copyWith(color: Palette.inkDim, fontSize: 10));
        }
      }
      // The vote, in a bubble over the hat.
      if (aye != null) {
        final bubble = Rect.fromCenter(center: at + Offset(0, -f * 1.05), width: f * 0.7, height: f * 0.32);
        canvas.drawRRect(RRect.fromRectAndRadius(bubble, Radius.circular(f * 0.12)), Paint()..color = aye ? Palette.good : Palette.clash);
        if (!bare) _write(canvas, aye ? 'aye' : 'nay', bubble.center, labels.copyWith(color: Palette.night, fontSize: math.max(9, f * 0.2), fontWeight: FontWeight.w800));
      }
    }
    // The pointer.
    final aim = pointing;
    if (aim != null && aim.$1 != 'vote') {
      canvas.drawCircle(m.at(aim.$2), m.figure * 0.75, Paint()
        ..color = aim.$1 == 'give' ? Palette.shown : Palette.clash
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(DeckView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a crew as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  final want = play.expects;
  final saying = [for (var i = 1; i < play.pirates; i++) '${DeckView.ranks[i]} ${want[i]}'].join(', ');
  final reckoning = 'Every pirate votes aye only if his share beats what he would get with '
      'the captain gone, and what he would get is the best plan of the crew one '
      'smaller, reckoned the same way down to one pirate alone: here the '
      '$saying. The plan passes with the ayes at least half, the captain\'s among them, '
      '${play.needed} of ${play.pirates}.';
  if (!level.winnable) {
    return '$reckoning Every division of the ten coins was swept for this crew and '
        'none keeping ${level.keep} passes; on every crew from one to seven the '
        'best plan is one alone, and the captain keeps the gold less half the crew '
        'rounded down.$note';
  }
  return '$reckoning The sweep divides the ten coins every way among the crew and '
      'keeps the plans that pass: ${level.ways} of the ${level.plans} keeping '
      '${level.keep} or more, and the best plan is one alone, the captain keeping the '
      'gold less half the crew rounded down, on every crew from one to seven.$note';
}

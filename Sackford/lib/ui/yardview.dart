import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import 'palette.dart';

/// Where things lie on the board: the carts across the top, each with a
/// bed and a load bar to the ten-stone line, and the sacks in a row on
/// the ground below, each tinted for the cart it is on.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    final n = play.carts;
    cartTop = room.height * (bare ? 0.06 : 0.09);
    cartHeight = room.height * (bare ? 0.6 : 0.44);
    cartWidth = room.width * 0.86 / n;
    cartLeft = room.width * 0.07;
    sackTop = room.height * 0.62;
    sackHeight = room.height * 0.34;
    sackGap = room.width * 0.9 / play.sacks.length;
    sackLeft = room.width * 0.05;
  }

  final Play play;

  late final double width;
  late final double height;
  late final double cartTop;
  late final double cartHeight;
  late final double cartWidth;
  late final double cartLeft;
  late final double sackTop;
  late final double sackHeight;
  late final double sackGap;
  late final double sackLeft;

  /// Cart [c]'s bed.
  Rect cart(int c) => Rect.fromLTWH(cartLeft + c * cartWidth + cartWidth * 0.08, cartTop, cartWidth * 0.84, cartHeight);

  /// Sack [i]'s slot on the ground.
  Rect sack(int i) => Rect.fromLTWH(sackLeft + i * sackGap, sackTop, sackGap, sackHeight);

  /// The middle of sack [i].
  Offset sackAt(int i) => sack(i).center;

  /// The sack under a touch, or null.
  int? under(Offset touch) {
    for (var i = 0; i < play.sacks.length; i++) {
      if (sack(i).contains(touch)) return i;
    }
    return null;
  }
}

/// The yard: carts with their loads, the ten-stone line, sacks on the
/// ground tinted for the cart they ride in, and their weights.
class YardView extends CustomPainter {
  YardView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// The (sack, taps) the show-me points at, or null.
  final (int, int)? pointing;
  final TextStyle labels;

  /// Whether to draw the carts alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.yard);
    final loads = play.loads;
    // The carts.
    for (var c = 0; c < play.carts; c++) {
      final r = m.cart(c);
      final colour = Palette.carts[c % Palette.carts.length];
      // The bed, and the load bar filling it from the bottom, ten stone
      // to the top; over ten spills red above the line.
      final bed = Rect.fromLTWH(r.left, r.top + r.height * 0.15, r.width, r.height * 0.7);
      canvas.drawRRect(RRect.fromRectAndRadius(bed, const Radius.circular(4)), Paint()..color = Palette.cartBed);
      final unit = bed.height / Rules.capacity;
      final load = loads[c];
      final filled = math.min(load, Rules.capacity) * unit;
      canvas.drawRect(Rect.fromLTWH(bed.left, bed.bottom - filled, bed.width, filled), Paint()..color = colour.withValues(alpha: 0.85));
      if (load > Rules.capacity) {
        final spill = math.min(load - Rules.capacity, 4) * unit;
        canvas.drawRect(Rect.fromLTWH(bed.left, bed.top - spill, bed.width, spill), Paint()..color = Palette.loadOver);
      }
      // The sacks in the cart, stacked as bands.
      var y = bed.bottom;
      for (var i = 0; i < play.sacks.length; i++) {
        if (play.cartOf[i] != c) continue;
        final h = play.sacks[i] * unit;
        canvas.drawLine(Offset(bed.left, y - h), Offset(bed.right, y - h), Paint()
          ..color = Palette.yard
          ..strokeWidth = 1.5);
        if (!bare && h >= 12) {
          _write(canvas, '${play.sacks[i]}', Offset(bed.center.dx, y - h / 2), labels.copyWith(color: Palette.night, fontSize: (h * 0.6).clamp(8.0, 12.0), fontWeight: FontWeight.w800));
        }
        y -= h;
      }
      // The ten-stone line and the wheels.
      canvas.drawLine(Offset(bed.left - 4, bed.top), Offset(bed.right + 4, bed.top), Paint()
        ..color = Palette.capLine
        ..strokeWidth = 2);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r.left - 3, bed.bottom, r.width + 6, r.height * 0.06), const Radius.circular(2)), Paint()..color = Palette.cart);
      final wheelR = (r.width * 0.09).clamp(4.0, 12.0);
      canvas.drawCircle(Offset(r.left + r.width * 0.25, bed.bottom + r.height * 0.06 + wheelR), wheelR, Paint()..color = Palette.cart);
      canvas.drawCircle(Offset(r.right - r.width * 0.25, bed.bottom + r.height * 0.06 + wheelR), wheelR, Paint()..color = Palette.cart);
      if (!bare) {
        _write(canvas, 'cart ${c + 1}: $load of 10', Offset(r.center.dx, m.cartTop * 0.5), labels.copyWith(color: load > Rules.capacity ? Palette.loadOver : Palette.ink, fontSize: 11, fontWeight: FontWeight.w800));
      }
    }
    if (bare) return;
    // The ground and the sacks.
    canvas.drawRect(Rect.fromLTWH(0, m.sackTop + m.sackHeight * 0.85, size.width, m.sackHeight * 0.15), Paint()..color = Palette.ground);
    for (var i = 0; i < play.sacks.length; i++) {
      final slot = m.sack(i);
      final w = play.sacks[i];
      final on = play.cartOf[i];
      final sackW = slot.width * 0.7, sackH = m.sackHeight * (0.35 + 0.05 * w);
      final r = Rect.fromLTWH(slot.center.dx - sackW / 2, slot.top + m.sackHeight * 0.85 - sackH, sackW, sackH);
      canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(sackW * 0.3)), Paint()..color = on == null ? Palette.sack : Palette.carts[on % Palette.carts.length]);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r.left + sackW * 0.2, r.top - 4, sackW * 0.6, 8), const Radius.circular(3)), Paint()..color = Palette.sackDark);
      _write(canvas, '$w', r.center, labels.copyWith(color: Palette.night, fontSize: (sackW * 0.45).clamp(9.0, 16.0), fontWeight: FontWeight.w800));
      _write(canvas, on == null ? 'ground' : 'cart ${on + 1}', Offset(slot.center.dx, slot.bottom - 2), labels.copyWith(color: on == null ? Palette.inkDim : Palette.carts[on % Palette.carts.length], fontSize: 9));
      if (pointing != null && pointing!.$1 == i) {
        canvas.drawRRect(RRect.fromRectAndRadius(r.inflate(4), const Radius.circular(8)), Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
      }
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(YardView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'Sacks of so many stone, carts that carry ten, and the sacks to be '
      'loaded into as few carts as will take them: bin packing, which has no quick '
      'rule that always finds the fewest. The search here tries every loading, '
      'sack by sack into a cart in use or the next fresh one, and tells the '
      'loadings by the weights each cart carries. The weight over ten, rounded up, '
      'is a floor no loading beats. The carrier\'s rule, heaviest first into the '
      'first cart with room, is quick and good, never more than eleven ninths of '
      'the fewest carts and two thirds of a cart besides, but it slips: on four of '
      'the 3,003 loads of six sacks of one to nine stone it needs a cart too many, '
      'and the fourth yard here is one where it slips.';
  return '$law ${level.note}';
}

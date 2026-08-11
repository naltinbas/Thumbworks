import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../yard/deal.dart';
import '../yard/fewest.dart';
import '../yard/play.dart';
import 'palette.dart';

/// Where everything stands, shared by the painter and the hit-testing, so
/// where a pile is drawn is exactly where a pile is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;

    // A slot for every pile and, while bales are still coming, one for the
    // ground. Never fewer than four, so early mornings are not drawn huge.
    slots = math.max(4, play.standing + (play.isDone ? 0 : 1));
    slotWide = width / slots;

    // A pile is a falling run, so the deepest it can ever get is the deal's
    // longest one; the yard reserves that and no more. The height branch
    // keeps the tiniest launcher icon at a positive bale height.
    final rows = Runs.falling(play.deal.tods) + 1;
    baleHigh = math.min(slotWide * 0.5, (height - 8) / (rows + 3.4));
    ground = height - 6;
    cartFloor = baleHigh * 2.6;
  }

  /// The height a yard for [deal] wants, given its width: enough for the
  /// cart, the deepest pile the rule allows, and a row of air. The screen
  /// hands the painter a box this tall rather than everything it has, so a
  /// tall phone does not put an acre of nothing between cart and piles.
  static double heightFor(Deal deal, double width) {
    final worst = math.max(4, deal.fewest + 2);
    final bale = math.min(width / worst * 0.5, 60.0);
    return bale * (Runs.falling(deal.tods) + 1 + 3.4) + 8;
  }

  final Play play;

  late final double width;
  late final double height;

  /// The bottom of the cart strip across the top.
  late final double cartFloor;

  /// Where the piles stand.
  late final double ground;

  late final int slots;
  late final double slotWide;
  late final double baleHigh;

  double middleOf(int slot) => slotWide * (slot + 0.5);

  /// How wide a bale of this weight is drawn. Heavier is wider, so a legal
  /// pile narrows as it rises and the rule can be seen across the yard.
  double wideFor(int tod) {
    var lightest = play.deal.tods[0], heaviest = play.deal.tods[0];
    for (final other in play.deal.tods) {
      lightest = math.min(lightest, other);
      heaviest = math.max(heaviest, other);
    }
    final part = heaviest == lightest
        ? 1.0
        : (tod - lightest) / (heaviest - lightest);
    return slotWide * (0.42 + 0.5 * part);
  }

  /// The bale so far up this pile.
  Rect baleRect(int pile, int height) {
    final tod = play.deal.tods[play.piles[pile][height]];
    final wide = wideFor(tod);
    final middle = middleOf(pile);
    final bottom = ground - height * (baleHigh + 2);
    return Rect.fromLTWH(middle - wide / 2, bottom - baleHigh, wide, baleHigh);
  }

  /// Where the ground waits for a new pile, while bales are still coming.
  Rect groundRect() {
    final middle = middleOf(play.standing);
    final wide = slotWide * 0.62;
    return Rect.fromLTWH(middle - wide / 2, ground - baleHigh, wide, baleHigh);
  }

  /// The bale coming up the lane, drawn on the cart.
  Rect arrivingRect() {
    final tod = play.arriving;
    if (tod == null) return Rect.zero;
    final wide = wideFor(tod);
    final middle = width * 0.30;
    final bottom = cartFloor - baleHigh * 0.3;
    return Rect.fromLTWH(
        middle - wide / 2, bottom - baleHigh, wide, baleHigh);
  }

  /// The slot under a touch: a pile, the ground one past them, or -1 for the
  /// cart strip and other nowhere.
  int slotAt(Offset touch) {
    if (touch.dy < cartFloor || touch.dy > height) return -1;
    final slot = touch.dx ~/ slotWide;
    final last = play.isDone ? play.standing - 1 : play.standing;
    if (slot < 0 || slot > last) return -1;
    return slot;
  }
}

/// The yard, drawn.
class YardView extends CustomPainter {
  YardView({
    required this.play,
    required this.pointing,
    required this.showThread,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The slot being pointed at, or -1.
  final int pointing;

  /// Whether to draw the rising run through the yard.
  final bool showThread;

  /// Whether to ink the weights on. Off only for the mark, where they would
  /// be a smudge.
  final bool showWords;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final thread = showThread ? Runs.thread(play.deal.tods) : const <int>[];

    _cart(canvas, metrics, thread);
    _ground(canvas, metrics);
    // The thread goes down first, so it runs behind the piles: a line over
    // the bales would cross their weights, and the gold rims already say
    // which bales it joins.
    if (showThread) _thread(canvas, metrics, thread);
    for (var pile = 0; pile < play.standing; pile++) {
      for (var height = 0; height < play.piles[pile].length; height++) {
        _bale(
          canvas,
          metrics.baleRect(pile, height),
          play.deal.tods[play.piles[pile][height]],
          threaded: thread.contains(play.piles[pile][height]),
        );
      }
    }
    if (!play.isDone) _groundSlot(canvas, metrics);
    if (pointing >= 0) _point(canvas, metrics);
  }

  void _cart(Canvas canvas, Metrics metrics, List<int> thread) {
    // Nothing at all once the cart is empty: a floor line with no cart on
    // it is just a stray mark over the piles.
    final arriving = metrics.arrivingRect();
    if (arriving == Rect.zero) return;

    canvas.drawLine(
      Offset(8, metrics.cartFloor),
      Offset(metrics.width - 8, metrics.cartFloor),
      Paint()
        ..color = Palette.line
        ..strokeWidth = 1.4,
    );

    // The cart: a plank and two wheels under the arriving bale.
    final plankY = metrics.cartFloor - metrics.baleHigh * 0.15;
    canvas.drawLine(
      Offset(arriving.left - 10, plankY),
      Offset(arriving.right + 10, plankY),
      Paint()
        ..color = Palette.cart
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    for (final wheelX in [arriving.left + 2, arriving.right - 2]) {
      canvas.drawCircle(
        Offset(wheelX, plankY + 4),
        3.4,
        Paint()
          ..color = Palette.cart
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    _bale(canvas, arriving, play.arriving!,
        threaded: thread.contains(play.placed));

    // The rest of the load, waiting behind it, lighter the further back.
    final behind = play.deal.many - play.placed - 1;
    for (var back = 0; back < math.min(behind, 5); back++) {
      final tod = play.deal.tods[play.placed + 1 + back];
      final wide = metrics.wideFor(tod) * 0.42;
      final high = metrics.baleHigh * 0.42;
      final left = arriving.right + 26 + back * (metrics.slotWide * 0.34);
      if (left + wide > metrics.width - 6) break;
      final rect = Rect.fromLTWH(
          left, metrics.cartFloor - metrics.baleHigh * 0.26 - high, wide, high);
      final paint = Paint()
        ..color = Palette.woolShade.withValues(alpha: 0.55 - back * 0.08);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(high * 0.4)), paint);
      if (thread.contains(play.placed + 1 + back)) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(high * 0.4)),
          Paint()
            ..color = Palette.thread
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }
  }

  void _ground(Canvas canvas, Metrics metrics) {
    canvas.drawLine(
      Offset(6, metrics.ground + 1),
      Offset(metrics.width - 6, metrics.ground + 1),
      Paint()
        ..color = Palette.edge
        ..strokeWidth = 2,
    );
  }

  void _bale(Canvas canvas, Rect rect, int tod, {required bool threaded}) {
    final round = RRect.fromRectAndRadius(
        rect, Radius.circular(rect.height * 0.38));
    canvas.drawRRect(round, Paint()..color = Palette.wool);

    // The underside, where the weight above it presses.
    final shade = Path()
      ..addRRect(round)
      ..addRect(Rect.fromLTRB(
          rect.left, rect.top, rect.right, rect.bottom - rect.height * 0.30))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(shade, Paint()..color = Palette.woolShade);

    // The ears where the ties are knotted.
    final ear = Paint()
      ..color = Palette.woolShade
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final earX in [rect.left + rect.width * 0.22,
        rect.right - rect.width * 0.22]) {
      canvas.drawLine(Offset(earX - 2, rect.top - 3), Offset(earX + 2, rect.top),
          ear);
      canvas.drawLine(Offset(earX + 2, rect.top - 3), Offset(earX - 2, rect.top),
          ear);
    }

    canvas.drawRRect(
      round,
      Paint()
        ..color = threaded ? Palette.thread : Palette.tod.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = threaded ? 2.6 : 1.2,
    );

    if (!showWords) return;
    final words = TextPainter(
      text: TextSpan(
        text: '$tod',
        style: labels.copyWith(
          color: Palette.tod,
          fontSize: rect.height * 0.46,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
      canvas,
      rect.center - Offset(words.width / 2, words.height / 2),
    );
  }

  void _groundSlot(Canvas canvas, Metrics metrics) {
    final rect = metrics.groundRect();
    final round = RRect.fromRectAndRadius(
        rect, Radius.circular(rect.height * 0.38));
    final dashed = Paint()
      ..color = Palette.inkDim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Dashes walked along the outline by hand; the canvas has no dashed
    // stroke of its own.
    final outline = Path()..addRRect(round);
    for (final piece in outline.computeMetrics()) {
      var along = 0.0;
      while (along < piece.length) {
        canvas.drawPath(
            piece.extractPath(along, math.min(along + 5, piece.length)),
            dashed);
        along += 9;
      }
    }
  }

  void _thread(Canvas canvas, Metrics metrics, List<int> thread) {
    // The gold line joins the thread bales already set down, in the order
    // they arrived, so the rising run can be followed across the piles.
    final stops = <Offset>[];
    for (final bale in thread) {
      final home = play.whereIs(bale);
      if (home == null) continue;
      stops.add(metrics.baleRect(home.pile, home.height).center);
    }
    if (stops.length < 2) return;

    final path = Path()..moveTo(stops.first.dx, stops.first.dy);
    for (var stop = 1; stop < stops.length; stop++) {
      final from = stops[stop - 1];
      final to = stops[stop];
      final lift = math.min(60.0, (to.dx - from.dx).abs() * 0.4) + 12;
      path.quadraticBezierTo(
        (from.dx + to.dx) / 2,
        math.min(from.dy, to.dy) - lift,
        to.dx,
        to.dy,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.thread.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  void _point(Canvas canvas, Metrics metrics) {
    final rect = pointing == play.standing
        ? metrics.groundRect()
        : (play.piles.isEmpty || pointing >= play.standing
            ? metrics.groundRect()
            : metrics.baleRect(pointing, play.piles[pointing].length - 1));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect.inflate(6), Radius.circular(rect.height * 0.5)),
      Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
  }

  @override
  bool shouldRepaint(YardView old) =>
      old.play != play ||
      old.pointing != pointing ||
      old.showThread != showThread;
}

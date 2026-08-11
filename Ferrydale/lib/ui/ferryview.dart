import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../ferry/play.dart';
import 'palette.dart';

/// Where the banks, the boat and everyone aboard lie, shared by the
/// painter and the hit-testing, so what is drawn is exactly what is
/// tapped.
class Metrics {
  Metrics(this.play, Size room) {
    width = room.width;
    height = room.height;
    bankWide = width * 0.27;
    chip = math.min(
      bankWide * 0.3,
      height / (play.rules.people + 3),
    );
  }

  final Play play;

  late final double width;
  late final double height;
  late final double bankWide;
  late final double chip;

  Rect bankRect({required bool far}) => Rect.fromLTWH(
        far ? width - bankWide : 0,
        height * 0.06,
        bankWide,
        height * 0.82,
      );

  Rect boatRect() {
    final wide = width * 0.2;
    final tall = chip * 3.4;
    final x = play.boatFar
        ? width - bankWide - wide - width * 0.015
        : bankWide + width * 0.015;
    return Rect.fromLTWH(x, height * 0.5 - tall / 2, wide, tall);
  }

  /// A passenger's place: ranked on their bank, or seated aboard.
  Offset chipCenter(int who) {
    if (play.isAboard(who)) {
      final boat = boatRect();
      final seat = play.aboard.indexOf(who);
      final seats = play.ferry.capacity;
      return Offset(
        boat.left + boat.width * (seat + 1) / (seats + 1),
        boat.center.dy - chip * 0.2,
      );
    }
    final far = play.onFar(who);
    final bank = bankRect(far: far);
    final fellows = [
      for (var other = 0; other < play.rules.people; other++)
        if (play.onFar(other) == far && !play.isAboard(other)) other,
    ];
    final at = fellows.indexOf(who);
    final perRow = math.max(1, bankWide ~/ (chip * 2.4));
    final row = at ~/ perRow;
    final col = at % perRow;
    return Offset(
      bank.left + bank.width * (col + 1) / (perRow + 1),
      bank.top + chip * 1.8 + row * chip * 2.5,
    );
  }

  /// The passenger under a touch, or null.
  int? chipAt(Offset touch) {
    for (var who = 0; who < play.rules.people; who++) {
      if ((chipCenter(who) - touch).distance <= chip * 1.35) return who;
    }
    return null;
  }

  bool boatAt(Offset touch) => boatRect().inflate(10).contains(touch);
}

/// The river, drawn.
class FerryView extends CustomPainter {
  FerryView({
    required this.play,
    required this.pointing,
    this.showWords = true,
    required this.labels,
  });

  final Play play;

  /// The passengers of a pointed load, rimmed blue.
  final List<int> pointing;

  /// Whether words may be written. Off for the mark.
  final bool showWords;

  final TextStyle labels;

  static const glyphs = ['K', 'W', 'G', 'C'];

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);

    // The river and its banks.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, metrics.width, metrics.height),
      Paint()..color = Palette.river,
    );
    for (var wave = 0; wave < 5; wave++) {
      final y = metrics.height * (0.15 + wave * 0.17);
      final path = Path()..moveTo(metrics.bankWide, y);
      var x = metrics.bankWide;
      var up = true;
      while (x < metrics.width - metrics.bankWide) {
        final next =
            math.min(x + metrics.chip, metrics.width - metrics.bankWide);
        path.quadraticBezierTo((x + next) / 2,
            y + (up ? -metrics.chip * 0.18 : metrics.chip * 0.18), next, y);
        x = next;
        up = !up;
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.wave
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
    for (final far in const [false, true]) {
      final bank = metrics.bankRect(far: far);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bank, Radius.circular(metrics.chip * 0.5)),
        Paint()..color = Palette.bank,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(bank, Radius.circular(metrics.chip * 0.5)),
        Paint()
          ..color = Palette.bankEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // The boat.
    final boat = metrics.boatRect();
    final hull = Path()
      ..moveTo(boat.left, boat.top + boat.height * 0.45)
      ..lineTo(boat.right, boat.top + boat.height * 0.45)
      ..lineTo(boat.right - boat.width * 0.16, boat.bottom)
      ..lineTo(boat.left + boat.width * 0.16, boat.bottom)
      ..close();
    canvas.drawPath(hull, Paint()..color = Palette.boat);
    canvas.drawPath(
      hull,
      Paint()
        ..color = Palette.boatRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    for (var who = 0; who < play.rules.people; who++) {
      _chip(canvas, metrics, who);
    }

  }

  Color _colour(int who) {
    if (play.ferry.keeper) {
      return const [
        Palette.keeper,
        Palette.wolf,
        Palette.goat,
        Palette.cabbage,
      ][who];
    }
    return who < play.ferry.each
        ? Palette.missionary
        : Palette.cannibal;
  }

  String _glyph(int who) {
    if (play.ferry.keeper) return FerryView.glyphs[who];
    return who < play.ferry.each ? 'M' : 'C';
  }

  void _chip(Canvas canvas, Metrics metrics, int who) {
    final middle = metrics.chipCenter(who);
    canvas.drawCircle(middle, metrics.chip, Paint()..color = _colour(who));
    if (pointing.contains(who)) {
      canvas.drawCircle(
        middle,
        metrics.chip * 1.22,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6,
      );
    }
    final words = TextPainter(
      text: TextSpan(
        text: _glyph(who),
        style: labels.copyWith(
          color: Palette.glyph,
          fontSize: metrics.chip * 1.05,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    words.paint(
        canvas, middle - Offset(words.width / 2, words.height / 2));
  }

  @override
  bool shouldRepaint(FerryView old) =>
      old.play != play || old.pointing != pointing;
}

/// The words the why speaks, from the river at hand.
String whyWords(Play play) {
  final ferry = play.ferry;
  final note = ferry.note == null ? '' : ' ${ferry.note}';
  if (!ferry.winnable) {
    return 'The walk boarded every load a boat of ${ferry.capacity} '
        'can carry, from every arrangement it can reach, all '
        '${ferry.reach} of them: the far bank is never full. There '
        'is no trick left untried.$note';
  }
  return 'The walk stood on every arrangement this river allows, '
      'all ${ferry.reach}, and wrote the crossings from each: '
      '${ferry.fewest} from the first bank, and Show me reads the '
      'same table.$note';
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../scale/play.dart';
import '../scale/rules.dart';
import 'palette.dart';

/// Where the weights sit on the board, so the screen and the tests can
/// find every one: on the ground below the scale when off, on the pan
/// across when against the load, on the load's pan when beside it.
class Metrics {
  Metrics(this.play, Size room) {
    pivot = Offset(room.width / 2, room.height * 0.3);
    arm = room.width * 0.3;
    panDrop = room.height * 0.22;
    groundY = room.height * 0.88;
    weightGap = room.width * 0.2;
    weightSize = math.min(room.width * 0.11, room.height * 0.1);
  }

  final Play play;

  late final Offset pivot;
  late final double arm;
  late final double panDrop;
  late final double groundY;
  late final double weightGap;
  late final double weightSize;

  /// The beam's tip, degrees of a kind: level at nought, the load's pan
  /// down when the load's side is heavier.
  double get angle {
    final t = play.tilt;
    if (t == 0) return 0;
    return (t > 0 ? 1 : -1) * math.min(0.22, 0.04 + t.abs() * 0.01);
  }

  /// The end of the beam on the load's side (left) and the weights'
  /// side (right).
  Offset get leftEnd => pivot + Offset(-arm * math.cos(angle), arm * math.sin(angle));
  Offset get rightEnd => pivot + Offset(arm * math.cos(angle), -arm * math.sin(angle));

  Offset get leftPan => leftEnd + Offset(0, panDrop);
  Offset get rightPan => rightEnd + Offset(0, panDrop);

  /// Where weight [i] stands on the ground when off.
  Offset groundAt(int i) => Offset(pivot.dx + (i - 1.5) * weightGap, groundY - weightSize * 0.6);

  /// Where weight [i] stands as placed.
  Offset at(int i) {
    switch (play.placing[i]) {
      case Side.off:
        return groundAt(i);
      case Side.against:
        return rightPan + Offset(_slot(i, Side.against), -weightSize * 0.55);
      case Side.withLoad:
        return leftPan + Offset(_slot(i, Side.withLoad) + weightSize * 0.9, -weightSize * 0.55);
    }
  }

  /// A weight's place along its pan, the weights on it spread out.
  double _slot(int i, Side side) {
    final on = [for (var k = 0; k < 4; k++) if (play.placing[k] == side) k];
    final n = on.length;
    final index = on.indexOf(i);
    return (index - (n - 1) / 2) * weightSize * 0.95;
  }

  /// The weight under a touch, wherever it stands, or null.
  int? under(Offset touch) {
    for (var i = 0; i < 4; i++) {
      if ((touch - at(i)).distance <= weightSize * 0.75) return i;
    }
    return null;
  }
}

/// The scale: post and beam, two pans, the load in a sack on the left,
/// the weights where they stand, and the ground below.
class ScaleView extends CustomPainter {
  ScaleView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final w = m.weightSize;

    // The ground and the post.
    canvas.drawRect(Rect.fromLTWH(0, m.groundY, size.width, size.height - m.groundY), Paint()..color = Palette.ground);
    canvas.drawRect(Rect.fromCenter(center: Offset(m.pivot.dx, (m.pivot.dy + m.groundY) / 2), width: w * 0.35, height: m.groundY - m.pivot.dy),
        Paint()..color = Palette.ironDark);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(m.pivot.dx, m.groundY), width: w * 2, height: w * 0.3), const Radius.circular(4)),
        Paint()..color = Palette.ironDark);
    // The beam.
    canvas.drawLine(m.leftEnd, m.rightEnd, Paint()
      ..color = Palette.iron
      ..strokeWidth = math.max(4, w * 0.16)
      ..strokeCap = StrokeCap.round);
    canvas.drawCircle(m.pivot, w * 0.16, Paint()..color = Palette.brass);
    // The pointer needle at the pivot: green level, rust tipped.
    final tipped = play.tilt != 0;
    canvas.drawLine(m.pivot, m.pivot + Offset(-math.sin(m.angle), -math.cos(m.angle)) * w * 0.9, Paint()
      ..color = tipped ? Palette.tipped : Palette.level
      ..strokeWidth = 3);
    // The strings and pans.
    for (final (end, pan) in [(m.leftEnd, m.leftPan), (m.rightEnd, m.rightPan)]) {
      for (final dx in [-w * 1.35, w * 1.35]) {
        canvas.drawLine(end, pan + Offset(dx, -w * 0.15), Paint()
          ..color = Palette.iron
          ..strokeWidth = 1.5);
      }
      canvas.drawOval(Rect.fromCenter(center: pan, width: w * 3.2, height: w * 0.5), Paint()..color = Palette.pan);
      canvas.drawOval(Rect.fromCenter(center: pan, width: w * 3.2, height: w * 0.5), Paint()
        ..color = Palette.ironDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    }
    // The load, a sack on the left pan.
    final sackAt = m.leftPan + Offset(-w * 0.9, -w * 0.75);
    final sack = Path()
      ..moveTo(sackAt.dx - w * 0.6, sackAt.dy + w * 0.6)
      ..lineTo(sackAt.dx + w * 0.6, sackAt.dy + w * 0.6)
      ..lineTo(sackAt.dx + w * 0.55, sackAt.dy - w * 0.35)
      ..quadraticBezierTo(sackAt.dx, sackAt.dy - w * 0.95, sackAt.dx - w * 0.55, sackAt.dy - w * 0.35)
      ..close();
    canvas.drawPath(sack, Paint()..color = Palette.sack);
    canvas.drawPath(sack, Paint()
      ..color = Palette.sackDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    canvas.drawLine(sackAt + Offset(-w * 0.3, -w * 0.5), sackAt + Offset(w * 0.3, -w * 0.5), Paint()
      ..color = Palette.sackDark
      ..strokeWidth = 2);
    _write(canvas, '${play.level.load}', sackAt + Offset(0, w * 0.1),
        labels.copyWith(color: Palette.night, fontSize: w * 0.5, fontWeight: FontWeight.w800));
    // The weights.
    for (var i = 0; i < 4; i++) {
      final at = m.at(i);
      final barred = play.barred(i);
      final size = w * (0.55 + 0.15 * i);
      final body = Rect.fromCenter(center: at, width: size, height: size * 0.9);
      canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(size * 0.15)), Paint()..color = barred ? Palette.barred : Palette.brass);
      canvas.drawRRect(RRect.fromRectAndRadius(body, Radius.circular(size * 0.15)), Paint()
        ..color = barred ? Palette.line : Palette.brassDark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: at - Offset(0, size * 0.55), width: size * 0.4, height: size * 0.18), const Radius.circular(3)),
          Paint()..color = barred ? Palette.line : Palette.brassDark);
      _write(canvas, '${Rules.weights[i]}', at,
          labels.copyWith(color: barred ? Palette.inkDim : Palette.brassInk, fontSize: size * 0.42, fontWeight: FontWeight.w800));
      if (barred) {
        canvas.drawLine(at + Offset(-size * 0.4, -size * 0.4), at + Offset(size * 0.4, size * 0.4), Paint()
          ..color = Palette.tipped
          ..strokeWidth = 2);
      }
    }
    // The pointer.
    final aim = pointing;
    if (aim != null) {
      canvas.drawCircle(m.at(aim.$2), w * 0.8, Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
    // The reading.
    _write(canvas, play.tilt == 0 ? 'level' : play.tilt > 0 ? 'load side heavy by ${play.tilt}' : 'weights heavy by ${-play.tilt}',
        Offset(m.pivot.dx, m.pivot.dy - w * 1.5),
        labels.copyWith(color: play.tilt == 0 ? Palette.level : Palette.tipped, fontSize: 13, fontWeight: FontWeight.w700));
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(ScaleView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a load as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'With the 1 kept off, every weight on the scale is a multiple of three, '
        'so whatever pan each stands on, the weights across less the weights '
        'beside the load is a multiple of three: 27 placings, 27 amounts, all '
        'multiples of three, and ten is not one. With the 1 allowed every load '
        'to forty balances, this one as 9 and 1 across.$note';
  }
  return 'The sweep sets each of the four weights off, across, or beside the load, '
      '81 placings, and reads what each weighs against the load: 81 different '
      'amounts from -40 to 40, so every load to forty balances exactly one way. '
      'Counting in threes with the digits 1, 0 and -1 writes that one way down '
      'with no sweep, a digit for each weight, and it agrees with the sweep on '
      'every load. ${level.ways} of the ${level.placings} land it.$note';
}

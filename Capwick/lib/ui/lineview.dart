import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../line/play.dart';
import 'palette.dart';

/// Where the men stand and the two caps to call with lie, so the
/// screen and the tests can find them.
class Metrics {
  Metrics(this.play, Size room) {
    final n = play.n;
    gap = math.min(room.width * 0.86 / n, 92);
    left = (room.width - gap * (n - 1)) / 2;
    lineY = room.height * 0.42;
    manHeight = math.min(room.height * 0.34, gap * 1.6);
    black = Rect.fromCenter(center: Offset(room.width * 0.32, room.height * 0.86), width: room.width * 0.28, height: room.height * 0.16);
    white = Rect.fromCenter(center: Offset(room.width * 0.68, room.height * 0.86), width: room.width * 0.28, height: room.height * 0.16);
  }

  final Play play;

  late final double gap;
  late final double left;
  late final double lineY;
  late final double manHeight;
  late final Rect black;
  late final Rect white;

  /// Where man [i] stands, the back of the line at the left.
  Offset at(int i) => Offset(left + i * gap, lineY);

  Offset get blackAt => black.center;
  Offset get whiteAt => white.center;

  /// The call under a touch: true for the black cap, false for the
  /// white, null off both.
  bool? under(Offset touch) {
    if (black.contains(touch)) return true;
    if (white.contains(touch)) return false;
    return null;
  }
}

/// The line: the wall behind, the men in a row facing the front, the
/// caps ahead of the man calling shown and the rest hidden, every call
/// made shown right or wrong, and the two caps to call with.
class LineView extends CustomPainter {
  LineView({required this.play, this.pointing, required this.labels});

  final Play play;

  /// What the show-me points at, or null.
  final (String, int)? pointing;
  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size);
    final n = play.n;
    final caps = play.caps;
    final current = play.current;

    // The wall and the yard.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.62), Paint()..color = Palette.wall);
    for (var y = 0.0; y < size.height * 0.62; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), Paint()
        ..color = Palette.wallLine
        ..strokeWidth = 1);
    }
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38), Paint()..color = Palette.yard);
    _write(canvas, 'back', Offset(m.at(0).dx, size.height * 0.05), labels.copyWith(color: Palette.inkDim, fontSize: 11));
    _write(canvas, 'front', Offset(m.at(n - 1).dx, size.height * 0.05), labels.copyWith(color: Palette.inkDim, fontSize: 11));

    // The men.
    final h = m.manHeight;
    for (var i = 0; i < n; i++) {
      final at = m.at(i);
      final isCurrent = i == current && !play.allCalled;
      // Body.
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: at + Offset(0, h * 0.28), width: h * 0.42, height: h * 0.6), Radius.circular(h * 0.1)),
          Paint()..color = isCurrent ? Palette.man : Palette.manDark);
      // Head.
      canvas.drawCircle(at - Offset(0, h * 0.14), h * 0.17, Paint()..color = Palette.skin);
      // The cap: seen if ahead of the calling man, or already called;
      // hidden otherwise.
      final called = i < play.calls.length;
      final seen = called || i > current;
      final capRect = Rect.fromCenter(center: at - Offset(0, h * 0.28), width: h * 0.4, height: h * 0.2);
      if (seen) {
        final black = caps[i];
        canvas.drawArc(capRect.inflate(h * 0.02), math.pi, math.pi, true, Paint()..color = black ? Palette.capBlack : Palette.capWhite);
        canvas.drawRect(Rect.fromCenter(center: at - Offset(-h * 0.06, h * 0.28), width: h * 0.34, height: h * 0.05),
            Paint()..color = black ? Palette.capBlack : Palette.capWhite);
        canvas.drawArc(capRect.inflate(h * 0.02), math.pi, math.pi, true, Paint()
          ..color = Palette.capEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
      } else {
        canvas.drawArc(capRect.inflate(h * 0.02), math.pi, math.pi, true, Paint()..color = Palette.hidden);
        _write(canvas, '?', at - Offset(0, h * 0.34), labels.copyWith(color: Palette.ink, fontSize: h * 0.16, fontWeight: FontWeight.w800));
      }
      // The call, spoken, and its judgement.
      if (called) {
        final said = play.calls[i];
        final ok = play.right(i)!;
        final bubble = Rect.fromCenter(center: at + Offset(0, h * 0.72), width: h * 0.62, height: h * 0.2);
        canvas.drawRRect(RRect.fromRectAndRadius(bubble, Radius.circular(h * 0.06)), Paint()..color = ok ? Palette.right : Palette.wrong);
        _write(canvas, said ? 'black' : 'white', bubble.center,
            labels.copyWith(color: Palette.night, fontSize: h * 0.11, fontWeight: FontWeight.w800));
      }
      _write(canvas, '${i + 1}', at + Offset(0, h * 0.9), labels.copyWith(color: Palette.inkDim, fontSize: 11));
      if (isCurrent) {
        canvas.drawCircle(at + Offset(0, h * 0.28), h * 0.5, Paint()
          ..color = Palette.brass
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
    }
    // The line of sight: from the current man forward.
    if (!play.allCalled) {
      canvas.drawLine(m.at(current) + Offset(m.gap * 0.3, -h * 0.14), Offset(size.width * 0.98, m.lineY - h * 0.14), Paint()
        ..color = Palette.brass.withValues(alpha: 0.35)
        ..strokeWidth = 1.5);
    }

    // The two caps to call with.
    for (final (rect, black) in [(m.black, true), (m.white, false)]) {
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)), Paint()..color = Palette.board);
      final capRect = Rect.fromCenter(center: rect.center - Offset(0, rect.height * 0.05), width: rect.width * 0.5, height: rect.height * 0.5);
      canvas.drawArc(capRect, math.pi, math.pi, true, Paint()..color = black ? Palette.capBlack : Palette.capWhite);
      canvas.drawRect(Rect.fromCenter(center: rect.center + Offset(rect.width * 0.08, -rect.height * 0.05), width: rect.width * 0.5, height: rect.height * 0.08),
          Paint()..color = black ? Palette.capBlack : Palette.capWhite);
      canvas.drawArc(capRect, math.pi, math.pi, true, Paint()
        ..color = Palette.capEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
      _write(canvas, black ? 'black' : 'white', Offset(rect.center.dx, rect.bottom - rect.height * 0.18),
          labels.copyWith(color: Palette.inkDim, fontSize: 12));
    }
    final aim = pointing;
    if (aim != null) {
      canvas.drawRRect(RRect.fromRectAndRadius(aim.$1 == 'black' ? m.black : m.white, const Radius.circular(10)), Paint()
        ..color = Palette.shown
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(LineView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for a line as it stands.
String whyWords(Play play) {
  final level = play.level;
  final note = level.note == null ? '' : ' ${level.note}';
  if (!level.winnable) {
    return 'The man at the back speaks first and learns nothing of his own cap '
        'before he does: his call can depend only on the caps ahead of him, and '
        'for every way those fall his own cap can be either colour. So whatever '
        'plan he has, he is right on exactly half of the deals, and against a '
        'warden who caps him after he speaks he is right on none. The men after '
        'him can all be saved, but not he.$note';
  }
  return 'The plan is one word of parity: the man at the back calls black when '
      'the black caps ahead of him are odd in number, and white when even; every '
      'man after him counts the black caps he sees ahead and the black caps '
      'called behind him, and calls the colour that brings the whole line to '
      'the parity the first man told. Run down every one of the ${level.deals} '
      'deals it saves every man but the first, and the calls of every man are '
      'checked against his cap.$note';
}

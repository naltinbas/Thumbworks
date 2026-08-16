import 'dart:math';

import 'package:flutter/material.dart';

import '../kith/play.dart';
import '../kith/rules.dart';
import 'palette.dart';

/// Where the six people stand in a board of a given size: round a
/// ring, Ann at the top, and the friendships straight between them.
class Metrics {
  Metrics(this.play, this.size, {bool bare = false}) {
    final strip = bare || !roomy ? 0.0 : 26.0;
    final room = min(size.width, size.height - strip);
    radius = room / 2 - (bare ? room * 0.1 : 30);
    centre = Offset(size.width / 2, (size.height - strip) / 2);
  }

  final Play play;
  final Size size;
  late final double radius;
  late final Offset centre;

  /// Where person [v] stands.
  Offset at(int v) {
    final angle = -pi / 2 + v * 2 * pi / Rules.people;
    return centre + Offset(cos(angle), sin(angle)) * radius;
  }

  /// The person under a point, or null when none is near enough.
  int? under(Offset p) {
    for (var v = 0; v < Rules.people; v++) {
      if ((at(v) - p).distance <= max(22.0, radius * 0.22)) return v;
    }
    return null;
  }

  /// Whether there is room for words on the board.
  bool get roomy => size.height >= 220 && size.width >= 260;
}

/// The people, the friendships laid, everyone's count, the person held
/// and the pointer.
class KithView extends CustomPainter {
  const KithView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null: (a, b, lift).
  final (int, int, bool)? pointing;

  final TextStyle labels;

  /// Whether to draw the people and friendships only, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    final thick = bare ? m.radius * 0.05 : 2.5;
    // The friendships that could be, faint.
    if (!bare) {
      for (final (a, b) in Rules.pairs) {
        canvas.drawLine(m.at(a), m.at(b), Paint()..color = Palette.line..strokeWidth = 1);
      }
    }
    // The friendships laid.
    for (final (a, b) in Rules.pairsOf(play.plan)) {
      canvas.drawLine(m.at(a), m.at(b), Paint()..color = Palette.bond..strokeWidth = thick..strokeCap = StrokeCap.round);
    }
    // The pointer's friendship, dashed.
    final aim = pointing;
    if (aim != null && !bare && aim.$1 != aim.$2) {
      _dashed(canvas, m.at(aim.$1), m.at(aim.$2), Paint()..color = Palette.shown..strokeWidth = 2.5);
    }
    // The people, named, the held one ringed, the counts beside.
    final r = bare ? m.radius * 0.16 : max(12.0, min(18.0, m.radius * 0.14));
    final degrees = play.degrees;
    for (var v = 0; v < Rules.people; v++) {
      final at = m.at(v);
      canvas.drawCircle(at, r, Paint()..color = play.held == v ? Palette.held : Palette.person);
      canvas.drawCircle(at, r, Paint()..color = Palette.chalk..style = PaintingStyle.stroke..strokeWidth = bare ? thick * 0.8 : 1.5);
      _word(canvas, Rules.names[v][0], at, play.held == v ? Palette.night : Palette.ink, size, r * 1.1, bold: true);
      if (!bare) {
        final out = (at - m.centre) / (at - m.centre).distance;
        _word(canvas, '${Rules.names[v]} ${degrees[v]}', at + out * (r + 14), degrees[v] > 0 ? Palette.gold : Palette.inkDim, size, 11);
      }
      if (aim != null && !bare && (aim.$1 == v || aim.$2 == v)) {
        canvas.drawCircle(at, r + 6, Paint()..color = Palette.shown..style = PaintingStyle.stroke..strokeWidth = 2.5);
      }
    }
    if (bare || !m.roomy) return;
    final String words;
    final f = play.friendsAverage;
    if (f == null) {
      words = 'no friendships yet';
    } else {
      words = 'people average ${tellFrac(play.average)}, the friends named ${tellFrac(f)}: gap ${tellFrac(play.gap!)}';
    }
    _word(canvas, words, Offset(size.width / 2, size.height - 11), f != null ? Palette.gold : Palette.inkDim, size, 12);
  }

  void _dashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    final d = to - from;
    final length = d.distance;
    final unit = d / length;
    var run = 0.0;
    while (run < length) {
      final end = min(run + 6, length);
      canvas.drawLine(from + unit * run, from + unit * end, paint);
      run += 11;
    }
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size, double fontSize, {bool bold = false}) {
    final text = TextPainter(
      text: TextSpan(text: words, style: labels.copyWith(color: colour, fontSize: max(1.0, fontSize), fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2).clamp(2.0, max(2.0, size.width - text.width - 2)).toDouble();
    final y = (at.dy - text.height / 2).clamp(0.0, max(0.0, size.height - text.height)).toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(KithView old) => old.play != play || old.pointing != pointing || old.bare != bare;
}

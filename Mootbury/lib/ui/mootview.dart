import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../moot/play.dart';
import '../moot/rules.dart';
import 'palette.dart';

/// Where things lie on the board: a row for each hamlet, its quota as a
/// hollow bar of seats with the fraction hatched, its largest-remainder
/// share and its dealt share as filled benches, and to the right what
/// one more seat would give.
class Metrics {
  Metrics(this.play, Size room, {bool bare = false}) {
    width = room.width;
    height = room.height;
    rows = play.pops.length;
    top = room.height * (bare ? 0.06 : 0.1);
    rowHeight = math.min(room.height * (bare ? 0.9 : 0.8) / rows, room.height * (bare ? 0.32 : 0.26));
    labelWidth = room.width * (bare ? 0.04 : 0.14);
    left = labelWidth + room.width * 0.02;
    right = room.width * (bare ? 0.96 : 0.98);
    // A seat's width: the widest quota on the sham plus one fits; the
    // mark fits its own moot alone.
    final most = bare
        ? [...play.hamiltonNext, ...play.jeffersonNext, ...play.hamilton].reduce(math.max) + 0.5
        : play.pops.reduce(math.max) * (Rules.most + 1) / play.level.total + 1;
    unit = (right - left) / most;
  }

  final Play play;

  late final double width;
  late final double height;
  late final int rows;
  late final double top;
  late final double rowHeight;
  late final double labelWidth;
  late final double left;
  late final double right;
  late final double unit;

  /// The bar rectangle for hamlet [i]'s row [which]: 0 the quota, 1
  /// largest remainders, 2 dealt.
  Rect bar(int i, int which) {
    final rowTop = top + i * rowHeight;
    final h = rowHeight * 0.2;
    return Rect.fromLTWH(left, rowTop + rowHeight * (0.08 + which * 0.28), 0, h);
  }
}

/// The moot: each hamlet's quota, share by largest remainders and share
/// by dealing, as benches, and what the next seat does.
class MootView extends CustomPainter {
  MootView({required this.play, this.pointing, required this.labels, this.bare = false});

  final Play play;

  /// What the show-me points at, or null.
  final int? pointing;
  final TextStyle labels;

  /// Whether to draw the shares alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Palette.hall);
    final quotas = play.quotas, ham = play.hamilton, hamNext = play.hamiltonNext, jef = play.jefferson, jefNext = play.jeffersonNext;
    // Too short a board carries no words.
    final words = !bare && size.height >= 200;
    if (words) {
      _write(canvas, '${play.seats} seats, and what ${play.seats + 1} would give', Offset(size.width / 2, m.top * 0.5), labels.copyWith(color: Palette.ink, fontSize: 13, fontWeight: FontWeight.w800));
    }
    for (var i = 0; i < m.rows; i++) {
      final colour = Palette.hamlets[i % Palette.hamlets.length];
      final rowTop = m.top + i * m.rowHeight;
      if (words) {
        _write(canvas, play.level.hamlets[i], Offset(m.labelWidth * 0.5, rowTop + m.rowHeight * 0.3), labels.copyWith(color: colour, fontSize: 13, fontWeight: FontWeight.w800));
        _write(canvas, '${play.pops[i]}00', Offset(m.labelWidth * 0.5, rowTop + m.rowHeight * 0.55), labels.copyWith(color: Palette.inkDim, fontSize: 11));
      }
      final h = m.rowHeight * 0.2;
      // The quota: a hollow bar to the exact fraction.
      final q = quotas[i];
      final qTop = rowTop + m.rowHeight * 0.06;
      final qWidth = m.unit * q.$1 / q.$2;
      canvas.drawRect(Rect.fromLTWH(m.left, qTop, qWidth, h), Paint()..color = Palette.quota);
      canvas.drawRect(Rect.fromLTWH(m.left, qTop, qWidth, h), Paint()
        ..color = colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
      if (words) {
        _write(canvas, 'quota ${Rules.quotaWords(q)}', Offset(m.left + qWidth + 6, qTop + h / 2), labels.copyWith(color: Palette.inkDim, fontSize: 10), left: true);
      }
      // Largest remainders now, and next.
      _benches(canvas, m.left, rowTop + m.rowHeight * 0.36, m.unit, h, ham[i], colour, next: hamNext[i]);
      if (words) {
        _write(canvas, 'remainders ${ham[i]}${_next(ham[i], hamNext[i])}', Offset(m.left + m.unit * math.max(ham[i], hamNext[i]) + 6, rowTop + m.rowHeight * 0.36 + h / 2), labels.copyWith(color: hamNext[i] < ham[i] ? Palette.lost : Palette.ink, fontSize: 10), left: true);
      }
      // Dealt now, and next.
      _benches(canvas, m.left, rowTop + m.rowHeight * 0.66, m.unit, h, jef[i], colour, next: jefNext[i]);
      if (words) {
        _write(canvas, 'dealt ${jef[i]}${_next(jef[i], jefNext[i])}', Offset(m.left + m.unit * math.max(jef[i], jefNext[i]) + 6, rowTop + m.rowHeight * 0.66 + h / 2), labels.copyWith(color: Palette.ink, fontSize: 10), left: true);
      }
    }
  }

  String _next(int now, int then) => then == now ? '' : then > now ? ', then $then' : ', then $then, a seat lost';

  /// A row of [count] benches, each a unit wide, and the seat the next
  /// moot adds or takes drawn hollow green or crossed rust.
  void _benches(Canvas canvas, double left, double top, double unit, double h, int count, Color colour, {required int next}) {
    for (var s = 0; s < count; s++) {
      final r = Rect.fromLTWH(left + s * unit + 1, top, unit - 2, h);
      final lost = s >= next;
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), Paint()..color = lost ? Palette.lost : colour);
      if (lost) {
        canvas.drawLine(r.topLeft, r.bottomRight, Paint()
          ..color = Palette.night
          ..strokeWidth = 1.5);
        canvas.drawLine(r.topRight, r.bottomLeft, Paint()
          ..color = Palette.night
          ..strokeWidth = 1.5);
      }
    }
    for (var s = count; s < next; s++) {
      final r = Rect.fromLTWH(left + s * unit + 1, top, unit - 2, h);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)), Paint()
        ..color = Palette.gained
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
    }
  }

  void _write(Canvas canvas, String words, Offset at, TextStyle style, {bool left = false}) {
    final painter = TextPainter(text: TextSpan(text: words, style: style), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, left ? at - Offset(0, painter.height / 2) : at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(MootView old) => old.play != play || old.pointing != pointing;
}

/// The why, spoken for an ask as it stands.
String whyWords(Play play) {
  final level = play.level;
  const law = 'A moot of S seats is shared among the hamlets by population. Largest '
      'remainders, Hamilton\'s rule, give each hamlet its quota, its share of S, '
      'rounded down, and the seats left over one each to the hamlets whose quotas '
      'have the largest fractions; dealing, Jefferson\'s rule, gives the seats one '
      'at a time, each to the hamlet whose population per seat, counting the seat '
      'it would get, is largest, which is the same as one common divisor with every '
      'quotient rounded down. When the moot grows by a seat every quota grows, but '
      'the fractions shift, and a hamlet whose fraction was largest can find it '
      'smallest and lose the seat it had: the Alabama paradox, found in 1880 when '
      'the census clerks worked the House at every size. Dealing never does that, '
      'since a seat once dealt is never taken back. Every moot on the sham is '
      'shared both ways, and every moot to sixty on five sets of hamlets, the '
      'dealing held to the divisor reading and largest remainders held within the '
      'quota on every one.';
  return '$law ${level.note}';
}

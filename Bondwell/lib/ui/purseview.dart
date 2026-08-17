import 'dart:math';

import 'package:flutter/material.dart';

import '../bond/play.dart';
import '../bond/rules.dart';
import 'palette.dart';

/// Where the three purses and the scales between them sit in a board of
/// a given size: the purses stand at the corners of a triangle, each
/// scale hangs on the side between its two.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    final pad = bare ? 12.0 : 18.0;
    final across = size.width - 2 * pad;
    final down = size.height - 2 * pad;
    span = min(across, down * 1.05);
    purse = max(10.0, min(span * 0.14, bare ? 90.0 : 44.0));
    middle = Offset(size.width / 2, size.height / 2);
  }

  final Size size;
  final bool bare;

  /// How wide the triangle of purses stands.
  late final double span;

  /// How big a purse is drawn.
  late final double purse;

  late final Offset middle;

  /// Where purse [i] stands: A low left, B low right, C at the top.
  Offset at(int i) {
    final wide = span * 0.36, tall = span * 0.30;
    switch (i) {
      case 0:
        return middle + Offset(-wide, tall);
      case 1:
        return middle + Offset(wide, tall);
      default:
        return middle + Offset(0, -tall);
    }
  }

  /// Where the scale between [i] and [j] hangs.
  Offset scaleAt(int i, int j) => (at(i) + at(j)) / 2;

  /// Which purse lies under [where], or null when none does.
  int? under(Offset where) {
    for (var i = 0; i < Rules.heirs; i++) {
      if ((at(i) - where).distance <= purse * 1.15) return i;
    }
    return null;
  }

  /// Whether there is room for the words that go with the purses.
  bool get roomy => purse >= 22 && (bare || size.height >= 300);
}

/// The chest, the three purses and the scale hanging between each pair.
class PurseView extends CustomPainter {
  const PurseView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the purses and scales alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);

    // The threads from each purse to the scale that weighs it against
    // its neighbour, so it is plain which scale belongs to which pair.
    for (final pair in [(0, 1), (1, 2), (2, 0)]) {
      final (i, j) = pair;
      canvas.drawLine(
        m.at(i),
        m.at(j),
        Paint()
          ..color = Palette.line
          ..strokeWidth = max(1.0, m.purse * 0.04),
      );
    }

    // The scales, one to each pair, drawn behind the purses.
    for (final pair in [(0, 1), (1, 2), (2, 0)]) {
      final (i, j) = pair;
      final tilt = Rules.tilt(play.purses, i, j);
      final level = tilt == 0;
      final at = m.scaleAt(i, j);
      final arm = m.purse * 0.9;
      final lean = (tilt.clamp(-6, 6)) / 6 * 0.42;
      final along = Offset(cos(lean), sin(lean));
      final left = at - along * arm, right = at + along * arm;
      canvas.drawLine(
        at,
        at + Offset(0, m.purse * 0.5),
        Paint()
          ..color = Palette.line
          ..strokeWidth = max(1.2, m.purse * 0.07),
      );
      canvas.drawLine(
        left,
        right,
        Paint()
          ..color = level ? Palette.gold : Palette.beam
          ..strokeWidth = max(1.6, m.purse * 0.12)
          ..strokeCap = StrokeCap.round,
      );
      for (final end in [left, right]) {
        canvas.drawCircle(
          end,
          m.purse * 0.13,
          Paint()..color = level ? Palette.gold : Palette.beam,
        );
      }
      canvas.drawCircle(at, m.purse * 0.09, Paint()..color = Palette.line);
    }

    // The purses.
    for (var i = 0; i < Rules.heirs; i++) {
      final at = m.at(i);
      final lit = pointing != null && pointing!.$1 == i;
      final body = Rect.fromCenter(
        center: at,
        width: m.purse * 1.7,
        height: m.purse * 1.5,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          body,
          topLeft: Radius.circular(m.purse * 0.35),
          topRight: Radius.circular(m.purse * 0.35),
          bottomLeft: Radius.circular(m.purse * 0.7),
          bottomRight: Radius.circular(m.purse * 0.7),
        ),
        Paint()..color = lit ? Palette.leatherLit : Palette.leather,
      );
      // The tie at the neck.
      canvas.drawLine(
        Offset(body.left + m.purse * 0.2, body.top + m.purse * 0.28),
        Offset(body.right - m.purse * 0.2, body.top + m.purse * 0.28),
        Paint()
          ..color = Palette.night
          ..strokeWidth = max(1.2, m.purse * 0.08),
      );
      if (lit) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            body.inflate(m.purse * 0.16),
            Radius.circular(m.purse * 0.5),
          ),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1.6, m.purse * 0.1),
        );
      }
      _word(
        canvas,
        '${play.purses[i]}',
        at + Offset(0, m.purse * 0.12),
        m.purse * 0.62,
        Palette.coin,
        bold: true,
      );
      if (m.roomy) {
        _word(
          canvas,
          '${Rules.names[i]}, bond ${Rules.bonds[i]}',
          at + Offset(0, -m.purse * 1.05),
          12,
          Palette.inkDim,
        );
      }
    }

    if (bare || !m.roomy) return;
    _word(
      canvas,
      play.chest == 0
          ? 'the chest is empty'
          : '${play.chest} coin${play.chest == 1 ? '' : 's'} left in the chest',
      Offset(size.width / 2, m.at(0).dy + m.purse * 1.4),
      13,
      play.chest == 0 ? Palette.gold : Palette.ink,
    );
  }

  void _word(
    Canvas canvas,
    String words,
    Offset at,
    double size,
    Color colour, {
    bool bold = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(
          color: colour,
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(PurseView old) =>
      old.play != play || old.pointing != pointing;
}

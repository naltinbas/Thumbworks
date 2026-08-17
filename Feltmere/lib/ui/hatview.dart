import 'dart:math';

import 'package:flutter/material.dart';

import '../hat/play.dart';
import '../hat/rules.dart';
import 'palette.dart';

/// Where the agreement grid and the eight hattings sit in a board of a
/// given size: the grid on top, a villager to a row and a sight to a
/// column, the hattings in a row underneath.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    final pad = bare ? 8.0 : 12.0;
    final names = bare ? 0.0 : 52.0;
    cell = min(
      (size.width - 2 * pad - names) / Rules.sights.length,
      bare ? 62.0 : 58.0,
    );
    left = pad + names;
    top = pad + (bare ? 10 : 22);
    hattingTop = top + cell * Rules.villagers + (bare ? 10 : 30);
    hatting = min((size.width - 2 * pad) / 8, 40.0);
    hattingLeft = (size.width - hatting * 8) / 2;
  }

  final Size size;
  final bool bare;

  /// How big a cell of the agreement grid is.
  late final double cell;
  late final double left;
  late final double top;

  /// Where the eight hattings are drawn, and how wide each is.
  late final double hattingTop;
  late final double hatting;
  late final double hattingLeft;

  Rect cellAt(int who, int sight) => Rect.fromLTWH(
        left + sight * cell,
        top + who * cell,
        cell - 4,
        cell - 4,
      );

  Rect hattingAt(int which) => Rect.fromLTWH(
        hattingLeft + which * hatting,
        hattingTop,
        hatting - 3,
        hatting * 1.7,
      );

  /// Which cell lies under [where], or null when none does.
  (int, int)? under(Offset where) {
    for (var who = 0; who < Rules.villagers; who++) {
      for (var sight = 0; sight < Rules.sights.length; sight++) {
        if (cellAt(who, sight).contains(where)) return (who, sight);
      }
    }
    return null;
  }

  bool get roomy => cell >= 40;
}

/// The agreement, a cell to each villager and sight, and the eight
/// hattings under it with what the village does on each.
class HatView extends CustomPainter {
  const HatView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The cell the show-me points at, or null.
  final (int, int)? pointing;

  final TextStyle labels;

  /// Whether to draw the grid alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);

    // The sights along the top.
    if (!bare) {
      for (var sight = 0; sight < Rules.sights.length; sight++) {
        final box = m.cellAt(0, sight);
        final seen = Rules.sights[sight];
        final wide = min(m.cell * 0.22, 12.0);
        for (var i = 0; i < 2; i++) {
          _hat(
            canvas,
            Offset(box.center.dx + (i == 0 ? -wide * 1.1 : wide * 1.1),
                m.top - 12),
            wide,
            seen[i] == Rules.black,
          );
        }
      }
    }

    for (var who = 0; who < Rules.villagers; who++) {
      if (!bare) {
        _word(
          canvas,
          Rules.tellVillager(who),
          Offset(m.left - 28, m.cellAt(who, 0).center.dy),
          12,
          Palette.inkDim,
        );
      }
      for (var sight = 0; sight < Rules.sights.length; sight++) {
        final box = m.cellAt(who, sight);
        final say = play.agreement[who][sight];
        final lit = pointing != null &&
            pointing!.$1 == who &&
            pointing!.$2 == sight;
        canvas.drawRRect(
          RRect.fromRectAndRadius(box, Radius.circular(m.cell * 0.16)),
          Paint()..color = Palette.cell,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(box, Radius.circular(m.cell * 0.16)),
          Paint()
            ..color = lit ? Palette.shown : Palette.line
            ..style = PaintingStyle.stroke
            ..strokeWidth = lit ? 2.4 : 1.2,
        );
        if (say == Rules.quiet) {
          canvas.drawLine(
            Offset(box.center.dx - m.cell * 0.16, box.center.dy),
            Offset(box.center.dx + m.cell * 0.16, box.center.dy),
            Paint()
              ..color = Palette.line
              ..strokeWidth = max(2.0, m.cell * 0.06),
          );
        } else {
          _hat(canvas, box.center, m.cell * 0.26, say == Rules.black);
        }
      }
    }

    if (bare) return;

    // The eight hattings, and what the village does on each.
    for (var which = 0; which < Rules.hattings.length; which++) {
      final hats = Rules.hattings[which];
      final box = m.hattingAt(which);
      final won = Rules.winsOn(play.agreement, hats);
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(6)),
        Paint()..color = won ? Palette.goldFill : Palette.cell,
      );
      for (var who = 0; who < Rules.villagers; who++) {
        _hat(
          canvas,
          Offset(box.center.dx, box.top + m.hatting * (0.3 + who * 0.42)),
          m.hatting * 0.17,
          hats[who] == Rules.black,
        );
      }
      _word(
        canvas,
        won ? 'won' : 'lost',
        Offset(box.center.dx, box.bottom - 8),
        9,
        won ? Palette.gold : Palette.inkDim,
      );
    }
    _word(
      canvas,
      'the eight hattings',
      Offset(size.width / 2, m.hattingTop - 10),
      11,
      Palette.inkDim,
    );
  }

  /// A hat: a crown and a brim.
  void _hat(Canvas canvas, Offset at, double wide, bool black) {
    final colour = black ? Palette.blackHat : Palette.whiteHat;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: at.translate(0, -wide * 0.28),
          width: wide * 1.2,
          height: wide * 1.1,
        ),
        Radius.circular(wide * 0.3),
      ),
      Paint()..color = colour,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: at.translate(0, wide * 0.34),
          width: wide * 2,
          height: wide * 0.36,
        ),
        Radius.circular(wide * 0.18),
      ),
      Paint()..color = colour,
    );
    if (black) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: at.translate(0, wide * 0.34),
            width: wide * 2,
            height: wide * 0.36,
          ),
          Radius.circular(wide * 0.18),
        ),
        Paint()
          ..color = Palette.brim
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }
  }

  void _word(
    Canvas canvas,
    String words,
    Offset at,
    double size,
    Color colour,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: words,
        style: labels.copyWith(color: colour, fontSize: size),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, at - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(HatView old) =>
      old.play != play || old.pointing != pointing;
}

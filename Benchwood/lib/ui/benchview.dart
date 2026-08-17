import 'dart:math';

import 'package:flutter/material.dart';

import '../bench/play.dart';
import '../bench/rules.dart';
import 'palette.dart';

/// Where the job card and the bench sit in a board of a given size: the
/// card runs across the top, the bench slots stand in a row below it.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final pad = bare ? 8.0 : 14.0;
    call = min((size.width - 2 * pad) / play.card.length, 34.0);
    cardLeft = (size.width - call * play.card.length) / 2;
    cardTop = bare ? pad : pad + 14;
    slot = min(
      (size.width - 2 * pad) / play.level.slots * 0.7,
      bare ? 64.0 : 56.0,
    );
    benchTop = cardTop + call + (bare ? 26 : 44);
    benchLeft = (size.width -
            slot * play.level.slots -
            10 * (play.level.slots - 1)) /
        2;
  }

  final Play play;
  final Size size;
  final bool bare;

  /// How wide one call of the card is drawn.
  late final double call;
  late final double cardLeft;
  late final double cardTop;

  /// How wide a bench slot is drawn.
  late final double slot;
  late final double benchLeft;
  late final double benchTop;

  Rect callAt(int i) =>
      Rect.fromLTWH(cardLeft + i * call, cardTop, call - 2, call);

  Rect slotAt(int i) =>
      Rect.fromLTWH(benchLeft + i * (slot + 10), benchTop, slot, slot);

  /// Which bench slot lies under [where], or null when none does.
  int? under(Offset where) {
    for (var i = 0; i < play.bench.length; i++) {
      if (slotAt(i).inflate(6).contains(where)) return i;
    }
    return null;
  }

  bool get roomy => slot >= 34;
}

/// The job card, the bench and what each tool on it is next called for.
class BenchView extends CustomPainter {
  const BenchView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The bench slot the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the card and the bench alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);

    // The job card.
    for (var i = 0; i < play.card.length; i++) {
      final box = m.callAt(i);
      final passed = i < play.at;
      final now = i == play.at;
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(m.call * 0.2)),
        Paint()..color = now ? Palette.gold : Palette.slot,
      );
      _word(
        canvas,
        Rules.tellTool(play.card[i]),
        box.center,
        m.call * 0.52,
        now
            ? Palette.night
            : passed
                ? Palette.done
                : Palette.ink,
        bold: now,
      );
    }
    if (!bare) {
      _word(
        canvas,
        'the job card',
        Offset(size.width / 2, m.cardTop - 9),
        11,
        Palette.inkDim,
      );
    }

    // The bench.
    final benchRect = Rect.fromLTWH(
      m.benchLeft - 10,
      m.benchTop - 8,
      (m.slot + 10) * play.level.slots,
      m.slot + 16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(benchRect, Radius.circular(10)),
      Paint()..color = Palette.oak,
    );
    for (var i = 0; i < play.level.slots; i++) {
      final box = m.slotAt(i);
      final held = i < play.bench.length;
      final lit = i == pointing;
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(m.slot * 0.16)),
        Paint()..color = held ? Palette.slot : Palette.night,
      );
      if (lit) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            box.inflate(4),
            Radius.circular(m.slot * 0.2),
          ),
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
      if (!held) continue;
      _word(
        canvas,
        Rules.tellTool(play.bench[i]),
        box.center.translate(0, -m.slot * 0.08),
        m.slot * 0.46,
        Palette.steel,
        bold: true,
      );
      if (m.roomy) {
        final when = play.nextCall(i);
        _word(
          canvas,
          when >= play.card.length ? 'not again' : 'next at ${when + 1}',
          box.center.translate(0, m.slot * 0.32),
          10,
          when >= play.card.length ? Palette.gold : Palette.inkDim,
        );
      }
    }
    if (bare) return;
    _word(
      canvas,
      play.finished
          ? 'the card is worked out'
          : play.waiting
              ? 'the bench is full: carry one back'
              : 'call ${play.at + 1} of ${play.card.length}',
      Offset(size.width / 2, benchRect.bottom + 14),
      12,
      play.waiting ? Palette.gold : Palette.inkDim,
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
  bool shouldRepaint(BenchView old) =>
      old.play != play || old.pointing != pointing;
}

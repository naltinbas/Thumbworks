import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../rack/play.dart';
import 'palette.dart';

/// Where every jar stands, shared by the painter and the
/// hit-testing, so what is drawn is exactly what is tapped.
class Metrics {
  Metrics(this.play, Size room) {
    columns = play.pantry.top;
    rows = play.pantry.racks + 1;
    slot = math.min(
      room.width * 0.92 / columns,
      room.height * 0.84 / rows,
    );
    left = (room.width - slot * columns) / 2;
    top = (room.height - slot * rows) / 2;
  }

  final Play play;

  late final int columns;
  late final int rows;
  late final double slot;
  late final double left;
  late final double top;

  /// A rack's row from the top: rack k highest, the tray last.
  double rowOf(int rack) => top + (play.pantry.racks - rack) * slot;

  /// The middle of a jar, in its column on its rack.
  Offset jarAt(int jar) => Offset(
        left + (jar + 0.5) * slot,
        rowOf(play.racking[jar]) + slot * 0.5,
      );

  /// The jar under a touch, or -1 for the larder: any touch in
  /// a jar's column within its standing row.
  int jarUnder(Offset touch) {
    for (var jar = 0; jar < columns; jar++) {
      if ((jarAt(jar) - touch).distance <= slot * 0.48) {
        return jar;
      }
    }
    return -1;
  }
}

/// The pantry, drawn: rack planks, the tray, and every jar on
/// whatever rack it stands.
class RackView extends CustomPainter {
  RackView({
    required this.play,
    this.pointing,
    required this.labels,
  });

  final Play play;

  /// The jar the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = Metrics(play, size);
    final slot = metrics.slot;

    // The planks, rack by rack, and the tray line.
    for (var rack = 0; rack <= play.pantry.racks; rack++) {
      final y = metrics.rowOf(rack) + slot * 0.92;
      canvas.drawLine(
        Offset(metrics.left, y),
        Offset(metrics.left + metrics.columns * slot, y),
        Paint()
          ..color = rack == 0 ? Palette.line : Palette.plank
          ..strokeWidth = rack == 0 ? 2.0 : 4.0
          ..strokeCap = StrokeCap.round,
      );
      final word = TextPainter(
        text: TextSpan(
          text: rack == 0 ? 'tray' : 'rack $rack',
          style: labels.copyWith(
            color: Palette.inkDim,
            fontSize: slot * 0.24,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      word.paint(
          canvas, Offset(metrics.left, y - slot * 0.02));
    }

    // The quarrels, linked rust along their shared rack.
    for (final (one, two) in play.quarrels) {
      canvas.drawLine(
        metrics.jarAt(one),
        metrics.jarAt(two),
        Paint()
          ..color = Palette.quarrel
          ..strokeWidth = 2.6,
      );
    }

    final sore = <int>{};
    for (final (one, two) in play.quarrels) {
      sore.addAll([one, two]);
    }

    // The jars.
    for (var jar = 0; jar < metrics.columns; jar++) {
      final at = metrics.jarAt(jar);
      final body = Rect.fromCenter(
        center: at + Offset(0, slot * 0.06),
        width: slot * 0.68,
        height: slot * 0.62,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(body, Radius.circular(slot * 0.12)),
        Paint()..color = Palette.jar,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: at + Offset(0, -slot * 0.28),
            width: slot * 0.5,
            height: slot * 0.14,
          ),
          Radius.circular(slot * 0.05),
        ),
        Paint()..color = Palette.jarLid,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: at + Offset(0, slot * 0.08),
            width: slot * 0.5,
            height: slot * 0.34,
          ),
          Radius.circular(slot * 0.06),
        ),
        Paint()..color = Palette.label,
      );
      final rim = sore.contains(jar)
          ? Palette.quarrel
          : play.isDone
              ? Palette.landed
              : null;
      if (rim != null) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              body.inflate(slot * 0.07), Radius.circular(slot * 0.14)),
          Paint()
            ..color = rim
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6,
        );
      }
      final number = TextPainter(
        text: TextSpan(
          text: '${play.rules.jars[jar]}',
          style: labels.copyWith(
            color: Palette.night,
            fontSize: slot * 0.3,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      number.paint(
          canvas,
          at +
              Offset(-number.width / 2,
                  slot * 0.08 - number.height / 2));

      if (pointing == jar) {
        canvas.drawCircle(
          at,
          slot * 0.52,
          Paint()
            ..color = Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8,
        );
      }
    }
  }

  @override
  bool shouldRepaint(RackView old) =>
      old.play != play || old.pointing != pointing;
}

/// A count with its thousands comma, for counts that earn one.
String withComma(int count) {
  if (count < 1000) return '$count';
  return '${count ~/ 1000},'
      '${(count % 1000).toString().padLeft(3, '0')}';
}

/// The words the why speaks, from the pantry at hand.
String whyWords(Play play) {
  final pantry = play.pantry;
  final note = pantry.note == null ? '' : ' ${pantry.note}';
  if (!pantry.winnable) {
    return 'One, two, four and eight each divide the next: a '
        'chain of four jars, and no two jars of a chain can share '
        'a rack, each dividing the one above it. The chain wants '
        'four racks and the pantry offers three. The sweep tried '
        'all ${withComma(531441)} rackings of the dozen on three '
        'and found not one clean.$note';
  }
  return 'The racks are counted two ways that share nothing: the '
      'quarrel census reads every rack pair by pair, and Mirsky\'s '
      'height racking builds a landing with no searching, every '
      'jar on the rack of its longest chain. The sweep walks all '
      '${withComma(pantry.ways)} clean rackings, and one rack '
      'fewer lands none at all.$note';
}

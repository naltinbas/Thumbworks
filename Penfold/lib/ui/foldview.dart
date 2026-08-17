import 'dart:math';

import 'package:flutter/material.dart';

import '../fold/play.dart';
import '../fold/rules.dart';
import 'palette.dart';

/// Where the four fields sit in a board of a given size: in a row, with
/// the left whistle's arrows arching over them and the right whistle's
/// arching under.
class Metrics {
  Metrics(this.size, {this.bare = false}) {
    // The pad has to shrink on a launcher icon of a few dozen pixels,
    // or the fields come out with no room at all.
    final pad = min(bare ? 10.0 : 16.0, size.width * 0.06);
    step = (size.width - 2 * pad) / Rules.fields;
    pen = max(1.0, min(step * 0.62, size.height * (bare ? 0.30 : 0.22)));
    left = pad + step / 2;
    middle = size.height / 2;
  }

  final Size size;
  final bool bare;

  /// How far apart the fields stand.
  late final double step;

  /// How big a field is drawn.
  late final double pen;

  late final double left;
  late final double middle;

  Offset at(int field) => Offset(left + field * step, middle);

  /// Which field lies under [where], or null when none does.
  int? under(Offset where) {
    for (var field = 0; field < Rules.fields; field++) {
      if ((at(field) - where).distance <= pen * 0.9) return field;
    }
    return null;
  }

  bool get roomy => pen >= 26;
}

/// The four fields, the sheep standing in them and the two whistles
/// drawn as arrows.
class FoldView extends CustomPainter {
  const FoldView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// The whistle the show-me points at, or null.
  final int? pointing;

  final TextStyle labels;

  /// Whether to draw the fields and the arrows alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(size, bare: bare);
    final standing = Rules.standing(play.flock);

    // The whistles: the left arching over, the right arching under.
    for (var whistle = 0; whistle < Rules.whistles.length; whistle++) {
      final up = whistle == 0;
      final colour = up ? Palette.left : Palette.right;
      final lit = whistle == pointing;
      final paint = Paint()
        ..color = lit ? Palette.shown : colour
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.6, m.pen * (lit ? 0.14 : 0.09));
      for (var field = 0; field < Rules.fields; field++) {
        final to = play.whistles[whistle][field];
        final from = m.at(field), landing = m.at(to);
        if (from == landing) {
          // A field that stays where it is: a loop over the pen.
          final centre = from + Offset(0, up ? -m.pen * 1.05 : m.pen * 1.05);
          canvas.drawCircle(centre, m.pen * 0.28, paint);
          _head(canvas, centre + Offset(m.pen * 0.28, 0),
              up ? const Offset(0, 1) : const Offset(0, -1), m.pen * 0.22, lit ? Palette.shown : colour);
          continue;
        }
        final rise = m.pen * (1.0 + (landing.dx - from.dx).abs() / m.step * 0.35);
        final lift = up ? -rise : rise;
        final path = Path()
          ..moveTo(from.dx, from.dy + (up ? -m.pen * 0.6 : m.pen * 0.6))
          ..quadraticBezierTo(
            (from.dx + landing.dx) / 2,
            from.dy + lift * 1.6,
            landing.dx,
            landing.dy + (up ? -m.pen * 0.6 : m.pen * 0.6),
          );
        canvas.drawPath(path, paint);
        final into = landing.dx > from.dx
            ? const Offset(1, 0)
            : const Offset(-1, 0);
        _head(
          canvas,
          Offset(landing.dx, landing.dy + (up ? -m.pen * 0.62 : m.pen * 0.62)),
          up ? into + const Offset(0, 1) : into + const Offset(0, -1),
          m.pen * 0.24,
          lit ? Palette.shown : colour,
        );
      }
    }

    // The fields, and the sheep standing in them.
    for (var field = 0; field < Rules.fields; field++) {
      final at = m.at(field);
      final holds = standing.contains(field);
      final box = Rect.fromCenter(
        center: at,
        width: m.pen * 1.5,
        height: m.pen * 1.2,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(m.pen * 0.25)),
        Paint()..color = holds ? Palette.grass : Palette.pen,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(m.pen * 0.25)),
        Paint()
          ..color = holds && standing.length == 1 ? Palette.gold : Palette.line
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.2, m.pen * 0.06),
      );
      if (holds) {
        _sheep(canvas, at, m.pen * 0.34);
      }
      if (m.roomy) {
        // Inside the pen, where the whistles' arcs cannot cross it.
        _word(
          canvas,
          Rules.tellField(field),
          Offset(box.left + m.pen * 0.22, box.top + m.pen * 0.22),
          12,
          Palette.inkDim,
        );
      }
    }
  }

  /// A sheep: a woolly body and a dark head.
  void _sheep(Canvas canvas, Offset at, double wide) {
    final body = Paint()..color = Palette.sheep;
    canvas.drawCircle(at, wide, body);
    canvas.drawCircle(at + Offset(-wide * 0.7, -wide * 0.15), wide * 0.6, body);
    canvas.drawCircle(at + Offset(wide * 0.72, -wide * 0.3), wide * 0.42,
        Paint()..color = Palette.night);
  }

  void _head(Canvas canvas, Offset at, Offset way, double size, Color colour) {
    final unit = way / way.distance;
    final side = Offset(-unit.dy, unit.dx);
    canvas.drawPath(
      Path()
        ..moveTo(at.dx + unit.dx * size, at.dy + unit.dy * size)
        ..lineTo(at.dx + side.dx * size * 0.55, at.dy + side.dy * size * 0.55)
        ..lineTo(at.dx - side.dx * size * 0.55, at.dy - side.dy * size * 0.55)
        ..close(),
      Paint()..color = colour,
    );
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
  bool shouldRepaint(FoldView old) =>
      old.play != play || old.pointing != pointing;
}

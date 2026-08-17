import 'dart:math';

import 'package:flutter/material.dart';

import '../rick/play.dart';
import '../rick/root3.dart';
import '../rick/rules.dart';
import 'palette.dart';

/// Where the green sits in a board of a given size. The ricks reach
/// outside the pegs, so the drawing is scaled to hold them too.
class Metrics {
  Metrics(this.play, this.size, {this.bare = false}) {
    final words = bare ? 0.0 : 26.0;
    // The ricks and their markers can stand well outside the green, so
    // the board is scaled to whatever the drawing actually reaches.
    var lowX = 0.0, highX = (Rules.pegs - 1).toDouble();
    var lowY = 0.0, highY = (Rules.pegs - 1).toDouble();
    for (final at in [...play.markers, ...play.rickCorners]) {
      lowX = min(lowX, at.$1.toDouble);
      highX = max(highX, at.$1.toDouble);
      lowY = min(lowY, at.$2.toDouble);
      highY = max(highY, at.$2.toDouble);
    }
    final pad = bare ? 0.7 : 0.5;
    lowX -= pad;
    highX += pad;
    lowY -= pad;
    highY += pad;
    final room = Size(size.width - 12, size.height - words - 12);
    step = min(room.width / (highX - lowX), room.height / (highY - lowY));
    left = 6 + (room.width - (highX - lowX) * step) / 2 - lowX * step;
    top = 6 + (room.height - (highY - lowY) * step) / 2 + highY * step;
    dot = min(step * 0.11, bare ? 9.0 : 6.0);
  }

  final Play play;
  final Size size;

  /// Whether this is the mark rather than a board.
  final bool bare;

  late final double step, left, top, dot;

  /// Whether there is room for words on the board.
  bool get roomy => !bare && size.height >= 170 && size.width >= 240;

  Offset at(num x, num y) =>
      Offset(left + x * step, top - y * step);

  Offset atRoot((Root3, Root3) p) => at(p.$1.toDouble, p.$2.toDouble);

  Offset peg((int, int) p) => at(p.$1, p.$2);

  /// The peg a tap means, or null when it lands nowhere near one.
  (int, int)? pegNear(Offset where) {
    (int, int)? best;
    var away = step * 0.5;
    for (var x = 0; x < Rules.pegs; x++) {
      for (var y = 0; y < Rules.pegs; y++) {
        final d = (peg((x, y)) - where).distance;
        if (d < away) {
          away = d;
          best = (x, y);
        }
      }
    }
    return best;
  }
}

/// The green, the field, the three ricks and the ring of markers.
class RickView extends CustomPainter {
  const RickView({
    required this.play,
    this.pointing,
    required this.labels,
    this.bare = false,
  });

  final Play play;

  /// What the show-me points at, or null.
  final (int, (int, int))? pointing;

  final TextStyle labels;

  /// Whether to draw the field alone, for the mark.
  final bool bare;

  @override
  void paint(Canvas canvas, Size size) {
    final m = Metrics(play, size, bare: bare);
    if (!bare) {
      for (var x = 0; x < Rules.pegs; x++) {
        for (var y = 0; y < Rules.pegs; y++) {
          canvas.drawCircle(
              m.peg((x, y)), m.dot * 0.6, Paint()..color = Palette.peg);
        }
      }
    }
    // The three ricks, raised outward.
    final corners = play.rickCorners;
    for (var i = 0; i < 3; i++) {
      final p = play.posts[i], q = play.posts[(i + 1) % 3];
      final path = Path()
        ..moveTo(m.peg(p).dx, m.peg(p).dy)
        ..lineTo(m.peg(q).dx, m.peg(q).dy)
        ..lineTo(m.atRoot(corners[i]).dx, m.atRoot(corners[i]).dy)
        ..close();
      canvas.drawPath(
          path, Paint()..color = Palette.straw.withValues(alpha: 0.22));
      canvas.drawPath(
        path,
        Paint()
          ..color = Palette.straw
          ..style = PaintingStyle.stroke
          ..strokeWidth = bare ? 2.5 : 1.2,
      );
    }
    // The field itself.
    final field = Path()..moveTo(m.peg(play.posts[0]).dx, m.peg(play.posts[0]).dy);
    for (var i = 1; i < 3; i++) {
      field.lineTo(m.peg(play.posts[i]).dx, m.peg(play.posts[i]).dy);
    }
    field.close();
    canvas.drawPath(
        field, Paint()..color = Palette.field.withValues(alpha: 0.28));
    canvas.drawPath(
      field,
      Paint()
        ..color = Palette.field
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 4 : 2.2,
    );
    // The ring of markers.
    final markers = play.markers;
    final ring = Path()..moveTo(m.atRoot(markers[0]).dx, m.atRoot(markers[0]).dy);
    for (var i = 1; i < 3; i++) {
      ring.lineTo(m.atRoot(markers[i]).dx, m.atRoot(markers[i]).dy);
    }
    ring.close();
    canvas.drawPath(
      ring,
      Paint()
        ..color = Palette.marker
        ..style = PaintingStyle.stroke
        ..strokeWidth = bare ? 4 : 2.4,
    );
    for (final marker in markers) {
      canvas.drawCircle(
          m.atRoot(marker), m.dot * 1.1, Paint()..color = Palette.marker);
    }
    // The posts.
    for (var i = 0; i < 3; i++) {
      final lifted = play.lifted == i;
      final wanted = pointing != null &&
          (play.lifted == null ? pointing!.$1 == i : false);
      canvas.drawCircle(m.peg(play.posts[i]), m.dot * 1.5,
          Paint()..color = lifted ? Palette.ring : Palette.ink);
      if (!bare && (lifted || wanted)) {
        canvas.drawCircle(
          m.peg(play.posts[i]),
          m.dot * 2.4,
          Paint()
            ..color = lifted ? Palette.ring : Palette.shown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
    if (!bare && pointing != null && play.lifted == pointing!.$1) {
      canvas.drawCircle(
        m.peg(pointing!.$2),
        m.dot * 2.4,
        Paint()
          ..color = Palette.shown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (bare || !m.roomy) return;
    _word(
        canvas,
        play.lifted == null
            ? 'the red ring joins the middles of the three ricks'
            : 'stand the post on a peg',
        Offset(size.width / 2, size.height - 8),
        Palette.inkDim,
        size,
        10);
  }

  void _word(Canvas canvas, String words, Offset at, Color colour, Size size,
      double points) {
    final text = TextPainter(
      text: TextSpan(
          text: words, style: labels.copyWith(color: colour, fontSize: points)),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - text.width / 2)
        .clamp(2.0, max(2.0, size.width - text.width - 2))
        .toDouble();
    final y = (at.dy - text.height / 2)
        .clamp(0.0, max(0.0, size.height - text.height))
        .toDouble();
    text.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(RickView old) =>
      old.play != play || old.pointing != pointing || old.bare != bare;
}

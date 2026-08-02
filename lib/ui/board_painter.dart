import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../game/board.dart';
import 'grid_geometry.dart';
import 'palette.dart';
import 'tracer.dart';

/// Draws the board and the trace being dragged across it.
///
/// Everything that moves comes in as a listenable, so a thumb moving repaints
/// this and rebuilds nothing: no widget in the tree changes between the finger
/// going down and coming up.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.live,
    required this.settle,
    required this.letters,
  }) : super(repaint: Listenable.merge([live, settle]));

  final Board board;
  final ValueListenable<Trace> live;

  /// The face the letters are cut from. It comes from the app rather than
  /// being named here, because a painter that picks its own font draws boxes
  /// in any test that has not loaded that one.
  final TextStyle letters;

  /// Runs from zero to one as a lifted trace is shown one last time and goes.
  final Animation<double> settle;

  /// Laid out glyphs, which is the expensive half of drawing a letter and does
  /// not change while a thumb moves. Thrown away wholesale when it grows,
  /// because the colours it is keyed on slide during the settle and there is
  /// no point keeping every step of that.
  final Map<String, TextPainter> _glyphs = {};

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = GridGeometry.fit(size, board.size);
    final trace = live.value;
    final tone = switch (trace.verdict) {
      Refusal.none => Palette.word,
      Refusal.alreadyFound => Palette.stale,
      _ => Palette.trace,
    };
    // A trace the finger has let go of is on its way out.
    final strength = trace.settling ? 1 - settle.value : 1.0;

    _paintPanel(canvas, geometry, trace, tone, strength);
    _paintSquares(canvas, geometry, trace, tone, strength);
    _paintTrace(canvas, geometry, trace, tone, strength);
    _paintLetters(canvas, geometry, trace, tone, strength);
  }

  void _paintPanel(
    Canvas canvas,
    GridGeometry geometry,
    Trace trace,
    Color tone,
    double strength,
  ) {
    final panel = RRect.fromRectAndRadius(
      geometry.panel,
      Radius.circular(geometry.corner * 1.6),
    );
    canvas.drawRRect(panel, Paint()..color = Palette.panel);

    // The slab edge picks up the trace's colour, which is the one part of the
    // answer that is nowhere near the thumb.
    final edge = trace.isEmpty
        ? Palette.panelEdge
        : Color.lerp(Palette.panelEdge, tone, 0.55 * strength)!;
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = edge,
    );
  }

  void _paintSquares(
    Canvas canvas,
    GridGeometry geometry,
    Trace trace,
    Color tone,
    double strength,
  ) {
    final taken = trace.spots.toSet();
    final radius = Radius.circular(geometry.corner);

    for (var row = 0; row < board.size; row++) {
      for (var col = 0; col < board.size; col++) {
        final spot = Spot(row, col);
        final square = RRect.fromRectAndRadius(geometry.squareOf(spot), radius);
        final lit = taken.contains(spot);

        canvas.drawRRect(
          square,
          Paint()
            ..color = lit
                ? Color.lerp(Palette.tile, tone, 0.16 * strength)!
                : Palette.tile,
        );
        canvas.drawRRect(
          square,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = lit ? 2 : 1
            ..color = lit
                ? tone.withValues(alpha: 0.9 * strength)
                : Palette.tileEdge,
        );
      }
    }
  }

  void _paintTrace(
    Canvas canvas,
    GridGeometry geometry,
    Trace trace,
    Color tone,
    double strength,
  ) {
    if (trace.isEmpty) return;

    // A word that counts swells as it is taken; one that does not just goes.
    final bloom = trace.settling && trace.isWord ? 1 + settle.value * 0.6 : 1.0;

    final start = geometry.centreOf(trace.spots.first);
    final path = Path()..moveTo(start.dx, start.dy);
    for (final spot in trace.spots.skip(1)) {
      final centre = geometry.centreOf(spot);
      path.lineTo(centre.dx, centre.dy);
    }

    // The line runs centre to centre and nowhere else, so it snaps from square
    // to square instead of following every wobble of the thumb.
    void ribbon(double width, double alpha) => canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.side * width * bloom
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = tone.withValues(alpha: alpha * strength),
    );
    ribbon(0.52, 0.14);
    ribbon(0.3, trace.isWord ? 0.5 : 0.34);

    // A dot on the square the word started from, so a trace that crosses
    // itself can still be read.
    canvas.drawCircle(
      start,
      geometry.side * 0.1,
      Paint()..color = tone.withValues(alpha: 0.8 * strength),
    );

    final thumb = trace.thumb;
    if (thumb == null) return;

    // A stub towards the finger so the trace stays attached to it, cut short
    // so that a thumb halfway down the screen does not drag a line after it.
    final head = geometry.centreOf(trace.spots.last);
    final away = thumb - head;
    if (away.distance > geometry.side * 0.2) {
      final reach = math.min(away.distance, geometry.pitch * 0.8);
      canvas.drawLine(
        head,
        head + away / away.distance * reach,
        Paint()
          ..strokeWidth = geometry.side * 0.18
          ..strokeCap = StrokeCap.round
          ..color = tone.withValues(alpha: 0.3),
      );
    }

    canvas.drawCircle(
      head,
      geometry.side * 0.56,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = geometry.side * 0.045
        ..color = tone.withValues(alpha: 0.45),
    );
  }

  void _paintLetters(
    Canvas canvas,
    GridGeometry geometry,
    Trace trace,
    Color tone,
    double strength,
  ) {
    final taken = trace.spots.toSet();
    final lit = Color.lerp(tone, const Color(0xFFFFFFFF), 0.55)!;
    final size = geometry.pitch * 0.46;

    for (var row = 0; row < board.size; row++) {
      for (var col = 0; col < board.size; col++) {
        final spot = Spot(row, col);
        final colour = taken.contains(spot)
            ? Color.lerp(Palette.ink, lit, strength)!
            : Palette.ink;
        final glyph = _glyph(board.letterAt(spot).toUpperCase(), colour, size);
        final centre = geometry.centreOf(spot);
        glyph.paint(
          canvas,
          centre - Offset(glyph.width / 2, glyph.height / 2),
        );
      }
    }
  }

  TextPainter _glyph(String letter, Color colour, double size) {
    final key = '$letter|${colour.toARGB32()}|$size';
    final known = _glyphs[key];
    if (known != null) return known;
    if (_glyphs.length > 120) _glyphs.clear();

    final glyph = TextPainter(
      text: TextSpan(
        text: letter,
        style: letters.copyWith(
          color: colour,
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
      // A letter has to fit its square, so it does not follow the system text
      // size the way the words around the board do.
      textScaler: TextScaler.noScaling,
    )..layout();
    _glyphs[key] = glyph;
    return glyph;
  }

  @override
  bool shouldRepaint(BoardPainter old) =>
      !identical(old.board, board) ||
      old.live != live ||
      old.settle != settle ||
      old.letters != letters;
}

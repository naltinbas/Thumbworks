import 'package:flutter/rendering.dart';

import '../play/session.dart';
import '../tune/tune.dart';
import 'palette.dart';

/// Where the lanes and the notes are on the screen.
class Metrics {
  factory Metrics(Size space) {
    final lane = space.width / Tune.lanes;
    return Metrics._(
      lane: lane,
      space: space,
      // The line sits low, because everything above it is what a player is
      // reading and everything below it is over.
      line: space.height * 0.80,
    );
  }

  const Metrics._({
    required this.lane,
    required this.space,
    required this.line,
  });

  /// How wide one lane is.
  final double lane;

  final Size space;

  /// How far down the screen the hit line is.
  final double line;

  /// How long a note is visible before it has to be hit.
  ///
  /// Long enough to read and act on, short enough that the screen is not a
  /// wall of notes. Fixed in seconds rather than in pixels, so a quick tune
  /// falls faster rather than showing more.
  static const lead = 1.7;

  double middleOf(int lane) => (lane + 0.5) * this.lane;

  /// Where a note due at [when] is drawn, given the music is at [now].
  double heightOf(double when, double now) =>
      line - (when - now) / lead * line;

  /// Which lane a point is in.
  int laneAt(Offset at) =>
      (at.dx ~/ lane).clamp(0, Tune.lanes - 1);
}

/// Draws the lanes, the line, and the notes coming down.
///
/// Nothing to load: four columns, a line and some rounded rectangles.
class StagePainter extends CustomPainter {
  StagePainter({
    required this.session,
    required this.metrics,
    required this.at,
    this.struck = const {},
  });

  final Session session;
  final Metrics metrics;

  /// Where the music is, in seconds.
  final double at;

  /// Lanes lit up because a finger is on them, and how long ago.
  final Map<int, double> struck;

  @override
  void paint(Canvas canvas, Size size) {
    _paintLanes(canvas, size);
    _paintNotes(canvas);
    _paintLine(canvas);
  }

  void _paintLanes(Canvas canvas, Size size) {
    for (var lane = 0; lane < Tune.lanes; lane++) {
      final left = lane * metrics.lane;
      canvas.drawRect(
        Rect.fromLTWH(left, 0, metrics.lane, size.height),
        Paint()
          ..color = lane.isEven ? Palette.stage : Palette.night,
      );

      // A lane a finger is on glows, and the glow fades. Without it there is
      // no way to tell a tap that landed from one that never happened.
      final since = struck[lane];
      if (since == null) continue;
      final strength = (1 - since / 0.18).clamp(0.0, 1.0);
      if (strength <= 0) continue;
      canvas.drawRect(
        Rect.fromLTWH(left, 0, metrics.lane, size.height),
        Paint()
          ..color = Palette.of(lane).withValues(alpha: 0.16 * strength),
      );
    }
  }

  void _paintNotes(Canvas canvas) {
    final tall = metrics.lane * 0.30;

    for (final note in session.waiting) {
      final when = note.secondsAt(session.tune.beatsPerMinute);
      if (when - at > Metrics.lead) break;

      final middle = metrics.heightOf(when, at);
      if (middle < -tall) continue;

      final box = Rect.fromCenter(
        center: Offset(metrics.middleOf(note.lane), middle),
        width: metrics.lane * 0.74,
        height: tall,
      );
      final colour = Palette.of(note.lane);

      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(tall * 0.35)),
        Paint()..color = colour,
      );
      // A brighter cap, so a note reads as a thing with a top edge rather than
      // a smear when several are close together.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(box.left, box.top, box.width, tall * 0.26),
          Radius.circular(tall * 0.2),
        ),
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.28),
      );
    }
  }

  void _paintLine(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, metrics.line - 1.5, metrics.space.width, 3),
      Paint()..color = Palette.line,
    );
    for (var lane = 0; lane < Tune.lanes; lane++) {
      final since = struck[lane];
      final strength = since == null ? 0.0 : (1 - since / 0.18).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(
          lane * metrics.lane + 2,
          metrics.line - 2.5,
          metrics.lane - 4,
          5,
        ),
        Paint()
          ..color = Color.lerp(
            Palette.line,
            Palette.lineLit,
            strength,
          )!,
      );
    }
  }

  @override
  bool shouldRepaint(StagePainter old) => true;
}

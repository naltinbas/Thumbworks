// This is a command line tool whose whole job is to print. It is not part of
// the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:chalkway/sim/levels.dart';
import 'package:chalkway/sim/shapes.dart';
import 'package:chalkway/sim/stroke.dart';
import 'package:chalkway/sim/world.dart';

/// Looks for a drawing that solves a level, and prints it.
///
/// Run with: dart run tool/find_answer.dart [level]
///
/// This is not in the game and never runs on a phone. It exists because a
/// level ships with a drawing that solves it, and finding that drawing by
/// hand means guessing where a ball will be after two seconds of bouncing —
/// which is a thing a computer is better at than a person and a thing this
/// simulation can answer exactly.
///
/// It tries two shapes. A long line from somewhere on the ball's own path to
/// the middle of the ring — which is what a first level wants, because it is
/// the obvious thing and it should work. And a short piece laid across the
/// path at an angle, which is what every level after that wants: with a small
/// chalk budget the long line does not fit, and the puzzle becomes where to
/// put a little one.
///
/// It reports the cheapest thing that works, because the cheapest answer is
/// the one that leaves a budget with something to say.
void main(List<String> args) {
  final only = args.isEmpty ? null : int.parse(args.first) - 1;

  for (var i = 0; i < Levels.count; i++) {
    if (only != null && i != only) continue;
    final level = Levels.at(i);
    final empty = Drawing.with_(level.ink);
    final bare = level.worldWith(empty);

    if (bare.played.ending == Ending.home) {
      print('${i + 1} ${level.name}: solves itself — the level needs changing');
      continue;
    }

    final path = bare.trail(every: 4);
    ({Stroke stroke, double seconds})? best;

    /// Whether a drawing solves the level.
    bool solves(Stroke stroke) =>
        level.worldWith(empty.add(stroke)).played.ending == Ending.home;

    /// The same stroke with both ends moved a little.
    Stroke nudged(Stroke stroke, double dx, double dy) => Stroke([
          for (final point in stroke.points) Spot(point.x + dx, point.y + dy),
        ]);

    void tryIt(Stroke stroke) {
      if (stroke.length > level.ink) return;
      if (best != null && stroke.length >= best!.stroke.length) return;
      if (!solves(stroke)) return;

      // And again, moved a little each way. A line that only works at one
      // exact position is not an answer, it is a coincidence — and a level
      // whose only answer is a coincidence is a level nobody can solve.
      //
      // This is not a nicety: the first set of answers was written out rounded
      // to a tenth of a unit, and two of the eight stopped working. Those two
      // were knife-edge, and would have been knife-edge for a player too.
      var stood = 0;
      for (final nudge in const [
        (0.06, 0.0),
        (-0.06, 0.0),
        (0.0, 0.06),
        (0.0, -0.06),
      ]) {
        if (solves(nudged(stroke, nudge.$1, nudge.$2))) stood++;
      }
      if (stood < 3) return;

      best = (
        stroke: stroke,
        seconds: level.worldWith(empty.add(stroke)).played.seconds,
      );
    }

    for (var p = 2; p < path.length; p++) {
      final on = path[p];

      // The long one: from beside the ball's own path to the ring.
      for (final lift in const [0.45, 0.8, 1.2]) {
        tryIt(Stroke([Spot(on.x - lift, on.y + lift * 0.4), level.goal.at]));
      }

      // The ramp: from beside the ball to the end of something already there.
      // A wall is only a wall until there is a way up to the top of it, and
      // the top of it is one of these points.
      for (final line in level.solid) {
        for (final end in [line.from, line.to]) {
          tryIt(Stroke([Spot(on.x - 0.5, on.y + 0.35), end]));
          tryIt(Stroke([Spot(on.x - 0.9, on.y + 0.5), end]));
        }
      }

      // The short one: a piece laid across the path, tried at every angle and
      // a few lengths.
      for (final size in const [1.4, 2.2, 3.0, 4.0]) {
        for (var turn = 0; turn < 12; turn++) {
          final angle = turn * pi / 12;
          final half = Spot(cos(angle), sin(angle)) * (size / 2);
          // Just below the ball, so it lands on the piece rather than being
          // pushed sideways by one it is already inside.
          final middle = Spot(on.x, on.y + 0.55);
          tryIt(Stroke([middle - half, middle + half]));
        }
      }
    }

    if (best == null) {
      print('${i + 1} ${level.name}: nothing found');
      continue;
    }
    final points = best!.stroke.points
        .map((s) => 'Spot(${s.x.toStringAsFixed(2)}, ${s.y.toStringAsFixed(2)})')
        .join(', ');
    print('${i + 1} ${level.name}:');
    print('     [$points]');
    print('     ink ${best!.stroke.length.toStringAsFixed(1)}/${level.ink}  '
        '${best!.seconds.toStringAsFixed(1)}s');
  }
}

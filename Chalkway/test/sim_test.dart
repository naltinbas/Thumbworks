import 'package:flutter_test/flutter_test.dart';
import 'package:chalkway/sim/levels.dart';
import 'package:chalkway/sim/shapes.dart';
import 'package:chalkway/sim/stroke.dart';
import 'package:chalkway/sim/world.dart';

/// A ball dropped on a stretch of chalk, with nothing else in the world.
World dropOn(List<Line> lines, {Spot from = const Spot(5, 2)}) => World.of(
      solid: lines,
      goal: const Blob(Spot(-99, -99), 0.5),
      spikes: const [],
      from: from,
    );

void main() {
  group('the shapes', () {
    test('the nearest point on a line is clamped to its ends', () {
      const line = Line(Spot(0, 0), Spot(4, 0));
      expect(line.nearestTo(const Spot(2, 3)), const Spot(2, 0));
      expect(line.nearestTo(const Spot(-5, 1)), const Spot(0, 0),
          reason: 'past one end is that end');
      expect(line.nearestTo(const Spot(9, 1)), const Spot(4, 0));
    });

    test('which is what makes a ledge a ledge and not an endless floor', () {
      // Dropped past the end of a ledge, the ball keeps going.
      final off = dropOn(
        const [Line(Spot(0, 10), Spot(3, 10))],
        from: const Spot(6, 2),
      ).played;
      expect(off.ending, Ending.lost);

      final on = dropOn(
        const [Line(Spot(0, 10), Spot(9, 10))],
        from: const Spot(4, 2),
      ).played;
      expect(on.ending, Ending.settled, reason: 'it should come to rest on it');
    });
  });

  group('the ball', () {
    test('falls, and lands on a flat line, and stays there', () {
      final world = dropOn(const [Line(Spot(0, 10), Spot(10, 10))]).played;

      expect(world.ending, Ending.settled);
      expect(world.ball.y, closeTo(10 - World.ballRadius, 0.05),
          reason: 'it should be resting on top of the line');
      expect(world.speed.length, lessThan(0.4));
    });

    test('slides down a slope rather than sitting on it', () {
      final world = dropOn(const [Line(Spot(0, 8), Spot(10, 13))]).played;
      expect(world.ending, Ending.lost, reason: 'it should run off the end');
      expect(world.ball.x, greaterThan(9));
    });

    test('does not go through a line, however fast it arrives', () {
      // Dropped from the very top onto one thin line near the bottom. This is
      // the whole reason the step is a two hundred and fortieth of a second
      // and the speed is capped: at that step the ball moves a sixth of its
      // own radius, so there is nothing for it to pass through.
      final world = dropOn(
        const [Line(Spot(0, 19), Spot(10, 19))],
        from: const Spot(5, 0.4),
      ).played;

      expect(world.ending, Ending.settled);
      expect(world.ball.y, lessThan(19), reason: 'it fell straight through');
    });

    test('never goes faster than the cap', () {
      var world = dropOn(
        const [Line(Spot(0, 19.5), Spot(10, 19.5))],
        from: const Spot(5, 0.2),
      );
      var fastest = 0.0;
      while (!world.isOver) {
        world = world.step();
        if (world.speed.length > fastest) fastest = world.speed.length;
      }
      expect(fastest, lessThanOrEqualTo(World.topSpeed + 1e-9));
    });

    test('runs the same way twice, because nothing in it is random', () {
      final once = dropOn(const [Line(Spot(0, 9), Spot(9, 12))]).played;
      final again = dropOn(const [Line(Spot(0, 9), Spot(9, 12))]).played;
      expect(once.steps, again.steps);
      expect(once.ball.x, again.ball.x);
      expect(once.ball.y, again.ball.y);
    });

    test('settles in a corner rather than shaking in it', () {
      // Two lines meeting in a V. Pushing out of one can push into the other,
      // which is why the resolve runs twice — without it the ball buzzes in
      // the corner and never comes to rest.
      final world = dropOn(const [
        Line(Spot(0, 8), Spot(5, 12)),
        Line(Spot(10, 8), Spot(5, 12)),
      ]).played;

      expect(world.ending, Ending.settled);
      expect(world.ball.x, closeTo(5, 0.6));
    });
  });

  group('the ring', () {
    /// A ball dropped straight down past a ring at [across], from the side.
    Ending pastARingAt(double across) => World.of(
          solid: const [],
          goal: Blob(Spot(across, 10), 0.8),
          spikes: const [],
          from: const Spot(5, 2),
        ).played.ending;

    test('catches the ball when its middle goes inside', () {
      expect(pastARingAt(5), Ending.home);
      expect(pastARingAt(5.7), Ending.home, reason: 'inside, if only just');
    });

    test('and lets it go by when it only grazes the rim', () {
      // The ball is 0.3 across and the ring 0.8, so at this distance the two
      // circles overlap and the middle of the ball is still outside. Calling
      // that in would end a run the player watched the ball miss.
      expect(pastARingAt(5.9), Ending.lost);
      expect(pastARingAt(6.4), Ending.lost);
    });
  });

  group('the chalk', () {
    test('thins a stroke as it is drawn', () {
      // A finger reports a hundred times a second; most of those points say
      // nothing the one before did not, and every one of them is a line the
      // physics checks forever.
      var stroke = const Stroke([]);
      for (var i = 0; i < 100; i++) {
        stroke = stroke.to(Spot(i * 0.02, 0));
      }
      expect(stroke.points.length, lessThan(20));
      expect(stroke.length, closeTo(1.98, 0.2), reason: 'and it is still 2 long');
    });

    test('runs out, and cuts the stroke where it ran out', () {
      final drawing = Drawing.with_(3).add(
        const Stroke([Spot(0, 0), Spot(10, 0)]),
      );
      expect(drawing.used, closeTo(3, 0.001));
      expect(drawing.strokes.single.points.last.x, closeTo(3, 0.001),
          reason: 'cut, not refused: a stroke that vanishes has to be redrawn');
    });

    test('takes strokes back one at a time, and all at once', () {
      var drawing = Drawing.with_(10)
          .add(const Stroke([Spot(0, 0), Spot(1, 0)]))
          .add(const Stroke([Spot(0, 2), Spot(2, 2)]));
      expect(drawing.used, closeTo(3, 0.001));

      drawing = drawing.back;
      expect(drawing.used, closeTo(1, 0.001));
      expect(drawing.cleared.used, 0);
      expect(drawing.cleared.left, 10);
    });

    test('is what the ball rolls on', () {
      final drawing = Drawing.with_(20).add(
        const Stroke([Spot(0, 9), Spot(9, 12)]),
      );
      final world = World.of(
        solid: drawing.lines,
        goal: const Blob(Spot(-99, -99), 0.5),
        spikes: const [],
        from: const Spot(2, 2),
      ).played;
      expect(world.ball.x, greaterThan(8), reason: 'it rolled down the chalk');
    });
  });

  group('every level', () {
    test('is solved by the drawing it ships with', () {
      // The claim the whole game rests on. Each level carries a drawing, and
      // this draws it and watches the ball arrive — which is a different thing
      // from a search saying a level is possible, because what ships is a
      // drawing a person could make.
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        final played = level.worldWith(level.answer).played;
        expect(played.ending, Ending.home,
            reason: '${level.name} is not solved by its own answer');
      }
    });

    test('needs the drawing: none of them solves itself', () {
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        final bare = level.worldWith(level.answer.cleared).played;
        expect(bare.ending, isNot(Ending.home),
            reason: '${level.name} does not need any chalk');
      }
    });

    test('gives enough chalk for its own answer, and not much more', () {
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        expect(level.answer.used, lessThanOrEqualTo(level.ink),
            reason: '${level.name} does not give enough chalk for its answer');
        expect(level.answer.used, greaterThan(0));
      }
    });

    test('is solved by an answer that still works when it moves a little', () {
      // A line that only works at one exact position is a coincidence, not an
      // answer — and a level whose only answer is a coincidence is a level
      // nobody can solve. Every shipped answer survives being nudged.
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        var stood = 0;
        for (final nudge in const [
          Spot(0.06, 0),
          Spot(-0.06, 0),
          Spot(0, 0.06),
          Spot(0, -0.06),
        ]) {
          var drawing = Drawing.with_(level.ink);
          for (final stroke in level.solution) {
            drawing = drawing.add(
              Stroke([for (final point in stroke) point + nudge]),
            );
          }
          if (level.worldWith(drawing).played.ending == Ending.home) stood++;
        }
        expect(stood, greaterThanOrEqualTo(3),
            reason: '${level.name} only works at one exact position');
      }
    });

    test('keeps its ring and its spikes on the board', () {
      // Anything whose middle is near an edge is drawn half off it, and a ring
      // hanging over the side of the slate looks like a mistake even when the
      // ball can still reach it.
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        for (final blob in [level.goal, ...level.spikes]) {
          expect(blob.at.x - blob.radius, greaterThanOrEqualTo(0),
              reason: '${level.name} has something over the left edge');
          expect(blob.at.x + blob.radius, lessThanOrEqualTo(World.across),
              reason: '${level.name} has something over the right edge');
          expect(blob.at.y + blob.radius, lessThanOrEqualTo(World.down),
              reason: '${level.name} has something over the bottom');
        }
      }
    });

    test('starts the ball in mid air and puts the ring somewhere else', () {
      for (var i = 0; i < Levels.count; i++) {
        final level = Levels.at(i);
        expect(level.start.x, inInclusiveRange(0, World.across));
        expect(level.start.y, inInclusiveRange(0, World.down));
        expect(level.goal.at.y, greaterThan(level.start.y),
            reason: '${level.name} has the ring above the ball');
        for (final line in level.solid) {
          expect(line.distanceTo(level.start),
              greaterThan(World.ballRadius),
              reason: '${level.name} starts the ball inside something');
        }
      }
    });
  });
}

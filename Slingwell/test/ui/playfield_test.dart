import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/playfield.dart';

/// Where the craft would have been at the step a well caught it.
///
/// The simulation snaps a caught craft onto the tether, so the position that
/// was actually near enough to catch is gone by the time anyone can look at
/// it. This works it out again the same way the flight does.
Vec _whereItWasCaught(World before) {
  final pulled =
      before.velocity + const Vec(0, -World.gravity) * World.stepSeconds;
  return before.craft + pulled * World.stepSeconds;
}

/// Plays a run with an unreliable thumb, which is what finds the edges of the
/// playfield: a player who never misses never touches a wall.
void _play(
  int seed, {
  double chance = 0.02,
  required void Function(World before, World after) watch,
}) {
  final random = Random(seed);
  var world = World.newRun(seed: seed);
  for (var i = 0; i < 20000 && !world.isOver; i++) {
    final before = world;
    world = world.step(tapped: world.isHeld && random.nextDouble() < chance);
    watch(before, world);
  }
}

void main() {
  // The view copies five numbers out of the simulation because it has to draw
  // them and they are private. These check each copy against what the
  // simulation actually does, so the drawing cannot quietly start lying about
  // the rules.
  group('what the view draws', () {
    test('the tether is the distance the craft rides at', () {
      var world = World.newRun(seed: 4);
      for (var i = 0; i < 300; i++) {
        final well = world.wells[world.heldBy!];
        expect(
          (world.craft - well.at).length,
          closeTo(Playfield.tether, 1e-9),
          reason: 'step $i',
        );
        world = world.step();
      }
    });

    test('the walls are where a run ends sideways', () {
      var ended = 0;
      for (var seed = 0; seed < 30; seed++) {
        _play(
          seed,
          watch: (before, after) {
            if (!after.isOver) {
              // Every step the craft survives is a step inside the walls.
              if (!after.isHeld) {
                expect(after.craft.x.abs(), lessThanOrEqualTo(Playfield.edgeX));
              }
              return;
            }
            if (after.ending != Ending.adrift) return;
            if (after.craft.x.abs() < Playfield.edgeX) return;
            ended++;
            // Just past the wall, not somewhere else entirely: the step it
            // died on is the step it crossed.
            expect(after.craft.x.abs(), greaterThan(Playfield.edgeX));
            expect(after.craft.x.abs(), lessThan(Playfield.edgeX + 0.3));
          },
        );
      }
      expect(ended, greaterThan(0), reason: 'no run reached a wall');
    });

    test('the fall the camera leaves room for is the fall that ends a run', () {
      var ended = 0;
      for (var seed = 0; seed < 30; seed++) {
        _play(
          seed,
          watch: (before, after) {
            if (!after.isOver) {
              // A craft that is still flying has not fallen too far. A craft
              // being swung has no such limit, which is why this only looks
              // at the ones in the air.
              if (!after.isHeld && !before.isHeld) {
                expect(
                  after.cameraY - after.craft.y,
                  lessThanOrEqualTo(Playfield.fallBehind),
                );
              }
              return;
            }
            if (after.ending != Ending.adrift) return;
            if (after.craft.x.abs() >= Playfield.edgeX) return;
            ended++;
            expect(
              after.cameraY - after.craft.y,
              greaterThan(Playfield.fallBehind),
            );
          },
        );
      }
      expect(ended, greaterThan(0), reason: 'no run fell out of the world');
    });

    test('the catching band is the range a well catches from', () {
      var catches = 0;
      var closest = double.infinity;
      var furthest = 0.0;
      for (var seed = 0; seed < 30; seed++) {
        _play(
          seed,
          watch: (before, after) {
            if (before.isHeld || !after.isHeld) return;
            final well = after.wells[after.heldBy!];
            final gap = (_whereItWasCaught(before) - well.at).length;
            catches++;
            expect(
              gap,
              lessThanOrEqualTo(well.radius + Playfield.catchBand + 1e-9),
              reason: 'caught from further out than the band drawn',
            );
            final share = (gap - well.radius) / Playfield.catchBand;
            if (share > furthest) furthest = share;
            if (gap / well.radius < closest) closest = gap / well.radius;
          },
        );
      }
      expect(catches, greaterThan(20));
      expect(
        furthest,
        greaterThan(0.9),
        reason: 'the band drawn is wider than the one that catches',
      );
      // Nothing is ever caught inside the middle, which is the part drawn as
      // solid.
      expect(closest, greaterThan(Playfield.coreShare));
    });
  });
}

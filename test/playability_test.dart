import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';

/// Releases when the craft points at where the next well will be by the time
/// it arrives, which is what a player who has learnt the game does.
World _playWell(int seed, {int limit = 40000}) {
  var world = World.newRun(seed: seed);
  for (var i = 0; i < limit && !world.isOver; i++) {
    var tap = false;
    if (world.isHeld) {
      final here = world.wells[world.heldBy!];
      Well? target;
      for (final well in world.wells) {
        if (well.at.y > here.at.y + 0.5) {
          target = well;
          break;
        }
      }
      if (target != null) {
        final flat = (target.at - world.craft).length;
        final flight = flat / World.launchSpeed;
        final lead = Vec(
          target.at.x,
          target.at.y + 0.5 * World.gravity * flight * flight,
        );
        final want = (lead - world.craft).normalised;
        final going = world.velocity.normalised;
        tap = want.x * going.x + want.y * going.y > 0.995;
      }
    }
    world = world.step(tapped: tap);
  }
  return world;
}

World _mash(int seed, {int limit = 40000}) {
  var world = World.newRun(seed: seed);
  for (var i = 0; i < limit && !world.isOver; i++) {
    world = world.step(tapped: world.isHeld);
  }
  return world;
}

void main() {
  // These two tests are the design, not a detail of it. A game where tapping
  // as fast as possible works is not asking the player anything, and a game a
  // careful player cannot get anywhere in is not worth asking. The numbers
  // are deliberately loose: they are there to catch a change that breaks the
  // shape of the difficulty, not to pin the balance to a decimal.
  group('the shape of the game', () {
    test('tapping at every chance gets nowhere', () {
      for (final seed in [1, 2, 3, 7, 11]) {
        final world = _mash(seed);
        expect(world.isOver, isTrue, reason: 'seed $seed should end');
        expect(world.score, lessThan(5), reason: 'seed $seed scored too well');
      }
    });

    test('aiming well chains a long way up', () {
      for (final seed in [1, 2, 3, 7, 11]) {
        final world = _playWell(seed);
        expect(world.score, greaterThan(40), reason: 'seed $seed');
        expect(world.cameraY, greaterThan(200), reason: 'seed $seed');
      }
    });

    test('the world does not run out however far a player gets', () {
      final world = _playWell(1, limit: 40000);
      // Far past the wells laid out at the start, so more must have appeared.
      expect(world.cameraY, greaterThan(500));
      expect(world.wells.last.at.y, greaterThan(world.craft.y));
    });
  });
}

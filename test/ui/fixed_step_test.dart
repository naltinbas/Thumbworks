import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/game_loop.dart';

void main() {
  group('the fixed step clock', () {
    test('runs a step for every step the frame covered', () {
      final clock = FixedStepClock();
      // A tenth of a second is twelve steps at a hundred and twenty a second.
      expect(clock.stepsFor(const Duration(milliseconds: 100)), 12);
    });

    test('keeps the part of a frame that was not a whole step', () {
      // Ten millisecond frames are a step and a fifth each. Throwing the
      // fifth away would run ten steps in a tenth of a second instead of
      // twelve, and the game would quietly run slow on that phone.
      final clock = FixedStepClock();
      var steps = 0;
      for (var i = 0; i < 10; i++) {
        steps += clock.stepsFor(const Duration(milliseconds: 10));
      }
      expect(steps, 12);
    });

    test('stays exact over an hour of frames', () {
      // Carrying the remainder as a double loses a step somewhere in here.
      final clock = FixedStepClock();
      const frame = Duration(microseconds: 16667);
      var steps = 0;
      for (var i = 0; i < 216000; i++) {
        steps += clock.stepsFor(frame);
      }
      final micros = 216000 * frame.inMicroseconds;
      expect(steps, micros * FixedStepClock.stepsPerSecond ~/ 1000000);
    });

    test('never plays more than a quarter second of a stall in one frame', () {
      // Coming back from the background hands over a frame that lasted
      // minutes. Playing all of it would move the craft the length of the
      // world between two pictures.
      final clock = FixedStepClock();
      expect(clock.stepsFor(const Duration(seconds: 30)), 30);
    });

    test('ignores a frame that went backwards', () {
      final clock = FixedStepClock();
      expect(clock.stepsFor(const Duration(milliseconds: -8)), 0);
      expect(clock.stepsFor(const Duration(milliseconds: 100)), 12);
    });

    test('drops the part step in hand when it is reset', () {
      final clock = FixedStepClock();
      clock.stepsFor(const Duration(milliseconds: 8));
      clock.reset();
      expect(clock.stepsFor(const Duration(milliseconds: 8)), 0);
    });

    test('agrees with the simulation about how long a step is', () {
      expect(FixedStepClock.stepsPerSecond * World.stepSeconds, closeTo(1, 1e-9));
    });
  });
}

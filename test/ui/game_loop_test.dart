import 'package:flutter_test/flutter_test.dart';
import 'package:slingwell/sim/world.dart';
import 'package:slingwell/ui/game_loop.dart';

/// A frame that is a whole number of steps long, for the tests that are about
/// something other than the arithmetic of the clock.
const _frame = Duration(milliseconds: 100);

/// Run the loop until the run ends, or give up.
void _playOut(GameLoop loop, {bool Function()? tapWhen, int frames = 2000}) {
  for (var i = 0; i < frames && !loop.world.isOver; i++) {
    if (tapWhen != null && tapWhen()) loop.tap();
    loop.advance(_frame);
  }
}

void main() {
  group('the loop', () {
    test('advances the simulation by the steps the frame covered', () {
      final loop = GameLoop(seed: 3);
      loop.advance(_frame);
      expect(loop.world.steps, 12);
      loop.advance(_frame);
      expect(loop.world.steps, 24);
    });

    test('carries the leftover of a frame into the next one', () {
      final loop = GameLoop(seed: 3);
      for (var i = 0; i < 10; i++) {
        loop.advance(const Duration(milliseconds: 10));
      }
      expect(loop.world.steps, 12);
    });

    test('does not step at all for a frame shorter than a step', () {
      final loop = GameLoop(seed: 3);
      loop.advance(const Duration(microseconds: 1000));
      expect(loop.world.steps, 0);
    });

    test('gives a tap to the simulation once and only once', () {
      final loop = GameLoop(seed: 3);
      loop.advance(_frame);
      loop.tap();
      loop.advance(const Duration(milliseconds: 500));
      expect(loop.replay.taps, hasLength(1));
      expect(loop.replay.taps.single, 12);
    });

    test('holds a tap until the next step rather than dropping it', () {
      // A thumb lands between frames, and often between steps. The tap has to
      // wait for a step to happen to it.
      final loop = GameLoop(seed: 3);
      loop.tap();
      loop.advance(const Duration(microseconds: 1000));
      expect(loop.world.isHeld, isTrue, reason: 'no step has run yet');
      loop.advance(_frame);
      expect(loop.world.isHeld, isFalse);
      expect(loop.replay.taps, hasLength(1));
    });

    test('spends a tap made in flight instead of saving it', () {
      // Keeping it would let a player tap early and have the game let go for
      // them the moment they caught something, which is the game playing
      // itself.
      final loop = GameLoop(seed: 3);
      loop.advance(_frame);
      loop.tap();
      loop.advance(const Duration(milliseconds: 200));
      expect(loop.world.isHeld, isFalse);

      loop.tap();
      for (var i = 0; i < 200 && !loop.world.isHeld && !loop.world.isOver; i++) {
        loop.advance(const Duration(milliseconds: 8));
      }
      expect(loop.world.isHeld, isTrue, reason: 'expected to catch something');
      expect(loop.replay.taps, hasLength(1));
    });

    test('ignores a tap once the run is over', () {
      final loop = GameLoop(seed: 3);
      _playOut(loop, tapWhen: () => loop.world.isHeld);
      expect(loop.world.isOver, isTrue);
      final taps = loop.replay.taps.length;
      loop.tap();
      loop.advance(_frame);
      expect(loop.replay.taps, hasLength(taps));
    });

    test('records a run that plays back to the same ending', () {
      // The whole point of the simulation being a pure function of a seed and
      // a list of taps: what the loop drove and what a replay plays have to
      // be the same run.
      final loop = GameLoop(seed: 17);
      var beat = 0;
      _playOut(loop, tapWhen: () => loop.world.isHeld && ++beat % 3 == 0);
      expect(loop.world.isOver, isTrue);

      final replayed = loop.replay.play();
      expect(replayed.steps, loop.world.steps);
      expect(replayed.score, loop.world.score);
      expect(replayed.ending, loop.world.ending);
      expect(replayed.craft.y, loop.world.craft.y);
    });

    test('starts a new run from the beginning', () {
      final loop = GameLoop(seed: 3);
      loop.advance(_frame);
      loop.tap();
      loop.advance(_frame);
      loop.restart();
      expect(loop.world.steps, 0);
      expect(loop.world.isHeld, isTrue);
      expect(loop.replay.taps, isEmpty);
      expect(loop.trail.length, 1);
      // The part step left over from the last run does not leak into this one.
      loop.advance(const Duration(microseconds: 1000));
      expect(loop.world.steps, 0);
    });
  });

  group('the camera', () {
    test('starts where the run does', () {
      final loop = GameLoop(seed: 5);
      expect(loop.focusY, loop.world.cameraY);
    });

    test('follows the climb instead of jumping to it', () {
      final loop = GameLoop(seed: 5);
      _playOut(loop, tapWhen: () => loop.world.isHeld, frames: 4);
      // Somewhere behind the height the run has reached, but on its way.
      var moved = false;
      final start = loop.focusY;
      for (var i = 0; i < 30 && !loop.world.isOver; i++) {
        loop.advance(const Duration(milliseconds: 16));
        if (loop.focusY > start) moved = true;
        expect(loop.focusY, lessThanOrEqualTo(loop.world.cameraY + 1e-9));
      }
      expect(moved, isTrue);
    });

    test('catches up and settles rather than creeping forever', () {
      final loop = GameLoop(seed: 5);
      for (var i = 0; i < 40; i++) {
        loop.advance(_frame);
      }
      expect(loop.focusY, loop.world.cameraY);
    });

    test('never drops back down the screen', () {
      final loop = GameLoop(seed: 8);
      var last = loop.focusY;
      _playOut(loop, tapWhen: () => loop.world.isHeld, frames: 60);
      for (var i = 0; i < 60 && !loop.world.isOver; i++) {
        loop.advance(const Duration(milliseconds: 16));
        expect(loop.focusY, greaterThanOrEqualTo(last));
        last = loop.focusY;
      }
    });
  });

  group('what the view remembers', () {
    test('keeps a point of trail for each step the craft flew', () {
      final loop = GameLoop(seed: 3);
      loop.advance(const Duration(milliseconds: 100));
      expect(loop.trail.length, 13, reason: 'the start, plus twelve steps');
    });

    test('never keeps more trail than it draws', () {
      final loop = GameLoop(seed: 3);
      for (var i = 0; i < 40; i++) {
        loop.advance(_frame);
      }
      expect(loop.trail.length, loop.trail.capacity);
    });

    test('draws the trail back in once the run is over', () {
      final loop = GameLoop(seed: 3);
      _playOut(loop, tapWhen: () => loop.world.isHeld);
      final left = loop.trail.length;
      loop.advance(_frame);
      expect(loop.trail.length, lessThan(left));
    });

    test('flashes when the craft lets go', () {
      final loop = GameLoop(seed: 3);
      loop.advance(_frame);
      loop.tap();
      loop.advance(const Duration(milliseconds: 16));
      expect(loop.flashes.map((f) => f.kind), contains(FlashKind.released));
    });

    test('flashes when a well catches the craft', () {
      final loop = GameLoop(seed: 3);
      loop.advance(_frame);
      loop.tap();
      loop.advance(const Duration(milliseconds: 16));
      expect(loop.world.isHeld, isFalse);
      for (var i = 0; i < 200 && !loop.world.isHeld; i++) {
        loop.advance(const Duration(milliseconds: 8));
      }
      expect(loop.flashes.map((f) => f.kind), contains(FlashKind.caught));
    });

    test('lets a flash fade out and stop being drawn', () {
      final loop = GameLoop(seed: 3);
      loop.advance(_frame);
      loop.tap();
      loop.advance(const Duration(milliseconds: 16));
      expect(loop.flashes, isNotEmpty);
      loop.advance(const Duration(milliseconds: 200));
      loop.advance(const Duration(milliseconds: 200));
      expect(
        loop.flashes.where((f) => f.kind == FlashKind.released),
        isEmpty,
      );
    });
  });

  group('a run that has stopped moving', () {
    test('stops asking the screen to redraw', () {
      final loop = GameLoop(seed: 3);
      _playOut(loop, tapWhen: () => loop.world.isHeld);
      // Long enough for the flashes to burn out, the trail to be drawn in and
      // the camera to arrive.
      for (var i = 0; i < 40; i++) {
        loop.advance(_frame);
      }
      var told = 0;
      loop.addListener(() => told++);
      loop.advance(_frame);
      loop.advance(_frame);
      expect(told, 0);
    });

    test('tells the screen while anything is still moving', () {
      final loop = GameLoop(seed: 3);
      var told = 0;
      loop.addListener(() => told++);
      loop.advance(_frame);
      expect(told, 1);
    });
  });

  test('the loop is worth a hundred and twenty steps a second', () {
    // The number the whole design rests on, checked here rather than assumed.
    final loop = GameLoop(seed: 1);
    loop.advance(const Duration(seconds: 1) ~/ 4);
    expect(loop.world.steps, (0.25 / World.stepSeconds).round());
  });
}

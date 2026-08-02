import 'world.dart';

/// A run recorded as the steps on which the player let go.
///
/// A run is a pure function of its seed and these numbers, so this is enough
/// to reproduce it exactly: what the player saw, what the score was, and where
/// it ended. That makes a bug reportable as two integers and a list, and it is
/// what the tests lean on rather than poking at the simulation's insides.
class Replay {
  const Replay({required this.seed, required this.taps});

  final int seed;

  /// The step numbers the player released on, in order.
  final List<int> taps;

  /// Play it out and hand back the run as it ended.
  World play({int maxSteps = 60000}) {
    var world = World.newRun(seed: seed);
    final pending = List<int>.from(taps)..sort();
    var next = 0;
    while (!world.isOver && world.steps < maxSteps) {
      final tapped = next < pending.length && pending[next] == world.steps;
      if (tapped) next++;
      world = world.step(tapped: tapped);
    }
    return world;
  }
}

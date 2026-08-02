import 'dart:math';

import 'ground.dart';
import 'passable.dart';

/// A stretch that has been got through, and what it took.
class Stretch {
  const Stretch({
    required this.written,
    required this.holds,
    required this.jumps,
  });

  /// The tiles, written down.
  final String written;

  /// The steps the button was held on, in the line that proved it. Kept
  /// because a proof nobody can replay is a claim.
  final List<int> holds;

  /// How many separate presses the line needed. This is the difficulty: one
  /// jump is a hop, four is a passage.
  final int jumps;

  Ground get ground => Ground.of(written);

  int get length => written.length;
}

/// Makes stretches, and throws away the ones that cannot be got through.
///
/// A generated stretch is a pile of numbers and there is no looking at it and
/// knowing whether it is fair. So every candidate is handed to the [Verifier],
/// which presses the button for itself, and only the ones it gets through are
/// kept. What a player meets has been played already.
///
/// Two more things are thrown away. A stretch nobody has to jump on is not a
/// stretch, and a stretch that ends with the runner in the air cannot be
/// joined to the next one — the verifier's goal is standing on the last tile,
/// which is what makes chaining safe.
class Maker {
  const Maker({this.tries = 60, this.verifier = const Verifier()});

  /// How many layouts to try for one seed before giving up on it.
  final int tries;

  final Verifier verifier;

  /// Every stretch starts and ends flat, so a runner arrives standing.
  static const _lead = 3;
  static const _tail = 4;

  /// The stretch for a seed, or null if nothing came of it.
  Stretch? make({required int seed, required int obstacles}) {
    for (var attempt = 0; attempt < tries; attempt++) {
      final random = Random(seed * 7919 + attempt);
      final written = _draw(random, obstacles);
      final found = verifier.check(Ground.of(written));

      if (!found.through) continue;
      if (!found.needsJumping) continue;

      return Stretch(
        written: written,
        holds: found.holds,
        jumps: _pressesIn(found.holds),
      );
    }
    return null;
  }

  /// Lays out a candidate: a flat run in, some obstacles with room between
  /// them, and a flat run out.
  String _draw(Random random, int obstacles) {
    final out = StringBuffer('.' * _lead);

    for (var i = 0; i < obstacles; i++) {
      switch (random.nextInt(3)) {
        case 0:
          // A pit. Up to five wide, which is past what a full hold clears, so
          // some of these are thrown away and that is the point.
          out.write('_' * (1 + random.nextInt(5)));
        case 1:
          // Spikes, in a row.
          out.write('^' * (1 + random.nextInt(2)));
        default:
          // A step up, and back down after it.
          final high = 1 + random.nextInt(3);
          out.write('$high' * (2 + random.nextInt(4)));
      }
      // Room to land and set up for the next one. Two tiles is tight and five
      // is a breather.
      out.write('.' * (2 + random.nextInt(4)));
    }

    out.write('.' * _tail);
    return out.toString();
  }

  /// How many separate presses a list of held steps is.
  static int _pressesIn(List<int> holds) {
    if (holds.isEmpty) return 0;
    var presses = 1;
    for (var i = 1; i < holds.length; i++) {
      if (holds[i] != holds[i - 1] + 1) presses++;
    }
    return presses;
  }
}

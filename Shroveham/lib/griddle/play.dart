import 'batch.dart';
import 'fewest.dart';

/// A batch part sorted: the cakes as they lie, and the flips spent.
class Play {
  const Play._(this.batch, this.cakes, this.made, this.before);

  Play.of(Batch batch) : this._(batch, batch.cakes, 0, null);

  final Batch batch;

  /// Sizes from the griddle up, as they lie now.
  final List<int> cakes;

  /// Flips made.
  final int made;

  /// The batch as it lay before the last flip, or null at the start.
  final Play? before;

  /// Served: smallest on top, biggest on the griddle.
  bool get isServed {
    for (var at = 0; at < cakes.length; at++) {
      if (cakes[at] != cakes.length - at) return false;
    }
    return true;
  }

  bool get isFewest => made == batch.fewest;

  /// Whether the slice can go under that cake: anywhere but under the top
  /// cake alone, which would turn one cake over and change nothing.
  bool mayFlip(int under) =>
      !isServed && under >= 0 && under <= cakes.length - 2;

  /// The flip. Returns this unchanged when the slice cannot go there.
  Play flip(int under) {
    if (!mayFlip(under)) return this;
    return Play._(batch, Flips.flipped(cakes, under), made + 1, this);
  }

  /// The last flip back, or this at the start.
  Play get back => before ?? this;

  /// The fewest flips this batch can still be served in.
  int get couldStillBe => made + Flips.byWalk(cakes);

  /// How many gaps are on the stack right now.
  int get gapsNow => Flips.gaps(cakes);

  /// A flip that brings serving one nearer, lowest slice first, or null
  /// when the batch is served.
  int? get next {
    if (isServed) return null;
    final away = Flips.byWalk(cakes);
    for (var under = 0; under <= cakes.length - 2; under++) {
      if (Flips.byWalk(Flips.flipped(cakes, under)) == away - 1) return under;
    }
    return null;
  }
}

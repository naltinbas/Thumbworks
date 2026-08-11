/// A stowing of chits in lockers, and the loops it hides.
///
/// The bosun has stowed one chit in each locker, every sailor's name on
/// one chit, nobody promised their own locker. A stowing is a shuffling,
/// and every shuffling breaks into loops: start at any locker, see whose
/// chit is in it, go to that sailor's locker, and you come back round to
/// where you began, always.
class Stow {
  const Stow(this.chits);

  /// chits[locker] is whose chit lies in that locker.
  final List<int> chits;

  int get lockers => chits.length;

  /// The loop through [locker]: the lockers visited until it closes.
  List<int> loopThrough(int locker) {
    final loop = <int>[locker];
    var at = chits[locker];
    while (at != locker) {
      loop.add(at);
      at = chits[at];
    }
    return loop;
  }

  /// Every loop once, longest first.
  List<List<int>> get loops {
    final seen = List<bool>.filled(lockers, false);
    final out = <List<int>>[];
    for (var locker = 0; locker < lockers; locker++) {
      if (seen[locker]) continue;
      final loop = loopThrough(locker);
      for (final visited in loop) {
        seen[visited] = true;
      }
      out.add(loop);
    }
    out.sort((a, b) => b.length.compareTo(a.length));
    return out;
  }

  /// The length of the longest loop.
  int get longestLoop => loops.first.length;
}

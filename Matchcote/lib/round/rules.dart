/// The law of the cote.
///
/// Players stand in a ring, and a fixture pairs them round by
/// round: each round pairs everyone at once, and by the last
/// round every pair of players has met exactly once.
///
/// Even counts fix and odd counts cannot: a round is a pairing
/// of everyone, and an odd crowd always leaves someone stood.
/// The suite covers every pair, sweeps every fixture, and
/// refuses the bake the moment any two computations part ways.
class Rules {
  Rules(this.players);

  final int players;

  /// Rounds a full fixture takes.
  int get rounds => players - 1;

  /// Games in a full round.
  int get gamesARound => players ~/ 2;

  /// Every pair the fixture must cover.
  List<(int, int)> get allPairs => [
        for (var a = 0; a < players; a++)
          for (var b = a + 1; b < players; b++) (a, b),
      ];

  /// Every perfect pairing of [free] players avoiding [used]
  /// pairs.
  List<List<(int, int)>> pairings(
      List<int> free, Set<(int, int)> used) {
    if (free.isEmpty) return [[]];
    if (free.length.isOdd) return [];
    final first = free.first;
    final out = <List<(int, int)>>[];
    for (final second in free.skip(1)) {
      final pair = (first, second);
      if (used.contains(pair)) continue;
      final rest = [
        for (final player in free)
          if (player != first && player != second) player,
      ];
      for (final tail in pairings(rest, used)) {
        out.add([pair, ...tail]);
      }
    }
    return out;
  }

  /// How many full fixtures extend the [given] rounds, counting
  /// round order.
  int fixtures(List<List<(int, int)>> given) {
    final used = <(int, int)>{
      for (final round in given) ...round,
    };
    var count = 0;
    void walk(Set<(int, int)> covered, int roundsDone) {
      if (roundsDone == rounds) {
        count++;
        return;
      }
      for (final pairing
          in pairings(List.generate(players, (p) => p), covered)) {
        walk({...covered, ...pairing}, roundsDone + 1);
      }
    }

    walk(used, given.length);
    return count;
  }

  /// One full fixture extending [given], or null.
  List<List<(int, int)>>? fixture(List<List<(int, int)>> given) {
    final used = <(int, int)>{
      for (final round in given) ...round,
    };
    List<List<(int, int)>>? found;
    void walk(Set<(int, int)> covered,
        List<List<(int, int)>> rounds_) {
      if (found != null) return;
      if (rounds_.length == rounds) {
        found = List.of(rounds_);
        return;
      }
      for (final pairing
          in pairings(List.generate(players, (p) => p), covered)) {
        walk({...covered, ...pairing}, [...rounds_, pairing]);
        if (found != null) return;
      }
    }

    walk(used, List.of(given));
    return found;
  }

  /// Whether a finished fixture covers every pair exactly once
  /// with every round a full pairing.
  bool covers(List<List<(int, int)>> fixture) {
    if (fixture.length != rounds) return false;
    final seen = <(int, int)>{};
    for (final round in fixture) {
      if (round.length != gamesARound) return false;
      final stood = <int>{};
      for (final (a, b) in round) {
        if (!stood.add(a) || !stood.add(b)) return false;
        if (!seen.add((a, b))) return false;
      }
    }
    return seen.length == allPairs.length;
  }
}

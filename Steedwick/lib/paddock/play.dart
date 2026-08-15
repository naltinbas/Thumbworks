import 'errand.dart';
import 'rules.dart';

/// An errand being ridden. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.errand, this.standing, this.picked, this.moves, this.before);

  factory Play.of(Errand errand) => Play._(errand, List.of(Rules.home), null, 0, null);

  /// A play stood at a standing, for the mark and the tests.
  factory Play.standing(Errand errand, Standing standing) =>
      Play._(errand, List.of(standing), null, 1, null);

  final Errand errand;

  /// Where each steed stands.
  final Standing standing;

  /// The steed picked to move, or null.
  final int? picked;

  /// Moves made, counted every one.
  final int moves;

  final Play? before;

  /// The line past which the hopeless errand admits it.
  static const gaveUpAt = 12;

  bool get isDone => errand.meets(standing);

  bool get gaveUp => !errand.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// The steed in a stall, or null.
  int? steedAt(int stall) {
    final at = standing.indexOf(stall);
    return at < 0 ? null : at;
  }

  /// The stalls the picked steed may move to.
  List<int> get openTo => picked == null
      ? const []
      : [for (final to in Rules.movesFrom(standing[picked!])) if (!standing.contains(to)) to];

  /// Taps a stall: picks the steed there, unpicks it, or moves the
  /// picked steed there when a knight may.
  Play tap(int stall) {
    if (isOver || stall < 0 || stall >= Rules.stalls) return this;
    final steed = steedAt(stall);
    if (steed != null) {
      return Play._(errand, standing, picked == steed ? null : steed, moves, before);
    }
    if (picked == null || !openTo.contains(stall)) return this;
    final next = [for (var j = 0; j < 4; j++) j == picked ? stall : standing[j]];
    return Play._(errand, next, null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The order of the steeds round the ring, as they stand.
  List<int> get orderRound => Rules.orderRound(standing);

  /// What the show-me points at: (steed, stall) for the next move of
  /// a fewest ride from here to the asking; null when none lands.
  (int, int)? get next {
    if (isOver || !errand.winnable) return null;
    // Ride out from here and pick the nearest standing that meets
    // the asking, then step back along parents to the first move.
    final walk = _walkFrom(standing);
    String? best;
    for (final entry in walk.fewest.entries) {
      if (!errand.meets(walk.standings[entry.key]!)) continue;
      if (best == null || entry.value < walk.fewest[best]!) best = entry.key;
    }
    if (best == null) return null;
    var k = best;
    while (walk.parent[k] != null && walk.parent[k] != Rules.key(standing)) {
      k = walk.parent[k]!;
    }
    final to = walk.standings[k]!;
    for (var i = 0; i < 4; i++) {
      if (to[i] != standing[i]) return (i, to[i]);
    }
    return null;
  }

  static ({Map<String, int> fewest, Map<String, Standing> standings, Map<String, String?> parent}) _walkFrom(Standing from) {
    final fewest = <String, int>{Rules.key(from): 0};
    final standings = <String, Standing>{Rules.key(from): List.of(from)};
    final parent = <String, String?>{Rules.key(from): null};
    final queue = [List.of(from)];
    var head = 0;
    while (head < queue.length) {
      final s = queue[head++];
      for (final n in Rules.nextStandings(s)) {
        final nk = Rules.key(n);
        if (fewest.containsKey(nk)) continue;
        fewest[nk] = fewest[Rules.key(s)]! + 1;
        standings[nk] = n;
        parent[nk] = Rules.key(s);
        queue.add(n);
      }
    }
    return (fewest: fewest, standings: standings, parent: parent);
  }
}

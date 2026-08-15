import 'dart:collection';

/// The four steeds' stalls, pale one and two then dark three and
/// four, each a stall nought to eight across the three-by-three
/// paddock, top row first.
typedef Standing = List<int>;

/// The law of the paddock.
///
/// Nine stalls in a square, four steeds in the corners, two pale
/// at the top and two dark at the bottom, and a steed moves as a
/// knight does: two stalls along and one across, into an empty
/// stall. Guarini set the puzzle in 1512: swap the pale for the
/// dark. It takes sixteen moves. The reason it can be done at all,
/// and the reason the two pale steeds can never change places
/// with each other, is one and the same: a knight's moves on the
/// eight outer stalls run round in a single ring, and steeds on a
/// ring cannot pass one another, so their order round the ring
/// never changes.
class Rules {
  Rules();

  static const stalls = 9;

  /// The four home stalls: pale at the top corners, dark at the
  /// bottom.
  static const home = <int>[0, 2, 6, 8];

  /// The eight outer stalls in the order a knight rides them round.
  static const ring = <int>[0, 5, 6, 1, 8, 3, 2, 7];

  /// Where a knight may go from a stall.
  static List<int> movesFrom(int stall) {
    final row = stall ~/ 3, col = stall % 3;
    final out = <int>[];
    for (final (dr, dc) in const [(1, 2), (2, 1), (-1, 2), (-2, 1), (1, -2), (2, -1), (-1, -2), (-2, -1)]) {
      final r = row + dr, c = col + dc;
      if (r >= 0 && r < 3 && c >= 0 && c < 3) out.add(r * 3 + c);
    }
    return out;
  }

  /// The knight's moves run round the outer stalls in one ring:
  /// each stall's two moves are its two neighbours on the ring, and
  /// the middle stall has none.
  static bool ringHolds() {
    if (movesFrom(4).isNotEmpty) return false;
    for (var i = 0; i < ring.length; i++) {
      final here = ring[i];
      final next = ring[(i + 1) % ring.length];
      final prev = ring[(i + ring.length - 1) % ring.length];
      final moves = movesFrom(here)..sort();
      final wanted = [next, prev]..sort();
      if ('$moves' != '$wanted') return false;
    }
    return true;
  }

  /// The order of the steeds round the ring, read from steed one:
  /// which steed comes next round, and next, and next.
  static List<int> orderRound(Standing standing) {
    final byRing = [0, 1, 2, 3]
      ..sort((a, b) => ring.indexOf(standing[a]) - ring.indexOf(standing[b]));
    final from = byRing.indexOf(0);
    return [for (var i = 0; i < 4; i++) byRing[(from + i) % 4]];
  }

  static String key(Standing s) => s.join(',');

  /// Every standing a knight's ride can reach from home, with the
  /// fewest moves to each and how many fewest rides there are.
  static ({Map<String, int> fewest, Map<String, int> rides, Map<String, Standing> standings, Map<String, String?> parent}) walk() {
    final fewest = <String, int>{};
    final rides = <String, int>{};
    final standings = <String, Standing>{};
    final parent = <String, String?>{};
    final queue = Queue<Standing>();
    fewest[key(home)] = 0;
    rides[key(home)] = 1;
    standings[key(home)] = List.of(home);
    parent[key(home)] = null;
    queue.add(List.of(home));
    while (queue.isNotEmpty) {
      final s = queue.removeFirst();
      final k = key(s);
      for (final next in nextStandings(s)) {
        final nk = key(next);
        if (!fewest.containsKey(nk)) {
          fewest[nk] = fewest[k]! + 1;
          rides[nk] = rides[k]!;
          standings[nk] = next;
          parent[nk] = k;
          queue.add(next);
        } else if (fewest[nk] == fewest[k]! + 1) {
          rides[nk] = rides[nk]! + rides[k]!;
        }
      }
    }
    return (fewest: fewest, rides: rides, standings: standings, parent: parent);
  }

  /// Every standing one move away.
  static List<Standing> nextStandings(Standing s) => [
        for (var i = 0; i < 4; i++)
          for (final to in movesFrom(s[i]))
            if (!s.contains(to)) [for (var j = 0; j < 4; j++) j == i ? to : s[j]],
      ];

  /// Every standing there is: four steeds on the eight outer stalls.
  static void allStandings(void Function(Standing) visit) {
    final s = <int>[];
    void place() {
      if (s.length == 4) {
        visit(List.of(s));
        return;
      }
      for (final stall in ring) {
        if (s.contains(stall)) continue;
        s.add(stall);
        place();
        s.removeLast();
      }
    }

    place();
  }
}

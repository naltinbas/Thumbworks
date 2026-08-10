/// A row: the order the bells sound in, lightest first when in rounds.
///
/// Four bells are written 1234 in rounds. A row is a permutation of them, and
/// there are twenty four.
typedef BellRow = List<int>;

/// One change: which pairs of places swap between rows.
///
/// The rule of the tower is the rule of the bells themselves: a bell swinging
/// full circle can be held or let go a little, so between one row and the
/// next it can keep its place or trade with a neighbour, and no more. A
/// change is therefore a set of adjacent swaps that do not touch.
class Change {
  const Change(this.name, this.swaps);

  final String name;

  /// Each swap as the lower place of the pair, places counted from 0.
  final List<int> swaps;

  BellRow apply(BellRow row) {
    final next = List.of(row);
    for (final place in swaps) {
      final held = next[place];
      next[place] = next[place + 1];
      next[place + 1] = held;
    }
    return next;
  }
}

/// A tower: how many bells, and the changes the tower allows.
class Tower {
  Tower({required this.name, required this.bells, required this.changes});

  final String name;
  final int bells;
  final List<Change> changes;

  /// Rounds: every bell in its own place.
  BellRow get rounds => [for (var bell = 0; bell < bells; bell++) bell];

  /// How many rows there are.
  int get rows {
    var all = 1;
    for (var bell = 2; bell <= bells; bell++) {
      all *= bell;
    }
    return all;
  }

  /// A row packed as one number, for sets and maps.
  int keyOf(BellRow row) {
    var key = 0;
    for (final bell in row) {
      key = key * bells + bell;
    }
    return key;
  }

  static String spoken(BellRow row) =>
      row.map((bell) => '${bell + 1}').join('');
}

/// The towers that ship ring on three or four bells.
class Towers {
  const Towers._();

  /// The changes on four bells: cross swaps both pairs, and the three
  /// single swaps each hold two bells still.
  static Tower four(String name) => Tower(
        name: name,
        bells: 4,
        changes: const [
          Change('cross', [0, 2]),
          Change('near', [0]),
          Change('mid', [1]),
          Change('far', [2]),
        ],
      );

  static Tower three(String name) => Tower(
        name: name,
        bells: 3,
        changes: const [
          Change('near', [0]),
          Change('far', [1]),
        ],
      );
}

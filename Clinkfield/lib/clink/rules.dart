/// The law of the feast.
///
/// Guests round a table, clinking in pairs, and each guest's
/// count is how many they clinked. The pigeonhole law says the
/// counts can never all differ: n different counts among nought
/// to n less one must use them all, and the wallflower who
/// clinked nobody cannot share a feast with the toast of the
/// table who clinked everyone, the wallflower included. The
/// sweep raises every feast there is and never catches it out.
class Rules {
  Rules(this.guests)
      : pairs = [
          for (var a = 0; a < guests; a++)
            for (var b = a + 1; b < guests; b++) (a, b),
        ];

  final int guests;

  /// Every pair of the table, low guest first.
  final List<(int, int)> pairs;

  /// Each guest's clink count under a wiring, one bool per pair.
  List<int> counts(List<bool> clinked) {
    final held = List.filled(guests, 0);
    for (var at = 0; at < pairs.length; at++) {
      if (clinked[at]) {
        held[pairs[at].$1]++;
        held[pairs[at].$2]++;
      }
    }
    return held;
  }

  /// How many different counts a feast shows.
  int distinct(List<bool> clinked) => counts(clinked).toSet().length;

  /// Every feast of the table, walked; calls [visit] with each.
  void feasts(void Function(List<bool>) visit) {
    final clinked = List.filled(pairs.length, false);
    void raise(int from) {
      if (from == pairs.length) {
        visit(clinked);
        return;
      }
      clinked[from] = false;
      raise(from + 1);
      clinked[from] = true;
      raise(from + 1);
    }

    raise(0);
  }

  /// How many feasts show exactly [asked] different counts.
  int waysTo(int asked) {
    var ways = 0;
    feasts((clinked) {
      if (distinct(clinked) == asked) ways++;
    });
    return ways;
  }

  /// The tally of feasts by their count of different counts.
  Map<int, int> spread() {
    final tally = <int, int>{};
    feasts((clinked) {
      final held = distinct(clinked);
      tally[held] = (tally[held] ?? 0) + 1;
    });
    return tally;
  }

  /// The wallflower argument, executed on one feast: whenever
  /// the counts hold both nought and the full table, something
  /// is wrong. True when the feast is possible, which is
  /// always.
  bool wallflowerHolds(List<bool> clinked) {
    final held = counts(clinked).toSet();
    return !(held.contains(0) && held.contains(guests - 1));
  }

  /// The laws over every feast: no feast shows all-different
  /// counts, the wallflower argument stands on each, and every
  /// one-count feast is regular, the two-regulars being rings.
  bool lawsHold() {
    var sound = true;
    feasts((clinked) {
      if (distinct(clinked) == guests) sound = false;
      if (!wallflowerHolds(clinked)) sound = false;
      if (guests == 5 && distinct(clinked) == 1) {
        final count = counts(clinked).first;
        if (count != 0 && count != 2 && count != 4) sound = false;
      }
    });
    return sound;
  }
}

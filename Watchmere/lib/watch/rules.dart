/// The law of the night.
///
/// Twelve hours on the mere wall, and watches of fixed lengths
/// slid along them. Two watches overlap when they share an
/// hour. Helly's law on a line says that when every pair
/// overlaps, some hour sits inside every watch at once: the
/// latest riser and the earliest turner-in overlap as a pair,
/// and their shared hour serves everybody. The sweep slides
/// every dialling there is and never catches the law out.
class Rules {
  Rules(this.lengths);

  /// The watches' lengths, fixed per mere.
  final List<int> lengths;

  /// The hours on the wall.
  static const day = 12;

  /// Where a watch may start.
  int startsOf(int watch) => day - lengths[watch] + 1;

  /// Whether two dialled watches share an hour.
  bool overlap(List<int> starts, int one, int two) {
    final lo = starts[one] > starts[two] ? starts[one] : starts[two];
    final hiOne = starts[one] + lengths[one] - 1;
    final hiTwo = starts[two] + lengths[two] - 1;
    return lo <= (hiOne < hiTwo ? hiOne : hiTwo);
  }

  /// How many pairs overlap.
  int pairsOverlapping(List<int> starts) {
    var pairs = 0;
    for (var one = 0; one < lengths.length; one++) {
      for (var two = one + 1; two < lengths.length; two++) {
        if (overlap(starts, one, two)) pairs++;
      }
    }
    return pairs;
  }

  int get allPairs => lengths.length * (lengths.length - 1) ~/ 2;

  /// The hours inside every watch, by arithmetic alone: the
  /// latest start to the earliest end.
  (int, int)? commonHours(List<int> starts) {
    var lo = 0;
    var hi = day - 1;
    for (var watch = 0; watch < lengths.length; watch++) {
      if (starts[watch] > lo) lo = starts[watch];
      final end = starts[watch] + lengths[watch] - 1;
      if (end < hi) hi = end;
    }
    return lo <= hi ? (lo, hi) : null;
  }

  /// Every dialling, walked; calls [visit] with each. The sweep
  /// the checker and the suite share.
  void diallings(void Function(List<int>) visit) {
    final starts = List.filled(lengths.length, 0);
    void slide(int watch) {
      if (watch == lengths.length) {
        visit(starts);
        return;
      }
      for (var start = 0; start < startsOf(watch); start++) {
        starts[watch] = start;
        slide(watch + 1);
      }
    }

    slide(0);
  }

  /// How many diallings land an asking of [pairs] overlapping
  /// and, when [common] is asked, exactly that many shared
  /// hours; [common] nought asks for none at all.
  int waysTo(int pairs, {int? common}) {
    var ways = 0;
    diallings((starts) {
      if (pairsOverlapping(starts) != pairs) return;
      if (common != null) {
        final held = commonHours(starts);
        final width = held == null ? 0 : held.$2 - held.$1 + 1;
        if (width != common) return;
      }
      ways++;
    });
    return ways;
  }

  /// Helly held over every dialling: all pairs overlapping
  /// always leaves a common hour. True when nothing breaks.
  bool lawHolds() {
    var sound = true;
    diallings((starts) {
      if (pairsOverlapping(starts) == allPairs &&
          commonHours(starts) == null) {
        sound = false;
      }
    });
    return sound;
  }
}

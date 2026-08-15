/// A run of milestones: the first and the last, both counted.
typedef Run = (int, int);

/// The law of the lane: runs of two or more milestones in a row, and
/// what they add up to.
class Rules {
  const Rules(this.count);

  /// The count asked, and the last milestone on the lane.
  final int count;

  /// What a run adds up to: so many stones, times the average.
  static int sum(Run run) => (run.$1 + run.$2) * (run.$2 - run.$1 + 1) ~/ 2;

  static int length(Run run) => run.$2 - run.$1 + 1;

  bool lands(Run run) => run.$1 >= 1 && run.$2 <= count && length(run) >= 2 && sum(run) == count;

  /// Every run of two or more within the lane, visited in turn.
  void runs(void Function(Run) visit) {
    for (var a = 1; a <= count; a++) {
      for (var b = a + 1; b <= count; b++) {
        visit((a, b));
      }
    }
  }

  int get runCount => count * (count - 1) ~/ 2;

  /// The sweep: runs that add to the count, and runs in all.
  (int, int) sweep() {
    var ways = 0, all = 0;
    runs((run) {
      all++;
      if (lands(run)) ways++;
    });
    return (ways, all);
  }

  /// The runs that land, in order of their first stone.
  List<Run> landings() {
    final out = <Run>[];
    runs((run) {
      if (lands(run)) out.add(run);
    });
    return out;
  }

  /// The odd divisors of the count greater than one, with no sweep of
  /// runs: each gives a run, and that is all the runs there are.
  static List<int> oddDivisors(int n) => [
        for (var d = 3; d <= n; d += 2)
          if (n % d == 0) d,
      ];

  /// The run an odd divisor gives: d stones centred on n/d when the
  /// centre stands far enough from the start, else the run of 2n/d
  /// stones that reaches from just past the fold to the mirror of it.
  static Run runFor(int n, int d) {
    final middle = n ~/ d;
    final half = (d - 1) ~/ 2;
    if (middle - half >= 1) return (middle - half, middle + half);
    // The stones from -(middle - half - 1) ... cancel: the run is
    // half - middle + 1 through half + middle.
    return (half - middle + 1, half + middle);
  }

  /// Runs built from the odd divisors, sorted by first stone.
  static List<Run> byOddDivisors(int n) =>
      [for (final d in oddDivisors(n)) runFor(n, d)]..sort((a, b) => a.$1 - b.$1);

  static bool isPowerOfTwo(int n) => n > 0 && (n & (n - 1)) == 0;
}

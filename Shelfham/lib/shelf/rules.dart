/// The law of the shelf.
///
/// Books of every height from shortest to tallest stand in a
/// row. A step down is a book standing just before a shorter
/// one, and the asking is always a count of steps down.
///
/// The counts are Euler's: across a shelf of n books the
/// orderings split by steps down into the Eulerian numbers, the
/// same row read forwards or backwards. They are checked three
/// ways that share nothing: the census reads the steps off the
/// shelf; the sweep stands every ordering and counts; the
/// recurrence builds each count from the row before; and the
/// reversal pairs every ordering with its mirror, swapping k
/// steps for n minus one minus k. The suite refuses the bake
/// the moment any two part ways.
class Rules {
  Rules(this.books);

  final int books;

  /// The steps down in an ordering: each place where a book
  /// stands just before a shorter one.
  static List<int> stepsDown(List<int> order) => [
        for (var at = 0; at + 1 < order.length; at++)
          if (order[at] > order[at + 1]) at,
      ];

  /// Every ordering of the shelf, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  void orderings(void Function(List<int>) visit) {
    final order = List.generate(books, (at) => at);
    void walk(int at) {
      if (at == books) {
        visit(order);
        return;
      }
      for (var swap = at; swap < books; swap++) {
        final held = order[at];
        order[at] = order[swap];
        order[swap] = held;
        walk(at + 1);
        order[swap] = order[at];
        order[at] = held;
      }
    }

    walk(0);
  }

  /// How many orderings keep exactly [steps] steps down.
  int waysTo(int steps) {
    var count = 0;
    orderings((order) {
      if (stepsDown(order).length == steps) count++;
    });
    return count;
  }

  /// One ordering keeping exactly [steps] steps down, or null.
  List<int>? ordering(int steps) {
    List<int>? found;
    orderings((order) {
      if (found == null && stepsDown(order).length == steps) {
        found = List.of(order);
      }
    });
    return found;
  }

  /// Euler's recurrence: the count at (n, k) is (k + 1) times
  /// the count at (n - 1, k), plus (n - k) times the count at
  /// (n - 1, k - 1).
  static int eulerian(int n, int k) {
    if (k < 0 || k >= n) return 0;
    if (n == 1) return k == 0 ? 1 : 0;
    return (k + 1) * eulerian(n - 1, k) +
        (n - k) * eulerian(n - 1, k - 1);
  }

  /// Whether the reversal pairs the counts: reversing every
  /// ordering must swap k steps for books - 1 - k.
  bool reversalPairs() {
    var sound = true;
    orderings((order) {
      final forwards = stepsDown(order).length;
      final backwards =
          stepsDown(order.reversed.toList()).length;
      if (forwards + backwards != books - 1) sound = false;
    });
    return sound;
  }
}

/// The law of the sampler.
///
/// A row of stitches, each in madder or indigo. A ladder is three
/// stitches evenly spaced sharing a thread: a start, a step, and
/// twice the step, all one colour. The sampler rule is to thread
/// the row with no ladder in it.
///
/// How long a row can stay ladder-free is van der Waerden's old
/// business: eight stitches leave exactly six threadings alive,
/// and nine leave none. It is checked more ways than one: the
/// census reads every ladder off the row; the sweep threads
/// every row there is and counts; and the prefix ledger re-adds
/// the sweep by first-three-stitches, the parts summing to the
/// whole. The suite refuses the bake the moment any two part
/// ways.
class Rules {
  Rules(this.stitches);

  final int stitches;

  /// Every ladder a threading holds: (start, step) pairs with all
  /// three stitches sharing a thread.
  List<(int, int)> ladders(List<String> threads) => [
        for (var start = 0; start < stitches; start++)
          for (var step = 1; start + 2 * step < stitches; step++)
            if (threads[start] == threads[start + step] &&
                threads[start] == threads[start + 2 * step])
              (start, step),
      ];

  bool ladderFree(List<String> threads) =>
      ladders(threads).isEmpty;

  /// Every threading of the row, walked; calls [visit] with each.
  void threadings(void Function(List<String>) visit) {
    final row = List.filled(stitches, 'R');
    void walk(int at) {
      if (at == stitches) {
        visit(row);
        return;
      }
      for (final thread in const ['R', 'B']) {
        row[at] = thread;
        walk(at + 1);
      }
    }

    walk(0);
  }

  /// How many threadings stay ladder-free.
  int ways() {
    var count = 0;
    threadings((row) {
      if (ladderFree(row)) count++;
    });
    return count;
  }

  /// How many ladder-free threadings begin with [prefix].
  int waysFrom(List<String> prefix) {
    var count = 0;
    threadings((row) {
      for (var at = 0; at < prefix.length; at++) {
        if (row[at] != prefix[at]) return;
      }
      if (ladderFree(row)) count++;
    });
    return count;
  }

  /// One ladder-free threading beginning with [prefix], or null.
  List<String>? threading(List<String> prefix) {
    List<String>? found;
    threadings((row) {
      if (found != null) return;
      for (var at = 0; at < prefix.length; at++) {
        if (row[at] != prefix[at]) return;
      }
      if (ladderFree(row)) found = List.of(row);
    });
    return found;
  }

  /// The prefix ledger: the ways, re-added by every possible
  /// first three stitches. Must equal [ways].
  int waysByPrefix() {
    var total = 0;
    for (final a in const ['R', 'B']) {
      for (final b in const ['R', 'B']) {
        for (final c in const ['R', 'B']) {
          total += waysFrom([a, b, c]);
        }
      }
    }
    return total;
  }
}

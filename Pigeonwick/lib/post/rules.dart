/// The law of the round.
///
/// Letters and pigeonholes, one of each to a cottage, and a
/// postman with a grudge: a letter posted to its own hole is
/// home, and the asking is usually that none should be.
///
/// The deranged rounds are counted three ways that share
/// nothing: the sweep posts every full round and reads the homes
/// off each; the recurrence builds the count from the two sizes
/// before, (n - 1) times the pair of them; and the round figure
/// of n! over e lands on the same number every time. The suite
/// refuses the bake the moment any two part ways.
class Rules {
  Rules(this.letters);

  final int letters;

  /// Every full round of the post, walked; calls [visit] with
  /// each: posting[letter] = hole.
  void rounds(void Function(List<int>) visit) {
    final posting = List.filled(letters, -1);
    final taken = List.filled(letters, false);
    void walk(int letter) {
      if (letter == letters) {
        visit(posting);
        return;
      }
      for (var hole = 0; hole < letters; hole++) {
        if (taken[hole]) continue;
        taken[hole] = true;
        posting[letter] = hole;
        walk(letter + 1);
        taken[hole] = false;
      }
    }

    walk(0);
  }

  /// The letters home in a posting: each in its own hole.
  static List<int> homes(List<int> posting) => [
        for (var letter = 0; letter < posting.length; letter++)
          if (posting[letter] == letter) letter,
      ];

  /// How many full rounds keep exactly [home] letters home.
  int waysTo(int home) {
    var count = 0;
    rounds((posting) {
      if (homes(posting).length == home) count++;
    });
    return count;
  }

  /// One full round keeping [home] letters home, or null.
  List<int>? round(int home) {
    List<int>? found;
    rounds((posting) {
      if (found == null && homes(posting).length == home) {
        found = List.of(posting);
      }
    });
    return found;
  }

  /// The subfactorial by its recurrence: nothing home on n
  /// letters is (n - 1) times the pair of counts before it.
  static int deranged(int n) {
    if (n == 0) return 1;
    if (n == 1) return 0;
    return (n - 1) * (deranged(n - 1) + deranged(n - 2));
  }

  /// The round figure of n! over e, done in integers: floor of
  /// (n! + 1) / e via the alternating sum, which lands exactly.
  static int byE(int n) {
    // n! * (1 - 1/1! + 1/2! - ...) computed as exact integers.
    var factorial = 1;
    for (var at = 2; at <= n; at++) {
      factorial *= at;
    }
    var sum = 0;
    var term = factorial;
    var sign = 1;
    for (var k = 0; k <= n; k++) {
      sum += sign * term ~/ 1;
      // term = n! / k!; step down for k+1.
      term = term ~/ (k + 1);
      sign = -sign;
    }
    return sum;
  }
}

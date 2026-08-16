/// Runs of consecutive odd numbers: the first odd number and how many,
/// what they add to, and the two squares whose difference that is.
class Rules {
  /// The first odd number runs from 1 to [firstMost], the count from 1
  /// to [countMost].
  static const firstMost = 99, countMost = 20;

  static int get settings => (firstMost + 1) ~/ 2 * countMost;

  /// The odd numbers of a run: [first], first + 2, and on, [count] of them.
  static List<int> run(int first, int count) => [for (var i = 0; i < count; i++) first + 2 * i];

  /// What the run adds to, added out. The first voice.
  static int sumByAdding(int first, int count) => run(first, count).fold(0, (a, b) => a + b);

  /// The inner square's side: the odd numbers below [first] add to it
  /// squared, (first - 1) / 2 of them.
  static int inner(int first) => (first - 1) ~/ 2;

  /// The outer square's side: the inner and the run together.
  static int outer(int first, int count) => inner(first) + count;

  /// What the run adds to, by the squares: the outer squared less the
  /// inner squared. The second voice, nothing added.
  static int sumBySquares(int first, int count) => outer(first, count) * outer(first, count) - inner(first) * inner(first);

  /// Every run on the dials that adds to [n]: (first, count) pairs.
  static List<(int, int)> runsTo(int n) => [
        for (var count = 1; count <= countMost; count++)
          for (var first = 1; first <= firstMost; first += 2)
            if (sumBySquares(first, count) == n) (first, count),
      ];

  /// A run told: '5 + 7 + 9'.
  static String told(int first, int count) => run(first, count).join(' + ');
}

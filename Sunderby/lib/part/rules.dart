/// The arithmetic of the parts: a whole number sundered into parts,
/// order set aside. Two voices for Euler's theorem: the sweep, every
/// partition of every number to thirty laid out and the all-different
/// and the all-odd ones counted; and Glaisher's folding, every all-odd
/// partition folded into an all-different one, pairs of equal parts
/// merged until none are alike, which lands on each all-different
/// partition exactly once. And the turning: a partition read down its
/// columns, which swaps the count of parts with the largest part.
class Rules {
  /// How far the sweep runs.
  static const top = 30;

  /// Every partition of [n], parts largest first, in order.
  static List<List<int>> partitions(int n) {
    final out = <List<int>>[];
    final parts = <int>[];
    void go(int left, int most) {
      if (left == 0) {
        out.add(List.of(parts));
        return;
      }
      for (var p = most < left ? most : left; p >= 1; p--) {
        parts.add(p);
        go(left - p, p);
        parts.removeLast();
      }
    }

    go(n, n);
    return out;
  }

  static bool allDifferent(List<int> parts) => parts.toSet().length == parts.length;
  static bool allOdd(List<int> parts) => parts.every((p) => p.isOdd);
  static bool allEven(List<int> parts) => parts.every((p) => p.isEven);

  /// Glaisher's folding: while two parts are alike, merge them into one
  /// twice the size; the result has all its parts different.
  static List<int> fold(List<int> parts) {
    final bag = List.of(parts)..sort((a, b) => b - a);
    while (true) {
      var merged = false;
      for (var i = 0; i + 1 < bag.length; i++) {
        if (bag[i] == bag[i + 1]) {
          bag[i] = bag[i] * 2;
          bag.removeAt(i + 1);
          bag.sort((a, b) => b - a);
          merged = true;
          break;
        }
      }
      if (!merged) return bag;
    }
  }

  /// The turning: the partition read down its columns, part i of the
  /// turned being how many parts are at least i.
  static List<int> turned(List<int> parts) {
    if (parts.isEmpty) return [];
    return [for (var i = 1; i <= parts.first; i++) parts.where((p) => p >= i).length];
  }

  /// A partition told: '5 + 2 + 1'.
  static String told(List<int> parts) => parts.join(' + ');
}

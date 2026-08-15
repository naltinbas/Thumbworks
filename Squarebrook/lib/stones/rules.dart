/// The law of the stones: square flagstones of one, four, nine, sixteen
/// and up, picked with repeats to make a number.
class Rules {
  const Rules();

  /// The square stones up to [n]: 1, 4, 9, ... not more than n.
  static List<int> stones(int n) => [for (var s = 1; s * s <= n; s++) s * s];

  /// Every picking of [k] stones from those up to [n], repeats allowed,
  /// told once each as a rising list, with those making [n] counted:
  /// (making, all).
  static (int, int) sweep(int n, int k) {
    final st = stones(n);
    var making = 0, all = 0;
    void go(int from, int left, int sum) {
      if (left == 0) {
        all++;
        if (sum == n) making++;
        return;
      }
      for (var i = from; i < st.length; i++) {
        go(i, left - 1, sum + st[i]);
      }
    }

    go(0, k, 0);
    return (making, all);
  }

  /// The pickings of [k] stones that make [n], each a rising list.
  static List<List<int>> makings(int n, int k) {
    final st = stones(n);
    final out = <List<int>>[];
    void go(int from, List<int> so, int sum) {
      if (so.length == k) {
        if (sum == n) out.add(List.of(so));
        return;
      }
      for (var i = from; i < st.length; i++) {
        if (sum + st[i] > n) break;
        go(i, [...so, st[i]], sum + st[i]);
      }
    }

    go(0, [], 0);
    return out;
  }

  /// The fewest stones that make [n], by the sweep, one to four.
  static int fewest(int n) {
    for (var k = 1; k <= 4; k++) {
      if (makings(n, k).isNotEmpty) return k;
    }
    return 5;
  }

  /// Legendre's law: three squares make [n] exactly when n is not four to
  /// a power times a number seven more than a multiple of eight.
  static bool threeSuffice(int n) {
    var m = n;
    while (m % 4 == 0) {
      m ~/= 4;
    }
    return m % 8 != 7;
  }

  /// A square leaves 0, 1 or 4 by eight, so [k] squares leave one of the
  /// sums of k of those by eight: the leavings k squares can have.
  static Set<int> leavings(int k) {
    var out = {0};
    for (var i = 0; i < k; i++) {
      out = {for (final a in out) for (final b in [0, 1, 4]) (a + b) % 8};
    }
    return out;
  }
}

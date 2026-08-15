/// The law of the whistles.
///
/// A whistle is a run of notes, high or low, and the runs of up to
/// [depth] notes stand as a tree: the root is the shepherd drawing
/// breath, and every node has a low child and a high child. Nodes are
/// numbered as a heap, the root 1, node k's low child 2k and high child
/// 2k + 1, so a node's depth is the count of notes in its whistle, and
/// one whistle is the start of another exactly when its node is an
/// ancestor of the other's.
class Rules {
  const Rules(this.depth);

  /// The most notes a whistle may have.
  final int depth;

  /// The whole, in shares: a whistle of l notes takes 2 to the (depth
  /// minus l) of these, so a one-note whistle takes half of them.
  int get whole => 1 << depth;

  /// The first node with [notes] notes; the nodes with that many run
  /// from it to twice it, less one.
  static int firstAt(int notes) => 1 << notes;

  /// Every node past the root, shortest whistles first.
  List<int> get nodes => [for (var k = 2; k < (1 << (depth + 1)); k++) k];

  /// How many notes node [k]'s whistle has.
  static int notesOf(int k) => k.bitLength - 1;

  /// The notes of node [k], the first blown first: true for high.
  static List<bool> notes(int k) => [for (var d = notesOf(k) - 1; d >= 0; d--) (k >> d) & 1 == 1];

  /// The whistle said in words: 'high, low, low'.
  static String said(int k) => notes(k).map((high) => high ? 'high' : 'low').join(', ');

  /// Whether node [a]'s whistle is the start of node [b]'s: a is an
  /// ancestor of b, and shorter.
  static bool begins(int a, int b) {
    final gap = notesOf(b) - notesOf(a);
    return gap > 0 && (b >> gap) == a;
  }

  /// Every pair among [marks] where one whistle is the start of another,
  /// the shorter first, in the order the marks stand.
  List<(int, int)> clashes(List<int> marks) => [
        for (var i = 0; i < marks.length; i++)
          for (var j = 0; j < marks.length; j++)
            if (i != j && begins(marks[i], marks[j])) (marks[i], marks[j]),
      ];

  /// Whether no whistle among [marks] is the start of another.
  bool prefixFree(List<int> marks) => clashes(marks).isEmpty;

  /// Whether some mark's whistle is the start of node [k]'s.
  bool shadowed(int k, List<int> marks) => marks.any((m) => begins(m, k));

  /// The shares [lengths] take of the whole, added up whether or not the
  /// whistles fit: Kraft's sum, in units of the whole.
  int share(Iterable<int> lengths) => lengths.fold(0, (sum, l) => sum + (1 << (depth - l)));

  /// Whether the shares come to no more than the whole: Kraft's
  /// inequality, which is exactly when some marking lands.
  bool fits(Iterable<int> lengths) => share(lengths) <= whole;

  /// Whether [marks] land the calls asked: the whistles have exactly the
  /// [lengths] asked, and none is the start of another.
  bool lands(List<int> marks, List<int> lengths) {
    if (marks.length != lengths.length) return false;
    final have = marks.map(notesOf).toList()..sort();
    final want = List.of(lengths)..sort();
    for (var i = 0; i < have.length; i++) {
      if (have[i] != want[i]) return false;
    }
    return prefixFree(marks);
  }

  /// Every marking of whistles with exactly the [lengths] asked, told
  /// once each: (landing, all), landing being those where no whistle
  /// starts another. Choices of nodes at each length, one length at a
  /// time, so no marking is told twice.
  (int, int) sweep(List<int> lengths) {
    final wanted = _counts(lengths);
    var landing = 0, all = 0;
    void go(int l, List<int> marks) {
      if (l > depth) {
        all++;
        if (prefixFree(marks)) landing++;
        return;
      }
      final m = wanted[l] ?? 0;
      final first = firstAt(l), last = 2 * first - 1;
      void choose(int from, int left, List<int> marks) {
        if (left == 0) {
          go(l + 1, marks);
          return;
        }
        for (var k = from; k <= last - left + 1; k++) {
          choose(k + 1, left - 1, [...marks, k]);
        }
      }

      choose(first, m, marks);
    }

    go(1, const []);
    return (landing, all);
  }

  /// The count of landings without the sweep: at each length, shortest
  /// first, the whistles no marked one begins are the free ones, each
  /// marked whistle of l notes taking 2 to the (length minus l) of them
  /// whatever the marks were, and the calls of that length choose among
  /// them.
  int product(List<int> lengths) {
    final wanted = _counts(lengths);
    var count = 1;
    for (var l = 1; l <= depth; l++) {
      var free = 1 << l;
      for (var shorter = 1; shorter < l; shorter++) {
        free -= (wanted[shorter] ?? 0) << (l - shorter);
      }
      count *= choose(free, wanted[l] ?? 0);
    }
    return count;
  }

  /// The shepherd's own way, no sweep: the calls shortest first, each
  /// given the leftmost whistle of its length that no given one begins,
  /// and null when some call finds none. The marks come back in the
  /// order the calls were given, shortest first, leftmost first.
  List<int>? byShepherd(List<int> lengths) {
    final sorted = List.of(lengths)..sort();
    final marks = <int>[];
    for (final l in sorted) {
      final first = firstAt(l), last = 2 * first - 1;
      int? found;
      for (var k = first; k <= last; k++) {
        if (!marks.contains(k) && !shadowed(k, marks)) {
          found = k;
          break;
        }
      }
      if (found == null) return null;
      marks.add(found);
    }
    return marks;
  }

  static Map<int, int> _counts(List<int> lengths) {
    final counts = <int, int>{};
    for (final l in lengths) {
      counts[l] = (counts[l] ?? 0) + 1;
    }
    return counts;
  }

  /// n choose k, nought when k is out of reach.
  static int choose(int n, int k) {
    if (k < 0 || n < 0 || k > n) return 0;
    var out = 1;
    for (var i = 1; i <= k; i++) {
      out = out * (n - k + i) ~/ i;
    }
    return out;
  }
}

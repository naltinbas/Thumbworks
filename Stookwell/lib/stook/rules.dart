/// The law of the stooks: partitions of a harvest of sheaves, counted
/// and turned.
class Rules {
  /// Every partition of [n], parts largest first, visited in turn.
  static void partitions(int n, void Function(List<int>) visit, {int? most}) {
    final parts = <int>[];
    void grow(int left, int cap) {
      if (left == 0) {
        visit(parts);
        return;
      }
      for (var p = cap < left ? cap : left; p >= 1; p--) {
        parts.add(p);
        grow(left - p, p);
        parts.removeLast();
      }
    }

    grow(n, most ?? n);
  }

  static bool allDistinct(List<int> parts) => parts.toSet().length == parts.length;

  static bool allOdd(List<int> parts) => parts.every((p) => p.isOdd);

  /// The partitions of [n], all told, and those with distinct parts,
  /// and those with odd parts, by walking every one.
  static (int all, int distinct, int odd) census(int n) {
    var all = 0, distinct = 0, odd = 0;
    partitions(n, (parts) {
      all++;
      if (allDistinct(parts)) distinct++;
      if (allOdd(parts)) odd++;
    });
    return (all, distinct, odd);
  }

  /// Partitions of [n] into exactly [k] distinct parts, by walking.
  static int distinctWithParts(int n, int k) {
    var count = 0;
    partitions(n, (parts) {
      if (parts.length == k && allDistinct(parts)) count++;
    });
    return count;
  }

  /// The smallest harvest that stands in [k] stooks of different sizes:
  /// 1 + 2 + ... + k.
  static int fewestFor(int k) => k * (k + 1) ~/ 2;

  /// Partitions into distinct parts for every harvest to [upTo], with
  /// no walk: the product of (1 + x^k) over every k, multiplied out.
  static List<int> distinctByProduct(int upTo) {
    final ways = List.filled(upTo + 1, 0)..[0] = 1;
    for (var k = 1; k <= upTo; k++) {
      for (var n = upTo; n >= k; n--) {
        ways[n] += ways[n - k];
      }
    }
    return ways;
  }

  /// Partitions into odd parts for every harvest to [upTo], with no
  /// walk: the product of 1 / (1 - x^k) over odd k, multiplied out.
  static List<int> oddByProduct(int upTo) {
    final ways = List.filled(upTo + 1, 0)..[0] = 1;
    for (var k = 1; k <= upTo; k += 2) {
      for (var n = k; n <= upTo; n++) {
        ways[n] += ways[n - k];
      }
    }
    return ways;
  }

  /// Glaisher's turn from odd parts to distinct ones: an odd part
  /// standing r times becomes the parts m times each power of two in
  /// r's binary writing.
  static List<int> merged(List<int> oddParts) {
    final count = <int, int>{};
    for (final p in oddParts) {
      count[p] = (count[p] ?? 0) + 1;
    }
    final out = <int>[];
    for (final e in count.entries) {
      var r = e.value, power = 1;
      while (r > 0) {
        if (r & 1 == 1) out.add(e.key * power);
        r >>= 1;
        power <<= 1;
      }
    }
    out.sort((a, b) => b - a);
    return out;
  }

  /// And back: every distinct part is an odd part times a power of
  /// two, and stands that many times.
  static List<int> split(List<int> distinctParts) {
    final out = <int>[];
    for (final p in distinctParts) {
      var m = p, times = 1;
      while (m.isEven) {
        m ~/= 2;
        times *= 2;
      }
      for (var i = 0; i < times; i++) {
        out.add(m);
      }
    }
    out.sort((a, b) => b - a);
    return out;
  }
}

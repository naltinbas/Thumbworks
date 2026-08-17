/// Five bins of grain at the almshouse, ten measures between them. A
/// share takes one measure out of a fuller bin and puts it in an
/// emptier one, but only where the fuller bin has at least two more
/// than the emptier: taking from a bin that is only one ahead would
/// leave it behind, which is not sharing out but swapping over.
///
/// However the shares are made, the fullest bin never rises, nor do the
/// two fullest together, nor the three, and so on. That is
/// majorization, and it is the whole of what a share-out can do: a
/// shape can be reached from another exactly when every one of those
/// running totals is no greater.
class Rules {
  static const bins = 5;
  static const grain = 10;

  /// Where a go opens: nine measures in the last bin and one in the
  /// fourth.
  static const opening = [0, 0, 0, 1, 9];

  static bool valid(List<int> bins) =>
      bins.length == Rules.bins &&
      bins.every((at) => at >= 0) &&
      bins.fold(0, (a, b) => a + b) == grain;

  /// Whether a measure can go from [from] to [to].
  static bool canShare(List<int> bins, int from, int to) =>
      from != to && bins[from] >= bins[to] + 2;

  static List<int> share(List<int> bins, int from, int to) {
    final out = List.of(bins);
    out[from]--;
    out[to]++;
    return out;
  }

  /// The heights, tallest first: the shape of the bins, which is what
  /// the asks are about.
  static List<int> shape(List<int> bins) =>
      List.of(bins)..sort((a, b) => b - a);

  /// The running totals of a shape, tallest first.
  static List<int> running(List<int> shape) {
    final out = <int>[];
    var at = 0;
    for (final height in shape) {
      at += height;
      out.add(at);
    }
    return out;
  }

  /// The second voice: whether [from] can reach [to] by shares, told by
  /// the running totals alone, without moving a measure.
  static bool covers(List<int> from, List<int> to) {
    final a = running(shape(from)), b = running(shape(to));
    for (var i = 0; i < bins; i++) {
      if (a[i] < b[i]) return false;
    }
    return true;
  }

  /// Every arrangement of the grain over the bins.
  static List<List<int>> arrangements() {
    final out = <List<int>>[];
    void build(int bin, int left, List<int> so) {
      if (bin == bins - 1) {
        out.add([...so, left]);
        return;
      }
      for (var take = 0; take <= left; take++) {
        build(bin + 1, left - take, [...so, take]);
      }
    }

    build(0, grain, const []);
    return out;
  }

  static int get howManyArrangements {
    var out = 1;
    for (var k = 1; k < bins; k++) {
      out = out * (grain + k) ~/ k;
    }
    return out;
  }

  /// Every shape the grain can stand in.
  static List<List<int>> shapes() {
    final seen = <String, List<int>>{};
    for (final at in arrangements()) {
      final s = shape(at);
      seen[s.join(',')] = s;
    }
    final out = seen.values.toList();
    out.sort((a, b) {
      for (var i = 0; i < bins; i++) {
        if (a[i] != b[i]) return b[i] - a[i];
      }
      return 0;
    });
    return out;
  }

  static String tellShape(List<int> shape) => shape.join(', ');

  static String tellBins(List<int> bins) => bins.join(', ');
}

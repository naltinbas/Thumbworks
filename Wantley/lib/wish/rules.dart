/// The law of the lists.
///
/// Farms round a green, each wishing for so many footpaths. A
/// wiring of paths lands the list when every farm's count comes
/// out exactly its wish. Erdos and Gallai's 1960 arithmetic
/// names the lists that can land: the wish sum even, and at
/// every k, the top k wishes at most k times k less one plus
/// what the other farms can spare. The sweep treads every yard
/// of four and five farms, 64 and 1,024 of them, and the
/// verdicts agree on every wish list there is.
class Rules {
  Rules(this.farms)
      : pairs = [
          for (var a = 0; a < farms; a++)
            for (var b = a + 1; b < farms; b++) (a, b),
        ];

  final int farms;

  /// Every pair of the green, low farm first.
  final List<(int, int)> pairs;

  /// Each farm's path count under a treading, one bool per pair.
  List<int> counts(List<bool> trodden) {
    final walked = List.filled(farms, 0);
    for (var at = 0; at < pairs.length; at++) {
      if (trodden[at]) {
        walked[pairs[at].$1]++;
        walked[pairs[at].$2]++;
      }
    }
    return walked;
  }

  /// How many treadings land a wish list exactly.
  int waysTo(List<int> wishes) {
    var ways = 0;
    treadings((trodden) {
      if (_lands(trodden, wishes)) ways++;
    });
    return ways;
  }

  bool _lands(List<bool> trodden, List<int> wishes) {
    final walked = counts(trodden);
    for (var farm = 0; farm < farms; farm++) {
      if (walked[farm] != wishes[farm]) return false;
    }
    return true;
  }

  /// Every treading of the green, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  void treadings(void Function(List<bool>) visit) {
    final trodden = List.filled(pairs.length, false);
    void tread(int from) {
      if (from == pairs.length) {
        visit(trodden);
        return;
      }
      trodden[from] = false;
      tread(from + 1);
      trodden[from] = true;
      tread(from + 1);
    }

    tread(0);
  }

  /// Erdos and Gallai's verdict on a wish list: the arithmetic
  /// voice, no searching anywhere in it.
  static bool arithmeticSays(List<int> wishes) {
    final sorted = List.of(wishes)..sort((a, b) => b - a);
    var sum = 0;
    for (final wish in sorted) {
      sum += wish;
    }
    if (sum.isOdd) return false;
    for (var k = 1; k <= sorted.length; k++) {
      var top = 0;
      for (var at = 0; at < k; at++) {
        top += sorted[at];
      }
      var spare = k * (k - 1);
      for (var at = k; at < sorted.length; at++) {
        spare += sorted[at] < k ? sorted[at] : k;
      }
      if (top > spare) return false;
    }
    return true;
  }

  /// Havel and Hakimi's build: wire the biggest wish first, to
  /// the next-biggest wishes, and repeat. Returns the paths, or
  /// null when the list cannot land. The third voice, and the
  /// hand behind the show-me.
  List<(int, int)>? build(List<int> wishes) {
    final left = [
      for (var farm = 0; farm < farms; farm++) [wishes[farm], farm],
    ];
    final paths = <(int, int)>[];
    while (true) {
      left.sort((a, b) =>
          a[0] != b[0] ? b[0] - a[0] : a[1] - b[1]);
      final top = left.first;
      if (top[0] == 0) return paths;
      if (top[0] > left.length - 1) return null;
      final take = top[0];
      top[0] = 0;
      for (var at = 1; at <= take; at++) {
        left[at][0]--;
        if (left[at][0] < 0) return null;
        final a = top[1], b = left[at][1];
        paths.add(a < b ? (a, b) : (b, a));
      }
    }
  }

  /// The three voices held together over every wish list of the
  /// green: true when nothing breaks.
  bool voicesAgree() {
    var sound = true;
    void wander(List<int> wishes) {
      if (wishes.length == farms) {
        final swept = waysTo(wishes) > 0;
        final said = arithmeticSays(wishes);
        final built = build(wishes);
        if (swept != said || swept != (built != null)) {
          sound = false;
        }
        if (built != null &&
            !_lands(_asTreading(built), wishes)) {
          sound = false;
        }
        return;
      }
      for (var wish = 0; wish < farms; wish++) {
        wander([...wishes, wish]);
      }
    }

    wander([]);
    return sound;
  }

  List<bool> _asTreading(List<(int, int)> paths) {
    final trodden = List.filled(pairs.length, false);
    for (final path in paths) {
      trodden[pairs.indexOf(path)] = true;
    }
    return trodden;
  }
}

/// The law of the yard: sacks of so many stone each, carts that carry
/// ten, and the sacks to be loaded into as few carts as will take them.
/// Every loading is a way of sharing the sacks among carts with no cart
/// past ten; the search tries every one, sack by sack into a cart in use
/// or the next fresh one, so no loading is counted twice for the carts
/// being named. The sacks' weight over ten, rounded up, is a floor no
/// loading beats. The carrier's rule, first-fit decreasing, takes the
/// sacks heaviest first and drops each into the first cart with room,
/// which never needs more than eleven ninths of the fewest carts and
/// two thirds of a cart besides, and sometimes needs one more than the
/// fewest.
class Rules {
  static const capacity = 10;

  /// How many loadings share [sacks] among exactly [carts] carts, no
  /// cart past ten, carts unnamed and sacks of a weight alike, so a
  /// loading is the weights each cart carries; and the first, as each
  /// sack's cart. [labelled] counts the sacks told apart instead.
  static (int, List<int>?) loadings(List<int> sacks, int carts, {int? atMost, bool labelled = false}) {
    final cart = List.filled(sacks.length, -1);
    final loads = List.filled(carts, 0);
    final seen = <String>{};
    var found = 0;
    List<int>? first;
    void place(int i, int used) {
      if (atMost != null && found >= atMost) return;
      if (i == sacks.length) {
        if (used == carts) {
          if (!labelled) {
            final key = pattern(sacks, cart);
            if (!seen.add(key)) return;
          }
          found++;
          first ??= List.of(cart);
        }
        return;
      }
      // Into a cart in use, or the next fresh one.
      final most = used < carts ? used + 1 : carts;
      for (var c = 0; c < most; c++) {
        if (loads[c] + sacks[i] > capacity) continue;
        loads[c] += sacks[i];
        cart[i] = c;
        place(i + 1, c == used ? used + 1 : used);
        cart[i] = -1;
        loads[c] -= sacks[i];
      }
    }

    place(0, 0);
    return (found, first);
  }

  /// A loading as the weights each cart carries, carts and sacks in
  /// order: '6,4|5,5|4,4,2'.
  static String pattern(List<int> sacks, List<int?> cartOf) {
    final carts = <int, List<int>>{};
    for (var i = 0; i < sacks.length; i++) {
      final c = cartOf[i];
      if (c != null) (carts[c] ??= []).add(sacks[i]);
    }
    final parts = carts.values.map((c) => (List.of(c)..sort((a, b) => b - a)).join(',')).toList()..sort();
    return parts.join('|');
  }

  /// The fewest carts that take [sacks].
  static int fewest(List<int> sacks) {
    for (var k = 1; k <= sacks.length; k++) {
      if (loadings(sacks, k, atMost: 1).$1 > 0) return k;
    }
    return sacks.length;
  }

  /// The floor: the sacks' weight over ten, rounded up.
  static int floor(List<int> sacks) => (sacks.fold(0, (a, b) => a + b) + capacity - 1) ~/ capacity;

  /// The carrier's rule, first-fit decreasing: the carts it fills, each
  /// a list of sacks.
  static List<List<int>> firstFitDecreasing(List<int> sacks) {
    final order = List.of(sacks)..sort((a, b) => b - a);
    final carts = <List<int>>[];
    for (final s in order) {
      var dropped = false;
      for (final c in carts) {
        if (c.fold(0, (a, b) => a + b) + s <= capacity) {
          c.add(s);
          dropped = true;
          break;
        }
      }
      if (!dropped) carts.add([s]);
    }
    return carts;
  }

  /// Whether [cartOf] loads every sack into a cart, none past ten.
  static bool sound(List<int> sacks, List<int?> cartOf, int carts) {
    if (cartOf.any((c) => c == null)) return false;
    final loads = List.filled(carts, 0);
    for (var i = 0; i < sacks.length; i++) {
      loads[cartOf[i]!] += sacks[i];
    }
    return loads.every((l) => l <= capacity);
  }
}

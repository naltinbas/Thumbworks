/// The law of the yard.
///
/// Twelve weights hang on the rack: 1, 2, 3, 4, 5, 8, 11, 17,
/// 20, 22, 23 and 24 pounds. A parcel is any handful of chosen
/// weights, and two parcels balance when they weigh the same
/// without sharing a weight. A choice is clean when no two of
/// its parcels balance, which is the same as every parcel
/// weighing differently.
///
/// The yard holds exactly one clean choice of six, and no clean
/// choice of seven exists by counting alone: seven weights make
/// 127 parcels, and no seven here weigh past 125 together. The
/// suite balances every clash, sweeps every choice, and refuses
/// the bake the moment any two computations part ways.
class Rules {
  /// The rack, lightest first.
  static const rack = [1, 2, 3, 4, 5, 8, 11, 17, 20, 22, 23, 24];

  /// The first two balancing parcels among chosen weights, both
  /// sides stripped of any shared weight; null when every parcel
  /// weighs its own.
  static (List<int>, List<int>)? balance(List<int> chosen) {
    final seen = <int, List<int>>{};
    List<(List<int>, int)> parcels = [(const [], 0)];
    for (final weight in chosen) {
      parcels = [
        for (final (parcel, sum) in parcels) ...[
          (parcel, sum),
          ([...parcel, weight], sum + weight),
        ],
      ];
    }
    for (final (parcel, sum) in parcels) {
      final other = seen[sum];
      if (other != null) {
        final left = [
          for (final weight in other)
            if (!parcel.contains(weight)) weight,
        ];
        final right = [
          for (final weight in parcel)
            if (!other.contains(weight)) weight,
        ];
        return (left, right);
      }
      seen[sum] = parcel;
    }
    return null;
  }

  static bool clean(List<int> chosen) => balance(chosen) == null;

  /// Every choice of [count] weights, walked; calls [visit] with
  /// each. The sweep the checker and the suite share.
  static void choices(
      int count, void Function(List<int>) visit) {
    final picked = <int>[];
    void walk(int from) {
      if (picked.length == count) {
        visit(picked);
        return;
      }
      for (var at = from; at < rack.length; at++) {
        picked.add(rack[at]);
        walk(at + 1);
        picked.removeLast();
      }
    }

    walk(0);
  }

  /// How many choices of [count] come clean.
  static int waysTo(int count) {
    var ways = 0;
    choices(count, (chosen) {
      if (clean(chosen)) ways++;
    });
    return ways;
  }

  /// One clean choice of [count], or null.
  static List<int>? choice(int count) {
    List<int>? found;
    choices(count, (chosen) {
      if (found == null && clean(chosen)) {
        found = List.of(chosen);
      }
    });
    return found;
  }

  /// The heaviest any [count] weights of the rack total.
  static int heaviest(int count) {
    final sorted = List.of(rack)..sort();
    return sorted
        .skip(rack.length - count)
        .fold(0, (sum, weight) => sum + weight);
  }
}

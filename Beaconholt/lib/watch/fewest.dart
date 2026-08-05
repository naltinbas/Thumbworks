import 'hills.dart';

/// The fewest beacons that light the whole country, and how it was settled.
class Watch {
  const Watch({
    required this.fewest,
    required this.where,
    required this.tried,
  });

  /// How many beacons it takes.
  final int fewest;

  /// One set of hills to put them on.
  final List<int> where;

  /// How many sets had to be looked at.
  final int tried;
}

/// Works out the fewest beacons that light every hill.
///
/// By trying sets of hills, smallest first: every set of one, then every set
/// of two, and so on. The first size that lights the country is the answer,
/// and the fact that nothing smaller was found is what makes it the fewest.
/// That is not a clever method and there is no clever method: this is the
/// kind of question where the honest way to be sure is to look at everything.
///
/// What keeps it affordable is that the country is small and the looking is
/// bits. Twenty hills is a million sets, and each is one and-with-a-mask per
/// hill in it.
class Beacons {
  const Beacons._();

  static Watch fewestFor(Country country) {
    final hills = country.count;

    for (var many = 1; many <= hills; many++) {
      final found = _ofSize(country, many);
      if (found != null) return found;
    }
    return Watch(fewest: hills, where: [], tried: 0);
  }

  /// A set of exactly this many hills that lights the country, or null.
  static Watch? _ofSize(Country country, int many) {
    final chosen = <int>[];
    var tried = 0;

    Watch? walk(int from, int lit) {
      if (chosen.length == many) {
        tried++;
        return lit == country.all
            ? Watch(fewest: many, where: List.of(chosen), tried: tried)
            : null;
      }
      // Not enough hills left to fill the set.
      if (country.count - from < many - chosen.length) return null;

      for (var hill = from; hill < country.count; hill++) {
        chosen.add(hill);
        final found = walk(hill + 1, lit | country.lights(hill));
        if (found != null) {
          return Watch(
            fewest: found.fewest,
            where: found.where,
            tried: tried + found.tried,
          );
        }
        tried++;
        chosen.removeLast();
      }
      return null;
    }

    return walk(0, 0);
  }

  /// What somebody gets by always lighting the hill that adds the most dark
  /// hills, which is the obvious way and is not the answer.
  static List<int> byGreed(Country country) {
    final chosen = <int>[];
    var lit = 0;

    while (lit != country.all) {
      var best = -1;
      var most = 0;
      for (var hill = 0; hill < country.count; hill++) {
        if (chosen.contains(hill)) continue;
        final adds = _countBits(country.lights(hill) & ~lit);
        if (adds > most) {
          most = adds;
          best = hill;
        }
      }
      if (best < 0) break;
      chosen.add(best);
      lit |= country.lights(best);
    }
    return chosen;
  }

  static int _countBits(int bits) {
    var count = 0;
    var left = bits;
    while (left != 0) {
      left &= left - 1;
      count++;
    }
    return count;
  }
}

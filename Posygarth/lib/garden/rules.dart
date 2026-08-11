/// The two answers: the plantings written straight down, and the search.
///
/// A garth of beds, each bed to hold one flower in one colour. Down every
/// row and every column, each flower appears once and each colour
/// appears once; and across the whole garth, no flower-and-colour
/// pairing repeats. Two Latin squares laid over each other with every
/// pairing fresh: the old officers problem, in bloom.
///
/// For odd sizes the planting is two lines of arithmetic: bed (r, c)
/// takes flower r + c and colour r + 2c, both wrapped. For four it is
/// the doubling trick, a known square baked and checked. For two there
/// is no planting at all, and the sweep of every attempt says so in a
/// blink. Six is the famous refusal, too large to sweep honestly here,
/// and the game does not ship it rather than assert what it has not
/// checked.
class Rules {
  const Rules._();

  /// The planting for [size], as (flower, colour) by row-major bed, or
  /// null for sizes with none.
  static List<(int, int)>? planted(int size) {
    if (size == 2) return null;
    if (size.isOdd) {
      return [
        for (var row = 0; row < size; row++)
          for (var column = 0; column < size; column++)
            ((row + column) % size, (row + 2 * column) % size),
      ];
    }
    if (size == 4) {
      // The doubled pair over GF(4), row-major, checked by the tests.
      const flowers = [0, 1, 2, 3, 1, 0, 3, 2, 2, 3, 0, 1, 3, 2, 1, 0];
      const colours = [0, 1, 2, 3, 2, 3, 0, 1, 3, 2, 1, 0, 1, 0, 3, 2];
      return [
        for (var bed = 0; bed < 16; bed++) (flowers[bed], colours[bed]),
      ];
    }
    return null;
  }

  /// Whether a full assignment is a true garth.
  static bool sound(int size, List<(int, int)> beds) {
    for (var line = 0; line < size; line++) {
      final rowFlowers = <int>{}, rowColours = <int>{};
      final colFlowers = <int>{}, colColours = <int>{};
      for (var at = 0; at < size; at++) {
        final row = beds[line * size + at];
        if (!rowFlowers.add(row.$1) || !rowColours.add(row.$2)) {
          return false;
        }
        final col = beds[at * size + line];
        if (!colFlowers.add(col.$1) || !colColours.add(col.$2)) {
          return false;
        }
      }
    }
    final pairs = <int>{};
    for (final (flower, colour) in beds) {
      if (!pairs.add(flower * size + colour)) return false;
    }
    return true;
  }

  /// Whether a part-planted garth can still be finished. Beds hold
  /// (flower, colour) or (-1, -1) while empty.
  static bool canStillPlant(int size, List<(int, int)> beds) {
    int firstEmpty() {
      for (var bed = 0; bed < beds.length; bed++) {
        if (beds[bed].$1 < 0) return bed;
      }
      return -1;
    }

    bool fits(int bed, int flower, int colour) {
      final row = bed ~/ size, column = bed % size;
      for (var at = 0; at < size; at++) {
        final inRow = beds[row * size + at];
        if (at != column && inRow.$1 >= 0) {
          if (inRow.$1 == flower || inRow.$2 == colour) return false;
        }
        final inCol = beds[at * size + column];
        if (at != row && inCol.$1 >= 0) {
          if (inCol.$1 == flower || inCol.$2 == colour) return false;
        }
      }
      for (final (f, c) in beds) {
        if (f == flower && c == colour) return false;
      }
      return true;
    }

    bool walk() {
      final bed = firstEmpty();
      if (bed < 0) return true;
      for (var flower = 0; flower < size; flower++) {
        for (var colour = 0; colour < size; colour++) {
          if (!fits(bed, flower, colour)) continue;
          beds[bed] = (flower, colour);
          if (walk()) {
            beds[bed] = (-1, -1);
            return true;
          }
          beds[bed] = (-1, -1);
        }
      }
      return false;
    }

    return walk();
  }

  /// Whether any garth of [size] exists at all, by exhausting when it is
  /// small and by planting when a planting is known.
  static bool anyExists(int size) {
    final planting = planted(size);
    if (planting != null) return sound(size, planting);
    return canStillPlant(
        size, List.filled(size * size, (-1, -1)));
  }
}

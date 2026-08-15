import 'frac.dart';

export 'frac.dart';

/// The arithmetic of the two glasses: wine in one, water in the other,
/// a spoon of wine carried into the water, and a spoon of what is then
/// in the water glass carried back. Two voices: the pouring, done in
/// exact fractions for three kinds of stir, well stirred, the wine
/// floating unstirred, and the wine sunk unstirred; and the account, the
/// wine glass ending at its old volume so its water is exactly the wine
/// it lost, and every drop of wine it lost is in the water glass.
class Rules {
  /// The glasses hold from one to this, in units.
  static const most = 10;

  /// The spoon holds from one to this.
  static const spoonMost = 5;

  /// How many settings the three dials have between them.
  static const settings = most * most * spoonMost;

  /// Whether the spoon can be filled from the wine glass at all.
  static bool pours(int wine, int water, int spoon) => spoon <= wine;

  /// After the two spoonfuls, well stirred: (water in the wine glass, wine
  /// in the water glass), each an exact fraction of a unit; null when
  /// the first spoon cannot be filled.
  static (Frac, Frac)? stirred(int wine, int water, int spoon) {
    if (!pours(wine, water, spoon)) return null;
    // The water glass holds water + spoon of wine; the spoon back takes
    // spoon/(water + spoon) of each.
    final share = Frac.of(spoon, water + spoon);
    final wineBack = share * Frac.of(spoon), waterBack = share * Frac.of(water);
    final wineLeftInWater = Frac.of(spoon) - wineBack;
    return (waterBack, wineLeftInWater);
  }

  /// Unstirred, the wine floating on the water: the spoon back takes wine
  /// first, all of it if it fits.
  static (Frac, Frac)? floating(int wine, int water, int spoon) {
    if (!pours(wine, water, spoon)) return null;
    // The spoon of wine floats; the spoon back takes spoon units from the
    // top: the whole spoonful of wine.
    return (Frac.zero, Frac.zero);
  }

  /// Unstirred, the wine sunk under the water: the spoon back takes water
  /// first, all water if the water glass held a spoonful.
  static (Frac, Frac)? sunk(int wine, int water, int spoon) {
    if (!pours(wine, water, spoon)) return null;
    // Water on top; the spoon back takes water up to a spoonful and wine
    // for the rest.
    final waterBack = water >= spoon ? spoon : water;
    final wineBack = spoon - waterBack;
    return (Frac.of(waterBack), Frac.of(spoon - wineBack));
  }

  /// The account, the second voice: the wine glass ends where it began
  /// in volume, so the water in it is exactly the wine that never came
  /// back, and that wine is in the water glass; so the two are equal
  /// whatever the stir. This is what the checker holds every pouring to.
  static bool accountHolds((Frac, Frac) pouring) => pouring.$1 == pouring.$2;

  /// Sweeps every setting: how many meet [ask], how many there are, and
  /// the first that meets it, wine climbing slowest.
  static (int, int, (int, int, int)?) sweep(bool Function(int wine, int water, int spoon) ask) {
    var met = 0, all = 0;
    (int, int, int)? first;
    for (var wine = 1; wine <= most; wine++) {
      for (var water = 1; water <= most; water++) {
        for (var spoon = 1; spoon <= spoonMost; spoon++) {
          all++;
          if (ask(wine, water, spoon)) {
            met++;
            first ??= (wine, water, spoon);
          }
        }
      }
    }
    return (met, all, first);
  }
}

/// One hamlet: what it is called, and where it sits when drawn.
class Place {
  const Place(this.name, this.x, this.y);

  final String name;

  /// Where it goes, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, so a parish is written down once and looks
  /// right on every phone.
  final double x;
  final double y;
}

/// A path that could be cut between two hamlets, and what it would cost.
class Trod {
  const Trod(this.from, this.to, this.yards);

  final int from;
  final int to;

  /// How many yards of path it would take.
  final int yards;

  bool touches(int place) => from == place || to == place;

  int otherEnd(int place) => place == from ? to : from;
}

/// A parish: hamlets, and the paths that could be cut between them.
class Parish {
  Parish({
    required this.name,
    required List<Place> places,
    required List<Trod> trods,
  })  : places = List.unmodifiable(places),
        trods = List.unmodifiable(trods);

  final String name;
  final List<Place> places;
  final List<Trod> trods;

  int get count => places.length;
  int get many => trods.length;

  Trod operator [](int trod) => trods[trod];

  /// Whether a set of paths leaves every hamlet reachable from every other.
  bool joinsItAll(Iterable<int> cut) => _sides(cut).toSet().length == 1;

  /// Which piece of the parish each hamlet is in, given a set of paths.
  List<int> _sides(Iterable<int> cut) {
    final side = [for (var place = 0; place < count; place++) place];

    int rootOf(int place) {
      var at = place;
      while (side[at] != at) {
        at = side[at];
      }
      return at;
    }

    for (final trod in cut) {
      final one = rootOf(trods[trod].from);
      final other = rootOf(trods[trod].to);
      if (one != other) side[one] = other;
    }
    return [for (var place = 0; place < count; place++) rootOf(place)];
  }

  List<int> sidesWith(Iterable<int> cut) => _sides(cut);

  /// Whether adding a path to a set would close a loop.
  bool wouldLoop(Iterable<int> cut, int trod) {
    final sides = _sides(cut);
    return sides[trods[trod].from] == sides[trods[trod].to];
  }

  int yardsOf(Iterable<int> cut) =>
      cut.fold(0, (sum, trod) => sum + trods[trod].yards);

  /// The paths in the order they would be cut cheapest first. Ties broken by
  /// the order they were written down, so the answer is the same every time.
  List<int> get byCost {
    final order = [for (var trod = 0; trod < many; trod++) trod];
    order.sort((one, other) {
      final by = trods[one].yards.compareTo(trods[other].yards);
      return by != 0 ? by : one.compareTo(other);
    });
    return order;
  }
}

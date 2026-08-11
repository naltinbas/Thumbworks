import 'town.dart';

/// The law of the walk.
///
/// A walk stands on a ground and crosses unwalked bridges, one after
/// the other, each from where it stands to the bridge's far end. It is
/// done when every bridge is walked. Everything the game claims comes
/// two ways that share nothing: the count of odd landings, and a
/// search over every trail there is.
class Rules {
  Rules(this.town);

  final Town town;

  int get bridgeCount => town.bridges.length;

  /// The grounds with an odd count of bridges.
  List<int> get oddGrounds => [
        for (var ground = 0; ground < town.grounds.length; ground++)
          if (town.degree(ground).isOdd) ground,
      ];

  /// The far end of a bridge from a ground, or null if the bridge does
  /// not touch it.
  int? across(int bridge, int from) {
    final (one, other) = town.bridges[bridge];
    if (one == from) return other;
    if (other == from) return one;
    return null;
  }

  /// How many complete walks leave a ground, counted by trying every
  /// trail. Knows nothing of parity.
  int walksFrom(int start) => _walks(start, 0);

  int _walks(int at, int walked) {
    if (walked == (1 << bridgeCount) - 1) return 1;
    var count = 0;
    for (var bridge = 0; bridge < bridgeCount; bridge++) {
      if (walked & (1 << bridge) != 0) continue;
      final far = across(bridge, at);
      if (far == null) continue;
      count += _walks(far, walked | (1 << bridge));
    }
    return count;
  }

  /// Whether any walk from anywhere crosses every bridge.
  bool get walkable {
    for (var ground = 0; ground < town.grounds.length; ground++) {
      if (walksFrom(ground) > 0) return true;
    }
    return false;
  }

  /// Whether a partly-made walk can still finish: standing at `at` with
  /// the walked bridges behind it.
  bool canStillWalk(int at, int walked) => _finishes(at, walked);

  final _known = <(int, int), bool>{};

  bool _finishes(int at, int walked) {
    if (walked == (1 << bridgeCount) - 1) return true;
    final key = (at, walked);
    final known = _known[key];
    if (known != null) return known;
    var can = false;
    for (var bridge = 0; bridge < bridgeCount && !can; bridge++) {
      if (walked & (1 << bridge) != 0) continue;
      final far = across(bridge, at);
      if (far == null) continue;
      if (_finishes(far, walked | (1 << bridge))) can = true;
    }
    return _known[key] = can;
  }

  /// A bridge from here that a finishing walk crosses next, or null.
  int? next(int at, int walked) {
    for (var bridge = 0; bridge < bridgeCount; bridge++) {
      if (walked & (1 << bridge) != 0) continue;
      final far = across(bridge, at);
      if (far == null) continue;
      if (_finishes(far, walked | (1 << bridge))) return bridge;
    }
    return null;
  }

  /// A ground a finishing walk can start from, or null.
  int? goodStart() {
    for (var ground = 0; ground < town.grounds.length; ground++) {
      if (walksFrom(ground) > 0) return ground;
    }
    return null;
  }
}

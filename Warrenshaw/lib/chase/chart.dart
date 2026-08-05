/// One place on the map: what it is called, and where it sits when drawn.
class Place {
  const Place(this.name, this.x, this.y);

  final String name;

  /// Where it goes, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, so a map is written down once and looks
  /// right on every phone.
  final double x;
  final double y;
}

/// A map: places, and the paths between them.
///
/// Not called a graph and not called a map, because one of those means
/// nothing to anybody who has not read a maths book and the other is already
/// a Dart type. It is a chart of a warren.
///
/// Every place counts as being next to itself. That is not a fiddle to make
/// the rules work — it is the rule: standing still is a move, for both of
/// them, and a chase where neither may wait is a different game with
/// different answers.
class Chart {
  Chart({required this.places, required List<(int, int)> paths})
      : paths = List.unmodifiable(paths) {
    final beside = [
      for (var place = 0; place < places.length; place++) <int>[place],
    ];
    for (final (one, other) in paths) {
      beside[one].add(other);
      beside[other].add(one);
    }
    for (final list in beside) {
      list.sort();
    }
    this.beside = List.unmodifiable([
      for (final list in beside) List<int>.unmodifiable(list),
    ]);
  }

  final List<Place> places;

  /// Each path once, as the two places it joins.
  final List<(int, int)> paths;

  /// Where each place can be reached from, itself included.
  late final List<List<int>> beside;

  int get count => places.length;

  bool joined(int one, int other) => beside[one].contains(other);

  /// Whether the whole map is one piece. A chase across two islands is two
  /// chases, and the one the robber is not on does not matter.
  bool get isWhole {
    final seen = <int>{0};
    final todo = <int>[0];
    while (todo.isNotEmpty) {
      for (final next in beside[todo.removeLast()]) {
        if (seen.add(next)) todo.add(next);
      }
    }
    return seen.length == count;
  }
}

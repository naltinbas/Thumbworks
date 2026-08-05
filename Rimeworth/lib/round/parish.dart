/// One junction: what it is called, and where it sits when drawn.
class Junction {
  const Junction(this.name, this.x, this.y);

  final String name;

  /// Where it goes, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, so a parish is written down once and looks
  /// right on every phone.
  final double x;
  final double y;
}

/// One lane, between two junctions. It can be salted in either direction.
class Lane {
  const Lane(this.from, this.to);

  final int from;
  final int to;

  bool touches(int junction) => from == junction || to == junction;

  int otherEnd(int junction) => junction == from ? to : from;
}

/// The parish: junctions, and the lanes between them.
///
/// The lorry drives down a lane to salt it and comes out at the other end. It
/// cannot go down a lane it has already salted, because it has no grit left
/// for one. That is the whole rule.
class Parish {
  Parish({required this.junctions, required List<Lane> lanes})
      : lanes = List.unmodifiable(lanes) {
    _at = List.generate(junctions.length, (_) => <int>[]);
    for (var lane = 0; lane < this.lanes.length; lane++) {
      _at[this.lanes[lane].from].add(lane);
      _at[this.lanes[lane].to].add(lane);
    }
  }

  final List<Junction> junctions;
  final List<Lane> lanes;

  /// Which lanes meet at each junction.
  late final List<List<int>> _at;

  int get count => junctions.length;
  int get laneCount => lanes.length;

  List<int> lanesAt(int junction) => _at[junction];

  /// How many lanes meet at a junction.
  int lanesOn(int junction) => _at[junction].length;

  int otherEnd(int lane, int junction) => lanes[lane].otherEnd(junction);

  /// The junctions with an odd number of lanes on them.
  ///
  /// These are the ones that decide everything. A lorry that drives into a
  /// junction has to drive out again on a different lane, so it uses two of
  /// them each time it passes through. A junction with an odd number of lanes
  /// cannot be passed through and leave nothing behind: whichever way the
  /// runs go, it has to be where one of them starts or ends.
  List<int> get oddJunctions => [
        for (var junction = 0; junction < count; junction++)
          if (_at[junction].length.isOdd) junction,
      ];

  /// Whether every lane can be reached from every other by driving.
  ///
  /// Junctions with no lanes on them do not count against it: there is
  /// nothing to salt there, so a lorry never has to get to one.
  bool get isJoinedUp {
    if (lanes.isEmpty) return true;

    final seen = <int>{lanes.first.from};
    final waiting = <int>[lanes.first.from];
    while (waiting.isNotEmpty) {
      final here = waiting.removeLast();
      for (final lane in _at[here]) {
        final there = otherEnd(lane, here);
        if (seen.add(there)) waiting.add(there);
      }
    }

    for (var junction = 0; junction < count; junction++) {
      if (_at[junction].isNotEmpty && !seen.contains(junction)) return false;
    }
    return true;
  }

  /// The lane between two junctions, or -1. Used by the drawing and by the
  /// tests; the game itself works in lane numbers.
  int laneBetween(int one, int other) {
    for (final lane in _at[one]) {
      if (lanes[lane].touches(other)) return lane;
    }
    return -1;
  }
}

/// One gate: what it is called, and where it stands when drawn.
class Gate {
  const Gate(this.name, this.x, this.y);

  final String name;

  /// Where it goes, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, so a fold is written down once and looks
  /// right on every phone.
  final double x;
  final double y;
}

/// One lane, between two gates.
class Lane {
  const Lane(this.from, this.to);

  final int from;
  final int to;

  bool touches(int gate) => from == gate || to == gate;
}

/// A fold: gates, and the lanes the sheep drift along between them.
///
/// A shepherd stands at a gate and watches every lane that touches it. The
/// night is safe when every lane has a shepherd at one end or the other.
class Fold {
  Fold({
    required this.name,
    required List<Gate> gates,
    required List<Lane> lanes,
    required this.fewest,
  })  : gates = List.unmodifiable(gates),
        lanes = List.unmodifiable(lanes);

  final String name;
  final List<Gate> gates;
  final List<Lane> lanes;

  /// The fewest shepherds that watch every lane. Written down here as well
  /// as worked out, so a test can hold the two against each other.
  final int fewest;

  int get count => gates.length;
  int get many => lanes.length;

  Lane operator [](int lane) => lanes[lane];

  /// The lanes at a gate.
  List<int> lanesAt(int gate) => [
        for (var lane = 0; lane < many; lane++)
          if (lanes[lane].touches(gate)) lane,
      ];

  /// The most lanes any one gate touches.
  int get busiest {
    var most = 0;
    for (var gate = 0; gate < count; gate++) {
      final here = lanesAt(gate).length;
      if (here > most) most = here;
    }
    return most;
  }

  /// Whether a set of gates, as bits, watches every lane.
  bool watches(int posted) {
    for (final lane in lanes) {
      if ((posted & (1 << lane.from)) == 0 &&
          (posted & (1 << lane.to)) == 0) {
        return false;
      }
    }
    return true;
  }
}

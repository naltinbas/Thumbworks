/// One ship, and the stretch of the day it wants the berth for.
///
/// From the hour it comes alongside up to but not including the hour it casts
/// off, so a ship that wants the berth from nine to one is in the way at nine,
/// ten, eleven and twelve, and the next one can come alongside at one.
class Ship {
  const Ship(this.name, this.from, this.to);

  final String name;
  final int from;
  final int to;

  int get hours => to - from;

  /// The last hour this ship is in the berth.
  int get lastHour => to - 1;

  bool wantsIt(int hour) => hour >= from && hour < to;

  bool clashesWith(Ship other) => from < other.to && other.from < to;
}

/// A day at the quay: one berth, and more ships than it will hold.
class Quay {
  Quay({
    required this.name,
    required List<Ship> ships,
    required this.opens,
    required this.shuts,
  }) : ships = List.unmodifiable(ships);

  final String name;
  final List<Ship> ships;

  /// The first and last hour of the working day, for the drawing.
  final int opens;
  final int shuts;

  int get count => ships.length;

  Ship operator [](int ship) => ships[ship];

  /// Whether two ships want the berth at the same time.
  bool clash(int one, int other) =>
      one != other && ships[one].clashesWith(ships[other]);

  /// Whether a set of ships can all have the berth.
  bool allFit(Iterable<int> taken) {
    final list = taken.toList();
    for (var one = 0; one < list.length; one++) {
      for (var other = one + 1; other < list.length; other++) {
        if (clash(list[one], list[other])) return false;
      }
    }
    return true;
  }

  /// The ships in the order they cast off, earliest first. Ties broken by the
  /// order they were written down, so the answer is the same every time.
  List<int> get byCastingOff {
    final order = [for (var ship = 0; ship < count; ship++) ship];
    order.sort((one, other) {
      final by = ships[one].to.compareTo(ships[other].to);
      return by != 0 ? by : one.compareTo(other);
    });
    return order;
  }
}

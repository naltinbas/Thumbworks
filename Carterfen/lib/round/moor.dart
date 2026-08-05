import 'dart:math' as math;

/// One place on the round: what it is called, and where it is.
class Stop {
  const Stop(this.name, this.x, this.y);

  final String name;

  /// Where it is, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, and the distances come out of them, so a
  /// round is written down once and is the same everywhere.
  final double x;
  final double y;
}

/// A round: the places, and how far it is between each pair of them.
///
/// Every place can be reached from every other, and the distance is the
/// straight line between them in furlongs, rounded. That is not a
/// simplification of a road map, it is the problem this game is about: which
/// order to call at them in.
class Moor {
  Moor(this.stops, {this.furlongs = 100}) {
    _away = List.generate(
      stops.length,
      (from) => List.generate(stops.length, (to) {
        if (from == to) return 0;
        final dx = stops[from].x - stops[to].x;
        final dy = stops[from].y - stops[to].y;
        return (math.sqrt(dx * dx + dy * dy) * furlongs).round();
      }),
    );
  }

  final List<Stop> stops;

  /// How much a unit of the layout is worth. Bigger numbers make the
  /// distances further apart from each other, which makes a round with one
  /// clear answer easier to find.
  final int furlongs;

  late final List<List<int>> _away;

  int get count => stops.length;

  /// How far it is from one place to another.
  int between(int from, int to) => _away[from][to];

  /// How long a round is, called at in this order and back to where it began.
  int lengthOf(List<int> order) {
    if (order.length < 2) return 0;
    var total = 0;
    for (var i = 0; i < order.length; i++) {
      total += between(order[i], order[(i + 1) % order.length]);
    }
    return total;
  }
}

import 'bridge.dart';

/// Every state a night can be in, and the fewest minutes from each to done.
///
/// A state is who stands on the far bank and where the lantern is. Crossings
/// cost minutes, not moves, so the walk is by cheapest-first rather than
/// breadth-first: states are settled in order of the minutes still needed,
/// and once settled they are settled for good.
class Crossings {
  Crossings(this.bridge) {
    _settle();
  }

  final Bridge bridge;

  /// _far[state] once settled: minutes still needed. The state packs the far
  /// bank bits with the lantern bit on top.
  late final List<int> _far;

  static const _never = 1 << 20;

  int _key(int over, bool lampFar) =>
      over | (lampFar ? 1 << bridge.count : 0);

  /// The fewest minutes still needed from a position.
  int from(int over, bool lampFar) => _far[_key(over, lampFar)];

  /// The crossing to make next on a fewest way: who walks, as bits.
  int? nextFrom(int over, bool lampFar) {
    final now = from(over, lampFar);
    if (now == 0) return null;

    for (final (party, cost) in _partiesFrom(over, lampFar)) {
      final landed = lampFar ? over & ~party : over | party;
      if (from(landed, !lampFar) + cost == now) return party;
    }
    return null;
  }

  /// Every party that could cross from here, with what it costs: singles and
  /// pairs from whichever bank has the lantern.
  Iterable<(int, int)> _partiesFrom(int over, bool lampFar) sync* {
    for (var one = 0; one < bridge.count; one++) {
      final oneFar = (over & (1 << one)) != 0;
      if (oneFar != lampFar) continue;
      yield (1 << one, bridge.walkers[one].minutes);
      for (var other = one + 1; other < bridge.count; other++) {
        final otherFar = (over & (1 << other)) != 0;
        if (otherFar != lampFar) continue;
        final slower = bridge.walkers[one].minutes > bridge.walkers[other].minutes
            ? bridge.walkers[one].minutes
            : bridge.walkers[other].minutes;
        yield ((1 << one) | (1 << other), slower);
      }
    }
  }

  void _settle() {
    final states = 1 << (bridge.count + 1);
    _far = List.filled(states, _never);
    _far[_key(bridge.everyone, true)] = 0;

    // Cheapest first, plainly: pick the unsettled state with the smallest
    // known figure, settle it, relax its neighbours backwards. The state
    // count is a few dozen, so nothing fancier earns its keep.
    final settled = List.filled(states, false);
    while (true) {
      var at = -1;
      for (var state = 0; state < states; state++) {
        if (settled[state] || _far[state] == _never) continue;
        if (at < 0 || _far[state] < _far[at]) at = state;
      }
      if (at < 0) break;
      settled[at] = true;

      final over = at & ~(1 << bridge.count);
      final lampFar = (at & (1 << bridge.count)) != 0;

      // Who could have crossed to reach this state? Anybody now standing on
      // the lantern's bank could be the party that just arrived with it, so
      // undo each such crossing.
      final cameLampFar = !lampFar;
      for (final (party, cost) in _partiesFrom(over, lampFar)) {
        final before = lampFar ? over & ~party : over | party;
        final key = _key(before, cameLampFar);
        if (_far[at] + cost < _far[key]) {
          _far[key] = _far[at] + cost;
        }
      }
    }
  }

  /// What somebody sensible but wrong does: the fastest walker ferries the
  /// lantern back every time, everybody else crosses with the fastest. On the
  /// famous four it loses two whole minutes to the answer.
  int byFerrying() {
    final order = [for (var walker = 0; walker < bridge.count; walker++) walker]
      ..sort((one, other) =>
          bridge.walkers[one].minutes.compareTo(bridge.walkers[other].minutes));
    final fastest = order.first;

    var minutes = 0;
    // Slowest first, each escorted over by the fastest, who walks back.
    for (var at = order.length - 1; at >= 1; at--) {
      minutes += bridge.walkers[order[at]].minutes;
      if (at > 1) minutes += bridge.walkers[fastest].minutes;
    }
    return minutes;
  }
}

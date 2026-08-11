import 'dart:typed_data';

/// The law of the ferry.
///
/// Passengers stand on two banks with one boat between them. A
/// crossing takes one to the boat's capacity from the boat's bank,
/// at least one of whom can row, and lands them opposite. No bank may
/// ever hold unsafe company, boat included in the landing.
///
/// The fewest crossings is known from a walk of every arrangement
/// there is, and the impossible ferries are known the same way: the
/// walk simply never finds the far bank full.
class Rules {
  Rules({
    required this.names,
    required this.rowers,
    required this.capacity,
    required this.safe,
  }) {
    _walk();
  }

  /// Who crosses, by name.
  final List<String> names;

  /// Which of them can row.
  final List<bool> rowers;

  /// How many the boat holds.
  final int capacity;

  /// Whether a bank's company stands safe: passed the passenger
  /// indexes on that bank.
  final bool Function(List<int> bank) safe;

  int get people => names.length;

  /// A state: bit per passenger (set = far bank), plus the boat's
  /// side as the top bit.
  int get states => 1 << (people + 1);

  int get start => 0;

  int get goal => ((1 << people) - 1) | (1 << people);

  bool onFar(int state, int who) => state & (1 << who) != 0;

  bool boatFar(int state) => state & (1 << people) != 0;

  List<int> bankOf(int state, {required bool far}) => [
        for (var who = 0; who < people; who++)
          if (onFar(state, who) == far) who,
      ];

  bool stateSafe(int state) =>
      safe(bankOf(state, far: false)) && safe(bankOf(state, far: true));

  /// Every legal crossing from a state: the passenger sets that may
  /// board and row, landing on a safe arrangement.
  List<int> crossings(int state) {
    final here = bankOf(state, far: boatFar(state));
    final out = <int>[];
    void pick(int from, List<int> aboard) {
      if (aboard.isNotEmpty && aboard.length <= capacity) {
        if (aboard.any((who) => rowers[who])) {
          var next = state ^ (1 << people);
          for (final who in aboard) {
            next ^= 1 << who;
          }
          if (stateSafe(next)) out.add(next);
        }
      }
      if (aboard.length >= capacity) return;
      for (var at = from; at < here.length; at++) {
        pick(at + 1, [...aboard, here[at]]);
      }
    }

    pick(0, const []);
    return out;
  }

  late final Uint8List _distance;

  void _walk() {
    _distance = Uint8List(states)..fillRange(0, states, 255);
    _distance[goal] = 0;
    var edge = [goal];
    while (edge.isNotEmpty) {
      final next = <int>[];
      for (final state in edge) {
        // Walk backwards: crossings are symmetric, so the states that
        // reach this one are exactly its crossings.
        for (final there in crossings(state)) {
          if (_distance[there] != 255) continue;
          _distance[there] = _distance[state] + 1;
          next.add(there);
        }
      }
      edge = next;
    }
  }

  /// The fewest crossings from a state to everyone across, or null.
  int? fewestFrom(int state) {
    final away = _distance[state];
    return away == 255 ? null : away;
  }

  int? get fewest => fewestFrom(start);

  /// How many safe arrangements the walk connects to the goal.
  int get reachable {
    var count = 0;
    for (var state = 0; state < states; state++) {
      if (_distance[state] != 255) count++;
    }
    return count;
  }

  /// How many safe arrangements there are at all, goal-reaching or
  /// not, found by a forward walk from the start.
  int get reachableFromStart {
    final seen = <int>{start};
    var edge = [start];
    while (edge.isNotEmpty) {
      final next = <int>[];
      for (final state in edge) {
        for (final there in crossings(state)) {
          if (seen.add(there)) next.add(there);
        }
      }
      edge = next;
    }
    return seen.length;
  }

  /// Whether the goal is reachable from the start at all.
  bool get canFerry => fewest != null;

  /// A crossing that steps one nearer, or null.
  int? next(int state) {
    final here = _distance[state];
    if (here == 0 || here == 255) return null;
    for (final there in crossings(state)) {
      if (_distance[there] == here - 1) return there;
    }
    return null;
  }
}

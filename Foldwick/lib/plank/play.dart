import 'crossing.dart';
import 'rules.dart';

/// A crossing being made. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.crossing, this.rules, this.plank, this.moves, this.before);

  factory Play.of(Crossing crossing) {
    final rules = Rules(crossing.sheep, crossing.goats, jumps: crossing.jumps);
    return Play._(crossing, rules, rules.start, 0, null);
  }

  /// A play stood at a plank, for the mark and the tests.
  factory Play.standing(Crossing crossing, String plank) {
    final rules = Rules(crossing.sheep, crossing.goats, jumps: crossing.jumps);
    return Play._(crossing, rules, plank, 1, null);
  }

  final Crossing crossing;
  final Rules rules;

  /// The plank as it stands.
  final String plank;

  /// Moves made, counted every one.
  final int moves;

  final Play? before;

  bool get isDone => plank == rules.goal;

  /// The pens whose beast may move now.
  List<int> get movers => rules.movers(plank);

  /// Whether nobody can move and the crossing is not made.
  bool get stuck => !isDone && movers.isEmpty;

  /// The hopeless crossing admits it as soon as it sticks.
  bool get gaveUp => !crossing.winnable && stuck;

  bool get isOver => isDone || gaveUp;

  /// Taps a pen: the beast there moves if it may.
  Play tap(int pen) {
    if (isOver || !movers.contains(pen)) return this;
    return Play._(crossing, rules, rules.moved(plank, pen), moves + 1, this);
  }

  Play get back => before ?? this;

  /// The order of the beasts along the plank.
  String get order => Rules.order(plank);

  /// The pen the show-me points at: a move on some crossing from
  /// here, or null when none lands.
  int? get next {
    if (isOver || !crossing.winnable) return null;
    for (final pen in movers) {
      if (_lands(rules.moved(plank, pen))) return pen;
    }
    return null;
  }

  bool _lands(String from) {
    if (from == rules.goal) return true;
    for (final pen in rules.movers(from)) {
      if (_lands(rules.moved(from, pen))) return true;
    }
    return false;
  }
}

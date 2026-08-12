import 'flock.dart';
import 'rules.dart';

/// A pecking being settled. Every state is a fresh value, and
/// the one before hangs on for take-back.
class Play {
  Play._(this.flock, this.rules, this.pecking, this.moves, this.before);

  factory Play.of(Flock flock) => Play._(
      flock,
      Rules(flock.chickens),
      List.filled(Rules(flock.chickens).pairs.length, false),
      0,
      null);

  /// A play stood at a pecking, for the mark and the tests.
  factory Play.standing(Flock flock, List<bool> pecking) =>
      Play._(flock, Rules(flock.chickens), List.of(pecking),
          pecking.where((bit) => bit).length, null);

  final Flock flock;
  final Rules rules;

  /// One bool per pair: false, the low chicken pecks the high.
  final List<bool> pecking;

  /// Flips taken, counted gross.
  final int moves;

  final Play? before;

  /// The line past which the hopeless flock admits it.
  static const gaveUpAt = 12;

  List<int> get kings => rules.kings(pecking);
  List<int> get emperors => rules.emperors(pecking);
  List<int> get outPecks => rules.outPecks(pecking);

  /// The chickens pecking the most, the certified crowns.
  List<int> get busiest {
    final out = outPecks;
    var best = 0;
    for (final count in out) {
      if (count > best) best = count;
    }
    return [
      for (var a = 0; a < flock.chickens; a++)
        if (out[a] == best) a,
    ];
  }

  bool get isDone => kings.length == flock.asked;

  bool get gaveUp => !flock.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Flips who pecks whom on one pair.
  Play flipAt(int pair) {
    if (isOver || pair < 0 || pair >= rules.pairs.length) {
      return this;
    }
    final turned = List.of(pecking);
    turned[pair] = !turned[pair];
    return Play._(flock, rules, turned, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The pair the show-me points at: the first flip of a
  /// shortest road to the asking, or null when none lands.
  int? get next {
    if (isOver) return null;
    final road = rules.flipsTo(pecking, flock.asked);
    if (road == null || road.isEmpty) return null;
    return road.first;
  }
}

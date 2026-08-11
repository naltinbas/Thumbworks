import 'ferry.dart';
import 'rules.dart';

/// A ferry being rowed. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.ferry, this.rules, this.state, this.aboard,
      this.crossings, this.before);

  Play.of(Ferry ferry) : this._(ferry, ferry.rules(), 0, const [], 0, null);

  final Ferry ferry;
  final Rules rules;

  /// Where everyone stands, and the boat.
  final int state;

  /// Who waits aboard, not yet rowed.
  final List<int> aboard;

  /// Crossings rowed so far.
  final int crossings;

  final Play? before;

  bool get isDone => state == rules.goal;

  bool onFar(int who) => rules.onFar(state, who);

  bool get boatFar => rules.boatFar(state);

  bool isAboard(int who) => aboard.contains(who);

  /// Whether a passenger may board: on the boat's bank, not aboard,
  /// room left.
  bool mayBoard(int who) =>
      !isDone &&
      who >= 0 &&
      who < rules.people &&
      !isAboard(who) &&
      onFar(who) == boatFar &&
      aboard.length < ferry.capacity;

  Play board(int who) {
    if (!mayBoard(who)) return this;
    return Play._(ferry, rules, state, [...aboard, who], crossings, this);
  }

  Play disembark(int who) {
    if (!isAboard(who)) return this;
    return Play._(
      ferry,
      rules,
      state,
      [for (final held in aboard) if (held != who) held],
      crossings,
      this,
    );
  }

  /// The landing this boarding would make.
  int get landing {
    var next = state ^ (1 << rules.people);
    for (final who in aboard) {
      next ^= 1 << who;
    }
    return next;
  }

  /// Why the boat cannot row, or null when it can.
  String? get refusal {
    if (aboard.isEmpty) return 'Nobody is aboard.';
    if (!aboard.any((who) => rules.rowers[who])) {
      return 'Nobody aboard can row.';
    }
    if (!rules.stateSafe(landing)) {
      return _danger();
    }
    return null;
  }

  String _danger() {
    final after = landing;
    for (final far in const [false, true]) {
      final bank = rules.bankOf(after, far: far);
      if (rules.safe(bank)) continue;
      if (ferry.keeper) {
        final goat = bank.contains(2);
        final wolf = bank.contains(1);
        if (goat && wolf) {
          return 'The wolf would be left with the goat.';
        }
        return 'The goat would be left with the cabbage.';
      }
      return 'The cannibals would outnumber the missionaries on the '
          '${far ? 'far' : 'near'} bank.';
    }
    return 'The landing is unsafe.';
  }

  /// Rows the boat. The ferry comes back unchanged if it may not.
  Play row() {
    if (isDone || refusal != null) return this;
    return Play._(
        ferry, rules, landing, const [], crossings + 1, this);
  }

  Play get back => before ?? this;

  /// The fewest crossings from here, boarding aside, or null.
  int? get fewestFromHere => rules.fewestFrom(state);

  /// Who a nearing crossing carries, or null.
  List<int>? get nextLoad {
    final there = rules.next(state);
    if (there == null) return null;
    return [
      for (var who = 0; who < rules.people; who++)
        if (rules.onFar(state, who) != rules.onFar(there, who)) who,
    ];
  }
}

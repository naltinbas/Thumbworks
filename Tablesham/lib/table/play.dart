import 'party.dart';
import 'rules.dart';

/// A table being seated. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.party, this.rules, this.seated, this.picked,
      this.moves, this.before);

  factory Play.of(Party party) {
    final seated = List<int?>.filled(party.couples, null);
    if (party.given != null) {
      seated[party.given!.$1] = party.given!.$2;
    }
    return Play._(party, Rules(party.couples), seated, null, 0, null);
  }

  /// A play stood at a seating, for the mark and the tests.
  factory Play.standing(Party party, List<int> seating) => Play._(
      party,
      Rules(party.couples),
      List<int?>.of(seating),
      null,
      1,
      null);

  final Party party;
  final Rules rules;

  /// The husband in each gap, or null for empty.
  final List<int?> seated;

  /// The husband picked off the bench, or null.
  final int? picked;

  /// Seatings and liftings taken, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless party admits it.
  static const gaveUpAt = 12;

  /// The husbands still on the bench.
  List<int> get bench => [
        for (var husband = 0; husband < party.couples; husband++)
          if (!seated.contains(husband)) husband,
      ];

  List<int> get quarrels => rules.quarrels(seated);

  bool get isDone => rules.lands(seated);

  bool get gaveUp => !party.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a gap may be touched: the given host never moves.
  bool touches(int gap) =>
      !isOver &&
      gap >= 0 &&
      gap < party.couples &&
      (party.given == null || party.given!.$1 != gap);

  /// Picks a husband off the bench, or unpicks him.
  Play pick(int husband) {
    if (isOver || !bench.contains(husband)) return this;
    return Play._(party, rules, seated,
        picked == husband ? null : husband, moves, before);
  }

  /// Taps a gap: seats the picked husband there, swapping any
  /// sitter back to the bench, or lifts the sitter when no
  /// husband is picked.
  Play tapAt(int gap) {
    if (!touches(gap)) return this;
    final held = List<int?>.of(seated);
    if (picked != null) {
      held[gap] = picked;
      return Play._(party, rules, held, null, moves + 1, this);
    }
    if (held[gap] == null) return this;
    held[gap] = null;
    return Play._(party, rules, held, null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: (gap, husband) toward the
  /// landing that honours the given; null when none lands.
  (int, int)? get next {
    if (isOver || !party.winnable) return null;
    final aim = rules.landing(given: party.given);
    if (aim == null) return null;
    for (var gap = 0; gap < party.couples; gap++) {
      if (seated[gap] != null && seated[gap] != aim[gap]) {
        return (gap, aim[gap]);
      }
    }
    for (var gap = 0; gap < party.couples; gap++) {
      if (seated[gap] == null) return (gap, aim[gap]);
    }
    return null;
  }
}

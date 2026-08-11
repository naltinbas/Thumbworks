import 'party.dart';
import 'rules.dart';

/// A party being paired. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.party, this.rules, this.wedded, this.weddings, this.before);

  Play.of(Party party)
      : this._(party, Rules(party.prefs),
            List<int?>.filled(party.people, null), 0, null);

  final Party party;
  final Rules rules;

  /// Who each person is wedded to, or null.
  final List<int?> wedded;

  /// Weddings made so far, partings included.
  final int weddings;

  final Play? before;

  bool get isSettled =>
      wedded.every((partner) => partner != null) && eloping.isEmpty;

  /// The eloping pairs as the party stands.
  List<(int, int)> get eloping => rules.eloping(wedded);

  /// How many people stand unwedded.
  int get unwedded => wedded.where((partner) => partner == null).length;

  /// Weds two people, parting whoever they were with; wedding a couple
  /// to itself parts it. The same party comes back for one person, or
  /// nobody.
  Play wed(int one, int other) {
    if (one == other ||
        one < 0 ||
        other < 0 ||
        one >= party.people ||
        other >= party.people) {
      return this;
    }
    final next = [...wedded];
    if (next[one] == other) {
      next[one] = null;
      next[other] = null;
    } else {
      final oneHeld = next[one];
      final otherHeld = next[other];
      if (oneHeld != null) next[oneHeld] = null;
      if (otherHeld != null) next[otherHeld] = null;
      next[one] = other;
      next[other] = one;
    }
    return Play._(party, rules, next, weddings + 1, this);
  }

  Play get back => before ?? this;

  /// A settled pairing's couple this one has not made yet, or null.
  /// The first settled pairing of the sweep stands for them all.
  (int, int)? get next {
    final settled = rules.settledPairings();
    if (settled.isEmpty) return null;
    final wanted = settled.first;
    for (var who = 0; who < party.people; who++) {
      if (wedded[who] != wanted[who]) return (who, wanted[who]);
    }
    return null;
  }
}

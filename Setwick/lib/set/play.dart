import 'dance.dart';
import 'rules.dart';

/// A set being paired off. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.dance, this.rules, this.pairs, this.picked, this.moves,
      this.before);

  factory Play.of(Dance dance) =>
      Play._(dance, Rules(dance.caller), const {}, null, 0, null);

  /// A play stood at a pairing, for the mark and the tests.
  factory Play.standing(Dance dance, Map<int, int> pairs) => Play._(
      dance, Rules(dance.caller), Map.of(pairs), null, pairs.length ~/ 2, null);

  final Dance dance;
  final Rules rules;

  /// Who is paired with whom, both ways.
  final Map<int, int> pairs;

  /// The dancer picked to pair, or null.
  final int? picked;

  /// Pairings made and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless set admits it.
  static const gaveUpAt = 9;

  bool get isDone => rules.lands(pairs);

  bool get gaveUp => !dance.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// The pairs as (lower, higher), lower first.
  List<(int, int)> get couples => [
        for (final entry in pairs.entries)
          if (entry.key < entry.value) (entry.key, entry.value),
      ]..sort((a, b) => a.$1 - b.$1);

  /// The pairs that come to one.
  List<(int, int)> get sound =>
      [for (final c in couples) if (rules.comesToOne(c.$1, c.$2)) c];

  /// The pairs that do not.
  List<(int, int)> get sour =>
      [for (final c in couples) if (!rules.comesToOne(c.$1, c.$2)) c];

  /// The dancers still unpaired.
  List<int> get loose =>
      [for (final d in rules.dancers) if (!pairs.containsKey(d)) d];

  /// Whether a dancer may be touched: 1 and n - 1 keep to
  /// themselves.
  bool touches(int dancer) =>
      !isOver && dancer >= 2 && dancer <= dance.caller - 2;

  /// Taps a dancer: lifts their pair, unpicks them, picks them, or
  /// pairs them with the one picked.
  Play tap(int dancer) {
    if (!touches(dancer)) return this;
    if (pairs.containsKey(dancer)) {
      final held = Map.of(pairs);
      final partner = held.remove(dancer)!;
      held.remove(partner);
      return Play._(dance, rules, held, null, moves + 1, this);
    }
    if (picked == null) {
      return Play._(dance, rules, pairs, dancer, moves, before);
    }
    if (picked == dancer) {
      return Play._(dance, rules, pairs, null, moves, before);
    }
    final held = Map.of(pairs);
    held[picked!] = dancer;
    held[dancer] = picked!;
    return Play._(dance, rules, held, null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', a, b) for a pair that
  /// does not come to one, or ('pair', a, b) for the lowest loose
  /// dancer and their partner; null when nothing lands.
  (String, int, int)? get next {
    if (isOver || !dance.winnable) return null;
    for (final (a, b) in sour) {
      return ('lift', a, b);
    }
    for (final dancer in loose) {
      final partner = rules.partnerOf(dancer)!;
      if (pairs.containsKey(partner)) {
        return ('lift', partner, pairs[partner]!);
      }
      return ('pair', dancer, partner);
    }
    return null;
  }
}

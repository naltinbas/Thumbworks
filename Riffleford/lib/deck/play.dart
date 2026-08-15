import 'riffle.dart';
import 'rules.dart';

/// A riffle being dealt. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.riffle, this.rules, this.drops, this.moves, this.before);

  factory Play.of(Riffle riffle) => Play._(
      riffle,
      Rules(riffle.deck, cut: riffle.cut, turned: riffle.turned, kinds: riffle.kinds),
      '',
      0,
      null);

  /// A play stood at a run of drops, for the mark and the tests.
  factory Play.standing(Riffle riffle, String drops) => Play._(
      riffle,
      Rules(riffle.deck, cut: riffle.cut, turned: riffle.turned, kinds: riffle.kinds),
      drops,
      drops.length,
      null);

  final Riffle riffle;
  final Rules rules;

  /// The drops so far, 'A' from the first pile, 'B' from the second.
  final String drops;

  /// Drops made, counted every one.
  final int moves;

  final Play? before;

  /// The line past which the hopeless riffle admits it: a whole
  /// deck dealt.
  static const gaveUpAt = 8;

  int get droppedA => drops.split('').where((d) => d == 'A').length;
  int get droppedB => drops.length - droppedA;

  /// What is left on each pile.
  int get leftA => rules.cut - droppedA;
  int get leftB => rules.length - rules.cut - droppedB;

  /// The cards dealt so far.
  String get dealt => rules.dealt(drops);

  /// Each full block, mixed or not.
  List<bool> get blocks => rules.blocks(dealt);

  bool get full => drops.length == rules.length;

  bool get isDone => full && (riffle.wantMixed
      ? blocks.every((yes) => yes)
      : blocks.any((yes) => !yes));

  bool get gaveUp => !riffle.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Whether a pile may drop: not over, and cards left on it.
  bool touches(String pile) =>
      !isOver && (pile == 'A' ? leftA > 0 : pile == 'B' ? leftB > 0 : false);

  /// Drops the top card of a pile.
  Play drop(String pile) {
    if (!touches(pile)) return this;
    return Play._(riffle, rules, '$drops$pile', moves + 1, this);
  }

  Play get back => before ?? this;

  /// The pile the show-me points at: the next drop of the sweep's
  /// first landing riffle that agrees with the drops so far, or
  /// null when nothing lands from here.
  String? get next {
    if (isOver || !riffle.winnable) return null;
    String? found;
    rules.riffles((run) {
      if (found == null && run.startsWith(drops) && rules.allMixed(run) == riffle.wantMixed) {
        found = run;
      }
    });
    if (found == null || found!.length == drops.length) return null;
    return found![drops.length];
  }
}

import 'rules.dart';

/// One ask: a rod of so many hands, and what the parts are to multiply
/// to.
class Level {
  const Level({
    required this.name,
    required this.hands,
    required this.want,
    required this.beats,
    required this.ways,
    required this.note,
  });

  final String name;

  /// How long the rod is.
  final int hands;

  /// What the parts are to come to, as a number.
  final int want;

  /// Whether the ask wants the product to pass [want] rather than reach
  /// it, which nothing does.
  final bool beats;

  /// How many cuttings land it, from the sweep.
  final int ways;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the cutting [cuts] lands the ask.
  bool meets(Set<int> cuts) {
    final got = Rules.product(Rules.partsOf(hands, cuts));
    final mark = BigInt.from(want);
    return beats ? got > mark : got == mark;
  }

  /// The cutting the pointer works towards, or null when nothing lands
  /// the ask.
  Set<int>? get aim => winnable ? Rules.bestCuts(hands) : null;

  /// The taps the cheapest cutting takes, which is one for each cut.
  int? get fewest => aim?.length;

  /// How many cuttings the rod has at all.
  int get cuttings => Rules.howManyCuttings(hands);

  /// The task, told in words for the ledger.
  String get task => beats
      ? 'cut the rod of $hands so that the parts multiply past $want'
      : 'cut the rod of $hands so that the parts multiply to $want';
}

import 'rules.dart';
import 'yard.dart';

/// A yard being laid. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.yard, this.rules, this.slabs, this.moves, this.before);

  factory Play.of(Yard yard) => Play._(yard, Rules(5), const {}, 0, null);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Yard yard, Set<Cell> slabs) =>
      Play._(yard, Rules(5), Set.of(slabs), slabs.length, null);

  final Yard yard;
  final Rules rules;

  /// The slabs as laid.
  final Set<Cell> slabs;

  /// Slabs laid and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless yard admits it.
  static const gaveUpAt = 11;

  int get kerb => Rules.kerb(slabs);

  bool get joined => Rules.joined(slabs);

  (int, int) get box => Rules.box(slabs);

  int get boxKerb => Rules.boxKerb(slabs);

  bool get isDone =>
      slabs.length == yard.slabs && joined && kerb == yard.asked;

  bool get gaveUp => !yard.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(Cell cell) =>
      !isOver && rules.inside(cell) &&
      (slabs.contains(cell) || slabs.length < yard.slabs);

  /// Taps a cell: lifts the slab there, or lays one when there is
  /// room.
  Play tap(Cell cell) {
    if (!touches(cell)) return this;
    final held = Set.of(slabs);
    if (!held.remove(cell)) held.add(cell);
    return Play._(yard, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', cell) for a slab off the
  /// aim, or ('lay', cell) for the next slab of the aim; null when
  /// nothing lands.
  (String, Cell)? get next {
    if (isOver || !yard.winnable) return null;
    final aim = aimFor(yard);
    if (aim == null) return null;
    for (final slab in slabs) {
      if (!aim.contains(slab)) return ('lift', slab);
    }
    for (final cell in aim) {
      if (!slabs.contains(cell)) return ('lay', cell);
    }
    return null;
  }

  /// The sweep's first placing that lands a yard, kept once found,
  /// since the sweep of ten is slow enough to notice under a thumb.
  static Set<Cell>? aimFor(Yard yard) {
    final key = '${yard.slabs}:${yard.asked}';
    if (!_aims.containsKey(key)) {
      _aims[key] = Rules(5).landing(yard.slabs, yard.asked);
    }
    return _aims[key];
  }

  static final _aims = <String, Set<Cell>?>{};
}

import 'house.dart';
import 'level.dart';
import 'rules.dart';

/// A quilt being sewn. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.level, this.quilt, this.sewn, this.patches, this.held, this.moves, this.before,
      this.houseLast, this.houseRule, this.lastSewer);

  factory Play.of(Level level, {Quilt? quilt}) {
    final q = quilt ?? Quilt(level.rows, level.cols);
    var play = Play._(level, q, 0, const [], null, 0, null, null, null, null);
    if (!level.youFirst) play = play._houseSews();
    return play;
  }

  /// A play stood at a quilt, for the mark and the tests: patches
  /// given as (patch, yours).
  factory Play.standing(Level level, List<(Patch, bool)> patches) {
    final q = Quilt(level.rows, level.cols);
    var sewn = 0;
    for (final (p, _) in patches) {
      sewn = q.sew(sewn, p);
    }
    return Play._(level, q, sewn, List.of(patches), null, 0, null, null, null, null);
  }

  final Level level;
  final Quilt quilt;

  /// The cells sewn, as bits.
  final int sewn;

  /// Every patch on the quilt in order, with whether it is yours.
  final List<(Patch, bool)> patches;

  /// The cell you have picked and not yet paired, or null.
  final int? held;

  /// Your patches sewn, counted.
  final int moves;

  final Play? before;

  /// The house's last patch and how it chose it, or null.
  final Patch? houseLast;
  final String? houseRule;

  /// Who sewed last: true for you, false for the house, null for nobody.
  final bool? lastSewer;

  bool get houseFirst => !level.youFirst;

  bool get isOver => quilt.moves(sewn).isEmpty;

  bool get won => isOver && lastSewer == true;
  bool get lost => isOver && lastSewer == false;

  bool get isDone => won;

  bool get gaveUp => !level.winnable && isOver && !won;

  /// The tree's word from your side, with you to sew.
  bool get youWin => isOver ? won : quilt.moverWins(sewn);

  Patch? get yourLast {
    for (var i = patches.length - 1; i >= 0; i--) {
      if (patches[i].$2) return patches[i].$1;
    }
    return null;
  }

  bool touches(int cell) => !isOver && cell >= 0 && cell < quilt.cells && quilt.free(sewn, cell);

  bool _neighbours(int a, int b) {
    final ra = quilt.rowOf(a), ca = quilt.colOf(a), rb = quilt.rowOf(b), cb = quilt.colOf(b);
    return (ra == rb && (ca - cb).abs() == 1) || (ca == cb && (ra - rb).abs() == 1);
  }

  /// Taps a cell: picks it, unpicks it, or sews it to the held one;
  /// after a patch the house answers at once.
  Play tap(int cell) {
    if (!touches(cell)) return this;
    final h = held;
    if (h == null || !_neighbours(h, cell)) {
      final pick = h == cell ? null : cell;
      return Play._(level, quilt, sewn, patches, pick, moves, before, houseLast, houseRule, lastSewer);
    }
    return sewPatch(h < cell ? (h, cell) : (cell, h));
  }

  /// Sews your patch outright, then the house answers.
  Play sewPatch(Patch patch) {
    if (isOver || !quilt.fits(sewn, patch)) return this;
    final mine = Play._(level, quilt, quilt.sew(sewn, patch), [...patches, (patch, true)], null,
        moves + 1, this, houseLast, houseRule, true);
    return mine.isOver ? mine : mine._houseSews();
  }

  Play _houseSews() {
    final (patch, rule) = House.advise(quilt, sewn, houseFirst: houseFirst, yourLast: yourLast);
    return Play._(level, quilt, quilt.sew(sewn, patch), [...patches, (patch, false)], null, moves,
        before, patch, rule, false);
  }

  Play get back => before ?? this;

  /// What the show-me points at: a winning patch, the mirror of the
  /// house's last patch when that wins; null when nothing does.
  Patch? get next {
    if (isOver || !level.winnable) return null;
    final winning = quilt.winningMoves(sewn);
    if (winning.isEmpty) return null;
    final last = houseLast;
    if (last != null && winning.contains(quilt.mirror(last))) return quilt.mirror(last);
    final middle = quilt.middle;
    if (sewn == 0 && middle != null && winning.contains(middle)) return middle;
    return winning.first;
  }
}

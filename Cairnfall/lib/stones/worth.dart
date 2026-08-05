import 'dart:typed_data';

import 'cairn.dart';

/// What every cairn is worth, and what a whole position is worth.
///
/// The number on a cairn is not a score and not a difficulty. It is the size
/// of the plain Nim heap that the cairn could be swapped for without changing
/// who wins — which is a real thing about the cairn rather than a way of
/// judging it, and it is why a position of three different rules can be
/// settled by one exclusive or.
///
/// It is worked out the only way it can be: the value of a cairn is the
/// smallest number that is not the value of anything it can turn into. Every
/// cairn is smaller than the one it came from, so the whole table fills in
/// from nothing upwards and never asks about itself.
class Worth {
  Worth._(this._table, this.most);

  factory Worth.upTo(int most) {
    final table = <Rule, Int32List>{};
    for (final rule in Rule.values) {
      final row = Int32List(most + 1);
      for (var stones = 0; stones <= most; stones++) {
        final reachable = <int>{
          for (final take in Cairn(rule, stones).takes) row[stones - take],
        };
        row[stones] = _mex(reachable);
      }
      table[rule] = row;
    }
    return Worth._(table, most);
  }

  final Map<Rule, Int32List> _table;

  /// The largest cairn this was worked out for.
  final int most;

  /// What one cairn is worth.
  int of(Cairn cairn) => _table[cairn.rule]![cairn.stones];

  /// What a whole position is worth: every cairn exclusive-ored together.
  ///
  /// Zero means the player about to move loses against anybody who knows
  /// this; anything else means they win, and the move that wins is the one
  /// that makes it zero.
  int ofAll(Iterable<Cairn> cairns) =>
      cairns.fold(0, (all, cairn) => all ^ of(cairn));

  /// The smallest number that is not in a set. The whole of the arithmetic.
  static int _mex(Set<int> taken) {
    var found = 0;
    while (taken.contains(found)) {
      found++;
    }
    return found;
  }
}

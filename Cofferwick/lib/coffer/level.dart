import 'frac.dart';
import 'rules.dart';

/// One ask: a chance to lay the coins for.
class Level {
  const Level({
    required this.name,
    required this.want,
    this.golds,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The chance asked for, as (over, under).
  final (int, int) want;

  /// How many gold coins the ask insists on, or null for any number.
  final int? golds;

  /// How many layings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  Frac get chance => Frac.of(want.$1, want.$2);

  /// The layings the ask is swept over: all 64, or those with the gold
  /// coins it insists on.
  int get settings => golds == null ? Rules.settings : [for (var n = 0; n < Rules.settings; n++) n].where((n) => Rules.golds(Rules.laying(n)) == golds).length;

  /// Whether the coins land the ask.
  bool meets(List<bool> coins) {
    if (golds != null && Rules.golds(coins) != golds) return false;
    return Rules.chanceByDraws(coins) == chance;
  }

  /// The laying the pointer works towards, the sweep's first, or null.
  List<bool>? get aim {
    for (var n = 0; n < Rules.settings; n++) {
      final coins = Rules.laying(n);
      if (meets(coins)) return coins;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    final p = want == (1, 1) ? 'for certain' : 'with chance ${want.$1} in ${want.$2}';
    final with_ = golds == null ? '' : ', with ${_word(golds!)} gold coins and ${_word(6 - golds!)} silver';
    return 'lay the coins so that a gold coin drawn at random has a gold mate $p$with_';
  }

  static String _word(int n) => const ['nought', 'one', 'two', 'three', 'four', 'five', 'six'][n];
}

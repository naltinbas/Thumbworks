import 'rules.dart';

/// One ask: a chance to set the duel to, or a length.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.want,
    this.coin,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'chance': Ash's chance is [want] exactly; 'atLeast': it is [want] or
  /// more; 'lasts': the duel lasts [want] tosses on average, exactly.
  final String kind;

  /// The fraction asked for, as (numerator, denominator).
  final (int, int) want;

  /// The coin the ask fixes, or null for any coin.
  final int? coin;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The setting the pointer walks to, (ash, birch, coin), or null when
  /// none lands it.
  final (int, int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  Frac get wanted => Frac.of(want.$1, want.$2);

  /// Whether the setting lands the ask.
  bool meets(int ash, int birch, int coin) {
    if (this.coin != null && coin != this.coin) return false;
    switch (kind) {
      case 'chance':
        return Rules.chanceByFormula(ash, birch, coin) == wanted;
      case 'atLeast':
        return Rules.chanceByFormula(ash, birch, coin).compareTo(wanted) >= 0;
      default:
        return Rules.lastsByFormula(ash, birch, coin) == wanted;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    final withCoin = coin == null ? '' : ', the coin ${Rules.coinNames[coin!]}';
    switch (kind) {
      case 'chance':
        return 'set the purses and the coin so Ash takes the pot ${Rules.chanceTold(wanted)} exactly$withCoin';
      case 'atLeast':
        return 'set the purses so Ash takes the pot ${Rules.chanceTold(wanted)} or better$withCoin';
      default:
        return 'set the purses and the coin so the duel lasts ${Rules.count(want.$1)} tosses on average exactly$withCoin';
    }
  }
}

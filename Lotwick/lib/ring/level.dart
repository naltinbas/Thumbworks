import 'rules.dart';

/// One ask: what the three dials are to show.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ring,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'overbid': a bid above the worth that wins and loses money;
  /// 'windfall': a win that earns something; 'passed': a bid under the
  /// worth that drops a sale worth having; 'shading': a bid that beats
  /// the truthful one in the open ring; 'beat': a bid that beats the
  /// truthful one in the sealed ring, which never happens.
  final String kind;

  /// Which ring the ask is run in.
  final String ring;

  /// How many settings land it, from the sweep.
  final int ways;

  /// The cheapest setting that lands it, from the sweep; null when none
  /// does.
  final (int, int, int)? aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask.
  bool meets(int worth, int bid, int rival) {
    switch (kind) {
      case 'overbid':
        return bid > worth &&
            Rules.wins(bid, rival) &&
            Rules.paidBy(Rules.sealed, worth, bid, rival) < 0;
      case 'windfall':
        return Rules.wins(bid, rival) &&
            Rules.paidBy(Rules.sealed, worth, bid, rival) > 0;
      case 'passed':
        return bid < worth && !Rules.wins(bid, rival) && rival < worth;
      case 'shading':
        return Rules.paidBy(Rules.open, worth, bid, rival) >
            Rules.truthPays(Rules.open, worth, rival);
      default:
        return Rules.paidBy(Rules.sealed, worth, bid, rival) >
            Rules.truthPays(Rules.sealed, worth, rival);
    }
  }

  /// The taps the cheapest setting takes from the opening.
  int? get fewest => aim == null
      ? null
      : Rules.taps(
          (Rules.openWorth, Rules.openBid, Rules.openRival), aim!);

  /// The task, told in words.
  String get task => switch (kind) {
        'overbid' => 'bid above what the beast is worth to you, win it, and '
            'pay more than it is worth',
        'windfall' => 'win the beast and pay less than it is worth to you',
        'passed' => 'bid under what the beast is worth and lose it to a rival '
            'who bid less than that',
        'shading' => 'in the open ring, set a bid that earns more than '
            'bidding what the beast is worth to you',
        _ => 'in the sealed ring, set a bid that earns more than bidding what '
            'the beast is worth to you',
      };
}

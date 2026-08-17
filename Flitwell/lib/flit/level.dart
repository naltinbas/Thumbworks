import 'rules.dart';

/// One ask: a street of four tenants, and what the lane is to become.
class Level {
  const Level({
    required this.name,
    required this.street,
    required this.kind,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The four tenants' orders, best cottage first: 'BCAD BADC CABD ABCD'.
  final String street;

  /// 'better': every tenant would rather be here than in the cottage
  /// they own. 'settled': no group can better all of its members.
  /// 'firm': no group can better one without setting another back.
  /// 'beat': every tenant would rather be here than in the firm lane,
  /// which never happens.
  final String kind;

  /// How many of the 24 lanes land it. The sweep's number, and the
  /// checker refuses the bake if it drifts.
  final int ways;

  /// The swaps from the opening to the nearest lane that lands it; null
  /// when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  List<List<int>> get orders => Rules.read(street);

  /// The lane no group can better one of without setting another back.
  List<int> get firmLane => Rules.rings(orders);

  bool get winnable => ways > 0;

  /// Whether this lane lands the ask.
  bool meets(List<int> where) => switch (kind) {
        'better' => Rules.allBetter(orders, where),
        'settled' => Rules.settled(orders, where),
        'firm' => Rules.firm(orders, where),
        _ => Rules.allBetterThan(orders, where, firmLane),
      };

  /// The task, told in words.
  String get task => switch (kind) {
        'better' => 'swap the tenants about so that every one of them would '
            'rather be where they end up than in the cottage they own',
        'settled' => 'swap the tenants about so that no group of them could '
            'all do better by trading among themselves',
        'firm' => 'swap the tenants about so that no group could better one '
            'of its own without setting another back',
        _ => 'swap the tenants about so that every one of them would rather '
            'be there than in the lane no group can better',
      };
}

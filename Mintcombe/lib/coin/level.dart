import 'rules.dart';

/// One ask: a price to pay, and how.
class Level {
  const Level({
    required this.name,
    required this.price,
    required this.kind,
    this.barred,
    required this.ways,
    required this.all,
    required this.note,
  });

  final String name;

  /// The price to pay.
  final int price;

  /// 'tidy': no two coins neighbours; 'untidy': some two neighbours;
  /// 'any': paid, however.
  final String kind;

  /// A coin kept back, never laid, or null.
  final int? barred;

  /// How many pickings land it, from the sweep.
  final int ways;

  /// How many pickings pay the price at all, from the sweep.
  final int all;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the coins [picked] land the ask.
  bool meets(Iterable<int> picked) {
    if (Rules.sumOf(picked) != price) return false;
    if (barred != null && picked.contains(barred)) return false;
    switch (kind) {
      case 'tidy':
        return Rules.tidy(picked);
      case 'untidy':
        return !Rules.tidy(picked);
      default:
        return true;
    }
  }

  /// The picking the pointer works towards: the fewest coins that land
  /// the ask, the sweep's first among those, dearest coin first; null
  /// when none does.
  List<int>? get aim {
    List<int>? best;
    for (final p in Rules.pickings) {
      if (meets(p) && (best == null || p.length < best.length)) best = p;
    }
    return best;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'tidy':
        return 'pay $price with no two neighbouring coins${barred == null ? '' : ', the $barred kept back'}';
      case 'untidy':
        return 'pay $price with two neighbouring coins somewhere in it';
      default:
        return 'pay $price with any coins of the purse';
    }
  }
}

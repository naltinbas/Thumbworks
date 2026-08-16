import 'rules.dart';

/// One ask: what the ticket is to be.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'pass': the ticket passes; 'swap': it passes with a 0 and a 9 side
  /// by side; 'twin': it passes with a slipping twin pair side by side;
  /// 'palindrome': it passes and reads the same backwards; 'slip': one
  /// digit of a passing ticket turned and passing still, which no
  /// ticket ever is.
  final String kind;

  /// How many tickets land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// The neighbouring places holding 0 and 9, either way round.
  static List<int> swapPlaces(List<int> d) => [for (var i = 0; i + 1 < Rules.places; i++) if ({d[i], d[i + 1]}.containsAll({0, 9})) i];

  /// The neighbouring places holding a slipping twin: 22, 33, 44, 55, 66
  /// or 77.
  static List<int> twinPlaces(List<int> d) => [
        for (var i = 0; i + 1 < Rules.places; i++)
          if (d[i] == d[i + 1] && Rules.twinsUnseen.any((p) => p.$1 == d[i] || p.$2 == d[i])) i,
      ];

  static bool palindrome(List<int> d) => [for (var i = 0; i < Rules.places; i++) d[i] == d[Rules.places - 1 - i]].every((x) => x);

  /// Whether the ticket [d] lands the ask.
  bool meets(List<int> d) {
    if (!Rules.passes(d)) return false;
    switch (kind) {
      case 'pass':
        return true;
      case 'swap':
        return swapPlaces(d).isNotEmpty;
      case 'twin':
        return twinPlaces(d).isNotEmpty;
      case 'palindrome':
        return palindrome(d);
      default:
        return false;
    }
  }

  /// The ticket the pointer works towards, the sweep's first that lands
  /// the ask, or null.
  List<int>? get aim {
    for (final d in Rules.tickets) {
      if (meets(d)) return d;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'pass':
        return 'turn the dials to a ticket that passes';
      case 'swap':
        return 'turn the dials to a passing ticket with a 0 and a 9 side by side';
      case 'twin':
        return 'turn the dials to a passing ticket with 22, 33, 44, 55, 66 or 77 in it';
      case 'palindrome':
        return 'turn the dials to a passing ticket that reads the same backwards';
      default:
        return 'turn one dial of a passing ticket and have it pass still';
    }
  }
}

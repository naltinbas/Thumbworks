import 'rules.dart';

/// One ask: which stone the crossing is to end on.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'hundred': a dry stone past the hundredth; 'twin': a dry stone
  /// with another two behind it; 'far': a stone whose rope reaches past
  /// the ford's end; 'lonely': a dry stone with four mossy either side;
  /// 'shallows': a stone in the long run of moss, which takes no foot.
  final String kind;

  /// How many stones of the ford land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether standing on [stone] lands the ask.
  bool meets(int stone) {
    if (!Rules.dry(stone)) return false;
    switch (kind) {
      case 'hundred':
        return stone > 100;
      case 'twin':
        return Rules.upperTwin(stone);
      case 'far':
        return Rules.ropePastFord(stone);
      case 'lonely':
        return Rules.lonely(stone);
      default:
        return stone > 89 && stone < 97;
    }
  }

  /// The first stone of the ford that lands the ask, or null.
  int? get aim {
    for (var k = 1; k <= Rules.stones; k++) {
      if (meets(k)) return k;
    }
    return null;
  }

  /// The fewest hops the ask takes from the ford's first dry stone, or
  /// null when nothing lands it.
  int? get fewest {
    var least = -1;
    for (final stone in Rules.dryStones) {
      if (!meets(stone)) continue;
      final hops = Rules.hops[stone];
      if (hops != null && (least < 0 || hops < least)) least = hops;
    }
    return least < 0 ? null : least;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'hundred':
        return 'cross to a dry stone past the hundredth';
      case 'twin':
        return 'cross to a dry stone with another dry stone two behind it';
      case 'far':
        return 'cross to a dry stone whose rope reaches past the ford\'s last';
      case 'lonely':
        return 'cross to a dry stone with nothing but moss for four stones either side';
      default:
        return 'cross to a stone between the eighty-ninth and the ninety-seventh';
    }
  }
}

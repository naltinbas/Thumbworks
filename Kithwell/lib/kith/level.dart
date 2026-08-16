import 'frac.dart';
import 'rules.dart';

/// One ask: what the friendships are to make of the two averages.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'even': everyone with the same number of friends, the gap nought;
  /// 'one': the friends' average one over the average; 'widest': the gap
  /// as wide as it gets, 4/3; 'half': the gap a half; 'under': the
  /// friends' average below the average, which never is.
  final String kind;

  /// How many plans land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// The widest gap any plan makes: the star's, one person friends
  /// with all five and the five with nobody else.
  static Frac get widest => Frac.of(4, 3);

  /// Whether the plan [mask] lands the ask.
  bool meets(int mask) {
    final gap = Rules.gap(mask);
    if (gap == null) return false;
    switch (kind) {
      case 'even':
        return gap == Frac.zero;
      case 'one':
        return gap == Frac.one;
      case 'widest':
        return gap == widest;
      case 'half':
        return gap == Frac.of(1, 2);
      default:
        return gap.compareTo(Frac.zero) < 0;
    }
  }

  /// The plan the pointer works towards, the sweep's first that lands
  /// the ask, or null.
  int? get aim {
    for (var mask = 1; mask < Rules.plans; mask++) {
      if (meets(mask)) return mask;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'even':
        return 'lay friendships so that everyone has the same number of friends';
      case 'one':
        return 'lay friendships so that the friends named have one friend more, on average, than people do';
      case 'widest':
        return 'lay friendships so that the gap between the two averages is as wide as it gets';
      case 'half':
        return 'lay friendships so that the friends named have half a friend more, on average, than people do';
      default:
        return 'lay friendships so that the friends named have fewer friends, on average, than people do';
    }
  }
}

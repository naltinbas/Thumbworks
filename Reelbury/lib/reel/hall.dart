/// A dance: two sides of the same size, and what everybody thinks of
/// everybody on the other side.
///
/// The people are numbers on each side. Their liking is written down as an
/// order — first choice first — because that is all the game ever asks about
/// them: not how much somebody is liked, only whether they are liked more
/// than somebody else.
class Hall {
  Hall({required this.callers, required this.dancers})
      : count = callers.length {
    assert(dancers.length == callers.length, 'the sides must be the same size');

    _callerRank = [
      for (final order in callers) _rankOf(order, callers.length),
    ];
    _dancerRank = [
      for (final order in dancers) _rankOf(order, dancers.length),
    ];
  }

  /// How many on each side.
  final int count;

  /// For each caller, the dancers in the order they would have them.
  final List<List<int>> callers;

  /// For each dancer, the callers in the order they would have them.
  final List<List<int>> dancers;

  late final List<List<int>> _callerRank;
  late final List<List<int>> _dancerRank;

  static List<int> _rankOf(List<int> order, int count) {
    final rank = List<int>.filled(count, count);
    for (var place = 0; place < order.length; place++) {
      rank[order[place]] = place;
    }
    return rank;
  }

  /// Where a dancer comes on a caller's list. Lower is better.
  int callerRank(int caller, int dancer) => _callerRank[caller][dancer];

  /// Where a caller comes on a dancer's list. Lower is better.
  int dancerRank(int dancer, int caller) => _dancerRank[dancer][caller];

  /// Whether a caller would rather have this dancer than that one.
  bool callerPrefers(int caller, int dancer, int over) =>
      callerRank(caller, dancer) < callerRank(caller, over);

  /// Whether a dancer would rather have this caller than that one.
  bool dancerPrefers(int dancer, int caller, int over) =>
      dancerRank(dancer, caller) < dancerRank(dancer, over);

  /// Whether every list has everybody on the other side, once.
  bool get isWhole {
    for (final order in [...callers, ...dancers]) {
      if (order.length != count) return false;
      if (order.toSet().length != count) return false;
      if (order.any((who) => who < 0 || who >= count)) return false;
    }
    return true;
  }
}

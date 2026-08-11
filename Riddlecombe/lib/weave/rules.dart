/// The arithmetic of the riddle.
///
/// A weave is a row of combs, each between two strands, upper and
/// lower. A grist runs down the strands; at each comb the heavier of
/// the two grains drops to the lower strand. A weave riddles clean when
/// every grist comes out with all the heavy grain at the bottom.
///
/// The live check leans on the old nought-one principle: a weave sorts
/// every ordering exactly when it sorts every mixture of noughts and
/// ones. Nothing here takes that on trust. The suite runs both checks
/// on everything that ships, and on every short weave there is.
class Rules {
  Rules(this.strands);

  final int strands;

  /// Every comb there could be, upper strand first.
  List<(int, int)> get pairs => [
        for (var upper = 0; upper < strands; upper++)
          for (var lower = upper + 1; lower < strands; lower++)
            (upper, lower),
      ];

  /// One grist of noughts and ones through one comb: the one, being
  /// heavier, drops to the lower strand.
  int combed(int grist, (int, int) comb) {
    final (upper, lower) = comb;
    final up = grist & (1 << upper) != 0;
    final down = grist & (1 << lower) != 0;
    if (up && !down) {
      return grist ^ (1 << upper) ^ (1 << lower);
    }
    return grist;
  }

  /// A grist through a whole weave.
  int run(int grist, List<(int, int)> weave) {
    var out = grist;
    for (final comb in weave) {
      out = combed(out, comb);
    }
    return out;
  }

  /// What a clean riddle leaves of a grist: its ones at the bottom.
  int settled(int grist) {
    var ones = 0;
    for (var strand = 0; strand < strands; strand++) {
      if (grist & (1 << strand) != 0) ones++;
    }
    return ((1 << ones) - 1) << (strands - ones);
  }

  /// The grists a weave leaves unsettled, of all two-to-the-strands.
  List<int> unsettled(List<(int, int)> weave) => [
        for (var grist = 0; grist < (1 << strands); grist++)
          if (run(grist, weave) != settled(grist)) grist,
      ];

  /// Whether a weave riddles every grist clean.
  bool riddles(List<(int, int)> weave) => unsettled(weave).isEmpty;

  /// The second way of knowing: every ordering of distinct grains,
  /// combed as numbers, must come out ascending. Knows nothing of
  /// noughts and ones.
  bool riddlesOrderings(List<(int, int)> weave) {
    final grains = [for (var grain = 0; grain < strands; grain++) grain];
    return _orderings(grains, 0, weave);
  }

  bool _orderings(List<int> grains, int from, List<(int, int)> weave) {
    if (from == grains.length) {
      final held = [...grains];
      for (final (upper, lower) in weave) {
        if (held[upper] > held[lower]) {
          final swap = held[upper];
          held[upper] = held[lower];
          held[lower] = swap;
        }
      }
      for (var strand = 1; strand < strands; strand++) {
        if (held[strand - 1] > held[strand]) return false;
      }
      return true;
    }
    for (var at = from; at < grains.length; at++) {
      var swap = grains[from];
      grains[from] = grains[at];
      grains[at] = swap;
      if (!_orderings(grains, from + 1, weave)) return false;
      swap = grains[from];
      grains[from] = grains[at];
      grains[at] = swap;
    }
    return true;
  }

  /// The grists' journey through a weave, comb by comb, for the words
  /// and the drawing: positions after each comb, first the raw grist.
  List<int> trace(int grist, List<(int, int)> weave) {
    final steps = [grist];
    var held = grist;
    for (final comb in weave) {
      held = combed(held, comb);
      steps.add(held);
    }
    return steps;
  }

  /// The distinct outcomes a weave leaves over every grist, as a set of
  /// bits: the whole of what any longer weave has to work with.
  int _outcomes(List<(int, int)> weave) {
    var mask = 0;
    for (var grist = 0; grist < (1 << strands); grist++) {
      mask |= 1 << run(grist, weave);
    }
    return mask;
  }

  final _futures = <(int, int), bool>{};

  /// Whether some longer weave with this many more combs riddles clean
  /// from what this one leaves.
  bool canStill(List<(int, int)> weave, int moreCombs) =>
      _canStillFrom(_outcomes(weave), moreCombs);

  bool _canStillFrom(int outcomes, int moreCombs) {
    var settledAll = true;
    for (var grist = 0; grist < (1 << strands); grist++) {
      if (outcomes & (1 << grist) == 0) continue;
      if (grist != settled(grist)) {
        settledAll = false;
        break;
      }
    }
    if (settledAll) return true;
    if (moreCombs == 0) return false;
    final key = (outcomes, moreCombs);
    final known = _futures[key];
    if (known != null) return known;
    var can = false;
    for (final comb in pairs) {
      var next = 0;
      for (var grist = 0; grist < (1 << strands); grist++) {
        if (outcomes & (1 << grist) != 0) {
          next |= 1 << combed(grist, comb);
        }
      }
      // A comb that changes nothing wastes its place: skip it.
      if (next == outcomes) continue;
      if (_canStillFrom(next, moreCombs - 1)) {
        can = true;
        break;
      }
    }
    return _futures[key] = can;
  }

  /// A comb that keeps a clean riddle within reach, or null.
  (int, int)? next(List<(int, int)> weave, int moreCombs) {
    if (moreCombs <= 0) return null;
    final outcomes = _outcomes(weave);
    for (final comb in pairs) {
      var after = 0;
      for (var grist = 0; grist < (1 << strands); grist++) {
        if (outcomes & (1 << grist) != 0) {
          after |= 1 << combed(grist, comb);
        }
      }
      if (after != outcomes && _canStillFrom(after, moreCombs - 1)) {
        return comb;
      }
    }
    return null;
  }

  /// Every weave of so many combs, for the sweeps.
  Iterable<List<(int, int)>> allWeaves(int combs) sync* {
    final weave = <(int, int)>[];
    yield* _weaves(weave, combs);
  }

  Iterable<List<(int, int)>> _weaves(
      List<(int, int)> weave, int left) sync* {
    if (left == 0) {
      yield [...weave];
      return;
    }
    for (final comb in pairs) {
      weave.add(comb);
      yield* _weaves(weave, left - 1);
      weave.removeLast();
    }
  }
}

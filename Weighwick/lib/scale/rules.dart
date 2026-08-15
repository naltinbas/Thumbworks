/// Where a weight stands: off the scale, on the pan against the load,
/// or on the pan with the load.
enum Side { off, against, withLoad }

/// The law of the scale: four weights, 1, 3, 9 and 27, a load on the
/// left pan, and the weights set on either pan; the scale balances
/// when the load with the weights beside it equals the weights across.
class Rules {
  static const weights = [1, 3, 9, 27];

  /// What the placing weighs against the load: weights across less
  /// weights beside the load.
  static int net(List<Side> placing) {
    var sum = 0;
    for (var i = 0; i < weights.length; i++) {
      if (placing[i] == Side.against) sum += weights[i];
      if (placing[i] == Side.withLoad) sum -= weights[i];
    }
    return sum;
  }

  static bool balances(int load, List<Side> placing) => net(placing) == load;

  /// Every placing of the four weights, three ways apiece: 81.
  static List<List<Side>> get placings {
    _placings ??= _buildPlacings();
    return _placings!;
  }

  static List<List<Side>>? _placings;

  static List<List<Side>> _buildPlacings() {
    final out = <List<Side>>[];
    void grow(List<Side> so) {
      if (so.length == weights.length) {
        out.add(List.of(so));
        return;
      }
      for (final s in Side.values) {
        so.add(s);
        grow(so);
        so.removeLast();
      }
    }

    grow([]);
    return out;
  }

  /// The placings that balance [load], with the weights allowed.
  static List<List<Side>> balancing(int load, {List<int> barred = const []}) => [
        for (final p in placings)
          if (balances(load, p) && !barred.any((b) => p[weights.indexOf(b)] != Side.off)) p,
      ];

  /// The placing counting in threes gives, with no sweep: write the
  /// load with digits 0, 1 and -1 in ones, threes, nines and
  /// twenty-sevens, and a digit of 1 puts the weight across, -1 beside
  /// the load, 0 off.
  static List<Side>? balancedTernary(int load) {
    var n = load;
    final out = <Side>[];
    for (var i = 0; i < weights.length; i++) {
      var r = n % 3;
      n ~/= 3;
      if (r == 2) {
        r = -1;
        n += 1;
      }
      out.add(r == 0 ? Side.off : r == 1 ? Side.against : Side.withLoad);
    }
    return n == 0 ? out : null;
  }

  /// The most the four weights can weigh, all across.
  static int get most => weights.fold(0, (a, b) => a + b);
}

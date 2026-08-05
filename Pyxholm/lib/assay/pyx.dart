/// One thing that could be true: a coin, and which way it is wrong.
class Verdict {
  const Verdict(this.coin, this.heavy);

  final int coin;

  /// Whether that coin is the heavy one. Otherwise it is the light one.
  final bool heavy;

  @override
  bool operator ==(Object other) =>
      other is Verdict && other.coin == coin && other.heavy == heavy;

  @override
  int get hashCode => coin * 2 + (heavy ? 1 : 0);

  @override
  String toString() => '$coin${heavy ? 'h' : 'l'}';
}

/// Which way the beam went.
enum Tip {
  /// The left pan went down.
  left,

  /// Neither pan moved.
  level,

  /// The right pan went down.
  right,
}

/// One weighing: what went on each pan.
class Weighing {
  Weighing(List<int> left, List<int> right)
      : left = List.unmodifiable(List.of(left)..sort()),
        right = List.unmodifiable(List.of(right)..sort());

  final List<int> left;
  final List<int> right;

  bool get isFair => left.length == right.length && left.isNotEmpty;

  int get coins => left.length + right.length;

  /// Which way the beam goes if a given verdict is the true one.
  ///
  /// Every coin but the wrong one weighs the same, so the pans differ only by
  /// where the wrong coin is and which way it is wrong.
  Tip tipFor(Verdict verdict) {
    if (left.contains(verdict.coin)) return verdict.heavy ? Tip.left : Tip.right;
    if (right.contains(verdict.coin)) {
      return verdict.heavy ? Tip.right : Tip.left;
    }
    return Tip.level;
  }

  /// The verdicts still standing after the beam goes a given way.
  List<Verdict> after(List<Verdict> standing, Tip tip) =>
      [for (final verdict in standing) if (tipFor(verdict) == tip) verdict];

  @override
  bool operator ==(Object other) =>
      other is Weighing &&
      other.left.length == left.length &&
      other.right.length == right.length &&
      _same(other.left, left) &&
      _same(other.right, right);

  static bool _same(List<int> one, List<int> other) {
    for (var at = 0; at < one.length; at++) {
      if (one[at] != other[at]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(left),
        Object.hashAll(right),
      );

  @override
  String toString() => '${left.join(',')} against ${right.join(',')}';
}

/// A box of coins with one wrong one in it.
class Pyx {
  const Pyx({
    required this.name,
    required this.coins,
    required this.fewest,
    this.knownLight = false,
  });

  final String name;

  /// How many coins are in the box.
  final int coins;

  /// Whether the wrong coin is known to be the light one. When it is not,
  /// there are twice as many things to tell apart and the beam still has only
  /// the same three answers to tell them apart with.
  final bool knownLight;

  /// The fewest weighings that are certain to settle it. Written down here as
  /// well as worked out, because working it out on twelve coins takes long
  /// enough to be worth doing once.
  final int fewest;

  /// Everything that could be true.
  List<Verdict> get everything => [
        for (var coin = 0; coin < coins; coin++) ...[
          if (!knownLight) Verdict(coin, true),
          Verdict(coin, false),
        ],
      ];

  /// How many things have to be told apart.
  int get verdicts => knownLight ? coins : coins * 2;

  /// The fewest weighings that could possibly settle it, from counting alone.
  ///
  /// A weighing has three answers, so k of them tell at most 3^k things apart,
  /// and no smaller number of weighings can work whatever anybody does. It is
  /// a floor rather than an answer: on four coins it says two and the answer
  /// is three.
  int get countingSays {
    var weighings = 0;
    var tells = 1;
    while (tells < verdicts) {
      tells *= 3;
      weighings++;
    }
    return weighings;
  }
}

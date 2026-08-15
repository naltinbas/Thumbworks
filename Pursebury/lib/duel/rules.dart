/// An exact fraction: numerator over denominator, in lowest terms, the
/// denominator positive. Everything the game says of a duel is one of
/// these; nothing is a double until the bar is drawn.
class Frac implements Comparable<Frac> {
  factory Frac(BigInt n, BigInt d) {
    if (d.isNegative) {
      n = -n;
      d = -d;
    }
    final g = n.gcd(d);
    return Frac._(g == BigInt.zero ? n : n ~/ g, g == BigInt.zero ? d : d ~/ g);
  }

  factory Frac.of(int n, [int d = 1]) => Frac(BigInt.from(n), BigInt.from(d));

  const Frac._(this.n, this.d);

  final BigInt n, d;

  static final zero = Frac.of(0), one = Frac.of(1);

  Frac operator +(Frac o) => Frac(n * o.d + o.n * d, d * o.d);
  Frac operator -(Frac o) => Frac(n * o.d - o.n * d, d * o.d);
  Frac operator *(Frac o) => Frac(n * o.n, d * o.d);
  Frac operator /(Frac o) => Frac(n * o.d, d * o.n);

  Frac pow(int k) {
    var out = one;
    for (var i = 0; i < k; i++) {
      out = out * this;
    }
    return out;
  }

  bool get isWhole => d == BigInt.one;

  double get toDouble => n.toDouble() / d.toDouble();

  @override
  int compareTo(Frac o) => (n * o.d).compareTo(o.n * d);

  @override
  bool operator ==(Object other) => other is Frac && other.n == n && other.d == d;

  @override
  int get hashCode => Object.hash(n, d);

  @override
  String toString() => isWhole ? '$n' : '$n/$d';
}

/// The arithmetic of the duel: Ash with a purse of so many coins, Birch
/// with another, a coin tossed for one coin a time until a purse is
/// empty. Ash's chance of taking the whole pot, and how many tosses the
/// duel lasts on average, each come two ways: the formula, and the
/// chain of purses solved as a system of equations, both in exact
/// fractions.
class Rules {
  /// The purses run from one to this.
  static const most = 6;

  /// The coins: Ash's chance of winning a toss, against him, fair, or
  /// for him.
  static final coins = [Frac.of(1, 3), Frac.of(1, 2), Frac.of(2, 3)];
  static const coinNames = ['against Ash', 'fair', 'for Ash'];

  /// How many settings the dials have between them: purses by purses by
  /// coins.
  static const settings = most * most * 3;

  /// Ash's chance of the pot by the formula: his share of the pot with a
  /// fair coin, and otherwise (1 - r^a) / (1 - r^(a+b)) with r the odds
  /// against him on a toss, q over p.
  static Frac chanceByFormula(int ash, int birch, int coin) {
    final p = coins[coin], q = Frac.one - p;
    if (p == q) return Frac.of(ash, ash + birch);
    final r = q / p;
    return (Frac.one - r.pow(ash)) / (Frac.one - r.pow(ash + birch));
  }

  /// The tosses the duel lasts on average, by the formula: the purses
  /// multiplied with a fair coin, and otherwise a/(q-p) - (a+b)/(q-p)
  /// times Ash's chance.
  static Frac lastsByFormula(int ash, int birch, int coin) {
    final p = coins[coin], q = Frac.one - p;
    if (p == q) return Frac.of(ash * birch);
    final gap = q - p;
    return Frac.of(ash) / gap - Frac.of(ash + birch) / gap * chanceByFormula(ash, birch, coin);
  }

  /// The chain solved: purse by purse Ash's chance from i coins is p times
  /// his chance from i+1 plus q times his chance from i-1, nothing from
  /// nought and everything from the whole pot; the equations eliminated
  /// exactly. With [tosses] the same system counts a toss a step instead
  /// and gives how long the duel lasts.
  static Frac chainSolved(int ash, int birch, int coin, {bool tosses = false}) => solveChain(ash + birch, coins[coin], tosses: tosses)[ash];

  /// The whole chain: value at each purse from 0 to [pot].
  static List<Frac> solveChain(int pot, Frac p, {bool tosses = false}) {
    final q = Frac.one - p;
    final n = pot - 1;
    // Rows for purses 1..pot-1: -q x[i-1] + x[i] - p x[i+1] = rhs.
    final a = List.generate(n, (_) => List.filled(n + 1, Frac.zero));
    for (var i = 0; i < n; i++) {
      a[i][i] = Frac.one;
      if (i > 0) a[i][i - 1] = Frac.zero - q;
      if (i < n - 1) a[i][i + 1] = Frac.zero - p;
      a[i][n] = tosses ? Frac.one : (i == n - 1 ? p : Frac.zero);
    }
    // Gaussian elimination, exact.
    for (var col = 0; col < n; col++) {
      var pivot = col;
      while (a[pivot][col] == Frac.zero) {
        pivot++;
      }
      final row = a[pivot];
      a[pivot] = a[col];
      a[col] = row;
      for (var r = 0; r < n; r++) {
        if (r == col || a[r][col] == Frac.zero) continue;
        final f = a[r][col] / a[col][col];
        for (var c = col; c <= n; c++) {
          a[r][c] = a[r][c] - f * a[col][c];
        }
      }
    }
    final x = [for (var i = 0; i < n; i++) a[i][n] / a[i][i]];
    return [Frac.zero, ...x, tosses ? Frac.zero : Frac.one];
  }

  /// Sweeps every setting: how many meet [ask], how many there are, and
  /// the first that meets it, Ash's purse climbing slowest.
  static (int, int, (int, int, int)?) sweep(bool Function(int ash, int birch, int coin) ask) {
    var met = 0, all = 0;
    (int, int, int)? first;
    for (var ash = 1; ash <= most; ash++) {
      for (var birch = 1; birch <= most; birch++) {
        for (var coin = 0; coin < coins.length; coin++) {
          all++;
          if (ask(ash, birch, coin)) {
            met++;
            first ??= (ash, birch, coin);
          }
        }
      }
    }
    return (met, all, first);
  }

  /// A chance, told: 'one time in four', 'two times in three', 'even'.
  static String chanceTold(Frac c) {
    if (c == Frac.of(1, 2)) return 'one time in two';
    if (c.isWhole) return c == Frac.one ? 'every time' : 'never';
    return '${count(c.n.toInt())} time${c.n == BigInt.one ? '' : 's'} in ${count(c.d.toInt())}';
  }

  static const _words = [
    'no', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
    'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen', 'seventeen',
    'eighteen', 'nineteen', 'twenty',
  ];

  static String count(int n) => n >= 0 && n < _words.length ? _words[n] : '$n';
}

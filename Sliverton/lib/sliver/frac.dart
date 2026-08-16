/// An exact fraction: numerator over denominator, in lowest terms, the
/// denominator positive. Every crossing the game states is one of
/// these; nothing is a double until the field is drawn.
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

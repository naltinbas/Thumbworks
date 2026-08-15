/// A fraction kept whole: numerator over denominator, always in
/// lowest terms, so the sums of cuts are exact.
class Fraction implements Comparable<Fraction> {
  factory Fraction(int num, int den) {
    if (den == 0) throw ArgumentError('over nought');
    if (den < 0) {
      num = -num;
      den = -den;
    }
    final g = _gcd(num.abs(), den);
    return Fraction._(num ~/ g, den ~/ g);
  }

  const Fraction._(this.num, this.den);

  final int num;
  final int den;

  static const zero = Fraction._(0, 1);
  static const one = Fraction._(1, 1);

  static Fraction unit(int den) => Fraction(1, den);

  static int _gcd(int a, int b) => b == 0 ? (a == 0 ? 1 : a) : _gcd(b, a % b);

  Fraction operator +(Fraction other) =>
      Fraction(num * other.den + other.num * den, den * other.den);

  Fraction operator -(Fraction other) =>
      Fraction(num * other.den - other.num * den, den * other.den);

  bool get isUnit => num == 1;

  bool get isZero => num == 0;

  @override
  int compareTo(Fraction other) => (num * other.den).compareTo(other.num * den);

  bool operator <(Fraction other) => compareTo(other) < 0;
  bool operator >(Fraction other) => compareTo(other) > 0;
  bool operator <=(Fraction other) => compareTo(other) <= 0;

  @override
  bool operator ==(Object other) =>
      other is Fraction && other.num == num && other.den == den;

  @override
  int get hashCode => Object.hash(num, den);

  @override
  String toString() => den == 1 ? '$num' : '$num/$den';
}

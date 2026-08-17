import 'frac.dart';

/// A number of the form a plus b times the root of three, with a and b
/// exact fractions. The corners of a hayrick land on numbers like
/// these and nowhere else, since raising an even triangle on a side
/// turns it by sixty degrees, and the sine of sixty is half the root
/// of three.
///
/// Two of them are equal when both halves match, which is a fact about
/// the root of three being irrational: if a plus b roots equalled c
/// plus d roots with b and d different, the root of three would be a
/// fraction.
class Root3 {
  Root3(this.a, this.b);

  /// A number with no root in it.
  Root3.flat(this.a) : b = Frac.zero;

  /// A whole number.
  Root3.of(int a) : a = Frac.of(a), b = Frac.zero;

  /// The whole part and the part carrying the root.
  final Frac a, b;

  static final zero = Root3(Frac.zero, Frac.zero);
  static final one = Root3(Frac.one, Frac.zero);

  /// Half the root of three, which is the height of an even triangle
  /// on a side of one.
  static final halfRoot = Root3(Frac.zero, Frac.of(1, 2));

  Root3 operator +(Root3 o) => Root3(a + o.a, b + o.b);
  Root3 operator -(Root3 o) => Root3(a - o.a, b - o.b);

  /// Multiplying keeps the shape, since the root of three squared is
  /// three.
  Root3 operator *(Root3 o) =>
      Root3(a * o.a + Frac.of(3) * b * o.b, a * o.b + b * o.a);

  Root3 over(int k) => Root3(a / Frac.of(k), b / Frac.of(k));

  bool get isZero => a == Frac.zero && b == Frac.zero;

  /// Only for drawing. Nothing the game decides is settled this way.
  double get toDouble => a.toDouble + b.toDouble * 1.7320508075688772;

  @override
  bool operator ==(Object other) =>
      other is Root3 && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(a, b);

  /// Told over a common bottom, which is how the board writes it.
  @override
  String toString() {
    if (b == Frac.zero) return '$a';
    final bottom = a.d == b.d ? a.d : a.d * b.d;
    final top = a.n * (bottom ~/ a.d);
    final root = b.n * (bottom ~/ b.d);
    final many = root.abs();
    final rootPart =
        many == BigInt.one ? 'the root of three' : '$many roots of three';
    final String head;
    if (top == BigInt.zero) {
      head = root < BigInt.zero ? 'less $rootPart' : rootPart;
    } else {
      head = root < BigInt.zero
          ? '$top less $rootPart'
          : '$top and $rootPart';
    }
    return bottom == BigInt.one ? head : '($head) over $bottom';
  }
}

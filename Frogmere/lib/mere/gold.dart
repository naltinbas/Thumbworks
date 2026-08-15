/// Numbers of the form a + b times the golden ratio, kept exact:
/// with phi squared equal to phi plus one, sums and products of
/// them stay in the same shape, so the pond's reckoning can be
/// added up with no rounding anywhere.
class Gold {
  const Gold(this.a, this.b);

  final int a;
  final int b;

  static const zero = Gold(0, 0);
  static const one = Gold(1, 0);
  static const phi = Gold(0, 1);

  /// One over phi, which is phi less one.
  static const overPhi = Gold(-1, 1);

  Gold operator +(Gold other) => Gold(a + other.a, b + other.b);
  Gold operator -(Gold other) => Gold(a - other.a, b - other.b);

  Gold operator *(Gold other) => Gold(
        a * other.a + b * other.b,
        a * other.b + b * other.a + b * other.b,
      );

  Gold times(int n) => Gold(a * n, b * n);

  /// phi to the power minus [k].
  static Gold phiToMinus(int k) {
    var out = one;
    for (var i = 0; i < k; i++) {
      out = out * overPhi;
    }
    return out;
  }

  /// The number as a double, for the screen.
  double get toDouble => a + b * 1.618033988749895;

  @override
  bool operator ==(Object other) =>
      other is Gold && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(a, b);

  @override
  String toString() => b == 0
      ? '$a'
      : a == 0
          ? '${b}phi'
          : '$a ${b < 0 ? '-' : '+'} ${b.abs()}phi';
}

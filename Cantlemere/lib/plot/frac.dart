/// An exact fraction, used only while the field works out where its own
/// cells lie. Nothing on screen is ever a fraction.
class Frac implements Comparable<Frac> {
  factory Frac(int top, int bottom) {
    if (bottom == 0) throw ArgumentError('a fraction over nothing');
    var t = top, b = bottom;
    if (b < 0) {
      t = -t;
      b = -b;
    }
    final g = _gcd(t.abs(), b);
    return Frac._(g == 0 ? 0 : t ~/ g, g == 0 ? 1 : b ~/ g);
  }

  const Frac._(this.top, this.bottom);

  factory Frac.of(int whole) => Frac._(whole, 1);

  static const zero = Frac._(0, 1);
  static const one = Frac._(1, 1);

  final int top, bottom;

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = a % b;
      a = b;
      b = t;
    }
    return a;
  }

  Frac operator +(Frac o) => Frac(top * o.bottom + o.top * bottom, bottom * o.bottom);
  Frac operator -(Frac o) => Frac(top * o.bottom - o.top * bottom, bottom * o.bottom);
  Frac operator *(Frac o) => Frac(top * o.top, bottom * o.bottom);
  Frac operator /(Frac o) => Frac(top * o.bottom, bottom * o.top);

  /// Which side of nothing this sits on: -1, 0 or 1.
  int get sign => top == 0 ? 0 : (top > 0 ? 1 : -1);

  @override
  int compareTo(Frac o) => (top * o.bottom).compareTo(o.top * bottom);

  bool operator <(Frac o) => compareTo(o) < 0;
  bool operator <=(Frac o) => compareTo(o) <= 0;

  @override
  bool operator ==(Object other) =>
      other is Frac && other.top == top && other.bottom == bottom;

  @override
  int get hashCode => Object.hash(top, bottom);

  @override
  String toString() => bottom == 1 ? '$top' : '$top/$bottom';
}

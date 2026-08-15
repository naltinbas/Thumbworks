// Exact geometry for the pieces: fractions over whole numbers, so that
// a sliver of one square is one square and not nearly one, and convex
// polygons cut against each other for the areas they share.

int _gcd(int a, int b) {
  a = a.abs();
  b = b.abs();
  while (b != 0) {
    final t = a % b;
    a = b;
    b = t;
  }
  return a;
}

/// A fraction, kept in lowest terms with the denominator positive.
class Q {
  factory Q(int n, [int d = 1]) {
    if (d == 0) throw ArgumentError('a fraction over nought');
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final g = _gcd(n, d);
    return Q._(g == 0 ? n : n ~/ g, g == 0 ? d : d ~/ g);
  }

  const Q._(this.n, this.d);

  final int n;
  final int d;

  static const zero = Q._(0, 1);
  static const one = Q._(1, 1);

  Q operator +(Q o) => Q(n * o.d + o.n * d, d * o.d);
  Q operator -(Q o) => Q(n * o.d - o.n * d, d * o.d);
  Q operator *(Q o) => Q(n * o.n, d * o.d);
  Q operator /(Q o) => Q(n * o.d, d * o.n);
  Q operator -() => Q._(-n, d);

  int get sign => n.sign;
  bool get isWhole => d == 1;

  bool operator <(Q o) => n * o.d < o.n * d;
  bool operator <=(Q o) => n * o.d <= o.n * d;
  bool operator >(Q o) => n * o.d > o.n * d;
  bool operator >=(Q o) => n * o.d >= o.n * d;

  @override
  bool operator ==(Object other) => other is Q && other.n == n && other.d == d;

  @override
  int get hashCode => Object.hash(n, d);

  double get asDouble => n / d;

  /// The fraction said: '1', '2/5', '1 3/8'.
  @override
  String toString() {
    if (d == 1) return '$n';
    final whole = n ~/ d, rest = n.abs() % d;
    if (whole == 0) return '$n/$d';
    return '$whole $rest/$d';
  }
}

/// A point with fraction coordinates.
typedef Pt = (Q, Q);

/// A point at whole coordinates.
Pt pt(int x, int y) => (Q(x), Q(y));

/// Twice the signed area of a polygon by the shoelace, positive when the
/// corners run counterclockwise.
Q area2(List<Pt> poly) {
  var s = Q.zero;
  for (var i = 0; i < poly.length; i++) {
    final (x1, y1) = poly[i];
    final (x2, y2) = poly[(i + 1) % poly.length];
    s = s + (x1 * y2 - x2 * y1);
  }
  return s;
}

/// The part of the convex polygon [subject] inside the convex
/// counterclockwise polygon [window], corner by corner (Sutherland and
/// Hodgman): the subject is cut against each edge of the window in turn.
List<Pt> clip(List<Pt> subject, List<Pt> window) {
  var out = List<Pt>.of(subject);
  for (var i = 0; i < window.length && out.isNotEmpty; i++) {
    final a = window[i], b = window[(i + 1) % window.length];
    Q side(Pt p) => (b.$1 - a.$1) * (p.$2 - a.$2) - (b.$2 - a.$2) * (p.$1 - a.$1);
    final input = out;
    out = <Pt>[];
    for (var j = 0; j < input.length; j++) {
      final cur = input[j], prev = input[(j + input.length - 1) % input.length];
      final curIn = side(cur).sign >= 0, prevIn = side(prev).sign >= 0;
      if (curIn) {
        if (!prevIn) out.add(_meet(prev, cur, a, b));
        out.add(cur);
      } else if (prevIn) {
        out.add(_meet(prev, cur, a, b));
      }
    }
  }
  return out;
}

/// Where the segment [p] to [q] meets the line through [a] and [b].
Pt _meet(Pt p, Pt q, Pt a, Pt b) {
  final (x1, y1) = p;
  final (x2, y2) = q;
  final (x3, y3) = a;
  final (x4, y4) = b;
  final den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
  final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den;
  return (x1 + t * (x2 - x1), y1 + t * (y2 - y1));
}

/// The polygon two convex polygons share, empty when they share no area.
List<Pt> shared(List<Pt> a, List<Pt> b) {
  final c = clip(a, b);
  if (c.length < 3 || area2(c).sign == 0) return const [];
  return c;
}

/// Twice the area two convex polygons share.
Q shared2(List<Pt> a, List<Pt> b) {
  final c = shared(a, b);
  return c.isEmpty ? Q.zero : area2(c);
}

/// Whether [p] lies in the convex counterclockwise polygon [poly], its
/// edge counted in.
bool encloses(List<Pt> poly, Pt p) {
  for (var i = 0; i < poly.length; i++) {
    final a = poly[i], b = poly[(i + 1) % poly.length];
    final side = (b.$1 - a.$1) * (p.$2 - a.$2) - (b.$2 - a.$2) * (p.$1 - a.$1);
    if (side.sign < 0) return false;
  }
  return true;
}

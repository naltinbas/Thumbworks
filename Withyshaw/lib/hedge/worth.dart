/// A worth: a whole number of halves of halves, kept exact.
///
/// Every stalk's worth is a number like three, or a half, or one and
/// three quarters, negative when the hedger's. Numerator over a power of
/// two, always eased.
class Worth {
  const Worth._(this.top, this.bottom);

  factory Worth(int top, int bottom) {
    assert(bottom > 0 && (bottom & (bottom - 1)) == 0);
    while (top % 2 == 0 && bottom > 1) {
      top ~/= 2;
      bottom ~/= 2;
    }
    return Worth._(top, bottom);
  }

  static const nought = Worth._(0, 1);

  /// Numerator, signed; denominator, a power of two.
  final int top;
  final int bottom;

  Worth operator +(Worth other) {
    final wide = bottom > other.bottom ? bottom : other.bottom;
    return Worth(
      top * (wide ~/ bottom) + other.top * (wide ~/ other.bottom),
      wide,
    );
  }

  bool get isPositive => top > 0;
  bool get isNought => top == 0;

  /// Said as a mercer would: 'one and three quarters', more or less.
  String get said {
    if (bottom == 1) return '$top';
    final whole = top ~/ bottom;
    final part = (top - whole * bottom).abs();
    final sign = top < 0 && whole == 0 ? '-' : '';
    final fraction = '$sign$part/$bottom';
    return whole == 0 ? fraction : '$whole $part/$bottom';
  }

  @override
  bool operator ==(Object other) =>
      other is Worth && other.top == top && other.bottom == bottom;

  @override
  int get hashCode => top * 31 + bottom;

  @override
  String toString() => '$top/$bottom';
}
